//
//  CameraEvent+Canon.swift
//  Rocc
//
//  Created by Simon Mitchell on 06/06/2021.
//  Copyright © 2021 Simon Mitchell. All rights reserved.
//

import Foundation

extension CameraEvent {

    static func fromCanonPTPEvents(_ canonPTPEvents: CanonPTPEvents) -> CameraEvent {

        // TODO: [Canon] handle partial events, much like API cameras for Sony canon
        // camera events are partial (do need to 100% confirm this) so we will lose info otherwise and functions
        // which remain available may be marked as unavailable!

        var currentISO: ISO.Value?
        var availableISO: [ISO.Value]?

        var currentShutterSpeed: ShutterSpeed?
        var availableShutterSpeed: [ShutterSpeed]?
        
        var currentAperture: Aperture.Value?
        var availableApertures: [Aperture.Value]?
        
        var currentFocusMode: Focus.Mode.Value?
        var availableFocusModes: [Focus.Mode.Value]?
        
        var currentExposureCompensation: Exposure.Compensation.Value?
        var availableExposureCompensations: [Exposure.Compensation.Value]?
        
        var currentExposureMode: Exposure.Mode.Value?
        var availableExposureModes: [Exposure.Mode.Value]?

        var availableFunctions: [_CameraFunction] = []
        var supportedFunctions: [_CameraFunction] = []
        var storageInformation: [StorageInformation]? = nil
        var batteryInfo: [BatteryInformation]?

        // According to libgphoto if a value is present as `CanonPTPPropValueChange` then
        // it is able to be set/got apart from a few hard-coded property codes obviously

        canonPTPEvents.events.forEach { event in

            // TODO: [Canon] Add support for all other event codes and types!
            switch event {
            case let propertyChange as CanonPTPPropValueChange:
                switch propertyChange.code {
                case .ISO, .ISOSpeedCanonEOS, .ISOSpeedCanon:
                    guard let current = ISO.Value(value: propertyChange.value, manufacturer: .canon) else {
                        return
                    }
                    availableFunctions.append(contentsOf: [.setISO, .getISO])
                    supportedFunctions.append(contentsOf: [.setISO, .getISO])
                    currentISO = current
                case .shutterSpeed, .shutterSpeedCanon, .shutterSpeedCanonEOS:
                    guard let current = ShutterSpeed(value: propertyChange.value, manufacturer: .canon) else {
                        return
                    }
                    availableFunctions.append(contentsOf: [.setShutterSpeed, .getShutterSpeed])
                    supportedFunctions.append(contentsOf: [.setShutterSpeed, .getShutterSpeed])
                    currentShutterSpeed = current
                case .availableShotsCanonEOS:
                    guard let shots = propertyChange.value.toInt else { return }

                    let info = storageInformation?.first
                    let storageInfo = StorageInformation(
                        description: info?.description,
                        spaceForImages: shots,
                        recordTarget: true,
                        recordableTime: info?.recordableTime,
                        id: nil,
                        noMedia: info?.noMedia ?? false
                    )
                    storageInformation = [
                        storageInfo
                    ]
                case .batteryPowerCanonEOS:
                    guard let level = propertyChange.value.toInt else { return }
                    batteryInfo = [
                        BatteryInformation(
                            identifier: "",
                            status: .active,
                            chargeStatus: level < 10 ? .nearEnd : nil,
                            description: nil,
                            level: Double(level)/100.0
                        )
                    ]
                case .apertureCanon, .apertureCanonEOS:
                    guard let current = Aperture.Value(value: propertyChange.value, manufacturer: .canon) else {
                        return
                    }
                    availableFunctions.append(contentsOf: [.setAperture, .getAperture])
                    supportedFunctions.append(contentsOf: [.setAperture, .getAperture])
                    currentAperture = current
                case .focusMode, .focusModeCanonEOS:
                    guard let current = Focus.Mode.Value(value: propertyChange.value, manufacturer: .canon) else {
                        return
                    }
                    availableFunctions.append(contentsOf: [.setFocusMode, .getFocusMode])
                    supportedFunctions.append(contentsOf: [.setFocusMode, .getFocusMode])
                    currentFocusMode = current
                case .exposureBiasCompensation, .expCompensationCanon, .expCompensationCanonEOS:
                    guard let current = Exposure.Compensation.Value(value: propertyChange.value, manufacturer: .canon) else {
                        return
                    }
                    availableFunctions.append(contentsOf: [.setExposureCompensation, .getExposureCompensation])
                    supportedFunctions.append(contentsOf: [.setExposureCompensation, .getExposureCompensation])
                    currentExposureCompensation = current
                case .autoExposureModeCanonEOS, .exposureProgramMode:
                    guard let current = Exposure.Mode.Value(value: propertyChange.value, manufacturer: .canon) else {
                        return
                    }
                    availableFunctions.append(contentsOf: [.setExposureMode, .getExposureMode])
                    supportedFunctions.append(contentsOf: [.setExposureMode, .getExposureMode])
                    currentExposureMode = current
                default:
                    break
                }
            case let availableValuesChange as CanonPTPAvailableValuesChange:
                switch availableValuesChange.code {
                case .ISO, .ISOSpeedCanon, .ISOSpeedCanonEOS:
                    availableISO = availableValuesChange.availableValues.compactMap({
                        ISO.Value(value: $0, manufacturer: .canon)
                    })
                case .shutterSpeed, .shutterSpeedCanon, .shutterSpeedCanonEOS:
                    availableShutterSpeed = availableValuesChange.availableValues.compactMap({
                        ShutterSpeed(value: $0, manufacturer: .canon)
                    })
                case .apertureCanon, .apertureCanonEOS:
                    availableApertures = availableValuesChange.availableValues.compactMap({
                        Aperture.Value(value: $0, manufacturer: .canon)
                    })
                case .focusMode, .focusModeCanonEOS:
                    availableFocusModes = availableValuesChange.availableValues.compactMap({
                        Focus.Mode.Value(value: $0, manufacturer: .canon)
                    })
                case .exposureBiasCompensation, .expCompensationCanon, .expCompensationCanonEOS:
                    availableExposureCompensations = availableValuesChange.availableValues.compactMap({
                        Exposure.Compensation.Value(value: $0, manufacturer: .canon)
                    })
                case .autoExposureModeCanonEOS, .exposureProgramMode:
                    availableExposureModes = availableValuesChange.availableValues.compactMap({
                        Exposure.Mode.Value(value: $0, manufacturer: .canon)
                    })
                default:
                    break
                }
            default:
                break
            }
        }
        
        var aperture: (current: Aperture.Value, available: [Aperture.Value], supported: [Aperture.Value])?
        if let currentAperture = currentAperture {
            aperture = (currentAperture, availableApertures ?? [], availableApertures ?? [])
        }
        
        var exposureComp: (current: Exposure.Compensation.Value, available: [Exposure.Compensation.Value], supported: [Exposure.Compensation.Value])?
        if let currentExposureCompensation {
            exposureComp = (currentExposureCompensation, availableExposureCompensations ?? [], availableExposureCompensations ?? [])
        }
        
        var exposureModes: (current: Exposure.Mode.Value, available: [Exposure.Mode.Value], supported: [Exposure.Mode.Value])?
        if let currentExposureMode {
            exposureModes = (currentExposureMode, availableExposureModes ?? [], availableExposureModes ?? [])
        }
        
        var focusMode: (current: Focus.Mode.Value, available: [Focus.Mode.Value], supported: [Focus.Mode.Value])?
        if let currentFocusMode {
            focusMode = (currentFocusMode, availableFocusModes ?? [], availableFocusModes ?? [])
        }

        var iso: (current: ISO.Value, available: [ISO.Value], supported: [ISO.Value])?
        if let currentISO {
            iso = (currentISO, availableISO ?? [], availableISO ?? [])
        }

        var shutterSpeed: (current: ShutterSpeed, available: [ShutterSpeed], supported: [ShutterSpeed])?
        if let currentShutterSpeed {
            shutterSpeed = (currentShutterSpeed, availableShutterSpeed ?? [], availableShutterSpeed ?? [])
        }

        let event = CameraEvent(
            status: nil,
            liveViewInfo: nil,
            liveViewQuality: nil,
            zoomPosition: nil,
            availableFunctions: availableFunctions,
            supportedFunctions: supportedFunctions,
            postViewPictureURLs: [:],
            storageInformation: nil,
            beepMode: nil,
            function: nil,
            functionResult: false,
            videoQuality: nil,
            stillSizeInfo: nil,
            steadyMode: nil,
            viewAngle: nil,
            exposureMode: exposureModes,
            exposureModeDialControl: nil,
            exposureSettingsLockStatus: nil,
            postViewImageSize: nil,
            selfTimer: nil,
            shootMode: nil,
            exposureCompensation: exposureComp,
            flashMode: nil,
            aperture: aperture,
            focusMode: focusMode,
            iso: iso,
            isProgramShifted: nil,
            shutterSpeed: shutterSpeed,
            whiteBalance: nil,
            touchAF: nil,
            focusStatus: nil,
            zoomSetting: nil,
            stillQuality: nil,
            stillFormat: nil,
            continuousShootingMode: nil,
            continuousShootingSpeed: nil,
            continuousBracketedShootingBrackets: nil,
            singleBracketedShootingBrackets: nil,
            flipSetting: nil,
            scene: nil,
            intervalTime: nil,
            colorSetting: nil,
            videoFileFormat: nil,
            videoRecordingTime: nil,
            highFrameRateCaptureStatus: nil,
            infraredRemoteControl: nil,
            tvColorSystem: nil,
            trackingFocusStatus: nil,
            trackingFocus: nil,
            batteryInfo: nil,
            numberOfShots: nil,
            autoPowerOff: nil,
            loopRecordTime: nil,
            audioRecording: nil,
            windNoiseReduction: nil,
            bulbShootingUrl: nil,
            bulbCapturingTime: nil
        )

        return event
    }
}
