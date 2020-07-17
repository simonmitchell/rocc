//
//  LiveViewQuality+SonyPTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/07/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension LiveView.Quality: SonyPTPPropValueConvertable {
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
        case .displaySpeed:
            return Byte(0x01)
        case .imageQuality:
            return Byte(0x02)
        }
    }
    
    var type: PTP.DeviceProperty.DataType {
        return .uint8
    }
    
    var code: PTP.DeviceProperty.Code {
        return .liveViewQuality
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        
        guard let binaryInt = sonyValue.toInt else {
            return nil
        }
        
        switch binaryInt {
        case 0x01:
            self = .displaySpeed
        case 0x02:
            self = .imageQuality
        default:
            return nil
        }
    }
}
