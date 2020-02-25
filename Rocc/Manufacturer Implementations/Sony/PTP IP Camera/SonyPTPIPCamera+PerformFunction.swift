//
//  SonyPTPIPCamera+PerformFunction.swift
//  Rocc
//
//  Created by Simon Mitchell on 17/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

extension SonyPTPIPDevice {
    
    func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
        switch function.function {
        case .getEvent:
            
            guard !imageURLs.isEmpty, var lastEvent = lastEvent else {
                
                ptpIPClient?.getAllDevicePropDesc(callback: { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let properties):
                        let eventAndStillModes = CameraEvent.fromSonyDeviceProperties(properties)
                        var event = eventAndStillModes.event
                        self.lastStillCaptureModes = eventAndStillModes.stillCaptureModes
                        event.postViewPictureURLs = self.imageURLs[.photo].flatMap({ return [$0] })
                        event.continuousShootingURLS = self.imageURLs[.continuous]?.compactMap({ (url) -> (postView: URL, thumbnail: URL) in
                            return (postView: url, thumbnail: url)
                        })
                        self.imageURLs = [:]
                        callback(nil, event as? T.ReturnType)
                    case .failure(let error):
                        callback(error, nil)
                    }
                })
                
                return
            }
            
            lastEvent.postViewPictureURLs = self.imageURLs[.photo].flatMap({ return [$0] })
            lastEvent.continuousShootingURLS = self.imageURLs[.continuous]?.compactMap({ (url) -> (postView: URL, thumbnail: URL) in
                return (postView: url, thumbnail: url)
            })
            
            imageURLs = [:]
            callback(nil, lastEvent as? T.ReturnType)
            
        case .setShootMode:
            guard let value = payload as? ShootingMode else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            guard let stillCapMode = bestStillCaptureMode(for: value) else {
                guard let exposureProgrammeMode = self.bestExposureProgrammeModes(for: value, currentExposureProgrammeMode: self.lastEvent?.exposureMode?.current)?.first else {
                    callback(FunctionError.notAvailable, nil)
                    return
                }
                self.setExposureProgrammeMode(exposureProgrammeMode) { (programmeError) in
                    // We return error here, as if callers obey the available shoot modes they shouldn't be calling this with an invalid value
                    callback(programmeError, nil)
                }
                return
            }
            setStillCaptureMode(stillCapMode) { [weak self] (error) in
                guard let self = self, error == nil, let exposureProgrammeMode = self.bestExposureProgrammeModes(for: value, currentExposureProgrammeMode: self.lastEvent?.exposureMode?.current)?.first else {
                    callback(error, nil)
                    return
                }
                self.setExposureProgrammeMode(exposureProgrammeMode) { (programmeError) in
                    // We return error here, as if callers obey the available shoot modes they shouldn't be calling this with an invalid value
                    callback(programmeError, nil)
                }
            }
        case .getShootMode:
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { [weak self] (result) in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let property):
                    self.getDevicePropDescFor(propCode: .exposureProgramMode) { (exposureProgrammeResult) in
                        switch exposureProgrammeResult {
                        case .success(let exposureProperty):
                            let event = CameraEvent.fromSonyDeviceProperties([property, exposureProperty]).event
                            callback(nil, event.shootMode?.current as? T.ReturnType)
                        case .failure(_):
                            // Ignore the error here as can still get a good estimation from still cap mode
                            let event = CameraEvent.fromSonyDeviceProperties([property]).event
                            callback(nil, event.shootMode?.current as? T.ReturnType)
                        }
                    }
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .setContinuousShootingMode:
            // This isn't a thing via PTP according to Sony's app (Instead we just have multiple continuous shooting speeds) so we just don't do anything!
            callback(nil, nil)
        case .setISO, .setShutterSpeed, .setAperture, .setExposureCompensation, .setFocusMode, .setExposureMode, .setExposureModeDialControl, .setFlashMode, .setContinuousShootingSpeed, .setStillQuality, .setStillFormat:
            guard let value = payload as? SonyPTPPropValueConvertable else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(value),
                callback: { (response) in
                    callback(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil, nil)
                }
            )
        case .getISO:
            getDevicePropDescFor(propCode: .ISO, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.iso?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getShutterSpeed:
            getDevicePropDescFor(propCode: .shutterSpeed, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.shutterSpeed?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getAperture:
            getDevicePropDescFor(propCode: .fNumber, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.aperture?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getExposureCompensation:
            getDevicePropDescFor(propCode: .exposureBiasCompensation, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.aperture?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getFocusMode:
            getDevicePropDescFor(propCode: .focusMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.focusMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getExposureMode:
            getDevicePropDescFor(propCode: .exposureProgramMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.exposureMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getExposureModeDialControl:
            getDevicePropDescFor(propCode: .exposureProgramModeControl, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.exposureMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getFlashMode:
            getDevicePropDescFor(propCode: .flashMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.flashMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .setStillSize:
            guard let stillSize = payload as? StillSize else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            var stillSizeByte: Byte? = nil
            switch stillSize.size {
            case "L":
                stillSizeByte = 0x01
            case "M":
                stillSizeByte = 0x02
            case "S":
                stillSizeByte = 0x03
            default:
                break
            }
            
            if let _stillSizeByte = stillSizeByte {
                ptpIPClient?.sendSetControlDeviceAValue(
                    PTP.DeviceProperty.Value(
                        code: .imageSizeSony,
                        type: .uint8,
                        value: _stillSizeByte
                    )
                )
            }
            
            guard let aspect = stillSize.aspectRatio else { return }
            
            var aspectRatioByte: Byte? = nil
            switch aspect {
            case "3:2":
                aspectRatioByte = 0x01
            case "16:9":
                aspectRatioByte = 0x02
            case "1:1":
                aspectRatioByte = 0x04
            default:
                break
            }
            
            guard let _aspectRatioByte = aspectRatioByte else { return }
            
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(
                    code: .imageSizeSony,
                    type: .uint8,
                    value: _aspectRatioByte
                )
            )
            
        case .getStillSize:
            
            // Still size requires still size and ratio codes to be fetched!
            getDevicePropDescFor(propCode: .imageSizeSony, callback: { [weak self] (imageSizeResult) in
                
                guard let this = self else {
                    callback(nil, nil)
                    return
                }
                
                switch imageSizeResult {
                case .success(let imageSizeProperty):
                    this.getDevicePropDescFor(propCode: .aspectRatio, callback: { (aspectResult) in
                        switch aspectResult {
                        case .success(let aspectProperty):
                            let event = CameraEvent.fromSonyDeviceProperties([imageSizeProperty, aspectProperty]).event
                            callback(nil, event.stillSizeInfo?.stillSize as? T.ReturnType)
                        case .failure(let error):
                            callback(error, nil)
                        }
                    })
                    
                case .failure(let error):
                    callback(error, nil)
                }
            })
            
        case .setSelfTimerDuration:
            guard let timeInterval = payload as? TimeInterval else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            let value: SonyStillCaptureMode
            switch timeInterval {
            case 0.0:
                value = .single
            case 2.0:
                value = .timer2
            case 5.0:
                value = .timer5
            case 10.0:
                // Pick out whichever 10 second timer duration is available
                value = lastStillCaptureModes?.available.first(where: { (stillCapMode) -> Bool in
                    return stillCapMode.isSingleTimerMode && stillCapMode.timerDuration == 10.0
                }) ?? .timer10_a
            default:
                value = .single
            }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(value)
            )
        case .getSelfTimerDuration:
            
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.selfTimer?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
            
        case .setWhiteBalance:
            
            guard let value = payload as? WhiteBalance.Value else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(value.mode)
            )
            guard let colorTemp = value.temperature else { return }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(
                    code: .colorTemp,
                    type: .uint16,
                    value: Word(colorTemp)
                )
            )
            
        case .getWhiteBalance:
            
            // White balance requires white balance and colorTemp codes to be fetched!
            getDevicePropDescFor(propCode: .whiteBalance, callback: { [weak self] (wbResult) in
                
                guard let this = self else {
                    callback(nil, nil)
                    return
                }
                
                switch wbResult {
                case .success(let wbProperty):
                    this.getDevicePropDescFor(propCode: .colorTemp, callback: { (ctResult) in
                        switch ctResult {
                        case .success(let ctProperty):
                            let event = CameraEvent.fromSonyDeviceProperties([wbProperty, ctProperty]).event
                            callback(nil, event.whiteBalance?.whitebalanceValue as? T.ReturnType)
                        case .failure(let error):
                            callback(error, nil)
                        }
                    })
                    
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .setupCustomWhiteBalanceFromShot:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setProgramShift, .getProgramShift:
            // Not available natively with PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .takePicture:
            takePicture { (result) in
                switch result {
                case .success(let url):
                    callback(nil, url as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .startContinuousShooting:
            startCapturing { (error) in
                callback(error, nil)
            }
            callback(nil, nil)
        case .endContinuousShooting:
            finishCapturing() { (result) in
                switch result {
                case .failure(let error):
                    callback(error, nil)
                case .success(let url):
                    callback(nil, url as? T.ReturnType)
                }
            }
        case .startVideoRecording:
            self.ptpIPClient?.sendSetControlDeviceBValue(
                PTP.DeviceProperty.Value(
                    code: .movie,
                    type: .uint16,
                    value: Word(2)
                ),
                callback: { (videoResponse) in
                    guard !videoResponse.code.isError else {
                        callback(PTPError.commandRequestFailed(videoResponse.code), nil)
                        return
                    }
                    callback(nil, nil)
                }
            )
        case .endVideoRecording:
            self.ptpIPClient?.sendSetControlDeviceBValue(
                PTP.DeviceProperty.Value(
                    code: .movie,
                    type: .uint16,
                    value: Word(1)
                ),
                callback: { (videoResponse) in
                    guard !videoResponse.code.isError else {
                        callback(PTPError.commandRequestFailed(videoResponse.code), nil)
                        return
                    }
                    callback(nil, nil)
                }
            )
        case .startAudioRecording, .endAudioRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .startIntervalStillRecording, .endIntervalStillRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .startLoopRecording, .endLoopRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .startBulbCapture:
            startCapturing { (error) in
                callback(error, nil)
            }
        case .endBulbCapture:
            finishCapturing() { (result) in
                switch result {
                case .failure(let error):
                    callback(error, nil)
                case .success(let url):
                    callback(nil, url as? T.ReturnType)
                }
            }
        case .startLiveView, .startLiveViewWithSize, .endLiveView:
            callback(nil, apiDeviceInfo.liveViewURL as? T.ReturnType)
        case .getLiveViewSize:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .setSendLiveViewFrameInfo:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .getSendLiveViewFrameInfo:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .startZooming:
            guard let direction = payload as? Zoom.Direction else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            startZooming(direction: direction) { (error) in
                callback(error, nil)
            }
        case .stopZooming:
            stopZooming { (error) in
                callback(error, nil)
            }
        case .setZoomSetting, .getZoomSetting:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .halfPressShutter, .cancelHalfPressShutter:
            ptpIPClient?.sendSetControlDeviceBValue(
                PTP.DeviceProperty.Value(
                    code: .autoFocus,
                    type: .uint16,
                    value: function.function == .halfPressShutter ? Word(2) : Word(1)
                ), callback: { response in
                    callback(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil, nil)
                }
            )
        case .setTouchAFPosition, .getTouchAFPosition, .cancelTouchAFPosition, .startTrackingFocus, .stopTrackingFocus, .setTrackingFocus, .getTrackingFocus:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .getContinuousShootingMode:
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.continuousShootingMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
            callback(nil, nil)
        case .getContinuousShootingSpeed:
            getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.continuousShootingSpeed?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getStillQuality:
            getDevicePropDescFor(propCode: .stillQuality, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.stillQuality?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getPostviewImageSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setPostviewImageSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setVideoFileFormat:
            //TODO: Implement
            callback(nil, nil)
        case .getVideoFileFormat:
            //TODO: Implement
            callback(nil, nil)
        case .setVideoQuality:
            //TODO: Implement
            callback(nil, nil)
        case .getVideoQuality:
            //TODO: Implement
            callback(nil, nil)
        case .setSteadyMode:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getSteadyMode:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setViewAngle:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getViewAngle:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setScene:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getScene:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setColorSetting:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getColorSetting:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setIntervalTime, .getIntervalTime:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setLoopRecordDuration, .getLoopRecordDuration:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setWindNoiseReduction:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getWindNoiseReduction:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setAudioRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getAudioRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setFlipSetting, .getFlipSetting:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setTVColorSystem, .getTVColorSystem:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .listContent, .getContentCount, .listSchemes, .listSources, .deleteContent, .setStreamingContent, .startStreaming, .pauseStreaming, .seekStreamingPosition, .stopStreaming, .getStreamingStatus:
            // Not available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .getInfraredRemoteControl, .setInfraredRemoteControl:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setAutoPowerOff, .getAutoPowerOff:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setBeepMode, .getBeepMode:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setCurrentTime:
            //TODO: Implement
            callback(nil, nil)
        case .getStorageInformation:
            //TODO: Implement
            callback(nil, nil)
        case .setCameraFunction:
            callback(CameraError.noSuchMethod("setCameraFunction"), nil)
        case .getCameraFunction:
            callback(CameraError.noSuchMethod("getCameraFunction"), nil)
        case .ping:
            ptpIPClient?.ping(callback: { (error) in
                callback(nil, nil)
            })
        case .startRecordMode:
            callback(CameraError.noSuchMethod("startRecordMode"), nil)
        case .getStillFormat:
            getDevicePropDescFor(propCode: .stillFormat, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.stillFormat?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
            return
        }
    }
}
