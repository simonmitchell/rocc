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
                default:
                    break
                }
            case let availableValuesChange as CanonPTPAvailableValuesChange:
                switch availableValuesChange.code {
                case .ISO, .ISOSpeedCanon, .ISOSpeedCanonEOS:
                    let available = availableValuesChange.availableValues.compactMap({
                        ISO.Value(value: $0, manufacturer: .canon)
                    })
                    availableISO = available
                case .shutterSpeed, .shutterSpeedCanon, .shutterSpeedCanonEOS:
                    let available = availableValuesChange.availableValues.compactMap({
                        ShutterSpeed(value: $0, manufacturer: .canon)
                    })
                    availableShutterSpeed = available
                default:
                    break
                }
            default:
                break
            }
        }

        var iso: (current: ISO.Value, available: [ISO.Value], supported: [ISO.Value])?
        if let currentISO = currentISO {
            iso = (currentISO, availableISO ?? [], availableISO ?? [])
        }

        var shutterSpeed: (current: ShutterSpeed, available: [ShutterSpeed], supported: [ShutterSpeed])?
        if let currentShutterSpeed = currentShutterSpeed {
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
            exposureMode: nil,
            exposureModeDialControl: nil,
            exposureSettingsLockStatus: nil,
            postViewImageSize: nil,
            selfTimer: nil,
            shootMode: nil,
            exposureCompensation: nil,
            flashMode: nil,
            aperture: nil,
            focusMode: nil,
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
