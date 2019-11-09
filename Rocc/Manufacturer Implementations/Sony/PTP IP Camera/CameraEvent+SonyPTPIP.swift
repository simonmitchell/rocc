//
//  CameraEvent+SonyPTPIP.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

enum SonyStillCaptureMode: DWord, SonyPTPPropValueConvertable {
    
    case single = 0x00000001
    case continuous_hi_plus = 0x00018010
    case continuous_lo = 0x00018012
    case continuous = 0x00018013
    case continuous_s = 0x00018014
    case continuous_hi = 0x00018015
    case timer_10_a = 0x00010002
    case timer_10_b = 0x00038004
    case timer_5 = 0x00038003
    case timer_2 = 0x00038005
    case timer_10_3 = 0x00088008
    case timer_10_5 = 0x00088009
    case timer_5_3 = 0x0008800c
    case timer_5_5 = 0x0008800d
    case timer_2_3 = 0x0008800e
    case timer_2_5 = 0x0008800f
    case brk_c_0_3_3 = 0x00048337
    case brk_c_0_3_5 = 0x00048537
    case brk_c_0_3_9 = 0x00048937
    case brk_c_0_5_3 = 0x00048357
    case brk_c_0_5_5 = 0x00048557
    case brk_c_0_5_9 = 0x00048957
    case brk_c_0_7_3 = 0x00048377
    case brk_c_0_7_5 = 0x00048577
    case brk_c_0_7_9 = 0x00048977
    case brk_c_1_3 = 0x00048311
    case brk_c_1_5 = 0x00048511
    case brk_c_1_9 = 0x00048911
    case brk_c_2_3 = 0x00048321
    case brk_c_2_5 = 0x00048521
    case brk_c_3_3 = 0x00048331
    case brk_c_3_5 = 0x00048531
    case brk_s_0_3_3 = 0x00058336
    case brk_s_0_3_5 = 0x00058536
    case brk_s_0_3_9 = 0x00058936
    case brk_s_0_5_3 = 0x00058356
    case brk_s_0_5_5 = 0x00058556
    case brk_s_0_5_9 = 0x00058956
    case brk_s_0_7_3 = 0x00058376
    case brk_s_0_7_5 = 0x00058576
    case brk_s_0_7_9 = 0x00058976
    case brk_s_1_3 = 0x00058310
    case brk_s_1_5 = 0x00058510
    case brk_s_1_9 = 0x00058910
    case brk_s_2_3 = 0x00058320
    case brk_s_2_5 = 0x00058520
    case brk_s_3_3 = 0x00058330
    case brk_s_3_5 = 0x00058530
    case brk_wb_hi = 0x00068028
    case brk_wb_lo = 0x00068018
    case brk_dro_hi = 0x00078029
    case brk_dro_lo = 0x00078019
    
    var timerDuration: TimeInterval {
        switch self {
        case .timer_2, .timer_2_3, .timer_2_5:
            return 2.0
        case .timer_5, .timer_5_3, .timer_5_5:
            return 5.0
        case .timer_10_a, .timer_10_b, .timer_10_3, .timer_10_5:
            return 10.0
        default:
            return 0.0
        }
    }
    
    var isSingleTimerMode: Bool {
        switch self {
        case .timer_2, .timer_5, .timer_10_a, .timer_10_b:
            return true
        default:
            return false
        }
    }
    
