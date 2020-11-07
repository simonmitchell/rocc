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
    
    let model: SonyCamera.Model?
    
    let firmwareVersion: String?
    
    let lensModelName: String?
    
    let serverType: String?
    
    let serverVersion: String?
    
    let macAddress: String?
    
    let installedPlayMemoriesApps: [PlayMemoriesApp]
    
    init(dictionary: [AnyHashable : Any]) {
        
        if let modelString = dictionary["X_ModelName"] as? String {
            model = SonyCamera.Model(rawValue: modelString)
        } else {
            model = nil
        }
        
        firmwareVersion = dictionary["X_FirmwareVersion"] as? String
        lensModelName = dictionary["X_LensModelName"] as? String
        serverType = dictionary["X_ServerType"] as? String
        serverVersion = dictionary["X_ServerVersion"] as? String
        macAddress = dictionary["X_MacAddress"] as? String
        
        if let apps = dictionary["X_InstalledPlayMemoriesCameraApps"] as? [[AnyHashable : Any]] {
            installedPlayMemoriesApps = apps.compactMap({ PlayMemoriesApp(dictionary: $0) })
        } else {
            installedPlayMemoriesApps = []
        }
    }
}
