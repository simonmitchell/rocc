//
//  PTPIPClient.swift
//  CCKit
//
//  Created by Simon Mitchell on 29/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

/// A client for transferring images using the PTP IP protocol
final class PTPIPClient: NSObject {
    
    fileprivate let ptpClientLog = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "PTPIPClient")
    
    var eventReadStream: InputStream?
    
    var eventWriteStream: OutputStream?
    
    let controlReadStream: InputStream
    
    let controlWriteStream: OutputStream
    
    var guid: String
    
    var byteBuffer: ByteBuffer = ByteBuffer()
    
    var openStreams: [Stream] = []
    
    let host: String
    
    let port: Int
    
    init?(camera: Camera, port: Int = 15740) {
        
        guard let host = camera.baseURL?.host else { return nil }
        
        self.port = port
        self.host = host
        
        // Remove any unwanted components from camera's identifier
        guid = camera.identifier.replacingOccurrences(of: "uuid", with: "").components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        // Trim GUID to 16 characters
        guid = String(guid.suffix(16))
        
        
        var cReadStream: InputStream?
        var cWriteStream: OutputStream?
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &cReadStream, outputStream: &cWriteStream)
        
        guard let _cReadStream = cReadStream, let _cWriteStream = cWriteStream else {
            return nil
        }

        controlReadStream = _cReadStream
        controlWriteStream = _cWriteStream
        
        super.init()
        
        controlReadStream.delegate = self
        controlWriteStream.delegate = self
        
        controlReadStream.schedule(in: RunLoop.current, forMode: .default)
        controlWriteStream.schedule(in: RunLoop.current, forMode: .default)
    
        controlReadStream.open()
        controlWriteStream.open()
    }
    
    var connectCallback: ((_ error: Error?) -> Void)?
    
    func connect(callback: @escaping (_ error: Error?) -> Void) {
        
        pendingControlPackets = []
        pendingEventPackets = []
        openStreams = []
        byteBuffer.clear()
        connectCallback = callback
        
        let guidData = guid.data(using: .utf8)
        let connectPacket = Packet.initCommandPacket(guid: guidData?.toBytes ?? [], name: UIDevice.current.name)
        sendControlPacket(connectPacket)
        
        Logger.log(message: "Sending InitCommandPacket to PTP IP Device", category: "PTPIPClient")
        os_log("Sending InitCommandPacket to PTP IP Device", log: ptpClientLog, type: .debug)
    }
    
    private func setupEventStreams() {
        
        var eReadStream: InputStream?
        var eWriteStream: OutputStream?
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &eReadStream, outputStream: &eWriteStream)
        
        guard let _eReadStream = eReadStream, let _eWriteStream = eWriteStream else {
            return
        }
        
        eventReadStream = _eReadStream
        eventWriteStream = _eWriteStream
        
        eventReadStream!.delegate = self
        eventWriteStream!.delegate = self
        
        eventReadStream!.schedule(in: RunLoop.current, forMode: .default)
        eventWriteStream!.schedule(in: RunLoop.current, forMode: .default)
        
        eventReadStream!.open()
        eventWriteStream!.open()
    }
    
    fileprivate var pendingEventPackets: [Packetable] = []
    
    fileprivate var pendingControlPackets: [Packetable] = []
    
    fileprivate func sendQueuedEventPackets() {
        guard let eventWriteStream = eventWriteStream else { return }
        for (index, packet) in pendingEventPackets.enumerated() {
            let response = eventWriteStream.write(packet)
            guard response == packet.length else {
                break
            }
            pendingEventPackets.remove(at: index)
        }
    }
    
    fileprivate func sendQueuedControlPackets() {
        for (index, packet) in pendingControlPackets.enumerated() {
            let response = controlWriteStream.write(packet)
            guard response == packet.length else {
                break
            }
            pendingControlPackets.remove(at: index)
        }
    }
    
    var onEventStreamsOpened: (() -> Void)?
    
    fileprivate func sendEventPacket(_ packet: Packetable) {
        
        guard let eventWriteStream = eventWriteStream else {
            return
        }
        
        guard eventWriteStream.hasSpaceAvailable else {
            pendingEventPackets.append(packet)
            return
        }
        eventWriteStream.write(packet)
    }
    
    fileprivate func sendControlPacket(_ packet: Packetable) {
        
        guard controlWriteStream.hasSpaceAvailable else {
            pendingControlPackets.append(packet)
            return
        }
        controlWriteStream.write(packet)
    }
    
    fileprivate func handle(packet: Packetable) {
        
        switch packet {
        case let initCommandAckPacket as InitCommandAckPacket:
            
            onEventStreamsOpened = { [weak self] in
                let initEventPacket = Packet.initEventPacket(sessionId: initCommandAckPacket.sessionId)
                self?.sendEventPacket(initEventPacket)
            }
            
            setupEventStreams()
            
        default:
            switch packet.name {
            case .initEventAck:
                // We're done with setting up sockets here, any further handshake should be done by the caller of `connect`
                connectCallback?(nil)
            default:
                break
            }
            break
        }
    }
    
    fileprivate func handle(packets: [Packetable]) {
        packets.forEach { (packet) in
            handle(packet: packet)
        }
    }
    
    fileprivate func readAvailableBytes(stream: InputStream) {
        
        var bytes: [Byte] = Array<Byte>.init(repeating: .zero, count: 1024)
        
        while stream.hasBytesAvailable {
            
            let numberOfBytesRead = stream.read(&bytes, maxLength: 1024)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
            let nBytes = min(numberOfBytesRead, bytes.count)
            let actualBytes = bytes[0..<nBytes]
            
            byteBuffer.append(bytes: Array(actualBytes))
        }
        
        guard let packets = byteBuffer.parsePackets(), !packets.isEmpty else { return }
        
        handle(packets: packets)
    }
}

extension OutputStream {
    @discardableResult func write(_ packet: Packetable) -> Int {
        var bytes = packet.data.bytes.compactMap({ $0 })
        let response = write(&bytes, maxLength: bytes.count)
        return response
    }
}

extension PTPIPClient: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case Stream.Event.errorOccurred:
            guard let error = aStream.streamError else { return }
            print("Stream error \(error.localizedDescription), \((error as NSError).code)")
            break
        case Stream.Event.hasSpaceAvailable:
            switch aStream {
            case eventWriteStream:
                sendQueuedEventPackets()
                break
            case controlWriteStream:
                sendQueuedControlPackets()
                break
            default:
                break
            }
        case Stream.Event.hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
            break
        case Stream.Event.openCompleted:
            switch aStream {
            case eventReadStream, eventWriteStream:
                openStreams.append(aStream)
                guard openStreams.count == 2 else { return }
                self.onEventStreamsOpened?()
            default:
                break
            }
            break
        case Stream.Event.endEncountered:
            print("End encountered!", aStream)
            break
        default:
            break
        }
    }
}
