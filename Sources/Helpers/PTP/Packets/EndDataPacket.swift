//
//  EndDataPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct EndDataPacket: Packetable {
    
    var name: Packet.Name
    
    var length: DWord
    
    var data: ByteBuffer
    
    let transactionId: DWord
        
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.length = length
        self.name = name
                
        guard let transactionId = data[dWord: 0] else { return nil }
        self.transactionId = transactionId
        
        // Use `length` here as otherwise we may end up stealing data from other packets!
        self.data = data.sliced(MemoryLayout<DWord>.size, Int(length) - Packet.headerLength)
    }
    
    init(transactionId: DWord) {
        self.transactionId = transactionId
        name = .startDataPacket
        length = 12
        data = ByteBuffer()
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
           data: \(data.toHex)
       }
       """
   }
}
