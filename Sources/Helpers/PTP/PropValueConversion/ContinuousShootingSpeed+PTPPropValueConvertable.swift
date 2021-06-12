//
//  FocusMode+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 10/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension ContinuousCapture.Speed.Value: PTPPropValueConvertable {
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        
        switch manufacturer {
        case .sony:
            switch self {
            case .tenFps1Sec, .eightFps1Sec, .fiveFps2Sec, .twoFps5Sec, .regular:
                return SonyStillCaptureMode.continuous.value(for: manufacturer)
            case .high:
                return SonyStillCaptureMode.continuousHigh.value(for: manufacturer)
            case .highPlus:
                return SonyStillCaptureMode.continuousHighPlus.value(for: manufacturer)
            case .low:
                return SonyStillCaptureMode.continuousLow.value(for: manufacturer)
            case .s:
                return SonyStillCaptureMode.continuousS.value(for: manufacturer)
            }
        case .canon:
            //TODO: [Canon] Implement!
            return DWord(0)
        }
    }

    init?(values: [PTP.DeviceProperty.Code : PTPDevicePropertyDataType], manufacturer: Manufacturer) {
        // TODO: Implement
        return nil
    }
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .stillCaptureMode
        case .canon:
            //TODO: [Canon] Implement!
            return .stillCaptureMode
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        // This is never needed as this property is never returned from the camera,
        // it is allocated based on the "single shooting mode" returned and defined there.
        return nil
    }
}
