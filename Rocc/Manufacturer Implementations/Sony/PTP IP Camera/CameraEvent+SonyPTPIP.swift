//
//  CameraEvent+SonyPTPIP.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

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
        selfTimer = nil
        shootMode = nil
        exposureCompensation = nil
        flashMode = nil
        var aperture: (current: Aperture.Value, available: [Aperture.Value])?
        focusMode = nil
        var _iso: (current: ISO.Value, available: [ISO.Value])?
        isProgramShifted = false
        var shutterSpeed: (current: ShutterSpeed, available: [ShutterSpeed])?
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
            
            switch deviceProperty.code {
            case .ISO:
                
                switch deviceProperty.getSet {
                case .get:
                    functions.append(.getISO)
                case .getSet:
                    functions.append(.getISO)
                    functions.append(.setISO)
                default:
                    break
                }
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let iso = ISO.Value(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ ISO.Value(sonyValue: $0) })
                _iso = (iso, available)
                
            case .shutterSpeed:
                
                switch deviceProperty.getSet {
                case .get:
                    functions.append(.getShutterSpeed)
                case .getSet:
                    functions.append(.getShutterSpeed)
                    functions.append(.setShutterSpeed)
                default:
                    break
                }
                
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
                
                switch deviceProperty.getSet {
                case .get:
                    functions.append(.getAperture)
                case .getSet:
                    functions.append(.getAperture)
                    functions.append(.setAperture)
                default:
                    break
                }
                
                guard let enumProperty = deviceProperty as? PTP.DeviceProperty.Enum else {
                    return
                }
                guard let value = Aperture.Value(sonyValue: deviceProperty.currentValue) else {
                    return
                }
                let available = enumProperty.available.compactMap({ Aperture.Value(sonyValue: $0) })
                aperture = (value, available)
                break
                
            default:
                break
            }
        }
        
        self.shutterSpeed = shutterSpeed
        self.iso = _iso
        self.availableFunctions = functions
        self.aperture = aperture
    }
}
