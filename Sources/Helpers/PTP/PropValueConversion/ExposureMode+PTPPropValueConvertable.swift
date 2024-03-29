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
            return .autoExposureModeCanonEOS
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
            guard let binaryInt = value.toInt else {
                return nil
            }
            
            switch binaryInt {
            case 0x00:
                self = .intelligentAuto // TODO: [Canon] Check this!
            case 0x01:
                self = .programmedAuto
            case 0x02:
                self = .shutterPriority
            case 0x03:
                self = .aperturePriority
            case 0x04:
                self = .manual
            case 0x05:
                self = .autoDepthOfField
            case 0x06:
                self = .manualDepthOfField
            case 0x07:
                self = .bulb // TODO: [Canon] BULB, will need to figure out how this differs from other manufacturers
            case 0x65:
                self = .manual2
            case 0x66:
                self = .scene(.far)
            case 0x67:
                self = .fastShutter
            case 0x68:
                self = .slowShutter
            case 0x69:
                self = .scene(.night)
            case 0x6a:
                self = .effect(.grayScale)
            case 0x6b:
                self = .effect(.sepia)
            case 0x6d:
                self = .spot
            case 0x6e:
                self = .scene(.macro)
            case 0x6f:
                self = .effect(.blackAndWhite)
            case 0x70:
                self = .effect(.panFocus)
            case 0x71:
                self = .effect(.vivid)
            case 0x72:
                self = .effect(.neutral)
            case 0x73:
                self = .flashOff
            case 0x74:
                self = .longShutter
            case 0x75:
                self = .scene(.superMacro)
            case 0x76:
                self = .scene(.foliage)
            case 0x77:
                self = .scene(.indoor)
            case 0x78:
                self = .scene(.fireworks)
            case 0x79:
                self = .scene(.beach)
            case 0x7a:
                self = .scene(.underwater)
            case 0x7b:
                self = .scene(.snow)
            case 0x7c:
                self = .scene(.pet)
            case 0x7d:
                self = .scene(.nightSnapshot)
            case 0x7e:
                self = .scene(.digitalMacro)
            case 0x7f:
                self = .effect(.myColours)
            case 0x80:
                self = .photoInMovie
            default:
                var byteBuffer = ByteBuffer()
                byteBuffer.appendValue(value, ofType: .uint16)
                print("[EXPOSURE MODE] Unknown exposure mode: \(byteBuffer.toHex)")
                return nil
            }
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
                case .digitalMacro:
                    return DWord(0) // Doesn't exist in Sony cameras
                case .superMacro:
                    return DWord(0) // Doesn't exist in Sony cameras
                case .nightSnapshot:
                    return DWord(0) // Doesn't exist in Sony cameras
                case .far:
                    return DWord(0) // Doesn't exist in Sony cameras
                case .foliage:
                    return DWord(0) // Doesn't exist in Sony cameras
                case .indoor:
                    return DWord(0) // Doesn't exist in Sony cameras
                case .beach:
                    return DWord(0) // Doesn't exist in Sony cameras
                case .underwater:
                    return DWord(0) // Doesn't exist in Sony cameras
                case .snow:
                    return DWord(0) // Doesn't exist in Sony cameras
                }
            case .manual2:
                return DWord(0) // Doesn't exist in Sony cameras
            case .autoDepthOfField:
                return DWord(0) // Doesn't exist in Sony cameras
            case .manualDepthOfField:
                return DWord(0) // Doesn't exist in Sony cameras
            case .flashOff:
                return DWord(0) // Doesn't exist in Sony cameras
            case .bulb:
                return DWord(0) // Doesn't exist in Sony cameras
            case .longShutter:
                return DWord(0) // Doesn't exist in Sony cameras
            case .spot:
                return DWord(0) // Doesn't exist in Sony cameras
            case .photoInMovie:
                return DWord(0) // Doesn't exist in Sony cameras
            case .effect(_):
                return DWord(0) // Doesn't exist in Sony cameras
            case .fastShutter:
                return DWord(0) // Doesn't exist in Sony cameras
            case .slowShutter:
                return DWord(0) // Doesn't exist in Sony cameras
            }
            
        case .canon:
            switch self {
            case .programmedAuto:
                return Word(0x01)
            case .aperturePriority:
                return Word(0x03)
            case .shutterPriority:
                return Word(0x02)
            case .manual:
                return Word(0x04)
            case .manual2:
                return Word(0x65)
            case .panorama:
                return Word(0) // Doesn't exist in Canon cameras
            case .videoProgrammedAuto:
                return Word(0) // Doesn't exist in Canon cameras
            case .videoAperturePriority:
                return Word(0) // Doesn't exist in Canon cameras
            case .videoShutterPriority:
                return Word(0) // Doesn't exist in Canon cameras
            case .videoManual:
                return Word(0) // Doesn't exist in Canon cameras
            case .slowAndQuickProgrammedAuto:
                return Word(0) // Doesn't exist in Canon cameras
            case .slowAndQuickAperturePriority:
                return Word(0) // Doesn't exist in Canon cameras
            case .slowAndQuickShutterPriority:
                return Word(0) // Doesn't exist in Canon cameras
            case .slowAndQuickManual:
                return Word(0) // Doesn't exist in Canon cameras
            case .intelligentAuto:
                return Word(0x00)
            case .superiorAuto:
                return Word(0) // Doesn't exist in Canon cameras
            case .highFrameRateProgrammedAuto:
                return Word(0) // Doesn't exist in Canon cameras
            case .highFrameRateAperturePriority:
                return Word(0) // Doesn't exist in Canon cameras
            case .highFrameRateShutterPriority:
                return Word(0) // Doesn't exist in Canon cameras
            case .highFrameRateManual:
                return Word(0) // Doesn't exist in Canon cameras
            case .autoDepthOfField:
                return Word(0x05)
            case .manualDepthOfField:
                return Word(0x06)
            case .flashOff:
                return Word(0x73)
            case .bulb:
                return Word(0x07)
            case .longShutter:
                return Word(0x74)
            case .spot:
                return Word(0x6d)
            case .photoInMovie:
                return Word(0x80)
            case .scene(let scene):
                switch scene {
                case .portrait:
                    return Word(0x6c)
                case .sport:
                    return Word(0) // Doesn't exist in Canon cameras?
                case .sunset:
                    return Word(0) // Doesn't exist in Canon cameras
                case .night:
                    return Word(0x69)
                case .landscape:
                    return Word(0) // Doesn't exist in Canon cameras
                case .macro:
                    return Word(0x6e)
                case .digitalMacro:
                    return Word(0x7e)
                case .superMacro:
                    return Word(0x75)
                case .handheldTwilight:
                    return Word(0) // Doesn't exist in Canon cameras
                case .nightPortrait:
                    return Word(0) // Doesn't exist in Canon cameras
                case .nightSnapshot:
                    return Word(0x7d)
                case .antiMotionBlur:
                    return Word(0) // Doesn't exist in Canon cameras
                case .pet:
                    return Word(0x7c)
                case .food:
                    return Word(0) // Doesn't exist in Canon cameras
                case .fireworks:
                    return Word(0x78)
                case .highSensitivity:
                    return Word(0) // Doesn't exist in Canon cameras
                case .far:
                    return Word(0x66)
                case .foliage:
                    return Word(0x76)
                case .indoor:
                    return Word(0x77)
                case .beach:
                    return Word(0x79)
                case .underwater:
                    return Word(0x7a)
                case .snow:
                    return Word(0x7b)
                }
            case .effect(let effect):
                switch effect {
                case .blackAndWhite:
                    return Word(0x6f)
                case .grayScale:
                    return Word(0x6a)
                case .neutral:
                    return Word(0x72)
                case .panFocus:
                    return Word(0x70)
                case .sepia:
                    return Word(0x6b)
                case .vivid:
                    return Word(0x71)
                case .myColours:
                    return Word(0x7f)
                }
            case .fastShutter:
                return Word(0x67)
            case .slowShutter:
                return Word(0x68)
            }
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
