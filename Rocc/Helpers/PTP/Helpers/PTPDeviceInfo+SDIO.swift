//
//  PTPDeviceInfo+SDIO.swift
//  Rocc
//
//  Created by Simon Mitchell on 06/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTP.DeviceInfo {
    
    mutating func update(with sdioExtDeviceInfo: PTP.SDIOExtDeviceInfo) {
        
        var supportedProperties = supportedDeviceProperties
        var supportedOpCodes = supportedOperations
        var supportedEvents = supportedEventCodes
        
        sdioExtDeviceInfo.supportedPropCodes.forEach { (propCode) in
            switch propCode & 0x7000 {
            case 0x1000:
                guard let opCode = PTP.CommandCode(rawValue: propCode), !supportedOpCodes.contains(opCode) else { return
                }
                supportedOpCodes.append(opCode)
            case 0x4000:
                guard let eventCode = PTP.EventCode(rawValue: propCode), !supportedEvents.contains(eventCode) else {
                    return
                }
                supportedEvents.append(eventCode)
            case 0x5000:
                guard let propertyCode = PTP.DeviceProperty.Code(rawValue: propCode), !supportedProperties.contains(propertyCode) else {
                    return
                }
                supportedProperties.append(propertyCode)
            default:
                return
            }
        }
        
        self.supportedDeviceProperties = supportedProperties
        self.supportedEventCodes = supportedEvents
        self.supportedOperations = supportedOpCodes
    }
}
