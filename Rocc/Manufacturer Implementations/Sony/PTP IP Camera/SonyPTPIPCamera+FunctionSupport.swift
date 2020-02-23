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
            getDevicePropDescFor(propCode: .fNumber, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.aperture?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setISO, .getISO:
            getDevicePropDescFor(propCode: .ISO, callback: { (result) in
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
            getDevicePropDescFor(propCode: .whiteBalance, callback: { [weak self] (wbResult) in
                
                guard let this = self else {
                    callback(false, nil, nil)
                    return
                }
                
                switch wbResult {
                case .success(let wbProperty):
                    this.getDevicePropDescFor(propCode: .colorTemp, callback: { (ctResult) in
                        switch ctResult {
                        case .success(let ctProperty):
                            let event = CameraEvent.fromSonyDeviceProperties([wbProperty, ctProperty]).event
                            callback(event.supportedFunctions?.contains(function.function), nil, event.whiteBalance?.supported as? [T.SendType])
                        case .failure(let error):
                            callback(false, error, nil)
                        }
                    })
                    
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setupCustomWhiteBalanceFromShot:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(false, nil, nil)
            break
        case .setShootMode, .getShootMode:
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { [weak self] (result) in
                
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let property):
                    self.getDevicePropDescFor(propCode: .exposureProgramMode) { (exposureProgrammeResult) in
                        let event: CameraEvent
                        switch exposureProgrammeResult {
                        case .success(let programmeProperty):
                            event = CameraEvent.fromSonyDeviceProperties([property, programmeProperty]).event
                        case .failure(_):
                            event = CameraEvent.fromSonyDeviceProperties([property]).event
                        }
                        callback(event.supportedFunctions?.contains(function.function), nil, event.shootMode?.supported as? [T.SendType])
                    }
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setProgramShift, .getProgramShift:
            // Not available natively with PTP/IP
            callback(false, nil, nil)
        case .takePicture, .startContinuousShooting, .endContinuousShooting, .startBulbCapture, .endBulbCapture:
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .startVideoRecording, .endVideoRecording:
            getDevicePropDescFor(propCode: .movie) { (result) in
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
        case .startLiveView, .startLiveViewWithSize, .endLiveView:
            callback(true, nil, nil)
        case .getLiveViewSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(false, nil, nil)
        case .setSendLiveViewFrameInfo, .getSendLiveViewFrameInfo:
            // Doesn't seem to be available via PTP/IP
            callback(false, nil, nil)
        case .startZooming, .stopZooming:
            callback(false, nil, nil)
        case .setZoomSetting, .getZoomSetting:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(false, nil, nil)
        case .halfPressShutter, .cancelHalfPressShutter:
            getDevicePropDescFor(propCode: .autoFocus, callback: { (result) in
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
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.continuousShootingMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.continuousShootingSpeed?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setSelfTimerDuration, .getSelfTimerDuration:
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.selfTimer?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureMode, .getExposureMode:
            getDevicePropDescFor(propCode: .exposureProgramMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.exposureMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setFocusMode, .getFocusMode:
            getDevicePropDescFor(propCode: .focusMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.focusMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureCompensation, .getExposureCompensation:
            getDevicePropDescFor(propCode: .exposureBiasCompensation, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.exposureCompensation?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setShutterSpeed, .getShutterSpeed:
            getDevicePropDescFor(propCode: .shutterSpeed, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.shutterSpeed?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setFlashMode, .getFlashMode:
            getDevicePropDescFor(propCode: .flashMode, callback: { (result) in
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
            getDevicePropDescFor(propCode: .imageSizeSony, callback: { [weak self] (imageSizeResult) in
                
                guard let this = self else {
                    callback(false, nil, nil)
                    return
                }
                
                switch imageSizeResult {
                case .success(let imageSizeProperty):
                    this.getDevicePropDescFor(propCode: .aspectRatio, callback: { (aspectResult) in
                        switch aspectResult {
                        case .success(let aspectProperty):
                            let event = CameraEvent.fromSonyDeviceProperties([imageSizeProperty, aspectProperty]).event
                            callback(event.supportedFunctions?.contains(function.function), nil, event.stillSizeInfo?.supported as? [T.SendType])
                        case .failure(let error):
                            callback(false, error, nil)
                        }
                    })
                    
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setStillQuality, .getStillQuality:
            getDevicePropDescFor(propCode: .stillQuality, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.stillQuality?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setStillFormat, .getStillFormat:
            getDevicePropDescFor(propCode: .stillFormat) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(event.supportedFunctions?.contains(function.function), nil, event.stillFormat?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            }
            callback(false, nil, nil)
        case .getPostviewImageSize, .setPostviewImageSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(false, nil, nil)
        case .setVideoFileFormat, .getVideoFileFormat:
            //TODO: Implement
            callback(false, nil, nil)
        case .setVideoQuality, .getVideoQuality:
            //TODO: Implement
            callback(false, nil, nil)
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
            //TODO: Implement
            callback(false, nil, nil)
        case .getEvent, .setCameraFunction, .getCameraFunction, .startRecordMode, .ping:
            callback(true, nil, nil)
        }
    }
    
}
