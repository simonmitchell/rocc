//
//  OperationResponsePacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct CommandResponsePacket: Packetable {
    
    enum Code: Word {
        case okay = 0x2001
        //TODO: Add other response codes
    }
    
    var name: Packet.Name
    
    var length: DWord
                
    var data: ByteBuffer = ByteBuffer()
    
    let code: Code
    
    let transactionId: DWord?
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.name = name
        self.length = length
        
        guard let responseWord = data[word: 0] else { return nil }
        guard let code = Code(rawValue: responseWord) else { return nil }
        
        self.code = code
        
        transactionId = data[dWord: 2]
    }
}
