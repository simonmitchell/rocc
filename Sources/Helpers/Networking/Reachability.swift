//
//  Reachability.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/06/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
#if os(macOS)
import CoreWLAN
#endif

fileprivate let NetworkChangeNotificationName = "com.apple.system.config.network_change"

/// A helper class for providing reachability callbacks to any listeners
public final class Reachability {
    
    /// The internal reachability listener
    public let reachability: SCNetworkReachability
    
    /// A closure to be called with a set of reachability flags when network reachability changes
    public var callback: ((_ flags: SCNetworkReachabilityFlags) -> Void)?
    
    /// A closure called when the SSID the local device is connected to changes
    public var networkChangeCallback: ((_ ssid: String?) -> Void)?
    
    #if os(iOS)
    /// The SSID the local device is connected to
    public static var currentWiFiSSID: String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [CFString] else { return nil }
        let interfaceInfo = interfaces.compactMap { (interface) -> String? in
            guard let info = CNCopyCurrentNetworkInfo(interface) as? [AnyHashable : Any] else { return nil }
            return info[kCNNetworkInfoKeySSID] as? String
        }
        return interfaceInfo.last
    }
    #elseif os(macOS)
    /// The SSID the local device is connected to
    public static var currentWiFiSSID: String? {
        let wifi = CWWiFiClient.shared().interface()
        return wifi?.ssid()
    }
    #endif
    
    /// Creates a new reachability instance between a two socket addresses
    ///
    /// - Parameters:
    ///   - localAddress: The local socket address
    ///   - socketAddress: The remote socket address
    public init?(localAddress: sockaddr_in, socketAddress: sockaddr_in) {
        
        var ipAddress = socketAddress
        var localAddr = localAddress
        
        let localSockAddr = withUnsafePointer(to: &localAddr, { pointer in
            // Converts to a generic socket address
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                // $0 is the pointer to `sockaddr`
                return $0
            }
        })
        
        let remoteSockAddr = withUnsafePointer(to: &ipAddress, { pointer in
            // Converts to a generic socket address
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                // $0 is the pointer to `sockaddr`
                return $0
            }
        })
        
        guard let _reachability = SCNetworkReachabilityCreateWithAddressPair(kCFAllocatorDefault, localSockAddr, remoteSockAddr) else {
            return nil
        }
        
        reachability = _reachability
    }
    
    /// Creates a new reachability instance to a given socket address
    ///
    /// - Parameter socketAddress: The remote socket address
    public init?(socketAddress: sockaddr_in) {
        
        var ipAddress = socketAddress
        
        guard let _reachability = withUnsafePointer(to: &ipAddress, { pointer in
            // Converts to a generic socket address
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                // $0 is the pointer to `sockaddr`
                return SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return nil
        }
        
        reachability = _reachability
    }
    
    /// Creates a new reachability instance to a given host name
    ///
    /// - Parameter hostName: The remote host name
    public init?(hostName: String) {
        
        guard let _reachability = SCNetworkReachabilityCreateWithName(nil, hostName) else { return nil }
        
        reachability = _reachability
    }
    
    // Queue where the `SCNetworkReachability` callbacks run
    private let queue = DispatchQueue.main
    
    // We use it to keep a backup of the last flags read.
    private var currentReachabilityFlags: SCNetworkReachabilityFlags?
    
    // Flag used to avoid starting listening if we are already listening
    private var isListening = false
    
    /// Starts listening for reachability changes
    ///
    /// - Parameter callback: The closure to be called when reachability changes
    public func start(callback: @escaping (_ flags: SCNetworkReachabilityFlags) -> Void) {
        
        // Checks if we are already listening
        guard !isListening else {
            self.callback = callback
            return
        }
        
        self.callback = callback
        
        // Creates a context
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        // Sets `self` as listener object
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        
        let callbackClosure: SCNetworkReachabilityCallBack? = {
            
            (reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            guard let info = info else { return }
            // Gets the `Handler` object from the context info
            let handler = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
            
            handler.queue.async {
                handler.checkReachability(flags: flags)
            }
        }
        
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            { (nc, observer, name, _, _) -> Swift.Void in
            
            
                guard let observer = observer, let name = name else {
                    return
                }
                
                let instance = Unmanaged<Reachability>.fromOpaque(observer).takeUnretainedValue()
                instance.onNetworkChange(name.rawValue as String)
            
            },
            NetworkChangeNotificationName as CFString,
            nil,
            .deliverImmediately
        )
        
        // Registers the callback. `callbackClosure` is the closure where we manage the callback implementation
        if !SCNetworkReachabilitySetCallback(reachability, callbackClosure, &context) {
            // Not able to set the callback
        }
        
        // Sets the dispatch queue which is `DispatchQueue.main` for this example. It can be also a background queue
        if !SCNetworkReachabilitySetDispatchQueue(reachability, queue) {
            // Not able to set the queue
        }
        
        // Runs the first time to set the current flags
        queue.async {
            
            // Resets the flags stored, in this way `checkReachability` will set the new ones
            self.currentReachabilityFlags = nil
            // Reads the new flags
            var flags = SCNetworkReachabilityFlags()
            SCNetworkReachabilityGetFlags(self.reachability, &flags)
            self.checkReachability(flags: flags)
        }
        
        isListening = true
    }
        
    private func onNetworkChange(_ notificationName: String) {
        
        guard notificationName == NetworkChangeNotificationName else {
            return
        }
        
        networkChangeCallback?(Reachability.currentWiFiSSID)
        NotificationCenter.default.post(name: .currentWiFiSSIDChanged, object: Reachability.currentWiFiSSID)
    }
    
    // Called inside `callbackClosure`
    private func checkReachability(flags: SCNetworkReachabilityFlags) {
        
        if currentReachabilityFlags != flags {
            
            // �� Network state is changed ��
            // Stores the new flags
            currentReachabilityFlags = flags
            callback?(flags)
        }
    }
    // Stops listening for reachability changes
    public func stop() {
        
        // Skips if we are not listening
        // Optional binding since `SCNetworkReachabilityCreateWithName` returns an optional object
        guard isListening else { return }
        
        // Remove callback and dispatch queue
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        isListening = false
        callback = nil
        
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), observer, nil, nil)
    }
}

extension Notification.Name {
    /// A notification which can be used to receive WiFi SSID changes separately to the callback closure
    public static let currentWiFiSSIDChanged = Notification.Name("current_wifi_ssid_changed")
}
