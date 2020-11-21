//
//  SonyPTPIPCamera+FunctionAvailability.swift
//  Rocc
//
//  Created by Simon Mitchell on 17/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension SonyPTPIPDevice {
    
    func isFunctionAvailable<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
            // Some functions aren't returned by device prop desc so we can assume these are always available if they're supported!
        
            let alwaysAvailableFunctions: [_CameraFunction] = [.halfPressShutter, .cancelHalfPressShutter]
            guard !alwaysAvailableFunctions.contains(function.function) else {
                supportsFunction(function) { (supported, error, sendType) in
                    guard let _supported = supported else {
                        callback(nil, error, nil)
                        return
                    }
                    // If it's supported, it's available!
                    callback(_supported, error, nil)
                }
                return
            }
                            
            if let latestEvent = lastEvent, let _ = latestEvent.availableFunctions {
                latestEvent.isFunctionAvailable(function, callback: callback)
                return
            }
            
            // Fallback for functions that aren't related to a particular camera prop type, or that function differently to the PTP spec!
            // We re-use the `CameraEvent` logic which parses and munges the response into the correct types here. Really should be moved to a formatter!
            switch function.function {
            case .setAperture, .getAperture:
                getDevicePropDescriptionFor(propCode: .fNumber, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.aperture?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setISO, .getISO:
                getDevicePropDescriptionFor(propCode: .ISO, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.iso?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setWhiteBalance, .getWhiteBalance:
                // White balance requires white balance and colorTemp codes to be fetched!
                getDevicePropDescriptionsFor(propCodes: [.whiteBalance, .colorTemp]) { (result) in
                    switch result {
                    case .success(let properties):
                        let event = CameraEvent.fromSonyDeviceProperties(properties).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.whiteBalance?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .setupCustomWhiteBalanceFromShot:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
                break
            case .setShootMode, .getShootMode:
                getDevicePropDescriptionsFor(propCodes: [.stillCaptureMode, .exposureProgramMode]) { (result) in
                 
                    switch result {
                    case .success(let properties):
                        let event = CameraEvent.fromSonyDeviceProperties(properties).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.shootMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .setProgramShift, .getProgramShift:
                // Not available natively with PTP/IP
                callback(false, nil, nil)
            case .takePicture, .startContinuousShooting, .endContinuousShooting, .startBulbCapture, .endBulbCapture, .startContinuousBracketShooting, .stopContinuousBracketShooting, .takeSingleBracketShot:
                getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, nil)
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .startVideoRecording, .endVideoRecording:
                getDevicePropDescriptionFor(propCode: .movie) { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, nil)
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .startAudioRecording, .endAudioRecording:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .startIntervalStillRecording, .endIntervalStillRecording:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .startLoopRecording, .endLoopRecording:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .startLiveView, .endLiveView:
                callback(true, nil, nil)
            case .getLiveViewQuality, .setLiveViewQuality, .startLiveViewWithQuality:
                getDevicePropDescriptionFor(propCode: .liveViewQuality, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(
                            event.availableFunctions?.contains(function.function),
                            nil,
                            event.liveViewQuality?.available as? [T.SendType]
                        )
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setSendLiveViewFrameInfo, .getSendLiveViewFrameInfo:
                // Doesn't seem to be available via PTP/IP
                callback(false, nil, nil)
            case .startZooming, .stopZooming:
                // If we get to this point, no way to tell if it's available as is setDeviceBValue
                callback(false, nil, nil)
            case .setZoomSetting, .getZoomSetting:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .halfPressShutter, .cancelHalfPressShutter:
                getDevicePropDescriptionFor(propCode: .autoFocus, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, nil)
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setTouchAFPosition, .getTouchAFPosition, .cancelTouchAFPosition:
                // Doesn't seem to be available via PTP/IP
                callback(false, nil, nil)
            case .startTrackingFocus, .stopTrackingFocus:
                // Doesn't seem to be available via PTP/IP
                callback(false, nil, nil)
            case .setTrackingFocus, .getTrackingFocus:
                // Doesn't seem to be available via PTP/IP
                callback(false, nil, nil)
            case .setContinuousShootingMode, .getContinuousShootingMode:
                getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.continuousShootingMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
                getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.continuousShootingSpeed?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setContinuousBracketedShootingBracket, .getContinuousBracketedShootingBracket:
                getDevicePropDescriptionFor(propCode: .stillCaptureMode) { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.continuousBracketedShootingBrackets?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .setSingleBracketedShootingBracket, .getSingleBracketedShootingBracket:
                getDevicePropDescriptionFor(propCode: .stillCaptureMode) { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.singleBracketedShootingBrackets?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .setSelfTimerDuration, .getSelfTimerDuration:
                getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.selfTimer?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setExposureMode, .getExposureMode:
                getDevicePropDescriptionFor(propCode: .exposureProgramMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.exposureMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setExposureModeDialControl, .getExposureModeDialControl:
                getDevicePropDescriptionFor(propCode: .exposureProgramModeControl, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.exposureModeDialControl?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setFocusMode, .getFocusMode:
                getDevicePropDescriptionFor(propCode: .focusMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.focusMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setExposureCompensation, .getExposureCompensation:
                getDevicePropDescriptionFor(propCode: .exposureBiasCompensation, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.exposureCompensation?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setShutterSpeed, .getShutterSpeed:
                getDevicePropDescriptionFor(propCode: .shutterSpeed, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.shutterSpeed?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setFlashMode, .getFlashMode:
                getDevicePropDescriptionFor(propCode: .flashMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.flashMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setStillSize, .getStillSize:
                // Still size requires still size and ratio codes to be fetched!
                getDevicePropDescriptionsFor(propCodes: [.imageSizeSony, .aspectRatio]) { (result) in
                    switch result {
                    case .success(let properties):
                        let event = CameraEvent.fromSonyDeviceProperties(properties).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.stillSizeInfo?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .setStillQuality, .getStillQuality:
                getDevicePropDescriptionFor(propCode: .stillQuality, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.stillQuality?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setStillFormat, .getStillFormat:
                getDevicePropDescriptionFor(propCode: .stillFormat, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.stillFormat?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .getPostviewImageSize, .setPostviewImageSize:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setVideoFileFormat, .getVideoFileFormat:
                getDevicePropDescriptionFor(propCode: .movieFormat) { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.videoFileFormat?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .setVideoQuality, .getVideoQuality:
                getDevicePropDescriptionFor(propCode: .movieQuality) { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.videoQuality?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .setSteadyMode, .getSteadyMode:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setViewAngle, .getViewAngle:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setScene, .getScene:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setColorSetting, .getColorSetting:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setIntervalTime, .getIntervalTime:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setLoopRecordDuration, .getLoopRecordDuration:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setWindNoiseReduction, .getWindNoiseReduction:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setAudioRecording, .getAudioRecording:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setFlipSetting, .getFlipSetting:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setTVColorSystem, .getTVColorSystem:
                //TODO: Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .listContent, .getContentCount, .listSchemes, .listSources, .deleteContent, .setStreamingContent, .startStreaming, .pauseStreaming, .seekStreamingPosition, .stopStreaming, .getStreamingStatus:
                // Not available via PTP/IP
                callback(false, nil, nil)
            case .setInfraredRemoteControl, .getInfraredRemoteControl:
                // Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setAutoPowerOff, .getAutoPowerOff:
                // Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setBeepMode, .getBeepMode:
                // Unable to reverse engineer as not supported on RX100 VII
                callback(false, nil, nil)
            case .setCurrentTime:
                //TODO: Implement
                callback(false, nil, nil)
            case .getStorageInformation:
                // Requires either remaining shots or remaining capture time to function
                getDevicePropDescriptionsFor(propCodes: [.remainingShots, .remainingCaptureTime, .storageState]) { (result) in
                    switch result {
                    case .success(let properties):
                        let event = CameraEvent.fromSonyDeviceProperties(properties).event
                        callback(event.availableFunctions?.contains(function.function), nil, nil)
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
            case .setExposureSettingsLock, .getExposureSettingsLock:
                getDevicePropDescriptionFor(propCode: .exposureSettingsLockStatus, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, nil)
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .recordHighFrameRateCapture:
                // Requires exposure programme mode and lock status to calculate accurately
                getDevicePropDescriptionsFor(propCodes: [.exposureProgramMode, .exposureSettingsLockStatus]) { (result) in
                    switch result {
                    case .success(let properties):
                        let event = CameraEvent.fromSonyDeviceProperties(properties).event
                        callback(event.availableFunctions?.contains(function.function), nil, nil)
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                }
                callback(true, nil, nil)
            case .getEvent, .setCameraFunction, .getCameraFunction, .startRecordMode, .ping:
                callback(true, nil, nil)
            }
        }
}
