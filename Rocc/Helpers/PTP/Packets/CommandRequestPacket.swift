//
//  CommandRequestPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct CommandRequestPacket: Packetable {
    
    var name: Packet.Name
    
    var length: DWord
                
    var data: ByteBuffer = ByteBuffer()
    
    let transactionId: DWord
    
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
}
