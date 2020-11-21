//
//  SonyFunctionNames.swift
//  Rocc
//
//  Created by Simon Mitchell on 29/10/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

extension _CameraFunction {
    var sonyCameraMethodName: String? {
        switch self {
        case .ping,
             .setContinuousBracketedShootingBracket, .getContinuousBracketedShootingBracket,
             .startContinuousBracketShooting, .stopContinuousBracketShooting,
             .setSingleBracketedShootingBracket, .getSingleBracketedShootingBracket,
             .takeSingleBracketShot:
            return nil
        case .setShootMode:
            return "setShootMode"
        case .getShootMode:
            return "getShootMode"
        case .setAperture:
            return "setFNumber"
        case .getAperture:
            return "getFNumber"
        case .setISO:
            return "setIsoSpeedRate"
        case .getISO:
            return "getIsoSpeedRate"
        case .setWhiteBalance:
            return "setWhiteBalance"
        case .getWhiteBalance:
            return "getWhiteBalance"
        case .setupCustomWhiteBalanceFromShot:
            return "actWhiteBalanceOnePushCustom"
        case .setProgramShift:
            return "setProgramShift"
        case .getProgramShift:
            return nil
        case .takePicture:
            return "actTakePicture"
        case .startBulbCapture:
            return "startBulbShooting"
        case .endBulbCapture:
            return "stopBulbShooting"
        case .startContinuousShooting:
            return "startContShooting"
        case .endContinuousShooting:
            return "stopContShooting"
        case .startVideoRecording:
            return "startMovieRec"
        case .endVideoRecording:
            return "stopMovieRec"
        case .startAudioRecording:
            return "startAudioRec"
        case .endAudioRecording:
            return "stopAudioRec"
        case .startIntervalStillRecording:
            return "startIntervalStillRec"
        case .endIntervalStillRecording:
            return "stopIntervalStillRec"
        case .startLoopRecording:
            return "startLoopRec"
        case .endLoopRecording:
            return "stopLoopRec"
        case .startLiveView:
            return "startLiveview"
        case .endLiveView:
            return "stopLiveview"
        case .startLiveViewWithQuality, .setLiveViewQuality:
            return "startLiveviewWithSize"
        case .getLiveViewQuality:
            return "getLiveViewSize"            
        case .setSendLiveViewFrameInfo:
            return "setLiveviewFrameInfo"
        case .getSendLiveViewFrameInfo:
            return "getLiveviewFrameInfo"
        case .startZooming, .stopZooming:
            return "actZoom"
        case .setZoomSetting:
            return "setZoomSetting"
        case .getZoomSetting:
            return "getZoomSetting"
        case .halfPressShutter:
            return "actHalfPressShutter"
        case .cancelHalfPressShutter:
            return "cancelHalfPressShutter"
        case .setTouchAFPosition:
            return "setTouchAFPosition"
        case .getTouchAFPosition:
            return "getTouchAFPosition"
        case .cancelTouchAFPosition:
            return "cancelTouchAFPosition"
        case .startTrackingFocus:
            return "actTrackingFocus"
        case .stopTrackingFocus:
            return "cancelTrackingFocus"
        case .setTrackingFocus:
            return "setTrackingFocus"
        case .getTrackingFocus:
            return "getTrackingFocus"
        case .setContinuousShootingMode:
            return "setContShootingMode"
        case .getContinuousShootingMode:
            return "getContShootingMode"
        case .setContinuousShootingSpeed:
            return "setContShootingSpeed"
        case .getContinuousShootingSpeed:
            return "getContShootingSpeed"
        case .setSelfTimerDuration:
            return "setSelfTimer"
        case .getSelfTimerDuration:
            return "getSelfTimer"
            // Not supported apart from PTP/IP
        case .setExposureModeDialControl, .getExposureModeDialControl, .recordHighFrameRateCapture, .setExposureSettingsLock, .getExposureSettingsLock:
            return nil
        case .setExposureMode:
            return "setExposureMode"
        case .getExposureMode:
            return "getExposureMode"
        case .setFocusMode:
            return "setFocusMode"
        case .getFocusMode:
            return "getFocusMode"
        case .setExposureCompensation:
            return "setExposureCompensation"
        case .getExposureCompensation:
            return "getExposureCompensation"
        case .setShutterSpeed:
            return "setShutterSpeed"
        case .getShutterSpeed:
            return "getShutterSpeed"
        case .setFlashMode:
            return "setFlashMode"
        case .getFlashMode:
            return "getFlashMode"
        case .setStillSize:
            return "setStillSize"
        case .getStillSize:
            return "getStillSize"
        case .setStillQuality, .setStillFormat:
            return "setStillQuality"
        case .getStillQuality, .getStillFormat:
            return "getStillQuality"
        case .getPostviewImageSize:
            return "getPostviewImageSize"
        case .setPostviewImageSize:
            return "setPostviewImageSize"
        case .setVideoFileFormat:
            return "setMovieFileFormat"
        case .getVideoFileFormat:
            return "getMovieFileFormat"
        case .setVideoQuality:
            return "setMovieQuality"
        case .getVideoQuality:
            return "getMovieQuality"
        case .setSteadyMode:
            return "setSteadyMode"
        case .getSteadyMode:
            return "getSteadyMode"
        case .setViewAngle:
            return "setViewAngle"
        case .getViewAngle:
            return "getViewAngle"
        case .setScene:
            return "setSceneSelection"
        case .getScene:
            return "getSceneSelection"
        case .setColorSetting:
            return "setColorSetting"
        case .getColorSetting:
            return "getColorSetting"
        case .setIntervalTime:
            return "setIntervalTime"
        case .getIntervalTime:
            return "getIntervalTime"
        case .setLoopRecordDuration:
            return "setLoopRecTime"
        case .getLoopRecordDuration:
            return "getLoopRecTime"
        case .setWindNoiseReduction:
            return "setWindNoiseReduction"
        case .getWindNoiseReduction:
            return "getWindNoiseReduction"
        case .setAudioRecording:
            return "setAudioRecording"
        case .getAudioRecording:
            return "getAudioRecording"
        case .setFlipSetting:
            return "setFlipSetting"
        case .getFlipSetting:
            return "getFlipSetting"
        case .setTVColorSystem:
            return "setTvColorSystem"
        case .getTVColorSystem:
            return "getTvColorSystem"
        case .getContentCount:
            return "getContentCount"
        case .listContent:
            return "getContentList"
        case .listSchemes:
            return "getSchemeList"
        case .listSources:
            return "getSourceList"
        case .deleteContent:
            return "deleteContent"
        case .setStreamingContent:
            return "setStreamingContent"
        case .startStreaming:
            return "startStreaming"
        case .pauseStreaming:
            return "pauseStreaming"
        case .seekStreamingPosition:
            return "seekStreamingPosition"
        case .stopStreaming:
            return "stopStreaming"
        case .getStreamingStatus:
            return "requestToNotifyStreamingStatus"
        case .setInfraredRemoteControl:
            return "setInfraredRemoteControl"
        case .getInfraredRemoteControl:
            return "getInfraredRemoteControl"
        case .setAutoPowerOff:
            return "setAutoPowerOff"
        case .getAutoPowerOff:
            return "getAutoPowerOff"
        case .setBeepMode:
            return "setBeepMode"
        case .getBeepMode:
            return "getBeepMode"
        case .setCurrentTime:
            return "setCurrentTime"
        case .getStorageInformation:
            return "getStorageInformation"
        case .getEvent:
            return "getEvent"
        case .setCameraFunction:
            return "setCameraFunction"
        case .getCameraFunction:
            return "getCameraFunction"
        case .startRecordMode:
            return "startRecMode"
        }
    }
    
    var isAVContentFunction: Bool {
        switch self {
        case .listSchemes, .listSources, .listContent, .getContentCount, .setStreamingContent, .startStreaming, .pauseStreaming, .stopStreaming, .seekStreamingPosition, .getStreamingStatus, .deleteContent:
            return true
        default:
            return false
        }
    }
    
    var requiresAPICheckForSupport: Bool {
        switch self {
            // Because these are undocumented, we need to check if it's supported!
        case .startBulbCapture, .endBulbCapture:
            return true
        default:
            return false
        }
    }
}
