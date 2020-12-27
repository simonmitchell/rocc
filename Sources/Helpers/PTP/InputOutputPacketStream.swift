//
//  InputOutputPacketStream.swift
//  Rocc
//
//  Created by Simon Mitchell on 25/09/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

final class InputOutputPacketStream: NSObject, PTPPacketStream {
    
    internal let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "InputOutputPacketStream")
    
    var delegate: PTPPacketStreamDelegate?
    
    private let host: String
    
    private let port: Int
        
    private var eventReadStream: InputStream?
    
    private var eventWriteStream: OutputStream?
    
    private var controlReadStream: InputStream?
    
    private var controlWriteStream: OutputStream?
    
    private var openStreams: [Stream] = []
    
    internal var awaitingFurtherDataControlPacket: Packetable?

    init?(camera: Camera, port: Int = 15740) {
        
        guard let host = camera.baseURL?.host else { return nil }
        
        self.port = port
        self.host = host
    }
    
    //MARK: - Connection -
        
    var connectCallback: ((_ error: Error?) -> Void)?
    
    func connect(callback: @escaping (Error?) -> Void) {
        
        // First clear out any old streams, otherwise we get crashes if we connect twice and then
        // server closes one of the previous sockets!
        
        disconnect()
        
        awaitingFurtherDataControlPacket = nil
        
        Logger.log(message: "Creating streams to host \(host):\(port)", category: "PTPIPClient", level: .debug)
        os_log("Creating streams to host %@", log: log, type: .debug, "\(host):\(port)")
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &controlReadStream, outputStream: &controlWriteStream)
        
        guard let controlReadStream = controlReadStream, let controlWriteStream = controlWriteStream else {
            callback(PTPIPClientError.failedToCreateStreamsToHost)
            Logger.log(message: "Failed to get streams to host", category: "PTPIPClient", level: .error)
            os_log("Failed to get streams to host", log: log, type: .error)
            return
        }
        
        controlReadStream.delegate = self
        controlWriteStream.delegate = self
        
        controlReadStream.schedule(in: RunLoop.current, forMode: .default)
        controlWriteStream.schedule(in: RunLoop.current, forMode: .default)
        
        controlReadStream.open()
        controlWriteStream.open()
        
        // We don't do anything else... we need to call `sendInitCommandAck` but we need the stream delegate
        // to tell us that the control write stream was opened!
    }
    
    func setupEventLoop() {
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &eventReadStream, outputStream: &eventWriteStream)
        
        guard let eventReadStream = eventReadStream, let eventWriteStream = eventWriteStream else {
            connectCallback?(PTPIPClientError.failedToCreateStreamsToHost)
            return
        }
        
        eventReadStream.delegate = self
        eventWriteStream.delegate = self
        
        eventReadStream.schedule(in: RunLoop.current, forMode: .default)
        eventWriteStream.schedule(in: RunLoop.current, forMode: .default)
        
        eventReadStream.open()
        eventWriteStream.open()
    }
    
    func disconnect() {
        
        [controlWriteStream, controlReadStream, eventWriteStream, eventReadStream].compactMap({ $0 }).forEach { (stream) in
            stream.close()
        }
        
        controlWriteStream = nil
        controlReadStream = nil
        eventWriteStream = nil
        eventReadStream = nil

        pendingControlPackets = []
        pendingEventPackets = []
        openStreams = []
        mainLoopByteBuffer.clear()
        eventLoopByteBuffer.clear()
        
        connectCallback = nil
    }
    
    //MARK: - Reading Bytes -
    
    var mainLoopByteBuffer: ByteBuffer = ByteBuffer()
    
    var eventLoopByteBuffer: ByteBuffer = ByteBuffer()
    
    fileprivate func readAvailableBytes(stream: InputStream) {
        
        var bytes: [Byte] = Array<Byte>.init(repeating: .zero, count: 1024)
        
        Logger.log(message: "Start reading available bytes", category: "PTPIPClient", level: .debug)
        os_log("Start reading available bytes", log: log, type: .debug)
        
        while stream.hasBytesAvailable {
            
            let numberOfBytesRead = stream.read(&bytes, maxLength: 1024)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
            let nBytes = min(numberOfBytesRead, bytes.count)
            let actualBytes = bytes[0..<nBytes]
            
            switch stream {
            case eventReadStream:
                eventLoopByteBuffer.append(bytes: Array(actualBytes))
            case controlReadStream:
                mainLoopByteBuffer.append(bytes: Array(actualBytes))
            default:
                break
            }
        }
        
        var packets: [Packetable]?
        
        switch stream {
        case eventReadStream:
            Logger.log(message: "Read event available bytes (\(eventLoopByteBuffer.length))", category: "PTPIPClient", level: .debug)
            os_log("Read event available bytes (%i)", log: log, type: .debug, eventLoopByteBuffer.length)
            packets = eventLoopByteBuffer.parsePackets()
        case controlReadStream:
            
            Logger.log(message: "Read control available bytes (\(mainLoopByteBuffer.length))", category: "PTPIPClient", level: .debug)
            os_log("Read control available bytes (%i)", log: log, type: .debug, mainLoopByteBuffer.length)
            
            // If we have a command response packet awaiting further data
            if var awaitingCommandResponsePacket = awaitingFurtherDataControlPacket {
                // Create a new packet by appending new data
                if let fullPacket = awaitingCommandResponsePacket.addingAwaitedData(mainLoopByteBuffer) {
                    
                    awaitingFurtherDataControlPacket = nil
                    // Make sure set to false, otherwise we end up in an infinite loop
                    var packet = fullPacket.packet
                    packet.awaitingFurtherData = false
                    delegate?.packetStream(self, didReceive: [packet])
                    // Remove the continued data
                    let lengthToRemove = packet.length - awaitingCommandResponsePacket.length
                    mainLoopByteBuffer.slice(Int(lengthToRemove))
                    
                } else {
                    
                    // If we don't get a new packet, just mark the current one as not awaiting data, and send it!
                    awaitingCommandResponsePacket.awaitingFurtherData = false
                    delegate?.packetStream(self, didReceive: [awaitingCommandResponsePacket])
                }
                
                awaitingFurtherDataControlPacket = nil
            }
            
            packets = mainLoopByteBuffer.parsePackets()
            
        default:
            break
        }
        
        
        guard let _packets = packets, !_packets.isEmpty else { return }

        // Only keep track of awaitingFurtherDataPacket for control stream, as this is only
        // to keep track of cmd response packets sent like so: "0e 00 00 00 07 00 00 00 | 01 20 c6 03 00 00"
        if stream == controlReadStream {
            awaitingFurtherDataControlPacket = _packets.first(where: { $0.awaitingFurtherData })
        }
        
        delegate?.packetStream(self, didReceive: _packets)
    }
    
    //MARK: - Sending Packets -
    
    func sendControlPacket(_ packet: Packetable) {
        
        guard let controlWriteStream = controlWriteStream else {
            pendingControlPackets.append(packet)
            return
        }
        guard controlWriteStream.hasSpaceAvailable else {
            pendingControlPackets.append(packet)
            return
        }
        Logger.log(message: "Sending control packet to device: \(packet.debugDescription)", category: "PTPIPClient", level: .debug)
        os_log("Sending control packet to device: %@", log: log, type: .debug, "\(packet.debugDescription)")
        controlWriteStream.write(packet)
    }
    
    func sendEventPacket(_ packet: Packetable) {
        
        guard let eventWriteStream = eventWriteStream else {
            return
        }
        
        guard eventWriteStream.hasSpaceAvailable else {
            pendingEventPackets.append(packet)
            return
        }
        Logger.log(message: "Sending event packet to device: \(packet.debugDescription)", category: "PTPIPClient", level: .debug)
        os_log("Sending event packet to device: %@", log: log, type: .debug, "\(packet.debugDescription)")
        eventWriteStream.write(packet)
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
            Logger.log(message: "Sending event packet to device: \(packet.debugDescription)", category: "PTPIPClient", level: .debug)
            os_log("Sending event packet to device: %@", log: log, type: .debug, "\(packet.debugDescription)")
            pendingEventPackets.remove(at: index)
        }
    }
    
    fileprivate func sendQueuedControlPackets() {
        guard let controlWriteStream = controlWriteStream else { return }
        for (index, packet) in pendingControlPackets.enumerated() {
            let response = controlWriteStream.write(packet)
            guard response == packet.length else {
                break
            }
            Logger.log(message: "Sending control packet to device: \(packet.debugDescription)", category: "PTPIPClient", level: .debug)
            os_log("Sending control packet to device: %@", log: log, type: .debug, "\(packet.debugDescription)")
            pendingControlPackets.remove(at: index)
        }
    }
}

