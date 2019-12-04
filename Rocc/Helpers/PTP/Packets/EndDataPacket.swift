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
        
        self.data = data
        
        guard let transactionId = data[dWord: 0] else { return nil }
        self.transactionId = transactionId
    }
    
    init(transactionId: DWord) {
        self.transactionId = transactionId
        name = .startDataPacket
        length = 12
        data = ByteBuffer()
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
