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
            ptpIPClient?.getDevicePropDescFor(propCode: .fNumber, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.aperture?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setISO, .getISO:
            ptpIPClient?.getDevicePropDescFor(propCode: .ISO, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.iso?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setWhiteBalance, .getWhiteBalance:
            // White balance requires white balance and colorTemp codes to be fetched!
            ptpIPClient?.getDevicePropDescFor(propCode: .whiteBalance, callback: { [weak self] (wbResult) in
                
                guard let this = self else {
                    callback(false, nil, nil)
                    return
                }
                
                switch wbResult {
                case .success(let wbProperty):
                    this.ptpIPClient?.getDevicePropDescFor(propCode: .colorTemp, callback: { (ctResult) in
                        switch ctResult {
                        case .success(let ctProperty):
                            let event = CameraEvent(sonyDeviceProperties: [wbProperty, ctProperty])
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
            //TODO: Implement
            callback(false, nil, nil)
            break
        case .setShootMode, .getShootMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.shootMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setProgramShift, .getProgramShift:
            //TODO: Implement
            callback(false, nil, nil)
        case .takePicture:
            //TODO: Implement
            callback(false, nil, nil)
        case .startContinuousShooting, .endContinuousShooting:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .startVideoRecording, .endVideoRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .startAudioRecording, .endAudioRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .startIntervalStillRecording, .endIntervalStillRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .startBulbCapture, .endBulbCapture:
            //TODO: Implement
            callback(false, nil, nil)
        case .startLoopRecording, .endLoopRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .startLiveView:
            //TODO: Implement
            callback(false, nil, nil)
        case .startLiveViewWithSize:
            //TODO: Implement
            callback(false, nil, nil)
        case .endLiveView:
            //TODO: Implement
            callback(false, nil, nil)
        case .getLiveViewSize:
            //TODO: Implement
            callback(false, nil, nil)
        case .setSendLiveViewFrameInfo, .getSendLiveViewFrameInfo:
            //TODO: Implement
            callback(false, nil, nil)
        case .startZooming, .stopZooming:
            //TODO: Implement
            callback(false, nil, nil)
        case .setZoomSetting, .getZoomSetting:
            //TODO: Implement
            callback(false, nil, nil)
        case .halfPressShutter, .cancelHalfPressShutter:
            ptpIPClient?.getDevicePropDescFor(propCode: .autoFocus, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, nil)
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setTouchAFPosition, .getTouchAFPosition, .cancelTouchAFPosition:
            //TODO: Implement
            callback(false, nil, nil)
        case .startTrackingFocus, .stopTrackingFocus:
            //TODO: Implement
            callback(false, nil, nil)
        case .setTrackingFocus, .getTrackingFocus:
            //TODO: Implement
            callback(false, nil, nil)
        case .setContinuousShootingMode, .getContinuousShootingMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.continuousShootingMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.continuousShootingSpeed?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setSelfTimerDuration, .getSelfTimerDuration:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.selfTimer?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureMode, .getExposureMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .exposureProgramMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.exposureMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setFocusMode, .getFocusMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .focusMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.focusMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureCompensation, .getExposureCompensation:
            ptpIPClient?.getDevicePropDescFor(propCode: .exposureBiasCompensation, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.exposureCompensation?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setShutterSpeed, .getShutterSpeed:
            ptpIPClient?.getDevicePropDescFor(propCode: .shutterSpeed, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.shutterSpeed?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setFlashMode, .getFlashMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .flashMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.supportedFunctions?.contains(function.function), nil, event.flashMode?.supported as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setStillSize, .getStillSize:
            // Still size requires still size and ratio codes to be fetched!
            ptpIPClient?.getDevicePropDescFor(propCode: .imageSizeSony, callback: { [weak self] (imageSizeResult) in
                
                guard let this = self else {
                    callback(false, nil, nil)
                    return
                }
                
                switch imageSizeResult {
                case .success(let imageSizeProperty):
                    this.ptpIPClient?.getDevicePropDescFor(propCode: .aspectRatio, callback: { (aspectResult) in
                        switch aspectResult {
                        case .success(let aspectProperty):
                            let event = CameraEvent(sonyDeviceProperties: [imageSizeProperty, aspectProperty])
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
            //TODO: Implement
            callback(false, nil, nil)
        case .getPostviewImageSize, .setPostviewImageSize:
            //TODO: Implement
            callback(false, nil, nil)
        case .setVideoFileFormat, .getVideoFileFormat:
            //TODO: Implement
            callback(false, nil, nil)
        case .setVideoQuality, .getVideoQuality:
            //TODO: Implement
            callback(false, nil, nil)
        case .setSteadyMode, .getSteadyMode:
            //TODO: Implement
            callback(false, nil, nil)
        case .setViewAngle, .getViewAngle:
            //TODO: Implement
            callback(false, nil, nil)
        case .setScene, .getScene:
            //TODO: Implement
            callback(false, nil, nil)
        case .setColorSetting, .getColorSetting:
            //TODO: Implement
            callback(false, nil, nil)
        case .setIntervalTime, .getIntervalTime:
            //TODO: Implement
            callback(false, nil, nil)
        case .setLoopRecordDuration, .getLoopRecordDuration:
            //TODO: Implement
            callback(false, nil, nil)
        case .setWindNoiseReduction, .getWindNoiseReduction:
            //TODO: Implement
            callback(false, nil, nil)
        case .setAudioRecording, .getAudioRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .setFlipSetting, .getFlipSetting:
            //TODO: Implement
            callback(false, nil, nil)
        case .setTVColorSystem, .getTVColorSystem:
            //TODO: Implement
            callback(false, nil, nil)
        case .listContent:
            //TODO: Implement
            callback(false, nil, nil)
        case .getContentCount:
            //TODO: Implement
            callback(false, nil, nil)
        case .listSchemes:
            //TODO: Implement
            callback(false, nil, nil)
        case .listSources:
            //TODO: Implement
            callback(false, nil, nil)
        case .deleteContent:
            //TODO: Implement
            callback(false, nil, nil)
        case .setStreamingContent:
            //TODO: Implement
            callback(false, nil, nil)
        case .startStreaming:
            //TODO: Implement
            callback(false, nil, nil)
        case .pauseStreaming:
            //TODO: Implement
            callback(false, nil, nil)
        case .seekStreamingPosition:
            //TODO: Implement
            callback(false, nil, nil)
        case .stopStreaming:
            //TODO: Implement
            callback(false, nil, nil)
        case .getStreamingStatus:
            //TODO: Implement
            callback(false, nil, nil)
        case .setInfraredRemoteControl, .getInfraredRemoteControl:
            //TODO: Implement
            callback(false, nil, nil)
        case .setAutoPowerOff, .getAutoPowerOff:
            //TODO: Implement
            callback(false, nil, nil)
        case .setBeepMode, .getBeepMode:
            //TODO: Implement
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
