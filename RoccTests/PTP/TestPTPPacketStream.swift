//
//  TestPTPPacketStream.swift
//  RoccTests
//
//  Created by Simon Mitchell on 25/09/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

@testable import Rocc
import Foundation

struct PacketInfo: Equatable, Codable, CustomStringConvertible {
    
    var description: String {
        return """
            {
                "data": "\(packetData.toHex)",
                "loop": "\(loop.rawValue)",
                "direction": "\(direction.rawValue)"
            }
            """
    }
    
    static func == (lhs: PacketInfo, rhs: PacketInfo) -> Bool {
        return lhs.loop == rhs.loop
            && lhs.direction == rhs.direction
            && lhs.packetData.toHex == rhs.packetData.toHex
    }
    
    enum Loop: String, Equatable, Codable {
        case event
        case control
    }
    
    enum Direction: String, Equatable, Codable {
        case sent
        case received
    }
    
    let packetData: ByteBuffer
    
    let loop: Loop
    
    let direction: Direction
    
    enum CodingKeys: String, CodingKey {
        case data
        case loop
        case direction
    }
    
    init(packetData: ByteBuffer, loop: Loop, direction: Direction) {
        self.packetData = packetData
        self.loop = loop
        self.direction = direction
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let hexData = try values.decode(String.self, forKey: .data)
        packetData = ByteBuffer(hexString: hexData)
        loop = try values.decode(Loop.self, forKey: .loop)
        direction = try values.decode(Direction.self, forKey: .direction)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(loop, forKey: .loop)
        try container.encode(direction, forKey: .direction)
        try container.encode(packetData.toHex, forKey: .data)
    }
}

final class TestPTPPacketStream: PTPPacketStream {
    
    struct TestFlow: Codable {
        
        let steps: Array<FlowStep>
        
        let initialPacket: PacketInfo?
    }
    
    /// Represents a step in the test flow being tested
    struct FlowStep: Codable {
        
        /// The packet received by the test packet stream
        /// used for comparison when packets are received
        var packetReceived: PacketInfo
        
        /// An array of packets to respond with when the given packet is received
        var response: [PacketInfo]?
    }
    
    var testFlow: TestFlow = .init(steps: [], initialPacket: nil)
    
    var currentTestFlowStep: Int = 0
    
    var delegate: PTPPacketStreamDelegate?
    
    var packetsSentAndReceived: [PacketInfo] = []
    
    init?(camera: Camera, port: Int) {
        
    }
    
    func connect(callback: @escaping (Error?) -> Void) {
        delegate?.packetStreamDidOpenControlStream(self)
    }
    
    func setupEventLoop() {
        delegate?.packetStreamDidOpenEventStream(self)
    }
    
    func sendInitialPacketIfPresent() {
        guard let initialPacket = testFlow.initialPacket else {
            return
        }
        packetsSentAndReceived.append(initialPacket)
        guard let packet = Packet.parse(from: initialPacket.packetData) else { return }
        delegate?.packetStream(
            self,
            didReceive: [packet]
        )
    }
    
    func disconnect() {
        
    }
    
    func sendControlPacket(_ packet: Packetable) {
        packetsSentAndReceived.append(
            .init(
                packetData: packet.data,
                loop: .control,
                direction: .sent
            )
        )
        guard currentTestFlowStep < testFlow.steps.count else {
            print("Expected further steps in PTP test flow!")
            return
        }
        let currentFlowStep = testFlow.steps[currentTestFlowStep]
        guard currentFlowStep.packetReceived.loop == .control
                && packet.data.toHex == currentFlowStep.packetReceived.packetData.toHex else {
            currentTestFlowStep += 1
            return
        }
        if let response = currentFlowStep.response {
            currentTestFlowStep += 1
            packetsSentAndReceived.append(contentsOf: response)
            delegate?.packetStream(
                self,
                didReceive: response.compactMap({ Packet.parse(from: $0.packetData) })
            )
        } else {
            currentTestFlowStep += 1
        }
    }
    
    func sendEventPacket(_ packet: Packetable) {
        packetsSentAndReceived.append(
            .init(
                packetData: packet.data,
                loop: .event,
                direction: .sent
            )
        )
        guard currentTestFlowStep < testFlow.steps.count else {
            print("Expected further steps in PTP test flow!")
            return
        }
        let currentFlowStep = testFlow.steps[currentTestFlowStep]
        guard currentFlowStep.packetReceived.loop == .event
                && packet.data.toHex == currentFlowStep.packetReceived.packetData.toHex else {
            currentTestFlowStep += 1
            return
        }
        if let response = currentFlowStep.response {
            currentTestFlowStep += 1
            packetsSentAndReceived.append(contentsOf: response)
            delegate?.packetStream(
                self,
                didReceive: response.compactMap({ Packet.parse(from: $0.packetData) })
            )
        } else {
            currentTestFlowStep += 1
        }
    }
}
