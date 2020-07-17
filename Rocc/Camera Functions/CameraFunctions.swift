//
//  CameraFunctions.swift
//  Rocc
//
//  Created by Simon Mitchell on 30/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// An enum prepresentation of all available camera functions
public enum _CameraFunction: String, CaseIterable {
    case setAperture
    case getAperture
    case setISO
    case getISO
    case setWhiteBalance
    case getWhiteBalance
    case setupCustomWhiteBalanceFromShot
    case setShootMode
    case getShootMode
    case setProgramShift
    case getProgramShift
    case takePicture
    case setExposureSettingsLock
    case getExposureSettingsLock
    case recordHighFrameRateCapture
    case startContinuousShooting
    case endContinuousShooting
    case startVideoRecording
    case endVideoRecording
    case startAudioRecording
    case endAudioRecording
    case startIntervalStillRecording
    case endIntervalStillRecording
    case startBulbCapture
    case endBulbCapture
    case startLoopRecording
    case endLoopRecording
    case startLiveView
    case startLiveViewWithQuality
    case endLiveView
    case getLiveViewQuality
    case setLiveViewQuality
    case setSendLiveViewFrameInfo
    case getSendLiveViewFrameInfo
    case startZooming
    case stopZooming
    case setZoomSetting
    case getZoomSetting
    case halfPressShutter
    case cancelHalfPressShutter
    case setTouchAFPosition
    case getTouchAFPosition
    case cancelTouchAFPosition
    case startTrackingFocus
    case stopTrackingFocus
    case setTrackingFocus
    case getTrackingFocus
    case setContinuousShootingMode
    case getContinuousShootingMode
    case setContinuousShootingSpeed
    case getContinuousShootingSpeed
    case setSelfTimerDuration
    case getSelfTimerDuration
    case setExposureMode
    case getExposureMode
    case setExposureModeDialControl
    case getExposureModeDialControl
    case setFocusMode
    case getFocusMode
    case setExposureCompensation
    case getExposureCompensation
    case setShutterSpeed
    case getShutterSpeed
    case setFlashMode
    case getFlashMode
    case setStillSize
    case getStillSize
    case setStillQuality
    case getStillQuality
    case setStillFormat
    case getStillFormat
    case getPostviewImageSize
    case setPostviewImageSize
    case setVideoFileFormat
    case getVideoFileFormat
    case setVideoQuality
    case getVideoQuality
    case setSteadyMode
    case getSteadyMode
    case setViewAngle
    case getViewAngle
    case setScene
    case getScene
    case setColorSetting
    case getColorSetting
    case setIntervalTime
    case getIntervalTime
    case setLoopRecordDuration
    case getLoopRecordDuration
    case setWindNoiseReduction
    case getWindNoiseReduction
    case setAudioRecording
    case getAudioRecording
    case setFlipSetting
    case getFlipSetting
    case setTVColorSystem
    case getTVColorSystem
    case listContent
    case getContentCount
    case listSchemes
    case listSources
    case deleteContent
    case setStreamingContent
    case startStreaming
    case pauseStreaming
    case seekStreamingPosition
    case stopStreaming
    case getStreamingStatus
    case setInfraredRemoteControl
    case getInfraredRemoteControl
    case setAutoPowerOff
    case getAutoPowerOff
    case setBeepMode
    case getBeepMode
    case setCurrentTime
    case getStorageInformation
    case getEvent
    case setCameraFunction
    case getCameraFunction
    case ping
    case startRecordMode
    case startContinuousBracketShooting
    case stopContinuousBracketShooting
    case takeSingleBracketShot
    case setContinuousBracketedShootingBracket
    case getContinuousBracketedShootingBracket
    case setSingleBracketedShootingBracket
    case getSingleBracketedShootingBracket
}

/// A protocol which can be adopted to define a function that can be performed on any given camera
public protocol CameraFunction {
    
    /// An associated type which is taken as an input when calling this function on a `Camera` instance
    associatedtype SendType: Equatable
    
    /// An associated type which is returned from the camera when calling this function on the `Camera`
    associatedtype ReturnType: Equatable
    
    /// The enum representation of this given function
    var function: _CameraFunction { get }
}
