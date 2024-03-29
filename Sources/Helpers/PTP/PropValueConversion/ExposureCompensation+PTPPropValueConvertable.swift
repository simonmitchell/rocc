//
//  ExposureCompensation+SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension Exposure.Compensation.Value: PTPPropValueConvertable {

    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .exposureBiasCompensation
        case .canon:
            return .expCompensationCanon
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let binaryInt = value.toInt else {
                return nil
            }
            self.value = Double(binaryInt)/1000.0
        case .canon:
            guard let binaryInt = value.toInt else {
                return nil
            }
            switch binaryInt {
            case 0x10:
                self.value = 5.0 / 3.0
            case 0x0c:
                self.value = 1.5
            case 0x0b:
                self.value = 4.0 / 3.0
            case 0x08:
                self.value = 1
            case 0x05:
                self.value = 2.0 / 3.0
            case 0x04:
                self.value = 0.5
            case 0x03:
                self.value = 1.0 / 3.0
            case 0x00:
                self.value = 0
            case 0xfd:
                self.value = -1.0 / 3.0
            case 0xfc:
                self.value = -0.5
            case 0xfb:
                self.value = -2.0 / 3.0
            case 0xf8:
                self.value = -1
            case 0xf5:
                self.value = -4.0 / 3.0
            case 0xf4:
                self.value = -1.5
            case 0xf3:
                self.value = -5.0 / 3.0
            case 0xf0:
                self.value = -2
            default:
                return nil
            }
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            return Int16(value * 1000)
        case .canon:
            switch value {
            case (5.0 / 3.0):
                return Byte(0x0d)
            case 1.5:
                return Byte(0x0c)
            case (4.0 / 3.0):
                return Byte(0x0b)
            case 1.0:
                return Byte(0x08)
            case (2.0 / 3.0):
                return Byte(0x05)
            case 0.5:
                return Byte(0x04)
            case (1.0 / 3.0):
                return Byte(0x03)
            case 0:
                return Byte(0x00)
            case (-1.0 / 3.0):
                return Byte(0xfd)
            case -0.5:
                return Byte(0xfc)
            case (-2.0 / 3.0):
                return Byte(0xfb)
            case -1:
                return Byte(0xf8)
            case (-4.0 / 3.0):
                return Byte(0xf5)
            case -1.5:
                return Byte(0xf4)
            case (-5.0 / 3.0):
                return Byte(0xf3)
            case -2:
                return Byte(0xf0)
            default:
                return Byte(0x00)
            }
        }
    }
}
