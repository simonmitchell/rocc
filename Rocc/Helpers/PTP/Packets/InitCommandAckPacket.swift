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
    
    let deviceName: String
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.name = name
        self.length = length
        
        let guidData = data.slice(0, 16)
        guard guidData.length == 16 else { return nil }
        
        self.guid = guidData.bytes.compactMap({ $0 })
        
        guard let wString = data[wString: 15] else { return nil }
        deviceName = wString
    }
}
