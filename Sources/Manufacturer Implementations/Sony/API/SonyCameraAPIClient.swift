//
//  SonyCameraApiClient.swift
//  Rocc
//
//  Created by Simon Mitchell on 25/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

internal class SonyCameraAPIClient {
    
    let camera: CameraClient?
    
    let avContent: AVContentClient?
    
    let system: SystemClient?
    
    internal init(apiInfo: SonyAPICameraDevice.ApiDeviceInfo) {
        
        self.camera = CameraClient(apiInfo: apiInfo)
        self.avContent = AVContentClient(apiInfo: apiInfo)
        self.system = SystemClient(apiInfo: apiInfo)
    }
}
