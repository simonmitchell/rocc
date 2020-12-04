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
            return .focusMode
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
            //TODO: [Canon] Implement
            return nil
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
            }
        case .canon:
            return Word(0)
        }
    }
}
