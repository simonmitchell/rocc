//
//  SonyDeviceDiscoverer.swift
//  Rocc
//
//  Created by Simon Mitchell on 24/10/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import os

extension SonyTransferDevice {
    
    func updated(with deviceInfo: SonyDeviceInfo?) -> SonyTransferDevice {
        
        let updatedSelf = self
        
        // Keep name if modelEnum currently nil as user has renamed camera!
        updatedSelf.name = model == nil ? name : (deviceInfo?.model?.friendlyName ?? name)
        updatedSelf.model = deviceInfo?.model ?? model
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
        if let deviceInfoService = services.first(where: { $0.type == .sonyDigitalImaging }) {
            
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

