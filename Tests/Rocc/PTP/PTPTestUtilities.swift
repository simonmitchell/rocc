//
//  PTPTestUtilities.swift
//  RoccTests
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

extension TestPTPPacketStream.TestFlow {
    
    var packetsSentAndReceived: [PacketInfo] {
        
        var packets: [PacketInfo] = []
        if let initialStepPacket = initialPacket {
            packets.append(initialStepPacket)
        }
        
        steps.forEach { (flowStep) in
            packets.append(flowStep.packetReceived)
            packets.append(contentsOf: flowStep.response ?? [])
        }
        return packets
    }
}

extension Packetable {
    var trimmedHexData: String {
        return data.toHex.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

func ==(lhs: TestPTPPacketStream.TestFlow, rhs: Array<PacketInfo>) -> Bool {
    return lhs.packetsSentAndReceived == rhs
}
