//
//  ShutterSpeed+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

// Some Canon values kindly donated by libgphoto2: https://github.com/gphoto/libgphoto2/blob/707c50902865abfe2d8a996c362345d06a221243/camlibs/canon/canon.h#L176

extension ShutterSpeed: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .shutterSpeed
        case .canon:
            return .shutterSpeedCanonEOS
            //TODO: [Canon] Implement
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {

        guard let binaryInt = value.toInt else {
            return nil
        }

        switch manufacturer {
        case .sony:
            var buffer = ByteBuffer()
            buffer.append(DWord(binaryInt))
            guard let denominator = buffer[word: 0] else {
                return nil
            }
            guard let numerator = buffer[word: 2] else {
                return nil
            }
            
            self.denominator = Double(denominator)
            self.numerator = Double(numerator)
        case .canon:
            switch binaryInt {
            case 0x04:
                self = .bulb
            case 0x10:
                self = .init(numerator: 30, denominator: 1)
            case 0x13:
                self = .init(numerator: 25, denominator: 1)
            case 0x15:
                self = .init(numerator: 20, denominator: 1)
            case 0x18:
                self = .init(numerator: 15, denominator: 1)
            case 0x1b:
                self = .init(numerator: 13, denominator: 1)
            case 0x1d:
                self = .init(numerator: 10, denominator: 1)
            case 0x20:
                self = .init(numerator: 8, denominator: 1)
            case 0x23:
                self = .init(numerator: 6, denominator: 1)
            case 0x25:
                self = .init(numerator: 5, denominator: 1)
            case 0x28:
                self = .init(numerator: 4, denominator: 1)
            case 0x2b:
                self = .init(numerator: 3.2, denominator: 1)
            case 0x2d:
                self = .init(numerator: 2.5, denominator: 1)
            case 0x30:
                self = .init(numerator: 2, denominator: 1)
            case 0x32:
                self = .init(numerator: 1.6, denominator: 1)
            case 0x35:
                self = .init(numerator: 1.3, denominator: 1)
            case 0x38:
                self = .init(numerator: 1, denominator: 1)
            case 0x3b:
                self = .init(numerator: 0.8, denominator: 1)
            case 0x3d:
                self = .init(numerator: 0.6, denominator: 1)
            case 0x40:
                self = .init(numerator: 0.5, denominator: 1)
            case 0x43:
                self = .init(numerator: 0.4, denominator: 1)
            case 0x45:
                self = .init(numerator: 0.3, denominator: 1)
            case 0x48:
                self = .init(numerator: 1, denominator: 4)
            case 0x4b:
                self = .init(numerator: 1, denominator: 5)
            case 0x4d:
                self = .init(numerator: 1, denominator: 6)
            case 0x50:
                self = .init(numerator: 1, denominator: 8)
            case 0x53:
                self = .init(numerator: 1, denominator: 10)
            case 0x55:
                self = .init(numerator: 1, denominator: 13)
            case 0x58:
                self = .init(numerator: 1, denominator: 15)
            case 0x5b:
                self = .init(numerator: 1, denominator: 20)
            case 0x5d:
                self = .init(numerator: 1, denominator: 25)
            case 0x60:
                self = .init(numerator: 1, denominator: 30)
            case 0x63:
                self = .init(numerator: 1, denominator: 40)
            case 0x65:
                self = .init(numerator: 1, denominator: 50)
            case 0x68:
                self = .init(numerator: 1, denominator: 60)
            case 0x6b:
                self = .init(numerator: 1, denominator: 80)
            case 0x6d:
                self = .init(numerator: 1, denominator: 100)
            case 0x70:
                self = .init(numerator: 1, denominator: 125)
            case 0x73:
                self = .init(numerator: 1, denominator: 160)
            case 0x75:
                self = .init(numerator: 1, denominator: 200)
            case 0x78:
                self = .init(numerator: 1, denominator: 250)
            case 0x7b:
                self = .init(numerator: 1, denominator: 320)
            case 0x7d:
                self = .init(numerator: 1, denominator: 400)
            case 0x80:
                self = .init(numerator: 1, denominator: 500)
            case 0x83:
                self = .init(numerator: 1, denominator: 640)
            case 0x85:
                self = .init(numerator: 1, denominator: 800)
            case 0x88:
                self = .init(numerator: 1, denominator: 1000)
            case 0x8b:
                self = .init(numerator: 1, denominator: 1250)
            case 0x8d:
                self = .init(numerator: 1, denominator: 1600)
            case 0x90:
                self = .init(numerator: 1, denominator: 2000)
            case 0x93:
                self = .init(numerator: 1, denominator: 2500)
            case 0x95:
                self = .init(numerator: 1, denominator: 3200)
            case 0x98:
                self = .init(numerator: 1, denominator: 4000)
            case 0x9a:
                self = .init(numerator: 1, denominator: 5000)
            case 0x9d:
                self = .init(numerator: 1, denominator: 6400)
            case 0xa0:
                self = .init(numerator: 1, denominator: 8000)
            default:
                //TODO: [Canon] Log missing value so we capture in logs
                return nil
            }
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            var data = ByteBuffer()
            // isBulb can be 0/0 or -1/-1 but PTP IP uses 0/0
            if isBulb {
                data.append(Word(0))
                data.append(Word(0))
            } else {
                data.append(Word(denominator))
                data.append(Word(numerator))
            }
            return data[dWord: 0] ?? DWord(value)
        case .canon:
            if isBulb {
                return DWord(0x04)
            }
            switch (numerator, denominator) {
            case (30, 1): return DWord(0x10)
            case (25, 1): return DWord(0x13)
            case (20, 1): return DWord(0x15)
            case (15, 1): return DWord(0x18)
            case (13, 1): return DWord(0x1b)
            case (10, 1): return DWord(0x1d)
            case (8, 1): return DWord(0x20)
            case (6, 1): return DWord(0x23)
            case (5, 1): return DWord(0x25)
            case (4, 1): return DWord(0x28)
            case (3.2, 1): return DWord(0x2b)
            case (2.5, 1): return DWord(0x2d)
            case (2, 1): return DWord(0x30)
            case (1.6, 1): return DWord(0x32)
            case (1.3, 1): return DWord(0x35)
            case (1, 1): return DWord(0x38)
            case (0.8, 1): return DWord(0x3b)
            case (0.6, 1): return DWord(0x3d)
            case (0.5, 1): return DWord(0x40)
            case (0.4, 1): return DWord(0x43)
            case (0.3, 1): return DWord(0x45)
            case (1, 4): return DWord(0x48)
            case (1, 5): return DWord(0x4b)
            case (1, 6): return DWord(0x4d)
            case (1, 8): return DWord(0x50)
            case (1, 10): return DWord(0x53)
            case (1, 13): return DWord(0x55)
            case (1, 15): return DWord(0x58)
            case (1, 20): return DWord(0x5b)
            case (1, 25): return DWord(0x5d)
            case (1, 30): return DWord(0x60)
            case (1, 40): return DWord(0x63)
            case (1, 50): return DWord(0x65)
            case (1, 60): return DWord(0x68)
            case (1, 80): return DWord(0x6b)
            case (1, 100): return DWord(0x6d)
            case (1, 125): return DWord(0x70)
            case (1, 160): return DWord(0x73)
            case (1, 200): return DWord(0x75)
            case (1, 250): return DWord(0x78)
            case (1, 320): return DWord(0x7b)
            case (1, 400): return DWord(0x7d)
            case (1, 500): return DWord(0x80)
            case (1, 640): return DWord(0x83)
            case (1, 800): return DWord(0x85)
            case (1, 1000): return DWord(0x88)
            case (1, 1250): return DWord(0x8b)
            case (1, 1600): return DWord(0x8d)
            case (1, 2000): return DWord(0x90)
            case (1, 2500): return DWord(0x93)
            case (1, 3200): return DWord(0x95)
            case (1, 4000): return DWord(0x98)
            case (1, 5000): return DWord(0x9a)
            case (1, 6400): return DWord(0x9d)
            case (1, 8000): return DWord(0xa0)
            default:
                // We should never get here assuming the mapping
                // in `init` matches the mapping in `value(for:)`
                // but we'll return a fairly standard shutter speed
                // just in-case (1/60)
                return DWord(0x6d)
            }
        }
    }
}
