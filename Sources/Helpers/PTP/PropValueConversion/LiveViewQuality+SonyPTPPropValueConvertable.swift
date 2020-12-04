//
//  LiveViewQuality+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/07/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension LiveView.Quality: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .liveViewQuality
        case .canon:
            //TODO: [Canon] Implement
            return .liveViewQuality
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let binaryInt = value.toInt else {
                return nil
            }
            
            switch binaryInt {
            case 0x01:
                self = .displaySpeed
            case 0x02:
                self = .imageQuality
            default:
                return nil
            }
        case .canon:
            return nil
            //TODO: [Canon] Implement
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            switch self {
            case .displaySpeed:
                return Byte(0x01)
            case .imageQuality:
                return Byte(0x02)
            }
        case .canon:
            return Word(0)
            //TODO: [Canon] Implement
        }
    }
}
