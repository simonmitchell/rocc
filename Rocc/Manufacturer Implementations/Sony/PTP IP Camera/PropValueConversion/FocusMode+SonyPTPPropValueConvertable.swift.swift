//
//  FocusMode+SonyPTPPropValueConvertable.swift.swift
//  Rocc
//
//  Created by Simon Mitchell on 10/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension Focus.Mode.Value: SonyPTPPropValueConvertable {
    
    var sonyPTPValue: PTPDevicePropertyDataType {
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
        }
    }
    
    var type: PTP.DeviceProperty.DataType {
        return .uint16
    }
    
    var code: PTP.DeviceProperty.Code {
        return .focusMode
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        guard let intValue = sonyValue.toInt else { return nil }
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
        default:
            return nil
        }
    }
}
