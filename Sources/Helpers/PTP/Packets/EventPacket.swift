//
//  DataPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct EventPacket: Packetable, Transactional {
    
    var name: Packet.Name
    
    var length: DWord
    
    var data: ByteBuffer
    
    let code: PTP.EventCode
    
    let transactionId: DWord?
        
    let variables: [DWord]?
    
    var transactionIdentifier: DWord? {
        return transactionId
    }
    
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
        
        guard let transactionId: DWord = self.data.read(offset: &offset) else {
            self.transactionId = nil
            variables = nil
            return
        }
        
        self.transactionId = transactionId
        
        guard self.data.length > MemoryLayout<DWord>.size else {
            variables = nil
            return
        }
        
        var variables: [DWord] = []
        while offset < self.data.length {
            if let variable: DWord = self.data.read(offset: &offset) {
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
