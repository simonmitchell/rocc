//
//  FocusMode+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 10/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension FocusStatus: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .focusFound
        case .canon:
            return .focusFound
            //TODO: [Canon] Implement
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            switch self {
            case .focused:
                return Byte(2)
            case .focusing, .notFocussing, .failed:
                return Byte(1)
            }
        case .canon:
            return Byte(0)
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let intValue = value.toInt else { return nil }
            switch intValue {
            case 1:
                self = .notFocussing
            case 2, 3:
                self = .focused
            default:
                return nil
            }
        case .canon:
            return nil
        }
    }
}
