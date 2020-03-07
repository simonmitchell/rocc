//
//  Event+FunctionSupport.swift
//  Rocc
//
//  Created by Simon Mitchell on 14/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension CameraEvent {
    
    func supportsFunction<T: CameraFunction>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) {
        
        guard let supportedFunctions = supportedFunctions else {
            callback(false, nil, nil)
            return
        }
        guard supportedFunctions.contains(function.function) else {
            callback(false, nil, nil)
            return
        }
        
        switch function.function {
        case .setCameraFunction, .getCameraFunction:
            callback(true, nil, self.function?.supported as? [T.SendType])
        case .setAperture, .getAperture:
            callback(true, nil, self.aperture?.supported as? [T.SendType])
        case .setISO, .getISO:
            callback(true, nil, self.iso?.supported as? [T.SendType])
        case .setWhiteBalance, .getWhiteBalance:
            callback(true, nil, self.whiteBalance?.supported as? [T.SendType])
        case .setShootMode, .getShootMode:
            callback(true, nil, self.shootMode?.supported as? [T.SendType])
        case .setZoomSetting, .getZoomSetting:
            callback(true, nil, self.zoomSetting?.supported as? [T.SendType])
        case .setContinuousShootingMode, .getContinuousShootingMode:
            callback(true, nil, self.continuousShootingMode?.supported as? [T.SendType])
        case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
            callback(true, nil, self.continuousShootingSpeed?.supported as? [T.SendType])
        case .setSelfTimerDuration, .getSelfTimerDuration:
            callback(true, nil, self.selfTimer?.supported as? [T.SendType])
        case .setExposureMode, .getExposureMode:
            callback(true, nil, self.exposureMode?.supported as? [T.SendType])
        case .setFocusMode, .getFocusMode:
            callback(true, nil, self.focusMode?.supported as? [T.SendType])
        case .setExposureCompensation, .getExposureCompensation:
            callback(true, nil, self.exposureCompensation?.supported as? [T.SendType])
        case .setShutterSpeed, .getShutterSpeed:
            callback(true, nil, self.shutterSpeed?.supported as? [T.SendType])
        case .setFlashMode, .getFlashMode:
            callback(true, nil, self.flashMode?.supported as? [T.SendType])
        case .setStillSize, .getStillSize:
            callback(true, nil, self.stillSizeInfo?.supported as? [T.SendType])
        case .setStillQuality, .getStillQuality:
            callback(true, nil, self.stillQuality?.supported as? [T.SendType])
        case .setStillFormat, .getStillFormat:
            callback(true, nil, self.stillFormat?.supported as? [T.SendType])
        case .getPostviewImageSize, .setPostviewImageSize:
            callback(true, nil, self.postViewImageSize?.supported as? [T.SendType])
        case .setVideoFileFormat, .getVideoFileFormat:
            callback(true, nil, self.videoFileFormat?.supported as? [T.SendType])
        case .setVideoQuality, .getVideoQuality:
            callback(true, nil, self.videoQuality?.supported as? [T.SendType])
        case .setSteadyMode, .getSteadyMode:
            callback(true, nil, self.steadyMode?.supported as? [T.SendType])
        case .setViewAngle, .getViewAngle:
            callback(true, nil, self.viewAngle?.supported as? [T.SendType])
        case .setScene, .getScene:
            callback(true, nil, self.scene?.supported as? [T.SendType])
        case .setColorSetting, .getColorSetting:
            callback(true, nil, self.colorSetting?.supported as? [T.SendType])
        case .setIntervalTime, .getIntervalTime:
            callback(true, nil, self.intervalTime?.supported as? [T.SendType])
        case .setLoopRecordDuration, .getLoopRecordDuration:
            callback(true, nil, self.loopRecordTime?.supported as? [T.SendType])
        case .setWindNoiseReduction, .getWindNoiseReduction:
            callback(true, nil, self.windNoiseReduction?.supported as? [T.SendType])
        case .setAudioRecording, .getAudioRecording:
            callback(true, nil, self.audioRecording?.supported as? [T.SendType])
        case .setFlipSetting, .getFlipSetting:
            callback(true, nil, self.flipSetting?.supported as? [T.SendType])
        case .setTVColorSystem, .getTVColorSystem:
            callback(true, nil, self.tvColorSystem?.supported as? [T.SendType])
        case .setInfraredRemoteControl, .getInfraredRemoteControl:
            callback(true, nil, self.infraredRemoteControl?.supported as? [T.SendType])
        case .setAutoPowerOff, .getAutoPowerOff:
            callback(true, nil, self.autoPowerOff?.supported as? [T.SendType])
        case .setBeepMode, .getBeepMode:
            callback(true, nil, self.beepMode?.supported as? [T.SendType])
        //TODO: HFR
        default:
            // Some don't have supported values!
            callback(true, nil, nil)
        }
    }
    
    func isFunctionAvailable<T: CameraFunction>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) {
        
        guard let availableFunctions = availableFunctions else {
            callback(false, nil, nil)
            return
        }
        guard availableFunctions.contains(function.function) else {
            callback(false, nil, nil)
            return
        }
        
        switch function.function {
        case .setCameraFunction, .getCameraFunction:
            callback(true, nil, self.function?.available as? [T.SendType])
        case .setAperture, .getAperture:
            callback(true, nil, self.aperture?.available as? [T.SendType])
        case .setISO, .getISO:
            callback(true, nil, self.iso?.available as? [T.SendType])
        case .setWhiteBalance, .getWhiteBalance:
            callback(true, nil, self.whiteBalance?.available as? [T.SendType])
        case .setShootMode, .getShootMode:
            callback(true, nil, self.shootMode?.available as? [T.SendType])
        case .setZoomSetting, .getZoomSetting:
            callback(true, nil, self.zoomSetting?.available as? [T.SendType])
        case .setContinuousShootingMode, .getContinuousShootingMode:
            callback(true, nil, self.continuousShootingMode?.available as? [T.SendType])
        case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
            callback(true, nil, self.continuousShootingSpeed?.available as? [T.SendType])
        case .setSelfTimerDuration, .getSelfTimerDuration:
            callback(true, nil, self.selfTimer?.available as? [T.SendType])
        case .setExposureMode, .getExposureMode:
            callback(true, nil, self.exposureMode?.available as? [T.SendType])
        case .setFocusMode, .getFocusMode:
            callback(true, nil, self.focusMode?.available as? [T.SendType])
        case .setExposureCompensation, .getExposureCompensation:
            callback(true, nil, self.exposureCompensation?.available as? [T.SendType])
        case .setShutterSpeed, .getShutterSpeed:
            callback(true, nil, self.shutterSpeed?.available as? [T.SendType])
        case .setFlashMode, .getFlashMode:
            callback(true, nil, self.flashMode?.available as? [T.SendType])
        case .setStillSize, .getStillSize:
            callback(true, nil, self.stillSizeInfo?.available as? [T.SendType])
        case .setStillQuality, .getStillQuality:
            callback(true, nil, self.stillQuality?.available as? [T.SendType])
        case .setStillFormat, .getStillFormat:
            callback(true, nil, self.stillFormat?.available as? [T.SendType])
        case .getPostviewImageSize, .setPostviewImageSize:
            callback(true, nil, self.postViewImageSize?.available as? [T.SendType])
        case .setVideoFileFormat, .getVideoFileFormat:
            callback(true, nil, self.videoFileFormat?.available as? [T.SendType])
        case .setVideoQuality, .getVideoQuality:
            callback(true, nil, self.videoQuality?.available as? [T.SendType])
        case .setSteadyMode, .getSteadyMode:
            callback(true, nil, self.steadyMode?.available as? [T.SendType])
        case .setViewAngle, .getViewAngle:
            callback(true, nil, self.viewAngle?.available as? [T.SendType])
        case .setScene, .getScene:
            callback(true, nil, self.scene?.available as? [T.SendType])
        case .setColorSetting, .getColorSetting:
            callback(true, nil, self.colorSetting?.available as? [T.SendType])
        case .setIntervalTime, .getIntervalTime:
            callback(true, nil, self.intervalTime?.available as? [T.SendType])
        case .setLoopRecordDuration, .getLoopRecordDuration:
            callback(true, nil, self.loopRecordTime?.available as? [T.SendType])
        case .setWindNoiseReduction, .getWindNoiseReduction:
            callback(true, nil, self.windNoiseReduction?.available as? [T.SendType])
        case .setAudioRecording, .getAudioRecording:
            callback(true, nil, self.audioRecording?.available as? [T.SendType])
        case .setFlipSetting, .getFlipSetting:
            callback(true, nil, self.flipSetting?.available as? [T.SendType])
        case .setTVColorSystem, .getTVColorSystem:
            callback(true, nil, self.tvColorSystem?.available as? [T.SendType])
        case .setInfraredRemoteControl, .getInfraredRemoteControl:
            callback(true, nil, self.infraredRemoteControl?.available as? [T.SendType])
        case .setAutoPowerOff, .getAutoPowerOff:
            callback(true, nil, self.autoPowerOff?.available as? [T.SendType])
        case .setBeepMode, .getBeepMode:
            callback(true, nil, self.beepMode?.available as? [T.SendType])
        //TODO: HFR
        default:
            // Some don't have supported values!
            callback(true, nil, nil)
        }
    }
}
