//
//  ExposureMode+SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension Exposure.Mode.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .exposureProgramMode
        case .canon:
            //TODO: [Canon] Implement
            return .exposureProgramMode
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let binaryInt = value.toInt else {
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
            case 0x00048001:
                self = .superiorAuto
            case 0x00068041:
                self = .panorama
            case 0x00088080:
                self = .highFrameRateProgrammedAuto
            case 0x00088081:
                self = .highFrameRateAperturePriority
            case 0x00088082:
                self = .highFrameRateShutterPriority
            case 0x00088083:
                self = .highFrameRateManual
            case 0x00000007:
                self = .scene(.portrait)
            case 0x00058011:
                self = .scene(.sport)
            case 0x00058012:
                self = .scene(.sunset)
            case 0x00058013:
                self = .scene(.night)
            case 0x00058014:
                self = .scene(.landscape)
            case 0x00058015:
                self = .scene(.macro)
            case 0x00058016:
                self = .scene(.handheldTwilight)
            case 0x00058017:
                self = .scene(.nightPortrait)
            case 0x00058018:
                self = .scene(.antiMotionBlur)
            case 0x00058019:
                self = .scene(.pet)
            case 0x0005801a:
                self = .scene(.food)
            case 0x0005801b:
                self = .scene(.fireworks)
            case 0x0005801c:
                self = .scene(.highSensitivity)
            default:
                var byteBuffer = ByteBuffer()
                byteBuffer.appendValue(value, ofType: .uint32)
                print("[EXPOSURE MODE] Unknown exposure mode: \(byteBuffer.toHex)")
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
            case .panorama:
                return DWord(0x00068041)
            case .superiorAuto:
                return DWord(0x00048001)
            case .highFrameRateProgrammedAuto:
                return DWord(0x00088080)
            case .highFrameRateAperturePriority:
                return DWord(0x00088081)
            case .highFrameRateShutterPriority:
                return DWord(0x00088082)
            case .highFrameRateManual:
                return DWord(0x00088083)
            case .scene(let scene):
                switch scene {
                case .portrait:
                    return DWord(0x00000007)
                case .sport:
                    return DWord(0x00058011)
                case .sunset:
                    return DWord(0x00058012)
                case .night:
                    return DWord(0x00058013)
                case .landscape:
                    return DWord(0x00058014)
                case .macro:
                    return DWord(0x00058015)
                case .handheldTwilight:
                    return DWord(0x00058016)
                case .nightPortrait:
                    return DWord(0x00058017)
                case .antiMotionBlur:
                    return DWord(0x00058018)
                case .pet:
                    return DWord(0x00058019)
                case .food:
                    return DWord(0x0005801a)
                case .fireworks:
                    return DWord(0x0005801b)
                case .highSensitivity:
                    return DWord(0x0005801c)
                }
            }
        case .canon:
            //TODO: [Canon] Implement
            return DWord(0)
        }
    }
}

extension Exposure.Mode.DialControl.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .exposureProgramModeControl
        case .canon:
            //TODO: [Canon] Implement
            return .exposureProgramModeControl
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        
        switch manufacturer {
        case .sony:
            guard let binaryInt = value.toInt else {
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
        case .canon:
            return nil
            //TODO: [Canon] Implement
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            switch self {
            case .app:
                return Byte(0x01)
            case .camera:
                return Byte(0x00)
            }
        case .canon:
            return Byte(0)
            //TODO: [Canon] Implement
        }
    }
}
