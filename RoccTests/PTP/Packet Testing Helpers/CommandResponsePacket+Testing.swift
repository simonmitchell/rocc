//
//  CommandResponsePacket+Testing.swift
//  RoccTests
//
//  Created by Simon Mitchell on 27/09/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation
@testable import Rocc

extension CommandResponsePacket {
    
    init(
        code responseCode: CommandResponsePacket.Code,
        transactionId: DWord = 0,
        data additionalData: ByteBuffer
    ) {
        
        var data = ByteBuffer()
        data[word: 0] = responseCode.rawValue
        data[dWord: 2] = transactionId
        data.append(bytes: additionalData.bytes.compactMap({ $0 }))
        
        self.init(
            length: DWord(Packet.headerLength + 6 + additionalData.length),
            name: .cmdResponse,
            data: data
        )!
    }
}
