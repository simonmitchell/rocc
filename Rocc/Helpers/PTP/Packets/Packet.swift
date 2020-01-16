//
//  Packet.swift
//  CCKit
//
//  Created by Simon Mitchell on 29/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import Network

extension ByteBuffer {
    mutating func set(header type: Packet.Name) {
        self[dWord: 0] = DWord(length)
        self[dWord: 4] = type.rawValue
    }
}

protocol Packetable {
    
    var debugDescription: String { get }
    
    var description: String { get }
        
    var name: Packet.Name { get }
    
    var length: DWord { get }
    
    var data: ByteBuffer { get }
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer)
}
    
struct Packet: Packetable {
    
    enum Name: DWord {
        case unknown
        case initCommandRequest
        case initCommandAck
        case initEventRequest
        case initEventAck
        case initFail
        case cmdRequest
        case cmdResponse
        case event
        case startDataPacket
        case dataPacket
        case cancelTransaction
        case endDataPacket
        case ping
        case pong
        case sonyUnknown1 = 0x0000ffff
    }
    
    static let headerLength: Int = 8
    
    var data = ByteBuffer()
    
    var length: DWord {
        return UInt32(data.length)
    }
        
    let name: Name
    
    let unparsedData: ByteBuffer
    
    private static let nameToType: [Packet.Name : Packetable.Type] = [
        .initCommandAck: InitCommandAckPacket.self,
        .cmdResponse: CommandResponsePacket.self,
        .startDataPacket: StartDataPacket.self,
        .dataPacket: DataPacket.self,
        .endDataPacket: EndDataPacket.self,
        .event: EventPacket.self,
        .sonyUnknown1: PainInTheArsePacket.self
    ]
    
    static func parse(from data: ByteBuffer) -> Packetable? {
        
        guard data.length >= 8 else {
            return nil
        }
       
        guard let length = data[dWord: 0] else {
            return nil
        }
       
        guard let typeInt = data[dWord: 4] else {
            return nil
        }
        guard let type = Name(rawValue: typeInt) else {
            return nil
        }
              
        let unparsedData = data.sliced(Packet.headerLength, Int(length))
        
        guard let packetType = nameToType[type] else {
            // We send full data object through here becaue otherwise has incorrect `length`
            return Packet(length: length, name: type, data: data.sliced(0, Int(length)))
        }
        
        return packetType.init(length: length, name: type, data: unparsedData)
    }
        
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        self.name = name
        self.data = data
        self.unparsedData = data.sliced(Packet.headerLength, nil)
    }
    
    init() {
        name = .unknown
        unparsedData = ByteBuffer()
    }
    
    init(name: Packet.Name) {
        self.name = name
        unparsedData = ByteBuffer()
    }
    
    /// Creates the initial packet to setup the command loop for PTP-IP
    ///
    /// Quote from the "White Paper of CIPA DC-005-2005": "[...] the Initiator
    /// sends the *Init Command Request* PTP-IP packet that contains its identity
    /// (GUID and Friendly Name).
    ///
    /// - Parameters:
    ///   - guid: A 16 byte array of the device's GUID. It is cut off is longer, or zero padded if shorter.
    ///   - name: The friendly name of the connecting device
    ///   - maxNameLength: Optional, the max length of the device name
    static func initCommandPacket(guid: [Byte], name: String, maxNameLength: Int = 80) -> Packet {
        
        var packet = Packet()
        for i in 0..<16 {
            packet.data[UInt(headerLength + i)] = guid[safe: UInt(i)] ?? 0
        }
        
        packet.data.append(wString: String(name.prefix(maxNameLength)))
        //TODO: This should be a version number, in this case hard-coded to 1.0
        packet.data.append(word: 0)
        packet.data.append(word: 1)
        packet.data.set(header: .initCommandRequest)
                        
        return packet
    }
    
    static func initEventPacket(sessionId: DWord) -> Packet {
        
        var packet = Packet()
        packet.data[dWord: UInt(headerLength)] = sessionId
        packet.data.set(header: .initEventRequest)
        return packet
    }
    
    static func pongPacket() -> Packet {
        var packet = Packet()
        packet.data = ByteBuffer(bytes: [nil, nil, nil, nil, nil, nil, nil, nil])
        packet.data.set(header: .pong)
        return packet
    }
    
    static func commandRequestPacket(code commandCode: PTP.CommandCode, arguments: [DWord]?, transactionId: DWord = 0, dataPhaseInfo: DWord = 1) -> CommandRequestPacket {
        
        var packet = CommandRequestPacket(transactionId: transactionId)
        packet.name = .cmdRequest
        packet.data[dWord: UInt(Packet.headerLength)] = dataPhaseInfo
        packet.data.append(word: commandCode.rawValue)
        packet.data.append(dWord: transactionId)
        
        arguments?.forEach({ (arg) in
            packet.data.append(dWord: arg)
        })
        
        packet.data.set(header: .cmdRequest)
        
        return packet
    }
    
    static func dataSendPackets(data: ByteBuffer, transactionId: DWord = 0) -> [Packetable] {
        
        let size = data.length
        
        let _startDataPacket = startDataPacket(size: DWord(size), transactionId: transactionId)
        
        // If we have small amounts of data send it with end data packet
        if data.length < 128 {
            return [
                _startDataPacket,
                endDataPacket(data: data, transactionId: transactionId)
            ]
        } else {
            let _dataPacket = dataPacket(data: data, transactionId: transactionId)
            let _endDataPacket = endDataPacket(data: nil, transactionId: transactionId)

            return [_startDataPacket, _dataPacket, _endDataPacket]
        }
    }
    
    static func dataPacket(data: ByteBuffer, transactionId: DWord = 0) -> DataPacket {
        
        var packet = DataPacket(transactionId: transactionId)
        packet.data[dWord: UInt(headerLength)] = transactionId
        packet.data.append(bytes: data.bytes.compactMap({ $0 }))
        packet.data.set(header: .dataPacket)
        
        return packet
    }
    
    static func startDataPacket(size: DWord, transactionId: DWord = 0) -> StartDataPacket {
        
        var packet = StartDataPacket(transactionId: transactionId, dataLength: size)
        packet.data[dWord: UInt(headerLength)] = transactionId
        packet.data.append(dWord: size) //TODO: This should be a single QWord
        packet.data.append(dWord: 0) //Fake to simulate 16 bytes
        packet.data.set(header: .startDataPacket)
        
        return packet
    }
    
    static func endDataPacket(data: ByteBuffer?, transactionId: DWord = 0) -> Packet {
        
        var packet = Packet(name: .endDataPacket)
        packet.data[dWord: UInt(headerLength)] = transactionId
        if let data = data {
            packet.data.append(bytes: data.bytes.compactMap({ $0 }))
        }
        packet.data.set(header: .endDataPacket)
        
        return packet
    }
}
