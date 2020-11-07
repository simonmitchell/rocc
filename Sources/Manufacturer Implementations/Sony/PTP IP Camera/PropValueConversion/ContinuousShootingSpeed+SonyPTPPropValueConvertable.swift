//
//  FocusMode+SonyPTPPropValueConvertable.swift.swift
//  Rocc
//
//  Created by Simon Mitchell on 10/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension ContinuousCapture.Speed.Value: SonyPTPPropValueConvertable {
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
        case .tenFps1Sec, .eightFps1Sec, .fiveFps2Sec, .twoFps5Sec, .regular:
            return SonyStillCaptureMode.continuous.sonyPTPValue
        case .high:
            return SonyStillCaptureMode.continuousHigh.sonyPTPValue
        case .highPlus:
            return SonyStillCaptureMode.continuousHighPlus.sonyPTPValue
        case .low:
            return SonyStillCaptureMode.continuousLow.sonyPTPValue
        case .s:
            return SonyStillCaptureMode.continuousS.sonyPTPValue
        }
    }
    
    var type: PTP.DeviceProperty.DataType {
        return .uint32
    }
    
    var code: PTP.DeviceProperty.Code {
        return .stillCaptureMode
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        // This is never needed as this property is never returned from the camera,
        // it is allocated based on the "single shooting mode" returned and defined there.
        return nil
    }
}
