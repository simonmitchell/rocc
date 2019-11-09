//
//  ISOValue+SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension Exposure.Compensation.Value: SonyPTPPropValueConvertable {
    
    var type: PTP.DeviceProperty.DataType {
        return .int16
    }
    
    var code: PTP.DeviceProperty.Code {
        return .exposureBiasCompensation
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        
        guard let binaryInt = sonyValue.toInt else {
            return nil
        }
        
        value = Double(binaryInt)
    }
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        return Int16(value)
    }
}
