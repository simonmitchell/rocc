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
    
    let eventReadStream: InputStream
    
    let eventWriteStream: OutputStream
    
    let controlReadStream: InputStream
    
    let controlWriteStream: OutputStream
    
    var guid: String
    
    var byteBuffer: ByteBuffer = ByteBuffer()
    
    var openStreams: [Stream] = []
    
    init?(camera: Camera, port: Int = 15740) {
        
        guard let host = camera.baseURL?.host else { return nil }
        
        // Remove any unwanted components from camera's identifier
        guid = camera.identifier.replacingOccurrences(of: "uuid", with: "").components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        // Trim GUID to 16 characters
        guid = String(guid.suffix(16))
        
        var eReadStream: InputStream?
        var eWriteStream: OutputStream?
        var cReadStream: InputStream?
        var cWriteStream: OutputStream?
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &eReadStream, outputStream: &eWriteStream)
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &cReadStream, outputStream: &cWriteStream)
        
        guard let _eReadStream = eReadStream, let _eWriteStream = eWriteStream, let _cReadStream = cReadStream, let _cWriteStream = cWriteStream else {
            return nil
        }
        
        eventReadStream = _eReadStream
        eventWriteStream = _eWriteStream
        controlReadStream = _cReadStream
        controlWriteStream = _cWriteStream
        
        super.init()
        
        eventReadStream.delegate = self
        eventWriteStream.delegate = self
        controlReadStream.delegate = self
        controlWriteStream.delegate = self
        
        eventReadStream.schedule(in: RunLoop.current, forMode: .default)
        eventWriteStream.schedule(in: RunLoop.current, forMode: .default)
        controlReadStream.schedule(in: RunLoop.current, forMode: .default)
        controlWriteStream.schedule(in: RunLoop.current, forMode: .default)
    
        controlReadStream.open()
        controlWriteStream.open()
    }
    
    var connectCallback: ((_ error: Error?) -> Void)?
    
    func connect(callback: @escaping (_ error: Error?) -> Void) {
        
        openStreams = []
        byteBuffer.clear()
        connectCallback = callback
        
        let guidData = guid.data(using: .utf8)
        let connectPacket = Packet.initCommandPacket(guid: guidData?.toBytes ?? [], name: UIDevice.current.name)
        controlWriteStream.write(connectPacket)
        
        Logger.log(message: "Sending InitCommandPacket to PTP IP Device", category: "PTPIPClient")
        os_log("Sending InitCommandPacket to PTP IP Device", log: ptpClientLog, type: .debug)
    }
    
    var onEventStreamsOpened: (() -> Void)?
    
    fileprivate func handle(packet: Packetable) {
        
        switch packet {
        case let initCommandAckPacket as InitCommandAckPacket:
            
            onEventStreamsOpened = { [weak self] in
                let initEventPacket = Packet.initEventPacket(sessionId: initCommandAckPacket.sessionId)
                self?.eventWriteStream.write(initEventPacket)
            }
            
            eventReadStream.open()
            eventWriteStream.open()
            
        default:
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
    @discardableResult func write(_ packet: Packet) -> Int {
        var bytes = packet.data.bytes.compactMap({ $0 })
        let response = write(&bytes, maxLength: bytes.count)
        return response
    }
}

extension PTPIPClient: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case Stream.Event.errorOccurred:
            break
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
        default:
            break
        }
    }
}
