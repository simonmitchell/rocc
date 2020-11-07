//
//  UDPClient.swift
//  Rocc
//
//  Created by Simon Mitchell on 20/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import Darwin
import os

internal extension in_addr {
    
    init?(_ string: String) {
        
        var addr = in_addr()
        let conversionResult = inet_pton(AF_INET, string, &addr)
        guard conversionResult == 1 else {
            return nil
        }
        self = addr
    }
}

fileprivate func toContext(refType : AnyObject) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(refType).toOpaque())
}

fileprivate func fromContext<T: AnyObject>(_ context: UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(context).takeUnretainedValue()
}

func htons(_ value: CUnsignedShort) -> CUnsignedShort {
    return (value << 8) + (value >> 8);
}

class UDPClient {
    
    struct Device {
        
        let uuid: String
        
        let ddURL: URL
    }
    
    private var sendSocket: CFSocket?
    
    private var listenSocket: CFSocket?
    
    private var timer: Timer?
    
    private var ssdpReceived: Bool = false
    
    internal var ssdpTimeout: TimeInterval = 10
    
    private let log: OSLog = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "UDPClient")
    
    var devices: [Device] = []
    
    private var ipInterface: NetworkInterface? {
        
        guard let interface = NetworkInterface.all.first(where: {
            guard let family = $0.family, family == .ipv4 else {
                return false
            }
            return $0.name == "en0" && $0.supportsMulticast
        }) else { return nil }
        
        return interface
    }
    
    private let initialMessage: [String]
    
    private let port: Int
    
    private let address: String
    
    init(initialMessages messages: [String], address: String, port: Int = 0) {
        initialMessage = messages
        self.port = port
        self.address = address
    }
    
    typealias UDPCompletionHandler = (_ device: Device?, _ error: Error?) -> Void
    
    var completionHandlers: [UDPCompletionHandler] = []
    
    /// Searches for UDP devices using a socket based connection
    ///
    /// - Parameter callback: A closure to be called when an error occured or a device was discovered. This is retained by the client until it is removed.
    func startSearching(with callback: @escaping UDPCompletionHandler) {
        
        completionHandlers.append(callback)
        releaseSocket()
        startListening()
    }
    
    var finishCallbacks: [() -> Void] = []
    
    var isRunning: Bool {
        return sendSocket != nil && listenSocket != nil
    }
    
    func finishSearching(with callback: @escaping () -> Void) {
        
        guard finishCallbacks.isEmpty else {
            finishCallbacks.append(callback)
            return
        }
        
        finishCallbacks.append(callback)
        completionHandlers = []
        
        let currentQueue = OperationQueue.current
        
        guard let backgroundQueue = backgroundQueue else {
            callback()
            _ = finishCallbacks.removeLast()
            return
        }
        
        backgroundQueue.async {
            
            let runLoop = CFRunLoopGetCurrent()
            self.releaseSocket()
            CFRunLoopStop(runLoop)
            
            currentQueue?.addOperation {
                
                self.finishCallbacks.forEach({ (callback) in
                    callback()
                })
                self.finishCallbacks = []
            }
            
            self.backgroundQueue = nil
        }
    }
    
    private func releaseSocket() {
//        @synchronized(self)
//        {
        if let sendSocket = sendSocket, CFSocketIsValid(sendSocket) {
            CFSocketInvalidate(sendSocket)
        }
        if let listenSocket = listenSocket, CFSocketIsValid(listenSocket) {
            CFSocketInvalidate(listenSocket)
        }
        
        self.sendSocket = nil
        self.listenSocket = nil

//        }
    }
    
    var backgroundQueue: DispatchQueue?
    
    private func startListening() {
        
        backgroundQueue = DispatchQueue.global(qos: .userInitiated)
        backgroundQueue?.async { [weak self] in
            
            guard let self = self else { return }
            
            if self.sendSocket == nil {
                self.sendSocket = self.newSocket()
            }
            
            guard let sendSocket = self.sendSocket else {
                self.callCompletionHandlers(with: nil, error: UDPClientError.failedToCreateSendSocket)
                return
            }
            
            // Send on the socket
            let messages = self.initialMessage
            
            let messageDatas = messages.map({ (message) in
                return (message: message, data: Data(Array(message.utf8)) as CFData)
            })
            
            var address: sockaddr_in = sockaddr_in(
                sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size),
                sin_family: sa_family_t(AF_INET),
                sin_port: htons(CUnsignedShort(self.port)),
                sin_addr: in_addr(self.address)!,
                sin_zero: ( 0, 0, 0, 0, 0, 0, 0, 0 )
            )
            
            let addressData = Data(bytes: &address, count: MemoryLayout.size(ofValue: address))
            
            Logger.log(message: "Initialising socket for listening", category: "UDPClient", level: .debug)
            os_log("Initialising socket for listening", log: self.log, type: .debug)
            
            if self.listenSocket == nil {
                self.listenSocket = self.newSocket()
            }
            
            guard let _listenSocket = self.listenSocket else {
                self.callCompletionHandlers(with: nil, error: UDPClientError.failedToCreateListenSocket)
                return
            }
            
            guard self.setReusePortOption(for: _listenSocket) else {
                self.callCompletionHandlers(with: nil, error: UDPClientError.failedToSetReuseOptions)
                return
            }
            
            // Send data to socket
            messageDatas.forEach({ (messageData) in
                let sendResponse = CFSocketSendData(sendSocket, addressData as CFData, messageData.data, 0.0)
                if sendResponse == CFSocketError.success {
                    Logger.log(message: "Sending data to socket:\n\n\(messageData.message)", category: "UDPClient", level: .debug)
                    os_log("sendSocket Sending data:\n\n%@", log: self.log, type: .debug, messageData.message)
                } else {
                    Logger.log(message: "Failed to send data to socket \(sendResponse):\n\n\(messageData.message)", category: "UDPClient", level: .error)
                    os_log("Failed to send data to socket:\n\n%@", log: self.log, type: .error, messageData.message)
                }
            })
            
            // Set the listen socket's address
            let setAddressResponse = CFSocketSetAddress(_listenSocket, addressData as CFData)
            guard setAddressResponse == CFSocketError.success else {
                self.callCompletionHandlers(with: nil, error: UDPClientError.failedToSetListenAddress)
                Logger.log(message: "listenSocket CFSocketSetAddress() failed. [errno \(errno)]", category: "UDPClient", level: .error)
                os_log("listenSocket CFSocketSetAddress() failed. [errno %d]", log: self.log, type: .error, errno)
                return
            }
            
            // Listen from the socket
            let _sendSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, sendSocket, 0)
            let _listenSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _listenSocket, 0)
            
            if _sendSource == nil && _listenSource == nil {
                self.callCompletionHandlers(with: nil, error: UDPClientError.failedToCreateRunLoopSources)
                Logger.log(message: "CFRunLoopSourceRef's couldn't be allocated", category: "UDPClient", level: .error)
                os_log("CFRunLoopSourceRef's couldn't be allocated", log: self.log, type: .error)
                return
            }
            
            if let sendSource = _sendSource {
                CFRunLoopAddSource(CFRunLoopGetCurrent(), sendSource, .defaultMode)
                Logger.log(message: "sendSource added", category: "UDPClient", level: .debug)
                os_log("sendSource added", log: self.log, type: .debug)
            }
            if let listenSource = _listenSource {
                CFRunLoopAddSource(CFRunLoopGetCurrent(), listenSource, .defaultMode)
                Logger.log(message: "listenSocket listening", category: "UDPClient", level: .debug)
                os_log("listenSocket listening", log: self.log, type: .debug)
            }
                        
            CFRunLoopRun()
        }
    }
    
    private func setReusePortOption(for socket: CFSocket) -> Bool {
        
        var on: Int = 1
        
        let reusePortResult = setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_REUSEPORT, &on, socklen_t(MemoryLayout.size(ofValue: on)))
        
        guard reusePortResult == 0 else {
            Logger.log(message: "setsockopt SO_REUSEPORT failed. [errno \(errno)]", category: "UDPClient", level: .error)
            os_log("setsockopt SO_REUSEPORT failed. [errno %d]", log: log, type: .error, errno)
            return false
        }
        
        let reuseAddressResult = setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_REUSEADDR, &on, socklen_t(MemoryLayout.size(ofValue: on)))
        
        guard reuseAddressResult == 0 else {
            Logger.log(message: "setsockopt SO_REUSEADDR failed. [errno \(errno)]", category: "UDPClient", level: .error)
            os_log("setsockopt SO_REUSEADDR failed. [errno %d]", log: log, type: .error, errno)
            return false
        }
        
        return true
    }
    
    private func newSocket() -> CFSocket? {
        
        guard let ipAddress = ipInterface?.address else { return nil }
        
        var socketContext: CFSocketContext = CFSocketContext(version: 0, info: toContext(refType: self), retain: nil, release: nil, copyDescription: nil)
        
        let callbackType: CFSocketCallBackType = [.acceptCallBack, .dataCallBack]
        let socket = CFSocketCreate(nil, AF_INET, SOCK_DGRAM, IPPROTO_UDP, callbackType.rawValue, { (socket, callbackType, address, data, info) in
            
            guard let _info = info else { return }
            let client = Unmanaged<UDPClient>.fromOpaque(_info).takeUnretainedValue()
            
            client.handle(data: data, from: socket, type: callbackType, address: address)

        }, &socketContext)
        
        guard let _socket = socket else {
            Logger.log(message: "UDP socket could not be created", category: "UDPClient", level: .error)
            os_log("UDP socket could not be created", log: log, type: .error)
            return socket
        }
        
        CFSocketSetSocketFlags(_socket, kCFSocketCloseOnInvalidate)
        
        let mutliaddr = in_addr(SonyConstants.SSDP.address)!
        let interface = in_addr(ipAddress)!
        var mreq: ip_mreq = ip_mreq(imr_multiaddr: mutliaddr, imr_interface: interface)
        
        let setResult = setsockopt(CFSocketGetNative(_socket), IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, socklen_t(MemoryLayout<ip_mreq>.size))
        
        guard setResult == 0 else {
            Logger.log(message: "setsockopt IP_ADD_MEMBERSHIP failed. [errno \(errno)]", category: "UDPClient", level: .error)
            os_log("setsockopt IP_ADD_MEMBERSHIP failed. [errno %d]", log: log, type: .error, errno)
            return nil
        }
        
        Logger.log(message: "setsockopt IP_ADD_MEMBERSHIP succeeded.", category: "UDPClient", level: .debug)
        os_log("setsockopt IP_ADD_MEMBERSHIP succeeded", log: log)
        
        return socket;
    }
    
    private func handle(data: UnsafeRawPointer?, from socket: CFSocket?, type callbackType: CFSocketCallBackType, address: CFData?) {
        
        switch callbackType {
        case .connectCallBack:
            
            break
            
        case .dataCallBack:
            
            guard let data = data else { return }
            
            // With a connection-oriented socket, if the connection is broken from the
            // other end, then one final kCFSocketReadCallBack or kCFSocketDataCallBack
            // will occur.  In the case of kCFSocketReadCallBack, the underlying socket
            // will have 0 bytes available to read.  In the case of kCFSocketDataCallBack,
            // the data argument will be a CFDataRef of length 0.
            let cfdata = fromContext(UnsafeMutableRawPointer(mutating: data)) as CFData
            let datalen = CFDataGetLength(cfdata)
            
            guard datalen != 0 else {
                callCompletionHandlers(with: nil, error: UDPClientError.socketDisonnected)
                return
            }

            // CFNetworking chunked some data in on our behalf.  Maybe we got a full packet maybe not.
            // Appending all data to a circular buf and reading from head:
            
            guard let responseString = String(data: cfdata as Data, encoding: .utf8) else {
                Logger.log(message: "Socket data couldn't be converted to utf8 string", category: "UDPClient", level: .debug)
                os_log("Socket data couldn't be converted to utf8 string", log: log, type: .debug)
                return
            }
            
            Logger.log(message: "Got data from socket:\n\(responseString)", category: "UDPClient", level: .debug)
            os_log("Got data from socket:\n%@", log: log, type: .debug, responseString)
            
            guard let ddURL = parseDDURL(from: responseString) else {
                Logger.log(message: "Could not parse ddURL from socket data", category: "UDPClient", level: .error)
                os_log("Could not parse ddURL from socket data", log: log, type: .error)
                return
            }
            
            guard let uuid = parseUUID(from: responseString) else {
                Logger.log(message: "Could not parse uuid from socket data", category: "UDPClient", level: .error)
                os_log("Could not parse uuid from socket data", log: log, type: .error)
                return
            }
            
            Logger.log(message: "Got device from socket with ddURL: \(ddURL.absoluteString), uuid: \(uuid)", category: "UDPClient", level: .debug)
            os_log("Got device from socket with ddURL: %@, uuid: %@", log: log, type: .debug, ddURL.absoluteString, uuid)
            
            let device = Device(uuid: uuid, ddURL: ddURL)
            if !devices.contains(where: { $0.uuid == uuid }) {
                devices.append(device)
                ssdpReceived = true
            }
            
            callCompletionHandlers(with: device, error: nil)
        
        default:
            break
        }
    }
    
    //MARK - Parsing UDP data
    
    private func parseDDURL(from string: String) -> URL? {
        
        do {
            let urlMatches = try string.matches(for: "LOCATION:\\s+([^\\s\\\\]+)", at: 1)
            guard let firstMatch = urlMatches.first?.capture(at: 1) else {
                return nil
            }
            return URL(string: firstMatch)
        } catch _ {
            return nil
        }
    }
    
    private func parseUUID(from string: String) -> String? {
        
        do {
            let uuidMatches = try string.matches(for: "uuid:([A-Za-z0-9\\-\\_]+)")
            return uuidMatches.first?.capture(at: 1)
        } catch _ {
            return nil
        }
    }
    
    private func callCompletionHandlers(with device: Device?, error: Error?) {
        completionHandlers.forEach({ $0(device, error) })
//        completionHandlers = []
    }
    
    enum UDPClientError: Error {
        case failedToCreateSendSocket
        case failedToCreateListenSocket
        case failedToSetReuseOptions
        case failedToSetListenAddress
        case failedToCreateRunLoopSources
        case socketDisonnected
    }
}
