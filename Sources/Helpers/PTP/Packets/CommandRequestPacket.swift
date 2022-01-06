//
//  CommandRequestPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct CommandRequestPacket: Packetable, Transactional {
    
    var name: Packet.Name
    
    var length: DWord
                
    var data: ByteBuffer = ByteBuffer()
    
    let transactionId: DWord
    
    var transactionIdentifier: DWord? {
        return transactionId
    }
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.name = name
        self.length = length
        self.data = data
        self.transactionId = 0
    }
    
    init(transactionId: DWord) {
        self.transactionId = transactionId
        self.name = .cmdRequest
        self.length = 0
    }
    
    private var commandCode: PTP.CommandCode? {
        guard let commandCodeWord = data[word: 12] else { return nil }
        return PTP.CommandCode(rawValue: commandCodeWord)
    }
    
    var debugDescription: String {
        return description
    }
    
    var description: String {
        return """
        {
            length: \(data.length)
            code: \(name)
            transactionId: \(data[dWord: UInt(Packet.headerLength + MemoryLayout<DWord>.size + MemoryLayout<Word>.size) ] ?? 0)
            command: \(commandCode != nil ? "\(commandCode!)" : "null")
            data: \(data.sliced(Packet.headerLength + (MemoryLayout<DWord>.size * 2) + MemoryLayout<Word>.size).toHex)
        }
        """
    }
}
