//
//  FocusMode+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 10/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension Focus.Mode.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .focusMode
        case .canon:
            //TODO: [Canon] Implement
            return .focusModeCanonEOS
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let intValue = value.toInt else { return nil }
            switch intValue {
            case 0x0001:
                self = .manual
            case 0x0002:
                self = .autoSingle
            case 0x8004:
                self = .autoContinuous
            case 0x8005:
                self = .auto
            case 0x8006:
                self = .directManual
            case 0x8009:
                self = .powerFocus
            default:
                return nil
            }
        case .canon:
            guard let intValue = value.toInt else { return nil }
            switch intValue {
            case 0x0000:
                self = .autoSingle
            case 0x0001:
                self = .autoContinuous // Called AI Servo on Canon
            case 0x0002:
                self = .autoFocusAuto
            case 0x0003:
                self = .manual
            default:
                return nil
            }
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            switch self {
            case .auto:
                return Word(0x8005)
            case .autoSingle:
                return Word(0x0002)
            case .autoContinuous:
                return Word(0x8004)
            case .directManual:
                return Word(0x8006)
            case .manual:
                return Word(0x0001)
            case .powerFocus:
                return Word(0x8009)
            case .autoFocusAuto:
                return Word(0x0000) // Not supported on Sony cameras
            }
        case .canon:
            switch self {
            case .auto, .powerFocus, .directManual:
                return DWord(0x0000) // Not supported on Canon cameras
            case .autoSingle:
                return DWord(0x0000)
            case .autoContinuous:
                return DWord(0x0001)
            case .autoFocusAuto:
                return DWord(0x0002)
            case .manual:
                return DWord(0x0003)
            }
        }
    }
}