    var shootMode: ShootingMode? {
        switch self {
        case .single, .timer_2, .timer_5, .timer_10_a, .timer_10_b:
            return .photo
        case .brk_c_0_3_3, .brk_c_0_3_5, .brk_c_0_3_9,
             .brk_c_0_5_3, .brk_c_0_5_5, .brk_c_0_5_9,
             .brk_c_0_7_3, .brk_c_0_7_5, .brk_c_0_7_9,
             .brk_c_1_3, .brk_c_1_5, .brk_c_1_9,
             .brk_c_2_3, .brk_c_2_5, .brk_c_3_3, .brk_c_3_5,
             .brk_s_0_3_3, .brk_s_0_3_5, .brk_s_0_3_9,
             .brk_s_0_5_3, .brk_s_0_5_5, .brk_s_0_5_9,
             .brk_s_0_7_3, .brk_s_0_7_5, .brk_s_0_7_9,
             .brk_s_1_3, .brk_s_1_5, .brk_s_1_9,
             .brk_s_2_3, .brk_s_2_5, .brk_s_3_3, .brk_s_3_5,
             .brk_wb_hi, .brk_wb_lo, .brk_dro_hi, .brk_dro_lo:
            //TODO: Add bracketed `ShootingMode`
            return nil
        case .continuous, .continuous_s, .continuous_hi, .continuous_lo,
             .continuous_hi_plus:
            return .continuous
        case .timer_2_3, .timer_2_5, .timer_5_3, .timer_5_5, .timer_10_3, .timer_10_5:
            //TODO: Add "multi-timer" timer mode
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

extension CameraEvent {
    
    init(sonyDeviceProperties: [PTPDeviceProperty]) {
        
        status = nil
        liveViewInfo = nil
        zoomPosition = nil
        postViewPictureURLs = []
        storageInformation = []
        beepMode = nil
        function = nil
        functionResult = false
        videoQuality = nil
        stillSizeInfo = nil
        steadyMode = nil
        viewAngle = nil
        exposureMode = nil
        postViewImageSize = nil
        var selfTimer: (current: TimeInterval, available: [TimeInterval])?
        var shootMode: (current: ShootingMode, available: [ShootingMode]) = (.photo, [])
        var exposureCompensation: (current: Exposure.Compensation.Value, available: [Exposure.Compensation.Value])?
        flashMode = nil
        var aperture: (current: Aperture.Value, available: [Aperture.Value])?
        focusMode = nil
        var _iso: (current: ISO.Value, available: [ISO.Value])?
        isProgramShifted = false
        var shutterSpeed: (current: ShutterSpeed, available: [ShutterSpeed])?
        var whiteBalance: WhiteBalanceInformation?
        whiteBalance = nil
        touchAF = nil
        focusStatus = nil
        zoomSetting = nil
        stillQuality = nil
        continuousShootingMode = nil
        continuousShootingSpeed = nil
        continuousShootingURLS = nil
        flipSetting = nil
        scene = nil
        intervalTime = nil
        colorSetting = nil
        videoFileFormat = nil
        videoRecordingTime = nil
        infraredRemoteControl = nil
        tvColorSystem = nil
        trackingFocusStatus = nil
        trackingFocus = nil
        batteryInfo = nil
        numberOfShots = nil
        autoPowerOff = nil
        loopRecordTime = nil
        audioRecording = nil
        windNoiseReduction = nil
        bulbShootingUrl
         = nil
        bulbCapturingTime = nil
        
        var functions: [_CameraFunction] = []
        
        sonyDeviceProperties.forEach { (deviceProperty) in
            
            switch deviceProperty.getSet {
            case .get:
                if let getFunction = deviceProperty.code.getFunction {
                    functions.append(getFunction)
                }
            case .getSet:
                if let getFunction = deviceProperty.code.getFunction {
                    functions.append(getFunction)
                }
                if let setFunctions = deviceProperty.code.setFunctions {
                    functions.append(contentsOf: setFunctions)
                }
            default:
                break
            }
            
            switch deviceProperty.code {
            
            case .stillCaptureMode:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let current = SonyStillCaptureMode(sonyValue: enumProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ SonyStillCaptureMode(sonyValue: $0) })
                
                // Adjust `ShootingMode`s that are available
                available.forEach {
                    guard let mode = $0.shootMode else { return }
                    if !shootMode.available.contains(mode) {
                        shootMode.available.append(mode)
                    }
                }
                
                //TODO: Maybe we shouldn't be doing this?
                switch current.shootMode {
                case .photo:
                    functions.append(.takePicture)
                    functions.append(contentsOf: [.startBulbCapture, .endBulbCapture])
                case .continuous:
                    functions.append(.startContinuousShooting)
                default:
                    //TODO: Hande others?
                    break
                }
                
                // Adjust our current shoot mode
                if let currentShootMode = current.shootMode {
                    shootMode.current = currentShootMode
                }
                
                let selfTimerSingleModes = available.filter({ $0.isSingleTimerMode })
                if !selfTimerSingleModes.isEmpty {
                    //TODO: What if current is a multiple timer mode?
                    var durations = selfTimerSingleModes.map({ $0.timerDuration })
                    durations.append(0.0)
                    selfTimer = (current.timerDuration, durations.sorted())
                    functions.append(.setSelfTimerDuration)
                }
                
                if shootMode.available.contains(.photo) {
                    shootMode.available.append(.timelapse)
                }
                                
                //TODO: Munge to camera protocol format!
                print("Still capture modes", current, available)
            
            case .exposureBiasCompensation:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let compensation = Exposure.Compensation.Value(sonyValue: enumProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ Exposure.Compensation.Value(sonyValue: $0) }).sorted { (value1, value2) -> Bool in
                    return value1.value < value2.value
                }
                exposureCompensation = (compensation, available)
                
            case .ISO:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let iso = ISO.Value(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ ISO.Value(sonyValue: $0) })
                _iso = (iso, available)
                
            case .shutterSpeed:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let value = ShutterSpeed(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ ShutterSpeed(sonyValue: $0) })
                shutterSpeed = (value, available)
                break
                
            case .fNumber:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let value = Aperture.Value(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ Aperture.Value(sonyValue: $0) })
                aperture = (value, available)
                break
                
            case .whiteBalance:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let currentMode = WhiteBalance.Mode(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let availableModes = enumProperty.available.compactMap({ WhiteBalance.Mode(sonyValue: $0) })
                var availableValues: [WhiteBalance.Value] = []
                let currentTemp: UInt16?
                
                // If we were sent the colour temp properties back from camera do some voodoo!
                if let colorTempProperty = sonyDeviceProperties.first(where: { $0.code == .colorTemp }) as? PTP.DeviceProperty.Range, availableModes.firstIndex(where: { $0 == .colorTemp }) != nil {
                    
                    currentTemp = colorTempProperty.currentValue as? UInt16
                    // Remove all modes which are `colorTemp` as we'll add these back in manually using `colorTempProperty` properties
                    let availableModesWithoutColorTemp = availableModes.filter({ $0.code != .colorTemp })
                    availableValues = availableModesWithoutColorTemp.map({ WhiteBalance.Value(mode: $0, temperature: nil, rawInternal: "") })
                    
                    if let min = colorTempProperty.min.toInt, let max = colorTempProperty.max.toInt, let step = colorTempProperty.step.toInt {
                        // Add back in a `colorTemp` mode for every value available in color temperatures
                        for temp in stride(from: min, to: max, by: step) {
                            availableValues.append(WhiteBalance.Value(mode: .colorTemp, temperature: temp, rawInternal: ""))
                        }
                    } else {
                        availableValues.append(WhiteBalance.Value(mode: .colorTemp, temperature: nil, rawInternal: ""))
                    }
                    
                } else {
                    availableValues = availableModes.map({ WhiteBalance.Value(mode: $0, temperature: nil, rawInternal: "") })
                    currentTemp = nil
                }
                
                // Only set color temp if current mode is `.colorTemp`
                let intCurrentTemp = currentMode == .colorTemp ? (currentTemp != nil ? Int(currentTemp!) : nil) : nil
                
                whiteBalance = WhiteBalanceInformation(
                    shouldCheck: false,
                    whitebalanceValue: WhiteBalance.Value(mode: currentMode, temperature: intCurrentTemp, rawInternal: ""),
                    available: availableValues
                )
                
            default:
                break
            }
        }
        
        self.shutterSpeed = shutterSpeed
        self.iso = _iso
        self.availableFunctions = functions
        self.aperture = aperture
        self.whiteBalance = whiteBalance
        self.exposureCompensation = exposureCompensation
        self.selfTimer = selfTimer
        self.shootMode = shootMode
    }
}