//MARK: - StreamDelegate implementation

extension InputOutputPacketStream: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case Stream.Event.errorOccurred:
            guard let error = aStream.streamError else { return }
            Logger.log(message: "Stream error: \(error.localizedDescription)", category: "PTPIPClient", level: .error)
            os_log("Stream error: %@", log: log, type: .error, error.localizedDescription)
            disconnect()
            delegate?.packetStreamDidDisconnect(self)
            break
        case Stream.Event.hasSpaceAvailable:
            Logger.log(message: "Stream has space available", category: "PTPIPClient", level: .debug)
            os_log("Stream has space available", log: log, type: .debug)
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
            Logger.log(message: "Stream has bytes available", category: "PTPIPClient", level: .debug)
            os_log("Stream has bytes available", log: log, type: .debug)
            readAvailableBytes(stream: aStream as! InputStream)
            break
        case Stream.Event.openCompleted:
            switch aStream {
            case eventReadStream, eventWriteStream:
                openStreams.append(aStream)
                guard openStreams.count == 2 else { return }
                delegate?.packetStreamDidOpenEventStream(self)
            case controlWriteStream:
                delegate?.packetStreamDidOpenControlStream(self)
            default:
                break
            }
            break
        case Stream.Event.endEncountered:
            Logger.log(message: "Stream end encountered", category: "PTPIPClient", level: .debug)
            os_log("Stream end encountered", log: log, type: .debug)
            aStream.close()
            aStream.remove(from: .current, forMode: .default)
            delegate?.packetStreamDidDisconnect(self)
            connectCallback?(PTPIPClientError.socketClosed)
            connectCallback = nil
            break
        default:
            break
        }
    }
}

extension OutputStream {
    @discardableResult func write(_ packet: Packetable) -> Int {
        var bytes = packet.data.bytes.compactMap({ $0 })
        let response = write(&bytes, maxLength: bytes.count)
        return response
    }
}

