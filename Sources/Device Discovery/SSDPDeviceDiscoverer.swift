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
        parser.parse { [weak self] result in
            
            guard let self = self else {
                return
            }
            
            guard case .success(let camera) = result else {
                callback(false)
                var error: Error = CameraDiscoveryError.unknown
                if case .failure(let parseError) = result {
                    error = parseError
                }
                self.sendErrorToDelegate(error)
                return
            }
            
            // Some cameras we can't get the base URL from the device description XML files, so set it here
            if camera.baseURL == nil {
                camera.baseURL = baseURL
            }
            
            callback(true)
            
            guard let digitalImagingService = camera.services?.first(where: { $0.type?.isDigitalImaging == true }) else {
                self.sendDeviceToDelegate(camera, isCached: isCached)
                return
            }
            
            let digitalImagingURL = digitalImagingService.SCPDURL
            
            self.getFurtherInfoAt(path: digitalImagingURL, baseURL: baseURL, callback: { [weak self] (response, error) in
                
                guard let self = self else {
                    return
                }
                
                guard let string = response?.string else {
                    self.sendDeviceToDelegate(camera, isCached: isCached)
                    return
                }
                
                let deviceInfoParser = SSDPCameraDeviceInfoParser(xmlString: string)
                deviceInfoParser.parse(completion: { [weak self] (result) in

                    guard let self = self else {
                        return
                    }
                    
                    if case .success(let deviceInfo) = result {
                        camera.update(with: deviceInfo)
                    }

                    self.sendDeviceToDelegate(camera, isCached: isCached)
                })
            })
            
            return
        }
    }
    
    private func parseTransferDeviceXML(string: String, baseURL: URL, isCached: Bool, callback: @escaping (Bool) -> Void) {
        
        let transferDeviceParser = SonyTransferDeviceParser(xmlString: string)
        transferDeviceParser.parse { [weak self] (result) in
            
            guard let strongSelf = self else {
                return
            }
            
            guard case .success(let transferDevice) = result else {
                callback(false)
                var error: Error = CameraDiscoveryError.unknown
                if case .failure(let resultError) = result {
                    error = resultError
                }
                strongSelf.sendErrorToDelegate(error)
                return
            }
            
            transferDevice.baseURL = baseURL
            transferDevice.loadServiceInformation(completion: { [weak strongSelf] (error) in
                
                guard let _strongSelf = strongSelf else {
                    return
                }
                
                guard transferDevice.contentDirectoryDevice?.actionFor(name: "Browse") != nil else {
                    callback(false)
                    _strongSelf.sendErrorToDelegate(error ?? CameraDiscoveryError.unknown)
                    return
                }
                
                callback(true)
                _strongSelf.sendDeviceToDelegate(transferDevice, isCached: isCached)
            })
        }
    }
}
