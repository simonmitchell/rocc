//
//  StillQuality+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/02/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension StillCapture.Quality.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .stillQuality
        case .canon:
            //TODO: [Canon] Implement
            return .stillQuality
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let intValue = value.toInt else { return nil }
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
        case .canon:
            //TODO: [Canon] Implement
        return nil
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            switch self {
            case .extraFine:
                return Byte(0x01)
            case .fine:
                return Byte(0x02)
            case .standard:
                return Byte(0x03)
            }
        case .canon:
            return Byte(0)
            //TODO: [Canon] Implement
        }
    }
}
