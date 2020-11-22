//
//  UPNPService.swift
//  Rocc
//
//  Created by Simon Mitchell on 24/02/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

internal struct UPnPService {
    
    enum `Type`: String {
        
        case canonEOSSystem = "urn:schemas-canon-com:service:ICPO-WFTEOSSystemService:1"
        case contentDirectory = "urn:schemas-upnp-org:service:ContentDirectory:1"
        case connectionManager = "urn:schemas-upnp-org:service:ConnectionManager:1"
        case sonyDigitalImaging = "urn:schemas-sony-com:service:DigitalImaging:1"
        case pushList = "urn:schemas-sony-com:service:XPushList:1"
        case scalarWebAPI = "urn:schemas-sony-com:service:ScalarWebAPI:1"
        
        var isDigitalImaging: Bool {
            let digitalImagingTypes: [Type] = [
                .sonyDigitalImaging,
                .canonEOSSystem
            ]
            return digitalImagingTypes.contains(self)
        }
    }
    
    let type: Type?
    
    let controlURL: String
    
    let eventSubURL: String?
    
    let SCPDURL: String
    
    let id: String?
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let scdpURL = dictionary["SCPDURL"] as? String else {
            return nil
        }
        guard let _controlURL = dictionary["controlURL"] as? String else {
            return nil
        }
        
        if let typeString = dictionary["serviceType"] as? String {
            type = Type(rawValue: typeString)
        } else {
            type = nil
        }
        id = dictionary["serviceId"] as? String
        SCPDURL = scdpURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        controlURL = _controlURL
        eventSubURL = dictionary["eventSubURL"] as? String
    }
}
