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
                
        guard let codeWord = data[word: 0], let code = PTP.EventCode(rawValue: codeWord) else {
            // Some manufacturers *coughs* Sony, send malformed packets... we handle this by hard-coding the height, and assume the code was property changed!
            self.length = DWord(Packet.headerLength)
            self.code = .propertyChanged
            self.data = ByteBuffer()
            return
        }
        self.code = code
        
        // Use `length` here as otherwise we may end up stealing data from other packets!
        self.data = data.sliced(MemoryLayout<Word>.size, Int(length) - Packet.headerLength)
    }
    
    var description: String {
           return """
           {
               length: \(length)
               code: \(name)
               event: \(code)
               data: \(data.toHex)
           }
           """
       }
}
