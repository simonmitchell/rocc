//
//  PTPPacketStream.swift
//  Rocc
//
//  Created by Simon Mitchell on 25/09/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

/// A delegate protocol for `PTPPacketStream` to pass back packets
/// to any interested listeners
protocol PTPPacketStreamDelegate {
    
    /// Called when the stream received an array of packets
    /// - Parameters:
    ///   - stream: The stream which received the packets
    ///   - packets: The packets which were received
    func packetStream(_ stream: PTPPacketStream, didReceive packets: [Packetable])
    
    /// Called when the stream is disconnected
    /// - Parameter stream: The stream which disconnected
    func packetStreamDidDisconnect(_ stream: PTPPacketStream)
    
    /// Called when the control stream has opened, after this it is up to the
    /// delegate to ask the stream to send the initial packet to the stream
    /// - Parameter stream: The stream which opened
    func packetStreamDidOpenControlStream(_ stream: PTPPacketStream)
    
    /// Called when the control stream has opened, after this it is up to the
    /// delegate to ask the stream to send the initial packet to the stream
    /// - Parameter stream: The stream which opened the event loop
    func packetStreamDidOpenEventStream(_ stream: PTPPacketStream)
}

/// A protocol to implement to provide a stream for PTP packets
protocol PTPPacketStream {
    
    /// A delegate which will have messages called upon receiving packets
    var delegate: PTPPacketStreamDelegate? { get set }
    
    /// Initialises the packet stream with a camera on a specific port
    /// - Parameters:
    ///   - camera: The camera to point at
    ///   - port: The port to communicate over
    init?(camera: Camera, port: Int)
    
    /// Connects the stream to the given camera
    /// - Parameter callback: A closure called once connection is complete
    func connect(callback: @escaping (_ error: Error?) -> Void)
    
    /// Should be called to setup the streams for the PTP IP event loop
    func setupEventLoop()
    
    /// Disconnects the stream
    func disconnect()
    
    /// Sends a packet to the control loop of the PTP IP connection
    /// - Parameter packet: The packet to send
    func sendControlPacket(_ packet: Packetable)
    
    /// Sends a packet to the event loop of the PTP IP connection
    /// - Parameter packet: The packet to send
    func sendEventPacket(_ packet: Packetable)
}
