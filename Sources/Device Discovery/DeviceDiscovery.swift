//
//  DeviceDiscovery.swift
//  Rocc
//
//  Created by Simon Mitchell on 20/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

import SystemConfiguration
import os

/// A protocol for providing discovery messages to the shared camera discoverer.
///
/// This mirrors CameraDiscovererDelegate, but is only used internally for individual implementations of `DeviceDiscover`
protocol DeviceDiscovererDelegate {
    
    /// Called if the DeviceDiscoverer error for any reason. The error will be as descriptive as possible.
    ///
    /// - Parameters:
    ///   - discoverer: The discoverer object that errored.
    ///   - error: The error that occured.
    func deviceDiscoverer<T: DeviceDiscoverer>(_ discoverer: T, didError error: Error)
    
    /// Called when a camera device is discovered
    ///
    /// - Parameters:
    ///   - discoverer: The discoverer object that discovered a device.
    ///   - discovered: The device that it discovered.
    ///   - isCached: Whether the device was loaded from a cached xml discovery file.
    func deviceDiscoverer<T: DeviceDiscoverer>(_ discoverer: T, discovered device: Camera, isCached: Bool)

    func deviceDiscoverer<T: DeviceDiscoverer>(_ discoverer: T, didDetectNetworkChange ssid: String?)

}

/// A protocol to be implemented by device discovery implementations
protocol DeviceDiscoverer {
    
    /// The delegate which can be called to provide discovery information
    var delegate: DeviceDiscovererDelegate? { get set }
    
    init(delegate: DeviceDiscovererDelegate)
    
    /// Function which can be called to start the discoverer
    func start()
    
    /// Function which can be called to stop the discoverer
    ///
    /// - Parameter callback: A callback function which MUST be called
    /// once the discoverer has stopped
    func stop(_ callback: @escaping () -> Void)
    
    /// Whether the discoverer is currently searching
    var isSearching: Bool { get }
}

public enum CameraDiscoveryError: Error {
    case unknown
}

/// A protocol for receiving messages about camera discovery
public protocol CameraDiscovererDelegate {
    
    /// Called if the DeviceDiscoverer errored for any reason. The error will be as descriptive as possible.
    ///
    /// - Parameters:
    ///   - discoverer: The discoverer object that errored.
    ///   - error: The error that occured.
    func cameraDiscoverer(_ discoverer: CameraDiscoverer, didError error: Error)
    
    /// Called when a camera device is discovered
    ///
    /// - Note: if `isCached == true` you should be cautious auto-connecting to the camera (Especially if it's a transfer device) as cameras in transfer mode can advertise multiple connectivity methods and the correct one may not be returned until it's passed to you with `isCached == false`.
    ///
    /// - Parameters:
    ///   - discoverer: The discoverer object that discovered a device.
    ///   - discovered: The device that it discovered.
    ///   - isCached: Whether the camera was loaded from a cached xml file url.
    func cameraDiscoverer(_ discoverer: CameraDiscoverer, discovered device: Camera, isCached: Bool)

    func cameraDiscoverer(_ discoverer: CameraDiscoverer, didDetectNetworkChange ssid: String?)
}

/// A class which enables the discovery of cameras
public final class CameraDiscoverer {
    
    /// A delegate which will have methods called on it when cameras are discovered or an error occurs.
    public var delegate: CameraDiscovererDelegate?
    
    private var discoveredCameras: [(camera: Camera, isCached: Bool)] = []
    
    /// A map of cameras by the SSID the local device was connected to when they were discovered
    public var camerasBySSID: [String?: [(camera: Camera, isCached: Bool)]] = [:]
    
    var discoverers: [DeviceDiscoverer] = []
    
    /// Creates a new discoverer
    public init() {
        
        discoverers = [
            SonyCameraDiscoverer(delegate: self)
        ]
    }
    
    /// Starts the camera discoverer listening for cameras
    public func start() {
        discoveredCameras = []
        camerasBySSID = [:]
        discoverers.forEach({ $0.start() })
    }
    
    /// Stops the camera discoverer from listening for cameras
    ///
    /// - Parameter callback: A closure called when all discovery has been stopped
    public func stop(with callback: @escaping () -> Void) {
        
        let searchingDiscoverers = discoverers.filter({ $0.isSearching })
        guard !searchingDiscoverers.isEmpty else {
            callback()
            return
        }
        
        searchingDiscoverers.forEach { (discoverer) in
            
            discoverer.stop { [weak self] in
                guard let strongSelf = self else { return }
                guard strongSelf.discoverers.filter({ $0.isSearching }).isEmpty else {
                    return
                }
                callback()
            }
        }
    }
}

extension CameraDiscoverer: DeviceDiscovererDelegate {
    
    func deviceDiscoverer<T>(_ discoverer: T, discovered device: Camera, isCached: Bool) where T : DeviceDiscoverer {
        
        if let previouslyDiscoveredCamera = discoveredCameras.enumerated().first(where: {
            $0.element.camera.identifier == device.identifier
        }) {
            // If we went from non-cached, to cached, let the delegate know!
            if previouslyDiscoveredCamera.element.isCached && !isCached {
                discoveredCameras[previouslyDiscoveredCamera.offset] = (device, isCached)
                if var camerasForSSID = camerasBySSID[Reachability.currentWiFiSSID], let indexInCamerasForSSID = camerasForSSID.firstIndex(where: { $0.camera.identifier == device.identifier }) {
                    camerasForSSID[indexInCamerasForSSID] = (device, isCached)
                    camerasBySSID[Reachability.currentWiFiSSID] = camerasForSSID
                }
                delegate?.cameraDiscoverer(self, discovered: device, isCached: false)
            }
            return
        }
        
        camerasBySSID[Reachability.currentWiFiSSID, default: []].append((device, isCached))
        discoveredCameras.append((device, isCached))
        delegate?.cameraDiscoverer(self, discovered: device, isCached: isCached)
    }
    
    
    func deviceDiscoverer<T>(_ discoverer: T, didError error: Error) where T : DeviceDiscoverer {
        delegate?.cameraDiscoverer(self, didError: error)
    }

    func deviceDiscoverer<T>(_ discoverer: T, didDetectNetworkChange ssid: String?) where T : DeviceDiscoverer {
        delegate?.cameraDiscoverer(self, didDetectNetworkChange: ssid)
    }
}
