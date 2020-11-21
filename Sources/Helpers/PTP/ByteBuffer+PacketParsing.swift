//
//  ByteBuffer+PacketParsing.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension ByteBuffer {
    
    mutating func parsePackets(removingParsedData removeParsed: Bool = true) -> [Packetable]? {
        
        // Packets have min length of 8
        guard length >= 8 else { return nil }
        
        var offset = 0
        var packets: [Packetable] = []
        
        while offset < length {
            
            // If we don't have a valid packet name, we clear the
            // first 8 bytes. This means if we get sent a packet type we don't
            // recognise, or invalid data (lengths which don't match the actual
            // data) we remove this pre-fixed data and don't get stuck in a loop!
            //      Left over spurious data                   Valid Start Data packet
            // e.g. 00 00 00 00 00 00 00 00 | 14 00 00 00 09 00 00 00 02 00 00 00 08 00 00 00 00 00 00 00 |
            
            // First make sure have non-zero length!
            guard let length = self[dWord: UInt(offset)], length > 0 else {
                offset += 1
                continue
            }
            // Then make sure we can get type int
            guard let typeInt = self[dWord: UInt(offset + MemoryLayout<DWord>.size)] else {
                offset += 1
                continue
            }
            // Then check if we can get valid packet name
            guard Packet.Name(rawValue: typeInt) != nil else {
                // Only move 1 byte on, because we may have a single spurious pre-pended byte!
                offset += 1
                continue
            }
            
            // Parse actual packet!
            guard let packet = parsePacket(offset: offset) else {
                // If we couldn't parse another packet, break out of the while loop
                break
            }
            packets.append(packet.packet)
            offset += Int(packet.length)
        }
        
        if removeParsed {
            slice(offset)
        }
        
        return packets.isEmpty ? nil : packets
    }
    
    func parsePacket(offset: Int) -> (packet: Packetable, length: DWord)? {
        guard length - offset >= 8 else { return nil }
        let packetData = sliced(offset)
        guard let packet = Packet.parse(from: packetData) else {
            return nil
        }
        return (packet, packet.length)
    }
}
