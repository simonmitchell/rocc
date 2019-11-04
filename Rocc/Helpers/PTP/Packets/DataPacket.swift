//
//  DataPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct DataPacket: Packetable {
    
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
        self.data = data.sliced(4, Int(length) - 8)
    }
    
    init(transactionId: DWord) {
        self.transactionId = transactionId
        name = .startDataPacket
        data = ByteBuffer()
        length = 0
    }
}
