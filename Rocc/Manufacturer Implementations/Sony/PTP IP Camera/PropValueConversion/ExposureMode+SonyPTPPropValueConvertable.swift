//
//  ExposureMode+SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension Exposure.Mode.Value: SonyPTPPropValueConvertable {
    
    var type: PTP.DeviceProperty.DataType {
        return .uint32
    }
    
    var code: PTP.DeviceProperty.Code {
        return .exposureProgramMode
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        
        guard let binaryInt = sonyValue.toInt else {
            return nil
        }
        
        switch binaryInt {
        case 0x00010002:
            self = .programmedAuto
        case 0x00020003:
            self = .aperturePriority
        case 0x00030004:
            self = .shutterPriority
        case 0x000000001:
            self = .manual
        case 0x00078050:
            self = .videoProgrammedAuto
        case 0x00078051:
            self = .videoAperturePriority
        case 0x00078052:
            self = .videoShutterPriority
        case 0x00078053:
            self = .videoManual
        case 0x00098059:
            self = .slowAndQuickProgrammedAuto
        case 0x0009805a:
            self = .slowAndQuickAperturePriority
        case 0x0009805b:
            self = .slowAndQuickShutterPriority
        case 0x0009805c:
            self = .slowAndQuickManual
        case 0x00048000:
            self = .intelligentAuto
        default:
            return nil
        }
    }
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
        case .programmedAuto:
            return DWord(0x00010002)
        case .aperturePriority:
            return DWord(0x00020003)
        case .shutterPriority:
            return DWord(0x00030004)
        case .manual:
            return DWord(0x000000001)
        case .videoProgrammedAuto:
            return DWord(0x00078050)
        case .videoAperturePriority:
            return DWord(0x00078051)
        case .videoShutterPriority:
            return DWord(0x00078052)
        case .videoManual:
            return DWord(0x00078053)
        case .slowAndQuickProgrammedAuto:
            return DWord(0x00098059)
        case .slowAndQuickAperturePriority:
            return DWord(0x0009805a)
        case .slowAndQuickShutterPriority:
            return DWord(0x0009805b)
        case .slowAndQuickManual:
            return DWord(0x0009805c)
        case .intelligentAuto:
            return DWord(0x00048000)
        case .superiorAuto:
            return DWord(0)
        }
    }
}

extension Exposure.Mode.DialControl.Value: SonyPTPPropValueConvertable {
    
    var type: PTP.DeviceProperty.DataType {
        return .uint8
    }
    
    var code: PTP.DeviceProperty.Code {
        return .exposureProgramModeControl
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        
        guard let binaryInt = sonyValue.toInt else {
            return nil
        }
        
        switch binaryInt {
        case 0x01:
            self = .app
        case 0x00:
            self = .camera
        default:
            return nil
        }
    }
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
        case .app:
            return Byte(0x01)
        case .camera:
            return Byte(0x00)
        }
    }
}
