//
//  UDPDeviceDiscoverer.swift
//  Rocc
//
//  Created by Simon Mitchell on 24/10/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import os
import ThunderRequest
import SystemConfiguration

extension UserDefaults {
    
    /// A map between SSID and the URL on which the device can be accessed...
    /// I we load onto a particular network this will drastically speed up the device discovery time
    /// as we don't have to rely on the UDP client
    var ssidDeviceMap: [String : [URL]] {
        get {
            guard let dictionary = dictionary(forKey: "Rocc.CachedDevices") as? [String : [String]] else {
                return [:]
            }
            var map: [String: [URL]] = [:]
            dictionary.forEach { (keyValue) in
                let urls = keyValue.value.compactMap({ URL(string: $0) })
                map[keyValue.key] = urls
            }
            return map
        }
        set {
            set(newValue.mapValues({ $0.map({ $0.absoluteString }) }), forKey: "Rocc.CachedDevices")
        }
    }
}

/// A superclass for device discoverers that use UDP discovery
class UDPDeviceDiscoverer: DeviceDiscoverer {
    
    required init(delegate: DeviceDiscovererDelegate) {
        udpClient = UDPClient(initialMessages: [""], address: "")
        reachability = nil
        self.delegate = delegate
    }
    
    var isSearching: Bool {
        return udpClient.isRunning
    }
    
    let requestController = RequestController(baseURL: URL(string: "https://www.a.com")!)
    
    var delegate: DeviceDiscovererDelegate?
    
    private let udpClient: UDPClient
    
    private let reachability: Reachability?
        
