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
    
    let transactionId: DWord?
    
    let variables: [DWord]?
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.length = length
        self.name = name
        
        guard let codeWord = data[word: 0], let code = PTP.EventCode(rawValue: codeWord) else {
            return nil
        }
        self.code = code
        
        // Use `length` here as otherwise we may end up stealing data from other packets!
        self.data = data.sliced(MemoryLayout<Word>.size, Int(length) - Packet.headerLength)
        
        guard self.data.length > 0 else {
            transactionId = nil
            variables = nil
            return
        }
        
        var offset: UInt = 0
        
        guard let transactionId = self.data[dWord: 0] else {
            self.transactionId = nil
            variables = nil
            return
        }
        
        self.transactionId = transactionId
        offset += UInt(MemoryLayout<DWord>.size)
        
        guard self.data.length > 4 else {
            variables = nil
            return
        }
        
        var variables: [DWord] = []
        while offset < self.data.length {
            if let variable = self.data[dWord: offset] {
                variables.append(variable)
            }
            offset += UInt(MemoryLayout<DWord>.size)
        }
        
        self.variables = variables
    }
    
    var debugDescription: String {
        return description
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
