//
//  SimplePing.swift
//  Rocc
//
//  Created by Simon Mitchell on 21/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

internal final class Pinger: NSObject {
    
    typealias Completion = (_ time: TimeInterval?, _ error: Error?) -> Void
    
    private var pinger: SimplePing?
    
    private var timeoutDuration: TimeInterval = 3.0
    
    fileprivate var completion: Completion?
    
    fileprivate var timeoutTimer: Timer?
    
    fileprivate var hostName: String
    
    fileprivate var startTime: TimeInterval?
    
    class func ping(hostName: String, timeout: TimeInterval = 3.0, completion: @escaping Completion) {
        let ping = Pinger(hostName: hostName)
        ping.ping(timeout: timeout, completion: completion)
    }
    
    init(hostName: String) {
        self.hostName = hostName
        super.init()
    }
    
    private func ping(timeout: TimeInterval, completion: @escaping Completion) {
        
        self.pinger = SimplePing(hostName: hostName)
        self.timeoutDuration = timeout
        self.completion = completion
        pinger!.delegate = self
        pinger!.start()
    }
    
    private func stop() {
        
        pinger?.stop()
        pinger = nil
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
}

enum PingerError: LocalizedError {
    
    case timeout
    
    var localizedDescription: String {
        return errorDescription ?? "Unknown Error"
    }
    
    public var errorDescription: String? {
        switch self {
        case .timeout:
            return "Timed Out"
        }
    }
}

extension Pinger: SimplePingDelegate {
    
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutDuration, repeats: false, block: { [weak self] (_) in
            guard let this = self else { return }
            this.completion?(nil, PingerError.timeout)
            this.stop()
        })
        pinger.send(ping: "Hello".data(using: .utf8) ?? Data())
    }
    
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        startTime = Date().timeIntervalSince1970
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        completion?(Date().timeIntervalSince1970 - (startTime ?? 0.0), nil)
        stop()
    }
    
    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        stop()
    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        completion?(nil, error)
        stop()
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        completion?(nil, error)
        stop()
    }
}
