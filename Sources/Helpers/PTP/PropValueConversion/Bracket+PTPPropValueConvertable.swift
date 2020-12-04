//
//  Bracket+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/07/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension ContinuousBracketCapture.Bracket.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .stillCaptureMode
        case .canon:
            //TODO: [Canon] Implement
            return .stillCaptureMode
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let stillCapMode = SonyStillCaptureMode(value: value, manufacturer: manufacturer) else {
                return nil
            }
            self.init(stillCapMode)
        case .canon:
            return nil
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            return stillCaptureMode?.rawValue ?? 0x00
        case .canon:
            //TODO: [Canon] Implement
            return Word(0x00)
        }
    }
    
    var stillCaptureMode: SonyStillCaptureMode? {
        switch (mode, interval) {
        case (.exposure, .custom(images: 3, interval: 0.3)):
            return .continuousBracket0_3_3
        case (.exposure, .custom(images: 5, interval: 0.3)):
            return .continuousBracket0_3_5
        case (.exposure, .custom(images: 9, interval: 0.3)):
            return .continuousBracket0_3_9
        case (.exposure, .custom(images: 3, interval: 0.5)):
            return .continuousBracket0_5_3
        case (.exposure, .custom(images: 5, interval: 0.5)):
            return .continuousBracket0_5_5
        case (.exposure, .custom(images: 9, interval: 0.5)):
            return .continuousBracket0_5_9
        case (.exposure, .custom(images: 3, interval: 0.7)):
            return .continuousBracket0_7_3
        case (.exposure, .custom(images: 5, interval: 0.7)):
            return .continuousBracket0_7_5
        case (.exposure, .custom(images: 9, interval: 0.7)):
            return .continuousBracket0_7_9
        case (.exposure, .custom(images: 3, interval: 1)):
            return .continuousBracket1_3
        case (.exposure, .custom(images: 5, interval: 1)):
            return .continuousBracket1_5
        case (.exposure, .custom(images: 9, interval: 1)):
            return .continuousBracket1_9
        case (.exposure, .custom(images: 3, interval: 2)):
            return .continuousBracket2_3
        case (.exposure, .custom(images: 5, interval: 2)):
            return .continuousBracket2_5
        case (.exposure, .custom(images: 3, interval: 3)):
            return .continuousBracket3_3
        case (.exposure, .custom(images: 5, interval: 3)):
            return .continuousBracket3_5
        case (.exposure, .custom(images: 3, interval: 0.3)):
            return .singleBracket0_3_3
        default:
            return nil
        }
    }
    
    init?(_ sonyStillCaptureMode: SonyStillCaptureMode) {
        switch sonyStillCaptureMode {
        case .continuousBracket0_3_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 0.3))
        case .continuousBracket0_3_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 0.3))
        case .continuousBracket0_3_9:
            self.init(mode: .exposure, interval: .custom(images: 9, interval: 0.3))
        case .continuousBracket0_5_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 0.5))
        case .continuousBracket0_5_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 0.5))
        case .continuousBracket0_5_9:
            self.init(mode: .exposure, interval: .custom(images: 9, interval: 0.5))
        case .continuousBracket0_7_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 0.7))
        case .continuousBracket0_7_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 0.7))
        case .continuousBracket0_7_9:
            self.init(mode: .exposure, interval: .custom(images: 9, interval: 0.7))
        case .continuousBracket1_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 1))
        case .continuousBracket1_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 1))
        case .continuousBracket1_9:
            self.init(mode: .exposure, interval: .custom(images: 9, interval: 1))
        case .continuousBracket2_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 2))
        case .continuousBracket2_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 2))
        case .continuousBracket3_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 3))
        case .continuousBracket3_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 3))
        default: return nil
        }
    }
}

