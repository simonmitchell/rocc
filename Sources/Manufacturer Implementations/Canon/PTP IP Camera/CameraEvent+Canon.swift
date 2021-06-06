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

        var currentISO: ISO.Value?
        var availableISO: [ISO.Value]?

        var availableFunctions: [_CameraFunction] = []
        var supportedFunctions: [_CameraFunction] = []

        // According to libgphoto if a value is present as `CanonPTPPropValueChange` then
        // it is able to be set/got apart from a few hard-coded property codes obviously

        canonPTPEvents.events.forEach { event in

            // TODO: Add support for all other event codes and types!
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
            shutterSpeed: nil,
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
