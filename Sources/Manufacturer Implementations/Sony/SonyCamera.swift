//
//  SonyCameramera.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

/// Common base class for all Sony cameras
class SonyCamera {
    
    let udn: String?
    
    var modelEnum: SonyCamera.Model?
    
    let services: [UPnPService]?
    
    let manufacturerURL: URL?
    
    public var identifier: String
    
    init?(dictionary: [AnyHashable : Any]) {
        
        udn = dictionary["UDN"] as? String
        identifier = udn ?? NSUUID().uuidString

        if let serviceDictionaries = dictionary["serviceList"] as? [[AnyHashable : Any]] {
            services = serviceDictionaries.compactMap({ UPnPService(dictionary: $0) })
        } else {
            services = nil
        }
        
        if let manufacturerURLString = dictionary["manufacturerURL"] as? String {
            manufacturerURL = URL(string: manufacturerURLString)
        } else {
            manufacturerURL = nil
        }
    }
    
    func update(with deviceInfo: SonyDeviceInfo?) {
        
    }
}