extension SingleBracketCapture.Bracket.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .stillCaptureMode
        case .canon:
            //TODO: [Canon] Implement
            return .stillCaptureMode
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let stillCapMode = SonyStillCaptureMode(value: value, manufacturer: manufacturer) else {
                return nil
            }
            self.init(stillCapMode)
        case .canon:
            return nil
            //TODO: [Canon] Implement
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            return stillCaptureMode?.rawValue ?? 0x00
        case .canon:
            return Word(0)
            //TODO: [Canon] Implement
        }
    }
    
    var stillCaptureMode: SonyStillCaptureMode? {
        switch (mode, interval) {
        case (.dro, .high):
            return .droBracketHigh
        case (.dro, .low):
            return .droBracketLow
        case (.whiteBalance, .high):
            return .whiteBalanceBracketHigh
        case (.whiteBalance, .low):
            return .whiteBalanceBracketLow
        case (.exposure, .custom(images: 3, interval: 0.3)):
            return .singleBracket0_3_3
        case (.exposure, .custom(images: 5, interval: 0.3)):
            return .singleBracket0_3_5
        case (.exposure, .custom(images: 9, interval: 0.3)):
            return .singleBracket0_3_9
        case (.exposure, .custom(images: 3, interval: 0.5)):
            return .singleBracket0_5_3
        case (.exposure, .custom(images: 5, interval: 0.5)):
            return .singleBracket0_5_5
        case (.exposure, .custom(images: 9, interval: 0.5)):
            return .singleBracket0_5_9
        case (.exposure, .custom(images: 3, interval: 0.7)):
            return .singleBracket0_7_3
        case (.exposure, .custom(images: 5, interval: 0.7)):
            return .singleBracket0_7_5
        case (.exposure, .custom(images: 9, interval: 0.7)):
            return .singleBracket0_7_9
        case (.exposure, .custom(images: 3, interval: 1)):
            return .singleBracket1_3
        case (.exposure, .custom(images: 5, interval: 1)):
            return .singleBracket1_5
        case (.exposure, .custom(images: 9, interval: 1)):
            return .singleBracket1_9
        case (.exposure, .custom(images: 3, interval: 2)):
            return .singleBracket2_3
        case (.exposure, .custom(images: 5, interval: 2)):
            return .singleBracket2_5
        case (.exposure, .custom(images: 3, interval: 3)):
            return .singleBracket3_3
        case (.exposure, .custom(images: 5, interval: 3)):
            return .singleBracket3_5
        default:
            return nil
        }
    }
    
    init?(_ sonyStillCaptureMode: SonyStillCaptureMode) {
        switch sonyStillCaptureMode {
        case .singleBracket0_3_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 0.3))
        case .singleBracket0_3_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 0.3))
        case .singleBracket0_3_9:
            self.init(mode: .exposure, interval: .custom(images: 9, interval: 0.3))
        case .singleBracket0_5_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 0.5))
        case .singleBracket0_5_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 0.5))
        case .singleBracket0_5_9:
            self.init(mode: .exposure, interval: .custom(images: 9, interval: 0.5))
        case .singleBracket0_7_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 0.7))
        case .singleBracket0_7_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 0.7))
        case .singleBracket0_7_9:
            self.init(mode: .exposure, interval: .custom(images: 9, interval: 0.7))
        case .singleBracket1_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 1))
        case .singleBracket1_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 1))
        case .singleBracket1_9:
            self.init(mode: .exposure, interval: .custom(images: 9, interval: 1))
        case .singleBracket2_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 2))
        case .singleBracket2_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 2))
        case .singleBracket3_3:
            self.init(mode: .exposure, interval: .custom(images: 3, interval: 3))
        case .singleBracket3_5:
            self.init(mode: .exposure, interval: .custom(images: 5, interval: 3))
        case .whiteBalanceBracketHigh:
            self.init(mode: .whiteBalance, interval: .high)
        case .whiteBalanceBracketLow:
            self.init(mode: .whiteBalance, interval: .low)
        case .droBracketHigh:
            self.init(mode: .dro, interval: .high)
        case .droBracketLow:
            self.init(mode: .dro, interval: .low)
        default: return nil
        }
    }
}
