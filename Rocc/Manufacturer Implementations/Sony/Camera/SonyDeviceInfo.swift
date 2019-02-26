//
//  SonyDeviceInfo.swift
//  Rocc
//
//  Created by Simon Mitchell on 12/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

internal struct PlayMemoriesApp {
    
    let name: String
    
    let version: String
    
    init?(dictionary: [AnyHashable : Any]) {
        guard let name = dictionary["X_PlayMemoriesCameraApps_AppName"] as? String else {
            return nil
        }
        guard let version = dictionary["X_PlayMemoriesCameraApps_AppVersion"] as? String else {
            return nil
        }
        self.name = name
        self.version = version
    }
}

internal struct SonyDeviceInfo {
    
    let model: SonyCameraDevice.Model?
    
    let firmwareVersion: String?
    
    let lensModelName: String?
    
    let installedPlayMemoriesApps: [PlayMemoriesApp]
    
    init(dictionary: [AnyHashable : Any]) {
        
        if let modelString = dictionary["X_ModelName"] as? String {
            model = SonyCameraDevice.Model(rawValue: modelString)
        } else {
            model = nil
        }
        
        if let firmwareString = dictionary["X_FirmwareVersion"] as? String {
            firmwareVersion = firmwareString
        } else {
            firmwareVersion = nil
        }
        
        if let lensModel = dictionary["X_LensModelName"] as? String {
            lensModelName = lensModel
        } else {
            lensModelName = nil
        }
        
        if let apps = dictionary["X_InstalledPlayMemoriesCameraApps"] as? [[AnyHashable : Any]] {
            installedPlayMemoriesApps = apps.compactMap({ PlayMemoriesApp(dictionary: $0) })
        } else {
            installedPlayMemoriesApps = []
        }
    }
}
