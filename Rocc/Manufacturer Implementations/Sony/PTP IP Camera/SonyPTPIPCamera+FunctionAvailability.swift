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
            
    //        getDevicePropDescFor(propCode: <#Code#>, callback: { (result) in
    //            switch result {
    //            case .success(let property):
    //                let event = CameraEvent(sonyDeviceProperties: [property])
    //                callback(event.availableFunctions?.contains(function.function), nil, event.<#Property#>?.available as? [T.SendType])
    //            case .failure(let error):
    //                callback(false, error, nil)
    //            }
    //        })
            
            // Fallback for functions that aren't related to a particular camera prop type, or that function differently to the PTP spec!
            // We re-use the `CameraEvent` logic which parses and munges the response into the correct types here. Really should be moved to a formatter!
            switch function.function {
            case .ping:
                callback(true, nil, nil)
            case .setAperture, .getAperture:
                getDevicePropDescFor(propCode: .fNumber, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.aperture?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setISO, .getISO:
                getDevicePropDescFor(propCode: .ISO, callback: { (result) in
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
                                callback(event.availableFunctions?.contains(function.function), nil, event.whiteBalance?.available as? [T.SendType])
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
                getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.shootMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setProgramShift, .getProgramShift:
                //TODO: Implement
                callback(false, nil, nil)
            case .takePicture, .startContinuousShooting, .endContinuousShooting, .startBulbCapture, .endBulbCapture:
                getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, nil)
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
            case .startLoopRecording, .endLoopRecording:
                //TODO: Implement
                callback(false, nil, nil)
            case .startLiveView, .startLiveViewWithSize, .endLiveView:
                callback(true, nil, nil)
            case .getLiveViewSize:
                //TODO: Implement
                callback(false, nil, nil)
            case .setSendLiveViewFrameInfo, .getSendLiveViewFrameInfo:
                //TODO: Implement
                callback(false, nil, nil)
            case .startZooming, .stopZooming:
                // If we get to this point, no way to tell if it's available as is setDeviceBValue
                callback(false, nil, nil)
            case .setZoomSetting, .getZoomSetting:
                //TODO: Implement
                callback(false, nil, nil)
            case .halfPressShutter, .cancelHalfPressShutter:
                getDevicePropDescFor(propCode: .autoFocus, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, nil)
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
                getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.continuousShootingMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
                getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.continuousShootingSpeed?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setSelfTimerDuration, .getSelfTimerDuration:
                getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.selfTimer?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setExposureMode, .getExposureMode:
                getDevicePropDescFor(propCode: .exposureProgramMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.exposureMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setFocusMode, .getFocusMode:
                getDevicePropDescFor(propCode: .focusMode, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.focusMode?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setExposureCompensation, .getExposureCompensation:
                getDevicePropDescFor(propCode: .exposureBiasCompensation, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.exposureCompensation?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setShutterSpeed, .getShutterSpeed:
                getDevicePropDescFor(propCode: .shutterSpeed, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.shutterSpeed?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setFlashMode, .getFlashMode:
                getDevicePropDescFor(propCode: .flashMode, callback: { (result) in
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
                                callback(event.availableFunctions?.contains(function.function), nil, event.stillSizeInfo?.available as? [T.SendType])
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
                        callback(event.availableFunctions?.contains(function.function), nil, event.stillQuality?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
            case .setStillFormat, .getStillFormat:
                getDevicePropDescFor(propCode: .stillFormat, callback: { (result) in
                    switch result {
                    case .success(let property):
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        callback(event.availableFunctions?.contains(function.function), nil, event.stillFormat?.available as? [T.SendType])
                    case .failure(let error):
                        callback(false, error, nil)
                    }
                })
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
            case .getEvent, .setCameraFunction, .getCameraFunction, .startRecordMode:
                callback(true, nil, nil)
            }
        }
}
