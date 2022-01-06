//
//  EndDataPacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct EndDataPacket: Packetable, Transactional {
    
    var name: Packet.Name
    
    var length: DWord
    
    var data: ByteBuffer
    
    let transactionId: DWord
    
    var transactionIdentifier: DWord? {
        return transactionId
    }
        
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.length = length
        self.name = name
        
        // If we don't have enough data yet, return nil, otherwise we'll get broken packets when parsing!
        // TODO: Add test case for this!
        // Received packet from device: {
//            length: 20
//            code: startDataPacket
//            transactionId: 6
//            dataLength:  2372
//            data: 06 00 00 00 44 09 00 00 00 00 00 00
//        }
        // Received packet from device: {
//    length: 2384
//    code: endDataPacket
//    transactionId: 6
//    data:
//}
//
        // Received packet from device: {
//    length: 2366
//    code: pong
//    data: a5 c1 00 00 0e 00 00 00 11 00 00 00 01 00 00 00 00 00 16 00 00 00 a5 c1 00 00 0e 00 00 00 11 00 00 00 15 00 00 00 00 00 16 00 00 00 a5 c1 00 00 0e 00 00 00 11 00 00 00 01 00 00 00 00 00 16 00 00 00 a5 c1 00 00 0e 00 00 00 11 00 00 00 15 00 00 00 00 00 10 00 00 00 89 c1 00 00 1b d1 00 00 ea 07 00 00 10 00 00 00 89 c1 00 00 1c d1 00 00 02 00 00 00 10 00 00 00 89 c1 00 00 b0 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 b0 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 05 d1 00 00 02 00 00 00 10 00 00 00 89 c1 00 00 08 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 06 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 07 d1 00 00 03 00 00 00 10 00 00 00 89 c1 00 00 09 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 0b d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 0c d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 0d d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 0e d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 0f d1 00 00 01 00 00 00 10 00 00 00 89 c1 00 00 1b d1 00 00 ea 07 00 00 10 00 00 00 89 c1 00 00 14 d1 00 00 1e 00 00 00 10 00 00 00 89 c1 00 00 16 d1 00 00 22 04 00 80 10 00 00 00 89 c1 00 00 19 d1 00 00 00 01 00 00 10 00 00 00 89 c1 00 00 10 d1 00 00 87 00 00 00 10 00 00 00 89 c1 00 00 01 d1 00 00 33 00 00 00 10 00 00 00 89 c1 00 00 02 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 03 d1 00 00 58 00 00 00 10 00 00 00 89 c1 00 00 04 d1 00 00 08 00 00 00 10 00 00 00 89 c1 00 00 1d d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 11 d1 00 00 02 00 00 00 10 00 00 00 89 c1 00 00 12 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 13 d1 00 00 7a d1 cc 61 20 00 00 00 89 c1 00 00 20 d1 00 00 01 00 00 00 10 00 00 00 01 00 00 00 00 00 00 00 03 00 00 00 20 00 00 00 89 c1 00 00 22 d1 00 00 01 00 00 00 10 00 00 00 01 00 00 00 00 00 00 00 03 00 00 00 28 00 00 00 89 c1 00 00 56 d1 00 00 1c 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 28 00 00 00 89 c1 00 00 50 d1 00 00 1c 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 28 00 00 00 89 c1 00 00 51 d1 00 00 1c 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 28 00 00 00 89 c1 00 00 52 d1 00 00 1c 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 28 00 00 00 89 c1 00 00 53 d1 00 00 1c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 28 00 00 00 89 c1 00 00 54 d1 00 00 1c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 28 00 00 00 89 c1 00 00 55 d1 00 00 1c 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2c 00 00 00 89 c1 00 00 60 d1 00 00 20 00 00 00 87 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2c 00 00 00 89 c1 00 00 61 d1 00 00 20 00 00 00 87 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2c 00 00 00 89 c1 00 00 62 d1 00 00 20 00 00 00 87 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 1c d1 00 00 02 00 00 00 c8 00 00 00 89 c1 00 00 a0 d1 00 00 bc 00 00 00 04 00 00 00 01 00 00 00 2c 00 00 00 03 00 00 00 01 01 00 00 01 00 00 00 00 00 00 00 03 01 00 00 01 00 00 00 00 00 00 00 0f 01 00 00 01 00 00 00 00 00 00 00 02 00 00 00 2c 00 00 00 03 00 00 00 01 02 00 00 01 00 00 00 00 00 00 00 02 02 00 00 01 00 00 00 00 00 00 00 03 02 00 00 01 00 00 00 00 00 00 00 03 00 00 00 14 00 00 00 01 00 00 00 0e 05 00 00 01 00 00 00 00 00 00 00 04 00 00 00 38 00 00 00 04 00 00 00 01 07 00 00 01 00 00 00 00 00 00 00 04 07 00 00 01 00 00 00 00 00 00 00 0e 07 00 00 01 00 00 00 00 00 00 00 11 08 00 00 01 00 00 00 00 00 00 00 14 00 00 00 89 c1 00 00 a1 d1 00 00 08 00 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 a8 d1 00 00 01 00 00 00 10 00 00 00 89 c1 00 00 ab d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 b0 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 b1 d1 00 00 01 00 00 00 10 00 00 00 89 c1 00 00 b2 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 b3 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 b4 d1 00 00 00 00 00 00 3c 00 00 00 89 c1 00 00 b5 d1 00 00 30 00 00 00 00 00 00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 00 04 00 04 00 04 00 04 10 00 00 00 89 c1 00 00 a9 d1 00 00 02 00 00 00 3c 00 00 00 89 c1 00 00 46 d1 00 00 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 de 01 00 04 00 04 a3 02 10 00 00 00 89 c1 00 00 ac d1 00 00 f6 00 00 00 10 00 00 00 89 c1 00 00 1e d1 00 00 01 00 02 00 10 00 00 00 89 c1 00 00 1f d1 00 00 00 00 90 91 10 00 00 00 89 c1 00 00 d9 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 ba d1 00 00 01 00 00 00 24 00 00 00 89 c1 00 00 ca d1 00 00 18 00 00 00 00 00 00 00 00 00 00 00 19 00 00 00 0c 00 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 bc d1 00 00 01 00 00 00 10 00 00 00 89 c1 00 00 b8 d1 00 00 00 00 00 00 70 00 00 00 89 c1 00 00 d3 d1 00 00 64 00 00 00 60 00 04 00 09 00 09 00 40 14 80 0d 40 14 80 0d b5 00 81 00 81 00 81 00 de 00 81 00 81 00 81 00 b5 00 75 00 ac 00 ac 00 ac 00 e0 00 ac 00 ac 00 ac 00 75 00 00 00 b9 fc 47 03 8e fa 00 00 72 05 b9 fc 47 03 00 00 e7 02 89 01 89 01 00 00 00 00 00 00 77 fe 77 fe 19 fd 00 00 ff 01 00 00 ff ff 4c 00 00 00 89 c1 00 00 d8 d1 00 00 45 46 2d 53 31 38 2d 35 35 6d 6d 20 66 2f 33 2e 35 2d 35 2e 36 20 49 49 49 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 b7 d1 00 00 00 00 00 00 32 00 00 00 89 c1 00 00 b9 d1 00 00 26 00 00 00 00 00 00 00 03 00 00 00 3a 00 00 00 39 00 03 80 00 00 00 00 03 00 00 00 32 00 00 00 3a 00 03 80 00 00 1a 00 00 00 89 c1 00 00 db d1 00 00 00 00 00 00 03 00 00 00 2f 00 00 00 28 00 10 00 00 00 89 c1 00 00 dc d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 df d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 bd d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 c1 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 c0 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 bf d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 c4 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 c2 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 c5 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 94 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 95 d1 00 00 02 00 00 00 10 00 00 00 89 c1 00 00 96 d1 00 00 2f 00 00 00 10 00 00 00 89 c1 00 00 97 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 98 d1 00 00 ff 00 00 00 10 00 00 00 89 c1 00 00 c6 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 c8 d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 7c d1 00 00 7a d1 cc 61 18 00 00 00 89 c1 00 00 7d d1 00 00 0c 00 00 00 14 00 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 7e d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 4d d1 00 00 00 3c 00 00 10 00 00 00 89 c1 00 00 38 d1 00 00 02 00 00 00 24 00 00 00 89 c1 00 00 77 d1 00 00 18 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 75 d1 00 00 07 07 00 00 10 00 00 00 89 c1 00 00 4a d1 00 00 00 00 00 00 10 00 00 00 89 c1 00 00 dd d1 00 00 35 00 00 00 0c 00 00 00 a4 c1 00 00 01 00 02 00 08 00 00 00 00 00 00 00 0e 00 00 00 07 00 00 00 01 20 06 00 00 00
//}
        // TODO: Check this requirement hasn't broken anything
        guard data.length >= length - 8 else {
            return nil
        }
                
        guard let transactionId = data[dWord: 0] else { return nil }
        self.transactionId = transactionId
        
        // Use `length` here as otherwise we may end up stealing data from other packets!
        self.data = data.sliced(MemoryLayout<DWord>.size, Int(length) - Packet.headerLength)
    }
    
    init(transactionId: DWord) {
        self.transactionId = transactionId
        name = .endDataPacket
        length = 12
        data = ByteBuffer()
    }
    
    var debugDescription: String {
        return description
    }
    
    var description: String {
       return """
       {
           length: \(length)
           code: \(name)
           transactionId: \(transactionId)
           data: \(data.toHex)
       }
       """
   }
}
