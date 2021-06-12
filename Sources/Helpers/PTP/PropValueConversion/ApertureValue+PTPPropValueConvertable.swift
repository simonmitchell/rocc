//
//  ISOValue+SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension Aperture.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .fNumber
        case .canon:
            return .apertureCanonEOS
            //TODO: [Canon] Implement
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let binaryInt = value.toInt else {
                return nil
            }
            self.value = Double(binaryInt)/100.0
            decimalSeperator = nil
        case .canon:
            guard let binaryInt = value.toInt else {
                return nil
            }
            switch binaryInt {
            case 0x0b:
                // Extrapolated, this may be incorrect!
                self.value = 1.0
            case 0x0d:
                self.value = 1.2
            case 0x10:
                self.value = 1.4
            case 0x13:
                self.value = 1.6
            case 0x15:
                self.value = 1.8
            case 0x18:
                self.value = 2.0
            case 0x1b:
                self.value = 2.2
            case 0x1d:
                self.value = 2.5
            case 0x20:
                self.value = 2.8
            case 0x23:
                self.value = 3.2
            case 0x25:
                self.value = 3.5
            case 0x28:
                self.value = 4.0
            case 0x2b:
                self.value = 4.5
            case 0x2d:
                self.value = 5.0
            case 0x30:
                self.value = 5.6
            case 0x33:
                self.value = 6.3
            case 0x35:
                self.value = 7.1
            case 0x38:
                self.value = 8
            case 0x3b:
                self.value = 9
            case 0x3d:
                self.value = 10
            case 0x40:
                self.value = 11
            case 0x43:
                self.value = 13
            case 0x45:
                self.value = 14
            case 0x48:
                self.value = 16
            case 0x4b:
                self.value = 18
            case 0x4d:
                self.value = 20
            case 0x50:
                self.value = 22
            case 0x53:
                self.value = 25
            case 0x55:
                self.value = 29
            case 0x58:
                self.value = 32
            default:
                return nil
            }
            decimalSeperator = nil
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            return Word(value * 100)
        case .canon:
            switch value {
            // TODO: [Canon] Extrapolate lower values!
            case 1.2:
                return DWord(0x0d)
            case 1.4:
                return DWord(0x10)
            case 1.6:
                return DWord(0x13)
            case 1.8:
                return DWord(0x15)
            case 2.0:
                return DWord(0x18)
            case 2.2:
                return DWord(0x1b)
            case 2.5:
                return DWord(0x1d)
            case 2.8:
                return DWord(0x20)
            case 3.2:
                return DWord(0x23)
            case 3.5:
                return DWord(0x25)
            case 4.0:
                return DWord(0x28)
            case 4.5:
                return DWord(0x2b)
            case 5.0:
                return DWord(0x2d)
            case 5.6:
                return DWord(0x30)
            case 6.3:
                return DWord(0x33)
            case 7.1:
                return DWord(0x35)
            case 8:
                return DWord(0x38)
            case 9:
                return DWord(0x3b)
            case 10:
                return DWord(0x3d)
            case 11:
                return DWord(0x40)
            case 13:
                return DWord(0x43)
            case 14:
                return DWord(0x45)
            case 16:
                return DWord(0x48)
            case 18:
                return DWord(0x4b)
            case 20:
                return DWord(0x4d)
            case 22:
                return DWord(0x50)
            case 25:
                return DWord(0x53)
            case 29:
                return DWord(0x55)
            case 32:
                return DWord(0x58)
            default:
                return DWord(0x20) // Sensible default, perhaps log if we get here?
            }
        }
    }
}
