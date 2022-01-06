//
//  DataStartPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct StartDataPacket: Packetable, Transactional {
    
    var name: Packet.Name
    
    var length: DWord
    
    var data: ByteBuffer
    
    let transactionId: DWord
    
    var transactionIdentifier: DWord? {
        return transactionId
    }
    
    let dataLength: DWord
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.length = length
        self.name = name
        
        self.data = data
        
        var offset: UInt = 0
        
        guard let transactionId: DWord = data.read(offset: &offset) else { return nil }
        self.transactionId = transactionId
        
        guard let dataLength: DWord = data.read(offset: &offset) else { return nil }
        self.dataLength = dataLength
    }
    
    init(transactionId: DWord, dataLength: DWord) {
        self.transactionId = transactionId
        name = .startDataPacket
        length = 20
        data = ByteBuffer()
        self.dataLength = dataLength
    }
    
    var debugDescription: String {
        return description
    }
    
    var description: String {
        return """
        {
            length: \(length)
            code: \(name)
            transactionId: \(transactionId)
            dataLength:  \(dataLength)
            data: \(data.toHex)
        }
        """
    }
}
