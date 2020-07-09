//
//  SonyStillCaptureMode.swift
//  Rocc
//
//  Created by Simon Mitchell on 04/07/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

enum SonyStillCaptureMode: DWord, SonyPTPPropValueConvertable {
    
    case single = 0x00000001
    case continuousHighPlus = 0x00018010
    case continuousLow = 0x00018012
    case continuous = 0x00018015
    case continuousS = 0x00018014
    case continuousHigh = 0x00010002
    case singleBurstHigh = 0x00098032
    case singleBurstMedium = 0x00098031
    case singleBurstLow = 0x00098030
    case timer10 = 0x00038004
    case timer5 = 0x00038003
    case timer2 = 0x00038005
    case timer10_3 = 0x00088008
    case timer10_5 = 0x00088009
    case timer5_3 = 0x0008800c
    case timer5_5 = 0x0008800d
    case timer2_3 = 0x0008800e
    case timer2_5 = 0x0008800f
    case continuousBracket0_3_3 = 0x00048337
    case continuousBracket0_3_5 = 0x00048537
    case continuousBracket0_3_9 = 0x00048937
    case continuousBracket0_5_3 = 0x00048357
    case continuousBracket0_5_5 = 0x00048557
    case continuousBracket0_5_9 = 0x00048957
    case continuousBracket0_7_3 = 0x00048377
    case continuousBracket0_7_5 = 0x00048577
    case continuousBracket0_7_9 = 0x00048977
    case continuousBracket1_3 = 0x00048311
    case continuousBracket1_5 = 0x00048511
    case continuousBracket1_9 = 0x00048911
    case continuousBracket2_3 = 0x00048321
    case continuousBracket2_5 = 0x00048521
    case continuousBracket3_3 = 0x00048331
    case continuousBracket3_5 = 0x00048531
    case singleBracket0_3_3 = 0x00058336
    case singleBracket0_3_5 = 0x00058536
    case singleBracket0_3_9 = 0x00058936
    case singleBracket0_5_3 = 0x00058356
    case singleBracket0_5_5 = 0x00058556
    case singleBracket0_5_9 = 0x00058956
    case singleBracket0_7_3 = 0x00058376
    case singleBracket0_7_5 = 0x00058576
    case singleBracket0_7_9 = 0x00058976
    case singleBracket1_3 = 0x00058310
    case singleBracket1_5 = 0x00058510
    case singleBracket1_9 = 0x00058910
    case singleBracket2_3 = 0x00058320
    case singleBracket2_5 = 0x00058520
    case singleBracket3_3 = 0x00058330
    case singleBracket3_5 = 0x00058530
    case whiteBalanceBracketHigh = 0x00068028
    case whiteBalanceBracketLow = 0x00068018
    case droBracketHigh = 0x00078029
    case droBracketLow = 0x00078019
    
    var singleBracket: SingleBracketCapture.Bracket.Value? {
        return SingleBracketCapture.Bracket.Value(self)
    }
    
    var continuousBracket: ContinuousBracketCapture.Bracket.Value? {
        return ContinuousBracketCapture.Bracket.Value(self)
    }
    
    var continuousShootingMode: ContinuousCapture.Mode.Value? {
        switch self {
        case .continuous, .continuousS, .continuousLow, .continuousHigh, .continuousHighPlus:
            return .continuous
        default:
            return nil
        }
    }
    
    var continuousShootingSpeed: ContinuousCapture.Speed.Value? {
        switch self {
        case .continuous:
            return .regular
        case .continuousS:
            return .s
        case .continuousLow:
            return .low
        case .continuousHigh:
            return .high
        case .continuousHighPlus:
            return .highPlus
        default:
            return nil
        }
    }
    
    var timerDuration: TimeInterval {
        switch self {
        case .timer2, .timer2_3, .timer2_5:
            return 2.0
        case .timer5, .timer5_3, .timer5_5:
            return 5.0
        case .timer10, .timer10_3, .timer10_5:
            return 10.0
        default:
            return 0.0
        }
    }
    
    var isSingleTimerMode: Bool {
        switch self {
        case .timer2, .timer5, .timer10:
            return true
        default:
            return false
        }
    }
    
    var shootMode: ShootingMode? {
        switch self {
        case .single, .timer2, .timer5, .timer10:
            return .photo
        case .singleBracket0_3_3, .singleBracket0_3_5, .singleBracket0_3_9,
             .singleBracket0_5_3, .singleBracket0_5_5, .singleBracket0_5_9,
             .singleBracket0_7_3, .singleBracket0_7_5, .singleBracket0_7_9,
             .singleBracket1_3, .singleBracket1_5, .singleBracket1_9,
             .singleBracket2_3, .singleBracket2_5, .singleBracket3_3, .singleBracket3_5,
             .whiteBalanceBracketHigh, .whiteBalanceBracketLow, .droBracketHigh, .droBracketLow:
            return .singleBracket
        case .continuousBracket0_3_3, .continuousBracket0_3_5, .continuousBracket0_3_9,
        .continuousBracket0_5_3, .continuousBracket0_5_5, .continuousBracket0_5_9,
        .continuousBracket0_7_3, .continuousBracket0_7_5, .continuousBracket0_7_9,
        .continuousBracket1_3, .continuousBracket1_5, .continuousBracket1_9,
        .continuousBracket2_3, .continuousBracket2_5, .continuousBracket3_3, .continuousBracket3_5:
            return .continuousBracket
        case .continuous, .continuousS, .continuousHigh, .continuousLow,
             .continuousHighPlus:
            return .continuous
        case .timer2_3, .timer2_5, .timer5_3, .timer5_5, .timer10_3, .timer10_5:
            //TODO: Add "multi-timer" timer mode
            return nil
        case .singleBurstLow, .singleBurstMedium, .singleBurstHigh:
            //TODO: Add burst mode!
            return nil
        }
    }
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        return DWord(rawValue)
    }
    
    var type: PTP.DeviceProperty.DataType {
        return .uint32
    }
    
    var code: PTP.DeviceProperty.Code {
        return .stillCaptureMode
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        guard let intValue = sonyValue.toInt else { return nil }
        guard let enumValue = SonyStillCaptureMode(rawValue: DWord(intValue)) else { return nil }
        self = enumValue
    }
}
