//
//  ByteBuffer+PacketParsing.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension ByteBuffer {
    
    func parsePackets(removingParsedData: Bool = true) -> [Packetable]? {
        
        // Packets have min length of 8
        
        var offset = 0
        var packets: [Packetable] = []
        
        while offset < length {
            guard let packet = parsePacket(offset: offset) else {
                // If we couldn't parse another packet, break out of the while loop
                break
            }
            packets.append(packet.packet)
            offset += Int(packet.length)
        }
        
        return packets.isEmpty ? nil : packets
    }
    
    func parsePacket(offset: Int) -> (packet: Packetable, length: DWord)? {
        guard length >= 8 else { return nil }
        let packetData = slice(offset)
        guard let packet = Packet.parse(from: packetData) else {
            return nil
        }
        return (packet, packet.length)
    }
}
