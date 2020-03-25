//
//  PainInTheArsePacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/12/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct PainInTheArsePacket: Packetable {
    
    var name: Packet.Name
    
    var length: DWord
                
    var data: ByteBuffer = ByteBuffer()
        
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.name = name
        self.data = data
        
        guard length > Packet.headerLength else {
            self.length = 8
            return
        }
        
        // Start at 4 because require a valid length before packet name
        var offset: DWord = 4
        
        // We are normally
        while offset < data.length {
            // If we can get a name at the current offset, and a valid length at offset -4, we must have reached the next packet!
            if let nextNameDword = data[dWord: UInt(offset)], Packet.Name(rawValue: nextNameDword) != nil, let length = data[dWord: UInt(offset - 4)], length > 0 {
                // Length should include header length!
                self.length = offset - 4 + UInt32(Packet.headerLength)
                self.data = data.sliced(0, Int(offset - 4))
                return
            }
            
            offset += 1
        }
        
        self.length = length
    }
}