    private let log: OSLog = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "UDPDeviceDiscoverer")
    
    init(initialMessages: [String], address: String, port: Int = 0) {
        
        self.udpClient = UDPClient(
            initialMessages: initialMessages,
            address: address,
            port: port
        )
        requestController.logger = Logger()
        
        reachability = Reachability(hostName: "www.google.co.uk")
    }
    
    func start() {
        start(ignoreSavedDevices: false)
    }
    
    func start(ignoreSavedDevices: Bool) {
        
        var isReachable: Bool = true
        
        Logger.log(message: "Starting device search", category: "UDPDeviceDiscoverer", level: .info)
        os_log("Starting device search", log: log, type: .info)
        
        // If we have a description URL cached for the current SSID, then first off try and hit that!
        if let currentSSID = Reachability.currentWiFiSSID, let urls = UserDefaults.standard.ssidDeviceMap[currentSSID], !ignoreSavedDevices {
            
            let urlString = urls.map({ $0.absoluteString }).joined(separator: ", ")
            Logger.log(message: "Have cached devices at \(urlString) for SSID \(currentSSID)", category: "UDPDeviceDiscoverer", level: .debug)
            os_log("Have cached devices at: %{public}@ for SSID %{public}@", log: log, type: .debug, urlString, currentSSID)
            
            urls.forEach { (url) in
                
                parseDeviceInfo(at: url, isCached: true) { [weak self] (error) in
                    guard let strongSelf = self else {
                        return
                    }
                    guard let _error = error else {
                        Logger.log(message: "Successfully fetched device info for cached device", category: "UDPDeviceDiscoverer", level: .debug)
                        os_log("Successfully fetched device info for cached device", log: strongSelf.log, type: .debug)
                        return
                    }
                    Logger.log(message: "Error fetching cached device info from url: \(_error.localizedDescription)", category: "UDPDeviceDiscoverer", level: .error)
                    os_log("Error fetching cached device info from url: %{public}@", log: strongSelf.log, type: .error, _error.localizedDescription)
                }
            }
        }
        
        if let reachability = reachability {
            var flags = SCNetworkReachabilityFlags()
            SCNetworkReachabilityGetFlags(reachability.reachability, &flags)
            isReachable = flags.contains(.reachable)
        }
        
        reachability?.networkChangeCallback = { [weak self] (ssid) in
            guard let self = self else { return }
            Logger.log(message: "Network did change: \(ssid ?? "null")", category: "UDPDeviceDiscoverer", level: .debug)
            os_log("Network did change %{public}@", log: self.log, type: .debug, ssid ?? "Unknown")
            self.requestController.cancelAllRequests()
            self.udpClient.finishSearching(with: { [weak self] in
                self?.start()
            })
        }
        
        #if os(iOS)
        guard isReachable else {
            
            Logger.log(message: "Device not reachable", category: "UDPDeviceDiscoverer", level: .debug)
            os_log("Device not reachable", log: log, type: .debug)
            
            reachability?.start(callback: { [weak self] (flags) in
                
                guard let self = self else { return }
                guard flags.contains(.reachable) else { return }
                self.requestController.cancelAllRequests()
                self.udpClient.finishSearching(with: { [weak self] in
                    self?.start()
                })
            })
            
            return
        }
        #endif
        
        // Start this so we also get network change callbacks!
        reachability?.start(callback: { (_) in
            
        })
        
        Logger.log(message: "Starting UDP device search on network: \(Reachability.currentWiFiSSID ?? "Unknown")", category: "UDPDeviceDiscoverer", level: .debug)
        os_log("Starting UDP device search on network: %{public}@", log: log, type: .debug, Reachability.currentWiFiSSID ?? "Unknown")
        
        udpClient.startSearching { [weak self] (device, error) in
            
            guard let self = self else { return }
            
            guard let device = device else {
                Logger.log(message: "Client did fail with error: \(error?.localizedDescription ?? "Unknown")", category: "UDPDeviceDiscoverer", level: .error)
                os_log("Client did fail with error: %{public}@", log: self.log, type: .error, error?.localizedDescription ?? "Unknown")
                self.delegate?.deviceDiscoverer(self, didError: error ?? CameraDiscoveryError.unknown)
                return
            }
            
            Logger.log(message: "Did find device at \(device.ddURL.absoluteString)", category: "UDPDeviceDiscoverer", level: .debug)
            os_log("Did find device at: %{public}@", log: self.log, type: .debug, device.ddURL.absoluteString)
            
            self.parseDeviceInfo(at: device.ddURL, isCached: false)
        }
    }
    
    func stop(_ callback: @escaping () -> Void) {
        
        Logger.log(message: "Stopping search for devices", category: "UDPDeviceDiscoverer", level: .debug)
        os_log("Stopping search for devices", log: log, type: .debug)
        
        requestController.cancelAllRequests()
        reachability?.stop()
        udpClient.finishSearching(with: callback)
    }
    
    private func parseDeviceInfo(at url: URL, isCached: Bool, callback: ((_ error: Error?) -> Void)? = nil) {
        
        let lastPathComponent = url.lastPathComponent
        let baseURL = url.deletingLastPathComponent()
        
        Logger.log(message: "Requesting device info", category: "UDPDeviceDiscoverer", level: .debug)
        os_log("Requesting device info", log: log, type: .debug)
        
        let currentSSID = Reachability.currentWiFiSSID
        
        requestController.sharedBaseURL = baseURL
        requestController.request(lastPathComponent, method: .GET) { [weak self] (response, error) in
            
            guard let strongSelf = self else { return }
            
            guard let stringResponse = response?.string else {
                Logger.log(message: "Failed to get device info with error: \(error?.localizedDescription ?? "Unknown")", category: "UDPDeviceDiscoverer", level: .error)
                os_log("Failed to get device info with error: %{public}@", log: strongSelf.log, type: .error, error?.localizedDescription ?? "Unknown")
                callback?(error ?? CameraDiscoveryError.unknown)
                strongSelf.delegate?.deviceDiscoverer(strongSelf, didError: error ?? CameraDiscoveryError.unknown)
                return
            }
            
            Logger.log(message: "Parsing device info", category: "UDPDeviceDiscoverer", level: .debug)
            os_log("Parsing device info", log: strongSelf.log, type: .debug)
            strongSelf.parseDevice(from: stringResponse, isCached: isCached, baseURL: baseURL, callback: { [weak strongSelf] parsed in
                
                // If we parsed a device, cache it's url!
                guard parsed else { return }
                
                callback?(nil)
                
                // Save the device URL to the cache for this SSID
                if let _currentSSID = currentSSID {
                    
                    var deviceMap = UserDefaults.standard.ssidDeviceMap
                    var devicesForSSID = deviceMap[_currentSSID] ?? []
                    if !devicesForSSID.contains(url) {
                        devicesForSSID.append(url)
                    }
                    deviceMap[_currentSSID] = devicesForSSID
                    if let _strongSelf = strongSelf {
                        Logger.log(message: "Caching device info url (\(url.absoluteString) for ssid: \(_currentSSID))", category: "UDPDeviceDiscoverer", level: .debug)
                        os_log("Caching device info url (%{public}@) for ssid: %{public}@", log: _strongSelf.log, type: .debug, url.absoluteString, _currentSSID)
                    }
                    UserDefaults.standard.ssidDeviceMap = deviceMap
                }
            })
        }
    }
    
    func getFurtherInfoAt(path: String, baseURL: URL, callback: @escaping (_ requestResponse: RequestResponse?, _ error: Error?) -> Void) {
        
        Logger.log(message: "Request further info from \(baseURL.appendingPathComponent(path).absoluteString)", category: "UDPDeviceDiscoverer", level: .debug)
        os_log("Request further info from %{public}@", log: log, type: .debug, baseURL.appendingPathComponent(path).absoluteString)
        
        requestController.sharedBaseURL = baseURL
        requestController.request(path, method: .GET) { (response, error) in
            callback(response, error)
        }
    }
    
    func parseDevice(from stringRepresentation: String, isCached: Bool, baseURL: URL, callback: @escaping (_ bool: Bool) -> Void) {
        
        
    }
    
    func sendErrorToDelegate(_ error: Error) {
        
        Logger.log(message: "Failed to parse device info with error: \(error.localizedDescription)", category: "UDPDeviceDiscoverer", level: .error)
        os_log("Failed to parse device info with error: %{public}@", log: log, type: .error, error.localizedDescription)
        delegate?.deviceDiscoverer(self, didError: error)
    }
    
    func sendDeviceToDelegate(_ camera: Camera, isCached: Bool) {
        
        Logger.log(message: "Letting delegate know about discovered device with name: \(camera.name ?? "Unknown")", category: "UDPDeviceDiscoverer", level: .debug)
        os_log("Letting delegate know about discovered device with name: %{public}@", log: log, type: .debug, camera.name ?? "Unknown")
        delegate?.deviceDiscoverer(self, discovered: camera, isCached: isCached)
    }
}
