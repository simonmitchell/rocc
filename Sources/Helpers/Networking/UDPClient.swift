//
//  UDPClient.swift
//  Rocc
//
//  Created by Simon Mitchell on 20/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import os
import Network

class UDPClient {
    
    struct Device {
        
        let uuid: String
        
        let ddURL: URL
    }
    
    private var timer: Timer?
    
    private var ssdpReceived: Bool = false
    
    internal var ssdpTimeout: TimeInterval = 10
    
    private let log: OSLog = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "UDPClient")
    
    private var connectionGroup: NWConnectionGroup?
    
    var devices: [Device] = []
    
    private let initialMessage: [String]
    
    private let port: NWEndpoint.Port
    
    private let address: NWEndpoint.Host
    
    init(initialMessages messages: [String], address: NWEndpoint.Host, port: NWEndpoint.Port = 0) {
        initialMessage = messages
        self.port = port
        self.address = address
    }
    
    typealias UDPCompletionHandler = (_ device: Device?, _ error: Error?) -> Void
    
    var completionHandler: UDPCompletionHandler?
    
    /// Searches for UDP devices using a socket based connection
    ///
    /// - Parameter callback: A closure to be called when an error occured or a device was discovered. This is retained by the client until it is removed.
    func startSearching(with callback: @escaping UDPCompletionHandler) {
        completionHandler = callback
        releaseSocket()
        startListening()
    }
    
    var finishCallbacks: [() -> Void] = []
    
    var isRunning: Bool {
        return connectionGroup != nil
    }
    
    func finishSearching(with callback: @escaping () -> Void) {
        completionHandler = nil
        self.releaseSocket()
        self.backgroundQueue = nil
        callback()
    }
    
    private func releaseSocket() {
        connectionGroup?.cancel()
        connectionGroup = nil
    }
    
    var backgroundQueue: DispatchQueue?
    
    private func startListening() {
        
        guard backgroundQueue == nil else { return }
        
        backgroundQueue = DispatchQueue.global(qos: .userInitiated)
        
        if self.connectionGroup == nil {
            do {
                let multicast = try NWMulticastGroup(
                    for: [
                        .hostPort(host: address, port: port)
                    ]
                )
                let params: NWParameters = .udp
                params.allowLocalEndpointReuse = true
                self.connectionGroup = NWConnectionGroup(with: multicast, using: params)
            } catch {
                
            }
        }
        
        self.connectionGroup?.setReceiveHandler(handler: { [weak self] message, content, isComplete in
            guard let self = self else { return }
            guard let data = content else { return }
            

            // CFNetworking chunked some data in on our behalf.  Maybe we got a full packet maybe not.
            // Appending all data to a circular buf and reading from head:
            
            guard let responseString = String(data: data, encoding: .utf8) else {
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
                        
            OperationQueue.main.addOperation {
                
                let device = Device(uuid: uuid, ddURL: ddURL)
                if !self.devices.contains(where: { $0.uuid == uuid }) {
                    self.devices.append(device)
                    self.ssdpReceived = true
                }
                
                self.callCompletionHandlers(with: device, error: nil)
            }
        })
                
        connectionGroup?.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            guard state == .ready else { return }
            
            let messageDatas = initialMessage.map({ message in
                return (message: message, data: message.data(using: .utf8))
            })
            
            messageDatas.forEach { messageData in
                Logger.log(message: "Sending \(messageData.data?.count ?? 0) bytes to multicast connection group", category: "UDPClient", level: .debug)
                os_log("Sending data: %i bytes", log: self.log, type: .debug, messageData.data?.count ?? 0)
                self.connectionGroup?.send(content: messageData.data, completion: { [weak self] error in
                    guard let self = self else { return }
                    if let error {
                        Logger.log(message: "Failed to send data to socket \(error):\n\n\(messageData.message)", category: "UDPClient", level: .error)
                        os_log("Failed to send data to socket:\n\n%@", log: self.log, type: .error, messageData.message)
                    } else {
                        Logger.log(message: "Sent data to socket:\n\n\(messageData.message)", category: "UDPClient", level: .debug)
                        os_log("Sent data:\n\n%@", log: self.log, type: .debug, messageData.message)
                    }
                })
            }
        }
        
        connectionGroup?.start(queue: backgroundQueue!)
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
        completionHandler?(device, error)
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
