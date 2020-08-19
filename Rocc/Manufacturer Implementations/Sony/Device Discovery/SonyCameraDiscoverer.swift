//
//  SonyDeviceDiscoverer.swift
//  Rocc
//
//  Created by Simon Mitchell on 24/10/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import ThunderRequest
import os

extension SonyTransferDevice {
    
    func updated(with deviceInfo: SonyDeviceInfo?) -> SonyTransferDevice {
        
        let updatedSelf = self
        
        // Keep name if modelEnum currently nil as user has renamed camera!
        updatedSelf.name = modelEnum == nil ? name : (deviceInfo?.model?.friendlyName ?? name)
        updatedSelf.modelEnum = deviceInfo?.model ?? modelEnum
        if let modelEnum = deviceInfo?.model {
            updatedSelf.model = modelEnum.friendlyName
        }
        updatedSelf.firmwareVersion = deviceInfo?.firmwareVersion
        updatedSelf.remoteAppVersion = deviceInfo?.installedPlayMemoriesApps.first(
            where: {
                $0.name.lowercased() == "smart remote control" ||
                $0.name.lowercased() == "smart remote embedded" ||
                $0.name.lowercased().contains("smart remote")
            }
        )?.version
        
        return updatedSelf
    }
    
    func loadServiceInformation(completion: @escaping (_ error: Error?) -> Void) {
        
        guard let baseURL = baseURL else { return }
        
        guard let services = services else {
            completion(nil)
            return
        }
        
        var loadedDevice = self
        let requestController = RequestController(baseURL: baseURL)
        self.requestController = requestController
        self.requestController?.logger = Logger()
        
        // Get additional device info (Model, firmware version e.t.c.)
        if let deviceInfoService = services.first(where: { $0.type == .digitalImaging }) {
            
            requestController.request(deviceInfoService.SCPDURL, method: .GET) { [weak self] (response, error) in
                
                guard let this = self else { return }
                guard let xmlString = response?.string else {
                    this.loadTransferServices(completion: completion)
                    return
                }
                
                let deviceInfoParser = SonyCameraDeviceInfoParser(xmlString: xmlString)
                deviceInfoParser.parse(completion: { [weak this] (deviceInfo, _) in
                    
                    loadedDevice = loadedDevice.updated(with: deviceInfo)
                    this?.loadTransferServices(completion: completion)
                })
            }
            
        } else {
            loadTransferServices(completion: completion)
        }
    }
    
    private func loadTransferServices(completion: @escaping (_ error: Error?) -> Void) {
        
        let contentDirectoryService = services?.first(where: { $0.type == .contentDirectory })
        let contentPushService = services?.first(where: { $0.type == .pushList })
        
        guard contentDirectoryService != nil || contentPushService != nil else {
            completion(nil)
            return
        }
        
        // Load both content directory service and content push service
        loadDeviceFor(service: contentDirectoryService) { [weak self] (contentDirectoryDevice, contentDirectoryError) in
            guard let this = self else { return }
            this.contentDirectoryDevice = contentDirectoryDevice
            this.loadDeviceFor(service: contentPushService, completion: { [weak this] (pushDevice, pushDeviceError) in
                guard let _this = this else { return }
                _this.pushContentDevice = pushDevice
                guard _this.pushContentDevice == nil  && _this.contentDirectoryDevice == nil else {
                    completion(nil)
                    return
                }
                completion(contentDirectoryError ?? pushDeviceError)
            })
        }
    }
    
    /// Loads the UPnP device that represents a particular service
    ///
    /// - Parameters:
    ///   - service: The service that we should load the UPnP device for (From it's SCPDUrl
    ///   - completion: A closure called once we have loaded it
    func loadDeviceFor(service: UPnPService?, completion: @escaping (_ device: UPnPDevice?, _ error: Error?) -> Void) {
        
        guard let _service = service, let requestController = requestController else {
            completion(nil, nil)
            return
        }
        
        // Get connection manager info!
        requestController.request(_service.SCPDURL, method: .GET) { (response, error) in
            
            guard let xmlString = response?.string else {
                completion(nil, error ?? CameraDiscoveryError.unknown)
                return
            }
            
            let upnpDeviceParser = UPnPDeviceParser(xmlString: xmlString, type: .contentDirectory)
            upnpDeviceParser.parse(completion: { (upnpDevice, parseError) in
                
                guard let _upnpDevice = upnpDevice else {
                    completion(nil, parseError ?? CameraDiscoveryError.unknown)
                    return
                }
                
                completion(_upnpDevice, nil)
            })
        }
    }
}



/// A class which enables the discovery of sony camera devices on the network
internal final class SonyCameraDiscoverer: UDPDeviceDiscoverer {
    
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
        
        let parser = SonyCameraParser(xmlString: string)
        parser.parse { [weak self] (cameraDevice, error) in
            
            guard let camera = cameraDevice as? Camera else {
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
            
            guard let digitalImagingService = device.services?.first(where: { $0.type == .digitalImaging }) else {
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
                
                let deviceInfoParser = SonyCameraDeviceInfoParser(xmlString: string)
                deviceInfoParser.parse(completion: { [weak _strongSelf] (deviceInfo, error) in
                    
                    guard let __strongSelf = _strongSelf else {
                        return
                    }
                    
                    device.update(with: deviceInfo)
                    __strongSelf.sendDeviceToDelegate(camera, isCached: isCached)
                })
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
