//
//  ISOValue+SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension WhiteBalance.Mode: SonyPTPPropValueConvertable {
    
    var type: PTP.DeviceProperty.DataType {
        return .uint16
    }
    
    var code: PTP.DeviceProperty.Code {
        return .whiteBalance
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        
        guard let binaryInt = sonyValue.toInt else {
            return nil
        }
        
        switch binaryInt {
        case 0x0002:
            self = .auto
        case 0x0004:
            self = .daylight
        case 0x8011:
            self = .shade
        case 0x8010:
            self = .cloudy
        case 0x0006:
            self = .incandescent
        case 0x8001:
            self = .fluorescentWarmWhite
        case 0x8002:
            self = .fluorescentCoolWhite
        case 0x8003:
            self = .fluorescentDayWhite
        case 0x8004:
            self = .fluorescentDaylight
        case 0x0007:
            self = .flash
        case 0x8030:
            self = .underwaterAuto
        case 0x8012:
            self = .colorTemp
        case 0x8020:
            self = .c1
        case 0x8021:
            self = .c2
        case 0x8022:
            self = .c3
        default:
            return nil
        }
    }
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
        case .auto:
            return Word(0x0002)
        case .daylight:
            return Word(0x0004)
        case .shade:
            return Word(0x8011)
        case .cloudy:
            return Word(0x8010)
        case .incandescent:
            return Word(0x0006)
        case .fluorescentWarmWhite:
            return Word(0x8001)
        case .fluorescentCoolWhite:
            return Word(0x8002)
        case .fluorescentDayWhite:
            return Word(0x8003)
        case .fluorescentDaylight:
            return Word(0x8004)
        case .flash:
            return Word(0x0007)
        case .underwaterAuto:
            return Word(0x8030)
        case .colorTemp:
            return Word(0x8012)
        case .c1:
            return Word(0x8020)
        case .c2:
            return Word(0x8021)
        case .c3:
            return Word(0x8022)
        }
    }
}
