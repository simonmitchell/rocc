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
    }
    
    private static let headerLength: Int = 8
    
    var data = ByteBuffer()
    
    var length: DWord {
        return UInt32(data.length)
    }
        
    let name: Name
    
    let unparsedData: ByteBuffer
    
    private static let nameToType: [Packet.Name : Packetable.Type] = [
        .initCommandAck: InitCommandAckPacket.self
    ]
    
    static func parse(from data: ByteBuffer) -> Packetable? {
        
        guard data.length >= 8 else {
            return nil
        }
       
        guard let length = data[dWord: 0] else { return nil }
       
        guard let typeInt = data[dWord: 4] else { return nil }
        guard let type = Name(rawValue: typeInt) else { return nil }
              
        let unparsedData = data.sliced(Packet.headerLength, Int(length))
        
        guard let packetType = nameToType[type] else {
            return Packet(length: length, name: type, data: unparsedData)
        }
        
        return packetType.init(length: length, name: type, data: unparsedData)
    }
        
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        self.name = name
        self.unparsedData = data
        self.data.set(header: name)
    }
    
    init() {
        name = .unknown
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
    
    static func commandPacket(code commandCode: DWord, arguments: [DWord]?, transactionId: DWord = 0) -> Packet {
        
        var packet = Packet()
        packet.data[dWord: UInt(headerLength)] = 1
        packet.data.append(dWord: commandCode)
        packet.data.append(dWord: transactionId)
        
        arguments?.forEach({ (arg) in
            packet.data.append(dWord: arg)
        })
        
        packet.data.set(header: .cmdRequest)
        
        return packet
    }
    
    static func startDataPacket(size: DWord, transactionId: DWord = 0) -> Packet {
        
        var packet = Packet()
        packet.data[dWord: UInt(headerLength)] = transactionId
        packet.data.append(dWord: size)
        packet.data.set(header: .startDataPacket)
        
        return packet
    }
    
    static func endDataPacket(payloadData: Data, transactionId: DWord = 0) -> Packet {
        
        var packet = Packet()
        packet.data[dWord: UInt(headerLength)] = transactionId
        packet.data.append(data: payloadData)
        packet.data.set(header: .endDataPacket)
        
        return packet
    }
}
