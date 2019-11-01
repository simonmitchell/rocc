//
//  PTPIPClient.swift
//  CCKit
//
//  Created by Simon Mitchell on 29/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

/// A client for transferring images using the PTP IP protocol
final class PTPIPClient: NSObject {
    
    let eventReadStream: InputStream
    
    let eventWriteStream: OutputStream
    
//    let controlReadStream: InputStream
    
//    let controlWriteStream: OutputStream
    
    init?(camera: Camera, port: Int = 15740) {
        
        guard let host = camera.baseURL?.host else { return nil }
        
        var eReadStream: InputStream?
        var eWriteStream: OutputStream?
        var cReadStream: InputStream?
        var cWriteStream: OutputStream?
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &eReadStream, outputStream: &eWriteStream)
//        Stream.getStreamsToHost(withName: host, port: port, inputStream: &cReadStream, outputStream: &cWriteStream)
        
        guard let _eReadStream = eReadStream, let _eWriteStream = eWriteStream/*, let _cReadStream = cReadStream, let _cWriteStream = cWriteStream*/ else {
            return nil
        }
        
        eventReadStream = _eReadStream
        eventWriteStream = _eWriteStream
//        controlReadStream = _cReadStream
//        controlWriteStream = _cWriteStream
        
        super.init()
        
        eventReadStream.delegate = self
        eventWriteStream.delegate = self
//        controlReadStream.delegate = self
//        controlWriteStream.delegate = self
        
        eventReadStream.schedule(in: RunLoop.current, forMode: .default)
        eventWriteStream.schedule(in: RunLoop.current, forMode: .default)
//        controlReadStream.schedule(in: RunLoop.current, forMode: .default)
//        controlWriteStream.schedule(in: RunLoop.current, forMode: .default)
        
        eventReadStream.open()
        eventWriteStream.open()
//        controlReadStream.open()
//        controlWriteStream.open()
    }
    
    var connectCallback: ((_ error: Error?) -> Void)?
    
    func connect(callback: @escaping (_ error: Error?) -> Void) {
        connectCallback = callback
        
        let guid = "ff:ff:52:54:00:b6:fd:a9:ff:ff:52:3c:28:07:a9:3a".data(using: .utf8)
        let connectPacket = Packet.initCommandPacket(guid: guid?.toBytes ?? [], name: "Test")
        eventWriteStream.write(connectPacket)
    }
    
    fileprivate func readAvailableBytes(stream: InputStream) {
        
        var bytes: [UInt8] = []
        
        while stream.hasBytesAvailable {
            
            let numberOfBytesRead = stream.read(&bytes, maxLength: 1024)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
            //Construct the Message object
            
        }
    }
}

extension OutputStream {
    @discardableResult func write(_ packet: Packet) -> Int {
        var bytes = packet.data.bytes.compactMap({ $0 })
        let response = write(&bytes, maxLength: bytes.count)
        return response
    }
}

extension PTPIPClient: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case Stream.Event.errorOccurred:
            break
        case Stream.Event.hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
            break
        case Stream.Event.openCompleted:
            break
        default:
            break
        }
    }
}
