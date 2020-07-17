//
//  SonyPTPIPCamera+FunctionSupport.swift
//  Rocc
//
//  Created by Simon Mitchell on 17/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension SonyPTPIPDevice {
    
    func supportsFunction<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
        var supported: Bool = false
                
        // If the function has a related PTP property value
        if let deviceInfo = deviceInfo, let propTypeCodes = function.function.ptpDevicePropertyCodes {
                        
            // Check that the related property value is supported
            supported = propTypeCodes.contains { (functionPropCode) -> Bool in
                return deviceInfo.supportedDeviceProperties.contains(functionPropCode)
            }
            if !supported {
                callback(false, nil, nil)
                return
            }
        }
        
        // Some functions aren't included in device prop, we'll handle them here otherwise we'll get incorrect results
        let nonDevicePropFunctions: [_CameraFunction] = [.halfPressShutter, .cancelHalfPressShutter]
        guard !nonDevicePropFunctions.contains(function.function) else {
            callback(supported, nil, nil)
            return
        }
                
        if let latestEvent = lastEvent, let _ = latestEvent.supportedFunctions {
            latestEvent.supportsFunction(function, callback: callback)
            return
        }
        
        // Fallback for functions that aren't related to a particular camera prop type, or that function differently to the PTP spec!
        switch function.function {
        case .setAperture, .getAperture:
            getDevicePropDescriptionFor(propCode: .fNumber, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.aperture?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setISO, .getISO:
            getDevicePropDescriptionFor(propCode: .ISO, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.iso?.supported as? [T.SendType])
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
                    callback(event.supportedFunctions?.contains(function.function), nil, event.whiteBalance?.supported as? [T.SendType])
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
                    callback(event.supportedFunctions?.contains(function.function), nil, event.shootMode?.supported as? [T.SendType])
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
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .startVideoRecording, .endVideoRecording:
            getDevicePropDescriptionFor(propCode: .movie) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
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
                        event.supportedFunctions?.contains(function.function),
                        nil,
                        event.liveViewQuality?.supported as? [T.SendType]
                    )
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setSendLiveViewFrameInfo, .getSendLiveViewFrameInfo:
            // Doesn't seem to be available via PTP/IP
            callback(false, nil, nil)
        case .startZooming, .stopZooming:
            callback(false, nil, nil)
        case .setZoomSetting, .getZoomSetting:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(false, nil, nil)
        case .halfPressShutter, .cancelHalfPressShutter:
            getDevicePropDescriptionFor(propCode: .autoFocus, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
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
                    callback(event.supportedFunctions?.contains(function.function), nil, event.continuousShootingMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
            getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.continuousShootingSpeed?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setContinuousBracketedShootingBracket, .getContinuousBracketedShootingBracket:
            getDevicePropDescriptionFor(propCode: .stillCaptureMode) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.continuousBracketedShootingBrackets?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            }
        case .setSingleBracketedShootingBracket, .getSingleBracketedShootingBracket:
            getDevicePropDescriptionFor(propCode: .stillCaptureMode) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.singleBracketedShootingBrackets?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            }
        case .setSelfTimerDuration, .getSelfTimerDuration:
            getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.selfTimer?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureMode, .getExposureMode:
            getDevicePropDescriptionFor(propCode: .exposureProgramMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.exposureMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureModeDialControl, .getExposureModeDialControl:
            getDevicePropDescriptionFor(propCode: .exposureProgramModeControl, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.exposureModeDialControl?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setFocusMode, .getFocusMode:
            getDevicePropDescriptionFor(propCode: .focusMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.focusMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureCompensation, .getExposureCompensation:
            getDevicePropDescriptionFor(propCode: .exposureBiasCompensation, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.exposureCompensation?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setShutterSpeed, .getShutterSpeed:
            getDevicePropDescriptionFor(propCode: .shutterSpeed, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.shutterSpeed?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setFlashMode, .getFlashMode:
            getDevicePropDescriptionFor(propCode: .flashMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.flashMode?.supported as? [T.SendType])
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
                    callback(event.supportedFunctions?.contains(function.function), nil, event.stillSizeInfo?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            }
        case .setStillQuality, .getStillQuality:
            getDevicePropDescriptionFor(propCode: .stillQuality, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.stillQuality?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setStillFormat, .getStillFormat:
            getDevicePropDescriptionFor(propCode: .stillFormat) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.stillFormat?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            }
        case .getPostviewImageSize, .setPostviewImageSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(false, nil, nil)
        case .setVideoFileFormat, .getVideoFileFormat:
            getDevicePropDescriptionFor(propCode: .movieFormat) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.videoFileFormat?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            }
        case .setVideoQuality, .getVideoQuality:
            getDevicePropDescriptionFor(propCode: .movieQuality) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.videoQuality?.supported as? [T.SendType])
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
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(false, nil, nil)
        case .setAutoPowerOff, .getAutoPowerOff:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(false, nil, nil)
        case .setBeepMode, .getBeepMode:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
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
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
                case .failure(let error):
                    callback(false, error, nil)
                }
            }
        case .getExposureSettingsLock, .setExposureSettingsLock:
            getDevicePropDescriptionFor(propCode: .exposureSettingsLockStatus, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
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
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
                case .failure(let error):
                    callback(false, error, nil)
                }
            }
        case .getEvent, .setCameraFunction, .getCameraFunction, .startRecordMode, .ping:
            callback(true, nil, nil)
        }
    }
    
}
