//
//  CameraEvent+SonyPTPIP.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}

extension Exposure.Mode.Value {
    var isVideo: Bool {
        switch self {
        case .videoManual, .videoProgrammedAuto, .videoShutterPriority, .videoAperturePriority:
            return true
        default:
            return false
        }
    }
    
    var isHighFrameRate: Bool {
        switch self {
        case .highFrameRateManual, .highFrameRateProgrammedAuto, .highFrameRateShutterPriority, .highFrameRateAperturePriority:
            return true
        default:
            return false
        }
    }
}

enum SonyStillCaptureMode: DWord, SonyPTPPropValueConvertable {
    
    case single = 0x00000001
    case continuousHighPlus = 0x00018010
    case continuousLow = 0x00018012
    case continuous = 0x00018013
    case continuousS = 0x00018014
    case continuousHigh = 0x00018015
    case timer10_a = 0x00010002
    case timer10_b = 0x00038004
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
    
    var continuousShootingMode: ContinuousShootingMode? {
        switch self {
        case .continuous, .continuousS, .continuousLow, .continuousHigh, .continuousHighPlus:
            return .continuous
        default:
            return nil
        }
    }
    
    var continuousShootingSpeed: ContinuousShootingSpeed? {
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
        case .timer10_a, .timer10_b, .timer10_3, .timer10_5:
            return 10.0
        default:
            return 0.0
        }
    }
    
    var isSingleTimerMode: Bool {
        switch self {
        case .timer2, .timer5, .timer10_a, .timer10_b:
            return true
        default:
            return false
        }
    }
    
    var shootMode: ShootingMode? {
        switch self {
        case .single, .timer2, .timer5, .timer10_a, .timer10_b:
            return .photo
        case .continuousBracket0_3_3, .continuousBracket0_3_5, .continuousBracket0_3_9,
             .continuousBracket0_5_3, .continuousBracket0_5_5, .continuousBracket0_5_9,
             .continuousBracket0_7_3, .continuousBracket0_7_5, .continuousBracket0_7_9,
             .continuousBracket1_3, .continuousBracket1_5, .continuousBracket1_9,
             .continuousBracket2_3, .continuousBracket2_5, .continuousBracket3_3, .continuousBracket3_5,
             .singleBracket0_3_3, .singleBracket0_3_5, .singleBracket0_3_9,
             .singleBracket0_5_3, .singleBracket0_5_5, .singleBracket0_5_9,
             .singleBracket0_7_3, .singleBracket0_7_5, .singleBracket0_7_9,
             .singleBracket1_3, .singleBracket1_5, .singleBracket1_9,
             .singleBracket2_3, .singleBracket2_5, .singleBracket3_3, .singleBracket3_5,
             .whiteBalanceBracketHigh, .whiteBalanceBracketLow, .droBracketHigh, .droBracketLow:
            //TODO: Add bracketed `ShootingMode`
            return nil
        case .continuous, .continuousS, .continuousHigh, .continuousLow,
             .continuousHighPlus:
            return .continuous
        case .timer2_3, .timer2_5, .timer5_3, .timer5_5, .timer10_3, .timer10_5:
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
    
    static func fromSonyDeviceProperties(_ sonyDeviceProperties: [PTPDeviceProperty]) -> (event: CameraEvent, stillCaptureModes: (available: [SonyStillCaptureMode], supported: [SonyStillCaptureMode])?) {
        
        var stillCapModes: (available: [SonyStillCaptureMode], supported: [SonyStillCaptureMode])?
           
        var zoomPosition: Double? = nil
        var storageInformation: [StorageInformation]? = nil
        var stillSizeInfo: StillSizeInformation?
        var exposureMode: (current: Exposure.Mode.Value, available: [Exposure.Mode.Value], supported: [Exposure.Mode.Value])?
        var exposureModeDialControl: (current: Exposure.Mode.DialControl.Value, available: [Exposure.Mode.DialControl.Value], supported: [Exposure.Mode.DialControl.Value])?
        var exposureSettingsLockStatus: Exposure.SettingsLock.Status?
        var selfTimer: (current: TimeInterval, available: [TimeInterval], supported: [TimeInterval])?
        var shootMode: (current: ShootingMode, available: [ShootingMode], supported: [ShootingMode]) = (.photo, [], [])
        var exposureCompensation: (current: Exposure.Compensation.Value, available: [Exposure.Compensation.Value], supported: [Exposure.Compensation.Value])?
        var flashMode: (current: Flash.Mode.Value, available: [Flash.Mode.Value], supported: [Flash.Mode.Value])?
        var aperture: (current: Aperture.Value, available: [Aperture.Value], supported: [Aperture.Value])?
        var focusMode: (current: Focus.Mode.Value, available: [Focus.Mode.Value], supported: [Focus.Mode.Value])?
        var iso: (current: ISO.Value, available: [ISO.Value], supported: [ISO.Value])?
        var shutterSpeed: (current: ShutterSpeed, available: [ShutterSpeed], supported: [ShutterSpeed])?
        var whiteBalance: WhiteBalanceInformation?
        var focusStatus: FocusStatus?
        var continuousShootingMode: (current: ContinuousShootingMode?, available: [ContinuousShootingMode], supported: [ContinuousShootingMode])?
        var continuousShootingSpeed: (current: ContinuousShootingSpeed?, available: [ContinuousShootingSpeed], supported: [ContinuousShootingSpeed])?
        var batteryInfo: [BatteryInformation]?
        var stillQuality: (current: StillQuality, available: [StillQuality], supported: [StillQuality])?
        var stillFormat: (current: StillFormat, available: [StillFormat], supported: [StillFormat])?
        
        var availableFunctions: [_CameraFunction] = []
        var supportedFunctions: [_CameraFunction] = []
        
        sonyDeviceProperties.forEach { (deviceProperty) in
                        
            switch deviceProperty.getSetSupported {
            case .get:
                if let getFunction = deviceProperty.code.getFunction {
                    supportedFunctions.append(getFunction)
                }
            case .getSet:
                if let getFunction = deviceProperty.code.getFunction {
                    supportedFunctions.append(getFunction)
                }
                if let setFunctions = deviceProperty.code.setFunctions {
                    supportedFunctions.append(contentsOf: setFunctions)
                }
            default:
                break
            }
            
            switch deviceProperty.getSetAvailable {
            case .get:
                if let getFunction = deviceProperty.code.getFunction {
                    availableFunctions.append(getFunction)
                }
            case .getSet:
                if let getFunction = deviceProperty.code.getFunction {
                    availableFunctions.append(getFunction)
                }
                if let setFunctions = deviceProperty.code.setFunctions {
                    availableFunctions.append(contentsOf: setFunctions)
                }
            default:
                break
            }
            
            switch deviceProperty.code {
                
            case .batteryLevel, .batteryLevelSony:
                
                guard let rangeProperty = deviceProperty as? PTP.DeviceProperty.Range else {
                    return
                }
                guard let level = rangeProperty.currentValue.toInt else {
                    return
                }
                
                batteryInfo = [
                    BatteryInformation(
                        identifier: "",
                        status: .active,
                        chargeStatus: level < 10 ? .nearEnd : nil,
                        description: nil,
                        level: Double(level)/100.0
                    )
                ]
                
            case .exposureProgramMode:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let mode = Exposure.Mode.Value(sonyValue: enumProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ Exposure.Mode.Value(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ Exposure.Mode.Value(sonyValue: $0) })
                
                exposureMode = (mode, available, supported)
                
            case .exposureProgramModeControl:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let control = Exposure.Mode.DialControl.Value(sonyValue: enumProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ Exposure.Mode.DialControl.Value(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ Exposure.Mode.DialControl.Value(sonyValue: $0) })
                
                exposureModeDialControl = (control, available, supported)
                
            case .exposureSettingsLockStatus:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                exposureSettingsLockStatus = Exposure.SettingsLock.Status(sonyValue: enumProperty.currentValue)
                
            case .focusFound:
                
                guard let enumProperty = deviceProperty
                    as? PTP.DeviceProperty.Enum else {
                    return
                }
                
                focusStatus = FocusStatus(sonyValue: enumProperty.currentValue)
                
            case .flashMode:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let mode = Flash.Mode.Value(sonyValue: enumProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ Flash.Mode.Value(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ Flash.Mode.Value(sonyValue: $0) })
                
                flashMode = (mode, available, supported)
            
            case .stillCaptureMode:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let current = SonyStillCaptureMode(sonyValue: enumProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ SonyStillCaptureMode(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ SonyStillCaptureMode(sonyValue: $0) })
                
                stillCapModes = (available, supported)
                
                // Adjust `ShootingMode`s that are available
                available.forEach {
                    guard let mode = $0.shootMode else { return }
                    if !shootMode.available.contains(mode) {
                        shootMode.available.append(mode)
                    }
                }
                
                // Adjust `ShootingMode`s that are supported
                supported.forEach {
                    guard let mode = $0.shootMode else { return }
                    if !shootMode.supported.contains(mode) {
                        shootMode.supported.append(mode)
                    }
                }
                
                // Sort out supported functions
                
                // Okay to for-each as array shouldn't hold multiple of each value
                shootMode.supported.forEach({ (mode) in
                    switch mode {
                    case .audio:
                        supportedFunctions.append(contentsOf: [.startAudioRecording, .endAudioRecording])
                    case .bulb:
                        supportedFunctions.append(contentsOf: [.startBulbCapture, .endBulbCapture])
                    case .photo:
                        supportedFunctions.append(contentsOf: [.takePicture])
                    case .video:
                        supportedFunctions.append(contentsOf: [.startVideoRecording, .endVideoRecording])
                    case .continuous:
                        supportedFunctions.append(contentsOf: [.startContinuousShooting, .endContinuousShooting])
                    case .loop:
                        supportedFunctions.append(contentsOf: [.startLoopRecording, .endLoopRecording])
                    case .interval:
                        supportedFunctions.append(contentsOf: [.startIntervalStillRecording, .endIntervalStillRecording])
                    default:
                        break
                    }
                })
                
                switch current.shootMode {
                case .photo:
                    availableFunctions.append(.takePicture)
                case .continuous:
                    availableFunctions.append(.startContinuousShooting)
                    availableFunctions.append(.endContinuousShooting)
                default:
                    // Others are handled by exposureProgrammeMode
                    break
                }
                
                // Adjust our current shoot mode
                if let currentShootMode = current.shootMode {
                    shootMode.current = currentShootMode
                }
                
                //Munge continuous shooting modes
                let availableContinuousShootingModes = available.filter({ $0.shootMode == .continuous })
                let supportedContinuousShootingModes = available.filter({ $0.shootMode == .continuous })
                if !availableContinuousShootingModes.isEmpty || !supportedContinuousShootingModes.isEmpty {
                    
                    let availableSpeeds = availableContinuousShootingModes.compactMap({ $0.continuousShootingSpeed }).unique
                    let availableModes = availableContinuousShootingModes.compactMap({ $0.continuousShootingMode }).unique
                    
                    let supportedSpeeds = supportedContinuousShootingModes.compactMap({ $0.continuousShootingSpeed }).unique
                    let supportedModes = supportedContinuousShootingModes.compactMap({ $0.continuousShootingMode }).unique
                    
                    continuousShootingSpeed = (current.continuousShootingSpeed, availableSpeeds, supportedSpeeds)
                    continuousShootingMode = (current.continuousShootingMode, availableModes, supportedModes)
                    
                    if !availableModes.isEmpty {
                        availableFunctions.append(contentsOf: [.setContinuousShootingMode, .getContinuousShootingMode])
                    }
                    if !supportedModes.isEmpty {
                        supportedFunctions.append(contentsOf: [.setContinuousShootingMode, .getContinuousShootingMode])
                    }
                    
                    if !availableSpeeds.isEmpty {
                        availableFunctions.append(contentsOf: [.setContinuousShootingSpeed, .getContinuousShootingSpeed])
                    }
                    if !supportedSpeeds.isEmpty {
                        supportedFunctions.append(contentsOf: [.setContinuousShootingMode, .getContinuousShootingMode])
                    }
                }
                
                //Munge self-timer modes
                
                let availableSelfTimerSingleModes = available.filter({ $0.isSingleTimerMode })
                let supportedSelfTimerSingleModes = supported.filter({ $0.isSingleTimerMode })

                if !availableSelfTimerSingleModes.isEmpty || !supportedSelfTimerSingleModes.isEmpty {
                    //TODO: What if current is a multiple timer mode?
                    var availableDurations = availableSelfTimerSingleModes.map({ $0.timerDuration })
                    var supportedDurations = supportedSelfTimerSingleModes.map({ $0.timerDuration })
                    availableDurations.append(0.0)
                    supportedDurations.append(0.0)
                    selfTimer = (current.timerDuration, availableDurations.sorted(), supportedDurations.sorted())
                    if !availableSelfTimerSingleModes.isEmpty {
                        availableFunctions.append(.setSelfTimerDuration)
                    }
                    supportedFunctions.append(.setSelfTimerDuration)
                }
                
                if shootMode.available.contains(.photo) {
                    shootMode.available.append(.timelapse)
                }
                if shootMode.supported.contains(.photo) {
                    shootMode.supported.append(.timelapse)
                }
            
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
                let supported = enumProperty.supported.compactMap({ Exposure.Compensation.Value(sonyValue: $0) }).sorted { (value1, value2) -> Bool in
                    return value1.value < value2.value
                }
                exposureCompensation = (compensation, available, supported)
                
            case .focusMode:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let currentFocusMode = Focus.Mode.Value(sonyValue: enumProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ Focus.Mode.Value(sonyValue: $0) })
                let supported = enumProperty.available.compactMap({ Focus.Mode.Value(sonyValue: $0) })
                focusMode = (currentFocusMode, available, supported)
                
            case .ISO:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let isoValue = ISO.Value(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ ISO.Value(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ ISO.Value(sonyValue: $0) })
                iso = (isoValue, available, supported)
                
            case .shutterSpeed:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let value = ShutterSpeed(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ ShutterSpeed(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ ShutterSpeed(sonyValue: $0) })
                shutterSpeed = (value, available, supported)
                
                if supported.contains(where: { $0.isBulb }), !supportedFunctions.contains(.startBulbCapture) {
                    supportedFunctions.append(contentsOf: [.startBulbCapture, .endBulbCapture])
                }
                // Only list startBulbCapture as available if current shutter speed is BULB
                if available.contains(where: { $0.isBulb }), value.isBulb, !availableFunctions.contains(.startBulbCapture) {
                    availableFunctions.append(contentsOf: [.startBulbCapture, .endBulbCapture])
                }
                
                break
                
            case .stillFormat:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let value = StillFormat(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ StillFormat(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ StillFormat(sonyValue: $0) })
                stillFormat = (value, available, supported)
                
            case .stillQuality:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let value = StillQuality(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ StillQuality(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ StillQuality(sonyValue: $0) })
                stillQuality = (value, available, supported)
                
            case .fNumber:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let value = Aperture.Value(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ Aperture.Value(sonyValue: $0) })
                let supported = enumProperty.supported.compactMap({ Aperture.Value(sonyValue: $0) })
                aperture = (value, available, supported)
                break
                
            case .imageSizeSony, .imageSize:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                let size: String
                switch enumProperty.currentValue.toInt {
                case 0x01:
                    size = "L"
                case 0x02:
                    size = "M"
                case 0x03:
                    size = "S"
                default:
                    return
                }
                
                var currentSize = StillSize(aspectRatio: nil, size: size)
                
                let availableSizes: [String] = enumProperty.available.compactMap({
                    switch $0.toInt {
                    case 0x01:
                        return "L"
                    case 0x02:
                        return "M"
                    case 0x03:
                        return "S"
                    default:
                        return nil
                    }
                })
                
                let supportedSizes: [String] = enumProperty.supported.compactMap({
                    switch $0.toInt {
                    case 0x01:
                        return "L"
                    case 0x02:
                        return "M"
                    case 0x03:
                        return "S"
                    default:
                        return nil
                    }
                })
                
                guard let ratioProperty = sonyDeviceProperties.first(where: { $0.code == .aspectRatio }) as? PTP.DeviceProperty.Enum else {
                    stillSizeInfo = StillSizeInformation(
                        shouldCheck: false,
                        stillSize: currentSize,
                        available: availableSizes.compactMap({ StillSize(aspectRatio: nil, size: $0)
                        }),
                        supported: supportedSizes.compactMap({
                            StillSize(aspectRatio: nil, size: $0)
                        })
                    )
                    return
                }
                
                let ratio: String?
                switch ratioProperty.currentValue.toInt {
                case 0x01:
                    ratio = "3:2"
                case 0x02:
                    ratio = "16:9"
                case 0x04:
                    ratio = "1:1"
                default:
                    ratio = nil
                }
                
                currentSize = StillSize(aspectRatio: ratio, size: currentSize.size)
                
                let availableRatios: [String] = ratioProperty.available.compactMap({
                    switch $0.toInt {
                    case 0x01:
                        return "3:2"
                    case 0x02:
                        return "16:9"
                    case 0x04:
                        return "1:1"
                    default:
                        return nil
                    }
                })
                
                let supportedRatios: [String] = ratioProperty.supported.compactMap({
                    switch $0.toInt {
                    case 0x01:
                        return "3:2"
                    case 0x02:
                        return "16:9"
                    case 0x04:
                        return "1:1"
                    default:
                        return nil
                    }
                })
                
                var allAvailableSizes: [StillSize] = []
                var allSupportedSizes: [StillSize] = []
                
                availableSizes.forEach { (size) in
                    availableRatios.forEach { (ratio) in
                        allAvailableSizes.append(StillSize(aspectRatio: ratio, size: size))
                    }
                }
                
                supportedSizes.forEach { (size) in
                    supportedRatios.forEach { (ratio) in
                        allSupportedSizes.append(StillSize(aspectRatio: ratio, size: size))
                    }
                }
                
                stillSizeInfo = StillSizeInformation(
                    shouldCheck: false,
                    stillSize: currentSize,
                    available: allAvailableSizes,
                    supported: allSupportedSizes
                )
                
            case .remainingShots:
                
                guard let shots = deviceProperty.currentValue.toInt else { return }
                
                let info = storageInformation?.first
                let storageInfo = StorageInformation(
                    description: info?.description,
                    spaceForImages: shots,
                    recordTarget: true,
                    recordableTime: info?.recordableTime,
                    id: nil
                )
                storageInformation = [
                    storageInfo
                ]
                
                break
                
            case .remainingCaptureTime:
                
                guard let seconds = deviceProperty.currentValue.toInt else { return }
                
                let info = storageInformation?.first
                let storageInfo = StorageInformation(
                    description: info?.description,
                    spaceForImages: info?.spaceForImages,
                    recordTarget: true,
                    recordableTime: seconds,
                    id: nil
                )
                storageInformation = [
                    storageInfo
                ]
                
            case .whiteBalance:
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let currentMode = WhiteBalance.Mode(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let availableModes = enumProperty.available.compactMap({ WhiteBalance.Mode(sonyValue: $0) })
                let supportedModes = enumProperty.supported.compactMap({ WhiteBalance.Mode(sonyValue: $0) })
                var availableValues: [WhiteBalance.Value] = []
                var supportedValues: [WhiteBalance.Value]
                var currentTemp: UInt16?
                
                // If we were sent the colour temp properties back from camera do some voodoo!
                if let colorTempProperty = sonyDeviceProperties.first(where: { $0.code == .colorTemp }) as? PTP.DeviceProperty.Range {
                    
                    currentTemp = colorTempProperty.currentValue as? UInt16
                    
                    if availableModes.firstIndex(where: { $0 == .colorTemp }) != nil {
                        
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
                    
                    if supportedModes.firstIndex(where: { $0 == .colorTemp }) != nil {
                        
                        // Remove all modes which are `colorTemp` as we'll add these back in manually using `colorTempProperty` properties
                        let supportedModesWithoutColorTemp = supportedModes.filter({ $0.code != .colorTemp })
                        supportedValues = supportedModesWithoutColorTemp.map({ WhiteBalance.Value(mode: $0, temperature: nil, rawInternal: "") })
                        
                        if let min = colorTempProperty.min.toInt, let max = colorTempProperty.max.toInt, let step = colorTempProperty.step.toInt {
                            // Add back in a `colorTemp` mode for every value available in color temperatures
                            for temp in stride(from: min, to: max, by: step) {
                                supportedValues.append(WhiteBalance.Value(mode: .colorTemp, temperature: temp, rawInternal: ""))
                            }
                        } else {
                            supportedValues.append(WhiteBalance.Value(mode: .colorTemp, temperature: nil, rawInternal: ""))
                        }
                        
                    } else {
                        
                        supportedValues = supportedModes.map({ WhiteBalance.Value(mode: $0, temperature: nil, rawInternal: "") })
                        currentTemp = nil
                    }
                    
                } else {
                    
                    supportedValues = supportedModes.map({ WhiteBalance.Value(mode: $0, temperature: nil, rawInternal: "") })
                    availableValues = availableModes.map({ WhiteBalance.Value(mode: $0, temperature: nil, rawInternal: "") })
                    currentTemp = nil
                }
                
                // Only set color temp if current mode is `.colorTemp`
                let intCurrentTemp = currentMode == .colorTemp ? (currentTemp != nil ? Int(currentTemp!) : nil) : nil
                
                whiteBalance = WhiteBalanceInformation(
                    shouldCheck: false,
                    whitebalanceValue: WhiteBalance.Value(mode: currentMode, temperature: intCurrentTemp, rawInternal: ""),
                    available: availableValues,
                    supported: supportedValues
                )
                
            case .zoomPosition:
                
                guard let otherProperty = deviceProperty as? PTP.DeviceProperty.Other else {
                    return
                }
                guard let intValue = otherProperty.currentValue.toInt else {
                    return
                }
                // We have to do some clever stuff here, because although the property is defined as `UInt32` it actually consists of two UInt16, the first
                // being a value 0-100 of the zoom level, and the other is unknown...
                var byteBuffer = ByteBuffer()
                byteBuffer.append(DWord(intValue))
                var offset: UInt = 0
                guard let uint16: Word = byteBuffer.read(offset: &offset) else {
                    return
                }
                zoomPosition = Double(uint16)/100
                
            default:
                break
            }
        }
        
        // Correct shooting mode for BULB!
        if let currentShutterSpeed = shutterSpeed?.current, currentShutterSpeed.isBulb, shootMode.current != .bulb {
            shootMode.current = .bulb
        }
        
        // Manually handle certain exposure modes to make new functions available!
        if let exposureProgrammeMode = exposureMode {
            if exposureProgrammeMode.supported.contains(where: { $0.isVideo }), !shootMode.supported.contains(.video) {
                shootMode.supported.append(.video)
                supportedFunctions.append(contentsOf: [.startVideoRecording, .endVideoRecording])
            }
            if exposureProgrammeMode.supported.contains(where: { $0.isHighFrameRate }), !shootMode.supported.contains(.highFrameRate) {
                shootMode.supported.append(.highFrameRate)
                supportedFunctions.append(contentsOf: [.startHighFrameRateCapture])
            }
            if exposureProgrammeMode.current.isVideo {
                
                shootMode.current = .video
                shootMode.available = [.video]
                availableFunctions.append(contentsOf: [.startVideoRecording, .endVideoRecording])
                let videoDisabledFunctions: [_CameraFunction] = [.takePicture, .startBulbCapture, .endBulbCapture, .endContinuousShooting, .startContinuousShooting,  .startHighFrameRateCapture]
                availableFunctions = availableFunctions.filter({
                    !videoDisabledFunctions.contains($0)
                })
                
            } else if exposureProgrammeMode.current.isHighFrameRate {
                
                shootMode.current = .highFrameRate
                shootMode.available = [.highFrameRate]
                
                // If exposure lock status is locked then we can start HFR capture!
                if exposureSettingsLockStatus == .locked {
                    availableFunctions.append(.startHighFrameRateCapture)
                }
            }
        }
    
        let event = CameraEvent(
            status: nil,
            liveViewInfo: nil,
            zoomPosition: zoomPosition,
            availableFunctions: availableFunctions,
            supportedFunctions: supportedFunctions,
            postViewPictureURLs: [],
            storageInformation: storageInformation,
            beepMode: nil,
            function: nil,
            functionResult: false,
            videoQuality: nil,
            stillSizeInfo: stillSizeInfo,
            steadyMode: nil,
            viewAngle: nil,
            exposureMode: exposureMode,
            exposureModeDialControl: exposureModeDialControl,
            exposureSettingsLockStatus: exposureSettingsLockStatus,
            postViewImageSize: nil,
            selfTimer: selfTimer,
            shootMode: shootMode,
            exposureCompensation: exposureCompensation,
            flashMode: flashMode,
            aperture: aperture,
            focusMode: focusMode,
            iso: iso,
            isProgramShifted: nil,
            shutterSpeed: shutterSpeed,
            whiteBalance: whiteBalance,
            touchAF: nil,
            focusStatus: focusStatus,
            zoomSetting: nil,
            stillQuality: stillQuality,
            stillFormat: stillFormat,
            continuousShootingMode: continuousShootingMode,
            continuousShootingSpeed: continuousShootingSpeed,
            continuousShootingURLS: nil,
            flipSetting: nil,
            scene: nil,
            intervalTime: nil,
            colorSetting: nil,
            videoFileFormat: nil,
            videoRecordingTime: nil,
            infraredRemoteControl: nil,
            tvColorSystem: nil,
            trackingFocusStatus: nil,
            trackingFocus: nil,
            batteryInfo: batteryInfo,
            numberOfShots: nil,
            autoPowerOff: nil,
            loopRecordTime: nil,
            audioRecording: nil,
            windNoiseReduction: nil,
            bulbShootingUrl: nil,
            bulbCapturingTime: nil
        )
        
        return (event, stillCapModes)
    }
}
