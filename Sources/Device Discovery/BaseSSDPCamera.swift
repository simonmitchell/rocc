//
//  SonyCameramera.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

/// Common base class for all Sony cameras
class BaseSSDPCamera {
    
    let udn: String?
        
    let services: [UPnPService]?
    
    let manufacturerURL: URL?
    
    public var identifier: String
    
    var manufacturer: Manufacturer?
    
    var name: String?
    
    init(dictionary: [AnyHashable : Any]) throws {
                
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
        
        name = dictionary["friendlyName"] as? String
        if let manufacturerString = dictionary["manufacturer"] as? String {
            manufacturer = Manufacturer(rawValue: manufacturerString)
        }
    }
}
