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
            //TODO: [Canon] Implement
            return .exposureBiasCompensation
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
            //TODO: [Canon] Implement
            return nil
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            return Int16(value * 1000)
        case .canon:
            //TODO: [Canon] Implement
            return Int16(0)
        }
    }
}
