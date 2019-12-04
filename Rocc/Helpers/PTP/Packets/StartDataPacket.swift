//
//  DataStartPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct StartDataPacket: Packetable {
    
    var name: Packet.Name
    
    var length: DWord
    
    var data: ByteBuffer
    
    let transactionId: DWord
    
    let dataLength: DWord
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.length = length
        self.name = name
        
        self.data = data
        
        guard let transactionId = data[dWord: 0] else { return nil }
        self.transactionId = transactionId
        
        guard let dataLength = data[dWord: 4] else { return nil }
        self.dataLength = dataLength
    }
    
    init(transactionId: DWord, dataLength: DWord) {
        self.transactionId = transactionId
        name = .startDataPacket
        length = 20
        data = ByteBuffer()
        self.dataLength = dataLength
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
