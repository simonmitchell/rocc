//
//  ExposureSettingsLockStatus+SonyPTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 07/03/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension Exposure.SettingsLock.Status: SonyPTPPropValueConvertable {
    
    var type: PTP.DeviceProperty.DataType {
        return .uint8
    }
    
    var code: PTP.DeviceProperty.Code {
        return .exposureSettingsLock
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        
        guard let binaryInt = sonyValue.toInt else {
            return nil
        }
        
        switch binaryInt {
        case 0x01:
            self = .normal
        case 0x02:
            self = .standby
        case 0x03:
            self = .locked
        case 0x04:
            self = .buffering
        case 0x05:
            self = .recording
        default:
            return nil
        }
    }
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
        case .normal:
            return Byte(0x01)
        case .standby:
            return Byte(0x02)
        case .locked:
            return Byte(0x03)
        case .buffering:
            return Byte(0x04)
        case .recording:
            return Byte(0x05)
        }
    }
}
