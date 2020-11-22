//
//  SSDPDeviceDiscoverer.swift
//  Rocc
//
//  Created by Simon Mitchell on 21/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

/// A class which enables the discovery of sony camera devices on the network
internal final class SSDPDeviceDiscoverer: UDPDeviceDiscoverer {
    
    required init(delegate: DeviceDiscovererDelegate) {
        super.init(
            initialMessages: [
                "M-SEARCH * HTTP/1.1\r\nHOST:\(SonyConstants.SSDP.address):\(SonyConstants.SSDP.port)\r\nMAN:\"ssdp:discover\"\r\nMX:\(SonyConstants.SSDP.mx)\r\nST:\(SonyConstants.SSDP.st)\r\n\r\n"
            ],
            address: SonyConstants.SSDP.address,
            port: SonyConstants.SSDP.port
        )
        self.delegate = delegate
    }
    
    override func parseDevice(from stringRepresentation: String, isCached: Bool, baseURL: URL, callback: @escaping (Bool) -> Void) {
        parseXML(string: stringRepresentation, baseURL: baseURL, isCached: isCached, callback: callback)
    }
    
    public func parseXML(string: String, baseURL: URL, isCached: Bool, callback: @escaping (Bool) -> Void) {
        
        parseCameraXML(string: string, baseURL: baseURL, isCached: isCached, callback: callback)
        parseTransferDeviceXML(string: string, baseURL: baseURL, isCached: isCached, callback: callback)
    }
    
    private func parseCameraXML(string: String, baseURL: URL, isCached: Bool, callback: @escaping (Bool) -> Void) {
        
        let parser = SSDPCameraParser(xmlString: string)
        parser.parse { [weak self] (cameraDevice, error) in
            
            guard let camera = cameraDevice else {
                callback(false)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            guard let device = cameraDevice else {
                callback(false)
                strongSelf.sendErrorToDelegate(error ?? CameraDiscoveryError.unknown)
                return
            }
            
            // Some cameras we can't get the base URL from the device description XML files, so set it here
            if camera.baseURL == nil {
                camera.baseURL = baseURL
            }
            
            callback(true)
            
            guard let digitalImagingService = device.services?.first(where: { $0.type?.isDigitalImaging == true }) else {
                strongSelf.sendDeviceToDelegate(camera, isCached: isCached)
                return
            }
            
            let digitalImagingURL = digitalImagingService.SCPDURL
            
            strongSelf.getFurtherInfoAt(path: digitalImagingURL, baseURL: baseURL, callback: { [weak strongSelf] (response, error) in
                
                guard let _strongSelf = strongSelf else {
                    return
                }
                
                guard let string = response?.string else {
                    _strongSelf.sendDeviceToDelegate(camera, isCached: isCached)
                    return
                }
                
                //TODO: Add back in!
//                let deviceInfoParser = SonyCameraDeviceInfoParser(xmlString: string)
//                deviceInfoParser.parse(completion: { [weak _strongSelf] (deviceInfo, error) in
//
//                    guard let __strongSelf = _strongSelf else {
//                        return
//                    }
//
//                    device.update(with: deviceInfo)
//                    __strongSelf.sendDeviceToDelegate(camera, isCached: isCached)
//                })
            })
            
            return
        }
    }
    
    private func parseTransferDeviceXML(string: String, baseURL: URL, isCached: Bool, callback: @escaping (Bool) -> Void) {
        
        let transferDeviceParser = SonyTransferDeviceParser(xmlString: string)
        transferDeviceParser.parse { [weak self] (transferDevice, error) in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let _transferDevice = transferDevice else {
                callback(false)
                strongSelf.sendErrorToDelegate(error ?? CameraDiscoveryError.unknown)
                return
            }
            
            _transferDevice.baseURL = baseURL
            _transferDevice.loadServiceInformation(completion: { [weak strongSelf] (error) in
                
                guard let _strongSelf = strongSelf else {
                    return
                }
                
                guard _transferDevice.contentDirectoryDevice?.actionFor(name: "Browse") != nil else {
                    callback(false)
                    _strongSelf.sendErrorToDelegate(error ?? CameraDiscoveryError.unknown)
                    return
                }
                
                callback(true)
                _strongSelf.sendDeviceToDelegate(_transferDevice, isCached: isCached)
            })
        }
    }
}
