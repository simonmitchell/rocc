//
//  StillFormat+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/02/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension StillCapture.Format.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .stillFormat
        case .canon:
            //TODO: [Canon] Implement
            return .stillFormat
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let intValue = value.toInt else { return nil }
            switch intValue {
            case 0x01:
                self = .raw
            case 0x02:
                self = .rawAndJpeg
            case 0x03:
                self = .jpeg("")
            case 0x04:
                self = .rawAndHeif
            case 0x05:
                self = .heif
            default:
                return nil
            }
        case .canon:
            //TODO: [Canon] Implement
            return nil
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            switch self {
            case .raw:
                return Byte(0x01)
            case .rawAndJpeg:
                return Byte(0x02)
            case .jpeg(_):
                return Byte(0x03)
            case .rawAndHeif:
                return Byte(0x04)
            case .heif:
                return Byte(0x05)
            }
        case .canon:
            //TODO: [Canon] Implement
            return Byte(9)
        }
    }
}
