//
//  DataPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct EventPacket: Packetable {
    
    var name: Packet.Name
    
    var length: DWord
    
    var data: ByteBuffer
    
    let code: PTP.EventCode
        
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.length = length
        self.name = name
                
        guard let codeWord = data[word: 0] else { return nil }
        guard let code = PTP.EventCode(rawValue: codeWord) else {
            // Some manufacturers *coughs* Sony, send malformed packets... we handle this by hard-coding the height!
            self.length = 8
            return nil
        }
        self.code = code
        
        // Use `length` here as otherwise we may end up stealing data from other packets!
        self.data = data.sliced(4, Int(length) - 8)
    }
}
