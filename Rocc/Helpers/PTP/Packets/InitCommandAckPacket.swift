//
//  InitCommandAckPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct InitCommandAckPacket: Packetable {
    
    var name: Packet.Name
    
    var length: DWord
    
    let guid: [Byte]
    
    let sessionId: DWord
    
    let deviceName: String?
    
    var data: ByteBuffer = ByteBuffer()
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.name = name
        self.length = length
        
        guard let sessionId = data[dWord: 0] else { return nil }
        self.sessionId = sessionId
        
        let guidData = data.sliced(MemoryLayout<DWord>.size, 16 + MemoryLayout<DWord>.size)
        guard guidData.length == 16 else { return nil }
        
        self.guid = guidData.bytes.compactMap({ $0 })
        
        // For some reason the device name isn't sent with a UInt8 beginning byte of it's length.
        deviceName = data[wStringWithoutCount: UInt(16 + MemoryLayout<DWord>.size)]
    }
}
