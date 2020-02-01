//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// A structural representation of still image size configuration
public struct StillSize {
    
    /// The aspect ratio of the size
    let aspectRatio: String?
    
    /// The size itself
    let size: String
}

/// Functions for interacting with the camera's still capture API.
public struct StillCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Void
    
    public typealias ReturnType = URL
    
    /// Makes the camera take a still image.
    public static let take = StillCapture(function: .takePicture)
    
    /// Functions for configuring the still capture size setting
    public struct Size: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = StillSize
        
        public typealias ReturnType = StillSize
        
        /// Sets the still image capture size setting
        public static let set = Size(function: .setStillSize)
        
        /// Returns the current still image size setting
        public static let get = Size(function: .getStillSize)
    }
    
    /// Functions for configuring the still capture quality setting
    public struct Quality: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Sets the still image capture quality
        public static let set = Quality(function: .setStillQuality)
        
        /// Returns the current still image capture quality
        public static let get = Quality(function: .getStillQuality)
    }
}

/// Functions to control the duration of the camera's self timer function.
public struct SelfTimerDuration: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = TimeInterval
    
    public typealias ReturnType = TimeInterval
    
    /// Sets the self timer duration.
    public static let set = SelfTimerDuration(function: .setSelfTimerDuration)
    
    /// Gets the current self timer duration.
    public static let get = SelfTimerDuration(function: .getSelfTimerDuration)
}

/// Functions for interacting with the camera's audio capture API
public struct AudioCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Void
    
    public typealias ReturnType = Void
    
    /// Starts audio capture
    public static let start = AudioCapture(function: .startAudioRecording)
    
    /// Ends audio capture
    public static let stop = AudioCapture(function: .endAudioRecording)
}

/// Functions for interacting with the camera's continuous capture API
public struct ContinuousCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Void
    
    public typealias ReturnType = Void
    
    /// Starts continuous capture of stills
    public static let start = ContinuousCapture(function: .startContinuousShooting)
    
    /// Ends continuous capture of stills
    public static let stop = ContinuousCapture(function: .endContinuousShooting)
    
    /// Functions for interacting with the continuous shooting mode
    public struct Mode: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = ContinuousShootingMode
        
        public typealias ReturnType = ContinuousShootingMode
        
        /// Sets the continous shooting mode
        public static let set = ContinuousCapture.Mode(function: .setContinuousShootingMode)
        
        /// Returns the current continuous shooting mode
        public static let get = ContinuousCapture.Mode(function: .getContinuousShootingMode)
    }
    
    /// Functions for interacting with the continuous shooting speed
    public struct Speed: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = ContinuousShootingSpeed
        
        public typealias ReturnType = ContinuousShootingSpeed
        
        /// Sets the continuous shooting speed
        public static let set = ContinuousCapture.Speed(function: .setContinuousShootingSpeed)
        
        /// Returns the current continuous shooting speed
        public static let get = ContinuousCapture.Speed(function: .getContinuousShootingSpeed)
    }
}

/// Enumeration representing the shooting mode which a camera is using
///
/// - single: A single shot for each shutter press
/// - continuous: Shoot continuously whilst the shutter button is pressed
/// - spdPriorityContinuous: Shoots continuously (At higher speed than continuous) whilst the shutter button is pressed
/// - burst: Shoots a burst
/// - motionShot: Takes shots using Sony's "MotionShot" technology
public enum ContinuousShootingMode: String {
    case single
    case continuous
    case spdPriorityContinuous = "spd priority cont."
    case burst
    case motionShot = "motionshot"
}

/// Enumeration representing the shooting speed for continuous shooting
///
/// - high: High speed
/// - low: Low speed
public enum ContinuousShootingSpeed: String {
    case regular
    case high = "hi"
    case highPlus
    case low
    case tenFps1Sec = "10fps 1 sec"
    case eightFps1Sec = "8fps 1 sec"
    case fiveFps2Sec = "5fps 2 sec"
    case twoFps5Sec = "2fps 5 sec"
    case s
}

/// Functions for interacting with the camera's video capture API
public struct VideoCapture: CameraFunction {
    
    /// Functions for controlling the file format that the video will be captured in
    struct FileFormat: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Sets the file format for video recording
        public static let set = FileFormat(function: .setVideoFileFormat)
        
        /// Returns the current file format for video recording
        public static let get = FileFormat(function: .getVideoFileFormat)
    }
    
    /// Functions for controlling the quality of video recording
    struct Quality: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Gets the current video recording quality
        public static let get = Quality(function: .setVideoQuality)
        
        /// Sets the video recording quality
        public static let set = Quality(function: .getVideoQuality)
    }
    
    /// Functions for controlling whether audio is captured along with video
    public struct Audio: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Sets whether audio should be recorded along with video
        public static let set = Audio(function: .setAudioRecording)
        
        /// Returns whether audio is being recorded along with video
        public static let get = Audio(function: .getAudioRecording)
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = Void
    
    public typealias ReturnType = Void
    
    /// Starts video capture
    public static let start = VideoCapture(function: .startVideoRecording)
    
    /// Ends video capture
    public static let stop = VideoCapture(function: .endVideoRecording)
}

/// Functions for interacting with the camera's loop capture API
public struct LoopCapture: CameraFunction {
    
    /// Functions for changing the duration of a loop capture
    public struct Duration: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = TimeInterval
        
        public typealias ReturnType = TimeInterval
        
        /// Sets the loop duration
        public static let set = LoopCapture(function: .setLoopRecordDuration)
        
        /// Returns the current loop duration
        public static let get = LoopCapture(function: .getLoopRecordDuration)
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = Void
    
    public typealias ReturnType = Void
    
    /// Starts a loop recording
    public static let start = LoopCapture(function: .startLoopRecording)
    
    /// Ends a loop recording
    public static let stop = LoopCapture(function: .endLoopRecording)
}

/// Functions for interacting with the camera's bulb capture API
public struct BulbCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Void
    
    public typealias ReturnType = Void
    
    /// Start capturing a bulb exposure
    public static let start = BulbCapture(function: .startBulbCapture)

    /// Stop capturing a bulb exposure
    public static let stop = BulbCapture(function: .endBulbCapture)
}
