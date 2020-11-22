//
//  StillQuality+SonyPTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/02/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension StillCapture.Quality.Value: SonyPTPPropValueConvertable {
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
        case .extraFine:
            return Byte(0x01)
        case .fine:
            return Byte(0x02)
        case .standard:
            return Byte(0x03)
        }
    }
    
    var type: PTP.DeviceProperty.DataType {
        return .uint8
    }
    
    var code: PTP.DeviceProperty.Code {
        return .stillQuality
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        guard let intValue = sonyValue.toInt else { return nil }
        switch intValue {
        case 0x01:
            self = .extraFine
        case 0x02:
            self = .fine
        case 0x03:
            self = .standard
        default:
            return nil
        }
    }
}
