//
//  DeviceConnectivityNotifier.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/06/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import SystemConfiguration
import os.log

/// A delegate protocol used to provide connectivity notifications to a listener
public protocol DeviceConnectivityNotifierDelegate {
    
    /// Called when the notifier detected that the camera is no longer connected/available
    ///
    /// - Parameters:
    ///   - notifier: The notifier which detected the change
    ///   - device: The device which was disconnected
    func connectivityNotifier(_ notifier: DeviceConnectivityNotifier, didDisconnectFrom device: Camera)


    /// Called when the notifier detected that the socket was disconnected (either camera was disconnected, or the app slept for too long)
    ///
    /// - Parameters:
    ///   - notifier: The notifier which detected the change
    ///   - device: The device which was disconnected
    func connectivityNotifier(_ notifier: DeviceConnectivityNotifier, didSocketDisconnectFrom device: Camera)

    /// Called when the notifier detected that the camera was re-connected / made available again
    ///
    /// - Parameters:
    ///   - notifier: The notifier which detected the change
    ///   - device: The device which was reconnected
    func connectivityNotifier(_ notifier: DeviceConnectivityNotifier, didReconnectTo device: Camera)
}

/// A class for subscribing to events from a particular instance of a Camera.
///
/// This class will be entirely responsible for fetching up-to-date events from the camera and providing
/// them back to the callee through a delegate based (Or NotificationCenter if you wish) approach
public final class DeviceConnectivityNotifier {
    
    private let logger: OSLog = {
       return OSLog(subsystem: "Rocc", category: "DeviceConnectivity")
    }()
    
    /// A delegate which will be notified of connectivity changes to the camera
    public var delegate: DeviceConnectivityNotifierDelegate?
    
    /// The camera which we are receiving connectivity notifications for
    public let camera: Camera
    
    /// Creates a new connectivity notifier for a given camera
    ///
    /// - Parameters:
    ///   - camera: The camera to notify about connectivity changes for
    ///   - delegate: The delegate to notify about changes in connectivity
    public init(camera: Camera, delegate: DeviceConnectivityNotifierDelegate?) {
        
        self.delegate = delegate
        self.camera = camera
        self.isReachable = true
        camera.onDisconnected = { [weak self] in
            guard let self = self else { return }
            if let _ = self.reachability, let delegate = self.delegate {
                delegate.connectivityNotifier(self, didSocketDisconnectFrom: self.camera)
            }
        }
    }
    
    private var reachability: Reachability?
    
    /// Whether the camera is currently reachable
    public var isReachable: Bool?
    
    private var isListening: Bool = false
    
    private var initialSSID: String? 
    
    /// Starts listening for changes to the camera's connectivity.
    ///
    /// This uses a mixture of reachability and detections for the local device's SSID changing
    ///
    /// - Parameter sendInitialCallback: Whether to call delegate methods for the initially detected state
    public func startNotifying(sendInitialCallback: Bool = false) {
        
        var setupReachability: Reachability?
        
        if let ipAddress = camera.ipAddress {
            
            let localSock = sockaddr_in()
            setupReachability = Reachability(localAddress: localSock, socketAddress: ipAddress)
            
        } else if let baseURL = camera.baseURL {
            
            setupReachability = Reachability(hostName: baseURL.absoluteString)
        }
        
        guard let _reachability = setupReachability else {
            return
        }
        
        isListening = true
        reachability = _reachability
        initialSSID = Reachability.currentWiFiSSID

        os_log("Initial SSID %s", log: self.logger, type: .debug, String(describing: initialSSID))
        print("DEVICE_CONN_NOTIFIER INITIAL \(initialSSID)")

        reachability?.start(callback: { [weak self] (flags) in
            print("DEVICE_CONN_NOTIFIER A \(Reachability.currentWiFiSSID)")

            //self?.handle(flags: flags)
        })
        reachability?.networkChangeCallback = { [weak self] (ssid) in
            
            guard let self = self else { return }

            print("DEVICE_CONN_NOTIFIER B \(ssid)")
            
            guard ssid != self.initialSSID else {
                Logger.log(message: "Re-connected to device's SSID", category: "DeviceConnectivity", level: .debug)
                os_log("Re-connected to device's SSID %s", log: self.logger, type: .debug, String(describing: ssid))
                self.handle(reachable: true)
                return
            }
            
            Logger.log(message: "Disconnected from device's SSID", category: "DeviceConnectivity", level: .debug)
            os_log("Disconnected from device's SSID %s", log: self.logger, type: .debug, String(describing: ssid))
            self.handle(reachable: false)
        }
    }
    
    private var currentFlags: SCNetworkReachabilityFlags?
    
    private func handle(flags: SCNetworkReachabilityFlags) {
        
        guard flags != currentFlags else {
            return
        }
        
        currentFlags = flags
        
        if flags.contains(.reachable) && !flags.contains(.connectionRequired) {
            
            guard Reachability.currentWiFiSSID == initialSSID else {
                os_log("Reachable, but not connected to same WiFi network!", log: logger, type: .debug)
                return
            }
            
            Logger.log(message: "Reachable and no connection required", category: "DeviceConnectivity", level: .debug)
            os_log("Reachable and no connection required %s", log: logger, type: .debug, String(describing: initialSSID))
            
            camera.performFunction(Ping.perform, payload: nil) { [weak self] (error, _) in                
                self?.handle(reachable: error == nil)
            }
            
        } else if !flags.contains(.reachable) {
            
            if Reachability.currentWiFiSSID == initialSSID {
                os_log("Not reachable, but still connected to same WiFi network: %s!", log: logger, type: .debug, String(describing: initialSSID))
                //return
            }
            
            Logger.log(message: "Not reachable", category: "DeviceConnectivity", level: .debug)
            os_log("Not reachable", log: logger, type: .debug)
            camera.performFunction(Ping.perform, payload: nil) { [weak self] (error, _) in
                self?.handle(reachable: error == nil)
            }
        }
    }
    
    private func handle(reachable: Bool) {
        
        // Don't notify for initial connection!
        guard isReachable != nil else {
            isReachable = reachable
            return
        }
        
        // If hasn't changed, no point in calling!
        guard reachable != isReachable else { return }
        
        isReachable = reachable
        
        if reachable {
            delegate?.connectivityNotifier(self, didReconnectTo: camera)
        } else {
            delegate?.connectivityNotifier(self, didDisconnectFrom: camera)
        }
    }
    
    deinit {
        stop()
    }
    
    /// Stops listening for connectivity changes
    public func stop() {
        
        reachability?.stop()
        reachability = nil
    }
}

