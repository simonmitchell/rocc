//
//  StillFormat+SonyPTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/02/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension StillCapture.Format.Value: SonyPTPPropValueConvertable {
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
        case .raw:
            return Byte(0x01)
        case .rawAndJpeg:
            return Byte(0x02)
        case .jpeg(_):
            return Byte(0x03)
        }
    }
    
    var type: PTP.DeviceProperty.DataType {
        return .uint8
    }
    
    var code: PTP.DeviceProperty.Code {
        return .stillFormat
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        guard let intValue = sonyValue.toInt else { return nil }
        switch intValue {
        case 0x01:
            self = .raw
        case 0x02:
            self = .rawAndJpeg
        case 0x03:
            self = .jpeg("")
        default:
            return nil
        }
    }
}
