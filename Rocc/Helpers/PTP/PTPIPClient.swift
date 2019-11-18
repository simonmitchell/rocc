//
//  PTPIPClient.swift
//  CCKit
//
//  Created by Simon Mitchell on 29/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

typealias CommandRequestPacketResponse = (_ packet: CommandResponsePacket) -> Void

/// A client for transferring images using the PTP IP protocol
final class PTPIPClient: NSObject {
    
    //MARK: - Initialisation -
    
    internal let ptpClientLog = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "PTPIPClient")
    
    var eventReadStream: InputStream?
    
    var eventWriteStream: OutputStream?
    
    let controlReadStream: InputStream
    
    let controlWriteStream: OutputStream
    
    var guid: String
    
    var byteBuffer: ByteBuffer = ByteBuffer()
    
    var openStreams: [Stream] = []
    
    let host: String
    
    let port: Int
    
    private var currentTransactionId: DWord = 0
        
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
    
    func getNextTransactionId() -> DWord {
        
        defer {
            if currentTransactionId == DWord.max {
                currentTransactionId = 0
            } else {
                currentTransactionId += 1
            }
        }
        
        if currentTransactionId == 0 {
            return 0
        }
        
        return currentTransactionId + 1
    }
    
    var onEvent: ((_ event: EventPacket) -> Void)?
    
    //MARK: - Connection -
    
    var connectCallback: ((_ error: Error?) -> Void)?
    
    func connect(callback: @escaping (_ error: Error?) -> Void) {
        
        commandRequestCallbacks = [:]
        dataContainers = [:]
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
    
    //MARK: - Sending Packets -
    
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
    
    /// Sends a packet to the event loop of the PTP IP connection
    /// - Parameter packet: The packet to send
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
    
    /// Sends a packet to the control loop of the PTP IP connection
    /// - Parameter packet: The packet to send
    func sendControlPacket(_ packet: Packetable) {
        
        guard controlWriteStream.hasSpaceAvailable else {
            pendingControlPackets.append(packet)
            return
        }
        controlWriteStream.write(packet)
    }
    
    //MARK: Command Requests
    
    private var commandRequestCallbacks: [DWord : (callback: CommandRequestPacketResponse, callForAnyResponse: Bool)] = [:]
        
    /// Sends a command request packet to the control loop of the PTP IP connection with optional callback
    /// - Important: If you are making a call that you do not expect to receive a CommandResponse in response to
    /// then `callback` may never be called.
    ///
    /// - Parameter packet: The packet to send
    /// - Parameter callback: An optional callback which will be called with the received CommandResponse packet
    /// - Parameter callCallbackForAnyResponse: Whether the callback should be called for any response received regardless of whether it contains a transaction ID or what it's transaction ID is. This fixes issues with the OpenSession command response Sony sends which doesn't contain a transaction ID.
    func sendCommandRequestPacket(_ packet: CommandRequestPacket, callback: CommandRequestPacketResponse?, callCallbackForAnyResponse: Bool = false) {
        if let _callback = callback {
            commandRequestCallbacks[packet.transactionId] = (_callback, callCallbackForAnyResponse)
        }
        sendControlPacket(packet)
    }
    
    func sendSetControlDeviceAValue(_ value: PTP.DeviceProperty.Value) {
        
        let opRequestPacket = Packet.commandRequestPacket(code: .setControlDeviceA, arguments: [UInt32(value.code.rawValue)], transactionId: getNextTransactionId())
        var data = ByteBuffer()
        data.appendValue(value.value, ofType: value.type)
        let dataPackets = Packet.dataSendPackets(data: data, transactionId: getNextTransactionId())
        
        //TODO: Do we have to wait for callback?
        sendCommandRequestPacket(opRequestPacket, callback: nil)
        dataPackets.forEach { (dataPacket) in
            sendControlPacket(dataPacket)
        }
    }
    
    func sendSetControlDeviceBValue(_ value: PTP.DeviceProperty.Value) {
        
        let opRequestPacket = Packet.commandRequestPacket(code: .setControlDeviceB, arguments: [UInt32(value.code.rawValue)], transactionId: getNextTransactionId())
        var data = ByteBuffer()
        data.appendValue(value.value, ofType: value.type)
        let dataPackets = Packet.dataSendPackets(data: data, transactionId: getNextTransactionId())
        
        //TODO: Do we have to wait for callback?
        sendCommandRequestPacket(opRequestPacket, callback: nil)
        dataPackets.forEach { (dataPacket) in
            sendControlPacket(dataPacket)
        }
    }
    
    //MARK: - Handling Responses -
    
    fileprivate func handle(packet: Packetable) {
        
        switch packet {
        case let initCommandAckPacket as InitCommandAckPacket:
            
            onEventStreamsOpened = { [weak self] in
                let initEventPacket = Packet.initEventPacket(sessionId: initCommandAckPacket.sessionId)
                self?.sendEventPacket(initEventPacket)
            }
            
            setupEventStreams()
        case let commandResponsePacket as CommandResponsePacket:
            handleCommandResponsePacket(commandResponsePacket)
        case let dataStartPacket as StartDataPacket:
            handleStartDataPacket(dataStartPacket)
        case let dataPacket as DataPacket:
            handleDataPacket(dataPacket)
        case let endDataPacket as EndDataPacket:
            handleEndDataPacket(endDataPacket)
        case let eventPacket as EventPacket:
            onEvent?(eventPacket)
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
    
    //MARK: Commands
    
    fileprivate func handleCommandResponsePacket(_ packet: CommandResponsePacket) {
        
        guard let transactionId = packet.transactionId else {
            commandRequestCallbacks = commandRequestCallbacks.filter { (_, value) -> Bool in
                // If not called for any response, then leave it in the callbacks dictionary
                guard value.callForAnyResponse else { return true }
                value.callback(packet)
                return false
            }
            return
        }
        commandRequestCallbacks[transactionId]?.callback(packet)
        commandRequestCallbacks[transactionId] = nil
        
        guard let code = packet.code, code.isError else { return }
        
        dataCallbacks[transactionId]?(Result.failure(code))
        dataCallbacks[transactionId] = nil
    }
    
    //MARK: Data
    
    internal var dataCallbacks: [DWord : DataResponse] = [:]
    
    internal var dataContainers: [DWord : DataContainer] = [:]
    
    //MARK: - Reading Bytes -
    
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

//MARK: - StreamDelegate implementation

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

enum PTPIPClientError: Error {
    case invalidResponse
}
