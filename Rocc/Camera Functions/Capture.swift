//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the camera's still capture API.
public struct StillCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = URL
    
    /// Makes the camera take a still image.
    public static let take = StillCapture(function: .takePicture)
    
    /// Functions for configuring the still capture size setting
    public struct Size: CameraFunction {
        
        /// A structural representation of still image size configuration
        public struct Value: Equatable {
            
            /// The aspect ratio of the size
            let aspectRatio: String?
            
            /// The size itself
            let size: String
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Sets the still image capture size setting
        public static let set = Size(function: .setStillSize)
        
        /// Returns the current still image size setting
        public static let get = Size(function: .getStillSize)
    }
    
    /// Functions for configuring the still capture quality setting
    public struct Quality: CameraFunction {
        
        /// A structural representation of image still quality
        public enum Value {
            case standard
            case fine
            case extraFine
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Sets the still image capture quality
        public static let set = Quality(function: .setStillQuality)
        
        /// Returns the current still image capture quality
        public static let get = Quality(function: .getStillQuality)
    }
    
    /// Functions for configuring the still capture format setting
    public struct Format: CameraFunction {
        
        /// A structural representation of image still format
        public enum Value: Equatable {
            case jpeg(String)
            case raw
            case rawAndJpeg
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Sets the still image format
        public static let set = Format(function: .setStillFormat)
        
        /// Returns the current still image format
        public static let get = Format(function: .getStillFormat)
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
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Starts audio capture
    public static let start = AudioCapture(function: .startAudioRecording)
    
    /// Ends audio capture
    public static let stop = AudioCapture(function: .endAudioRecording)
}

/// A structural representation of a image capture 'bracket'
public struct CaptureBracket: Equatable {
    
    /// The interval at which bracketed images are captured
    public enum Interval: Equatable {
        case low
        case high
        case custom(images: Int, interval: Double)
    }

    /// Enumeration representing the bracket mode which a camera is using
    public enum Mode: String {
        case exposure
        case whiteBalance
        case dro
    }
}

public struct ContinuousBracketCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Starts capture of bracketed stills
    public static let start = ContinuousBracketCapture(function: .startContinuousBracketShooting)
    
    /// Ends capture of bracketed stills
    public static let stop = ContinuousBracketCapture(function: .stopContinuousBracketShooting)
    
    public struct Bracket: CameraFunction {
        
        public struct Value: Equatable {
            
            /// The bracket's mode
            public let mode: CaptureBracket.Mode
            
            /// The interval to perform at
            public let interval: CaptureBracket.Interval
            
            /// Public memberwise initialiser for bracket shooting value
            ///
            /// - Warning: This should not be used unless you are absolutely certain
            /// the connected camera supports the given mode and interval. The preferred
            /// way to get values is to call `ContinuousBracketCapture.Bracket.get` or use the
            /// values returned via the eventing mechanism
            ///
            /// - Parameters:
            ///   - mode: The bracketing mode (single/continuous/whiteBalance/dro)
            ///   - interval: The "interval" of the bracket, or how many images will be taken at what intervals
            public init(mode: CaptureBracket.Mode, interval: CaptureBracket.Interval) {
                self.mode = mode
                self.interval = interval
            }
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = ContinuousBracketCapture.Bracket.Value
        
        public typealias ReturnType = ContinuousBracketCapture.Bracket.Value
        
        /// Sets the bracketed shooting mode
        public static let set = ContinuousBracketCapture.Bracket(function: .setContinuousBracketedShootingBracket)
        
        /// Returns the current bracketed shooting mode
        public static let get = ContinuousBracketCapture.Bracket(function: .getContinuousBracketedShootingBracket)
    }
}

public struct SingleBracketCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    public static let take = SingleBracketCapture(function: .takeSingleBracketShot)
    
    /// Functions for interacting with the bracketed shooting mode
    public struct Bracket: CameraFunction {
        
        public struct Value: Equatable {
            
            /// The bracket's mode
            public let mode: CaptureBracket.Mode
            
            /// The interval to perform at
            public let interval: CaptureBracket.Interval
            
            /// Public memberwise initialiser for bracket shooting value
            ///
            /// - Warning: This should not be used unless you are absolutely certain
            /// the connected camera supports the given mode and interval. The preferred
            /// way to get values is to call `SingleBracketCapture.Bracket.get` or use the
            /// values returned via the eventing mechanism
            ///
            /// - Parameters:
            ///   - mode: The bracketing mode (single/continuous/whiteBalance/dro)
            ///   - interval: The "interval" of the bracket, or how many images will be taken at what intervals
            public init(mode: CaptureBracket.Mode, interval: CaptureBracket.Interval) {
                self.mode = mode
                self.interval = interval
            }
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = SingleBracketCapture.Bracket.Value
        
        public typealias ReturnType = SingleBracketCapture.Bracket.Value
        
        /// Sets the bracketed shooting mode
        public static let set = SingleBracketCapture.Bracket(function: .setSingleBracketedShootingBracket)
        
        /// Returns the current bracketed shooting mode
        public static let get = SingleBracketCapture.Bracket(function: .getSingleBracketedShootingBracket)
    }
}

/// Functions for interacting with the camera's continuous capture API
public struct ContinuousCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Starts continuous capture of stills.
    /// - Warning: Continuous capture behaves quite strangely, you have to let the user manually
    /// call `stop` as there is no feedback from the camera as to when it has completed the shots
    public static let start = ContinuousCapture(function: .startContinuousShooting)
    
    /// Ends continuous capture of stills
    public static let stop = ContinuousCapture(function: .endContinuousShooting)
    
    /// Functions for interacting with the continuous shooting mode
    public struct Mode: CameraFunction {
        
        /// Enumeration representing the shooting mode which a camera is using
        ///
        /// - single: A single shot for each shutter press
        /// - continuous: Shoot continuously whilst the shutter button is pressed
        /// - spdPriorityContinuous: Shoots continuously (At higher speed than continuous) whilst the shutter button is pressed
        /// - burst: Shoots a burst
        /// - motionShot: Takes shots using Sony's "MotionShot" technology
        public enum Value: String {
            case single
            case continuous
            case spdPriorityContinuous = "spd priority cont."
            case burst
            case motionShot = "motionshot"
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Sets the continous shooting mode
        public static let set = ContinuousCapture.Mode(function: .setContinuousShootingMode)
        
        /// Returns the current continuous shooting mode
        public static let get = ContinuousCapture.Mode(function: .getContinuousShootingMode)
    }
    
    /// Functions for interacting with the continuous shooting speed
    public struct Speed: CameraFunction {
        
        /// Enumeration representing the shooting speed for continuous shooting
        ///
        /// - high: High speed
        /// - low: Low speed
        public enum Value: String {
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
        
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Sets the continuous shooting speed
        public static let set = ContinuousCapture.Speed(function: .setContinuousShootingSpeed)
        
        /// Returns the current continuous shooting speed
        public static let get = ContinuousCapture.Speed(function: .getContinuousShootingSpeed)
    }
}

/// Functions for interacting with the camera's high frame rate API
public struct HighFrameRateCapture: CameraFunction {
    
    /// The current status of the HFR capture
    public enum Status {
        case idle
        case buffering
        case recording
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Status
    
    /// Starts high frame rate capture, calling back with the current status of capture as it progresses (Also available via `CameraEvent`)
    public static let record = HighFrameRateCapture(function: .recordHighFrameRateCapture)
}

/// Functions for interacting with the camera's video capture API
public struct VideoCapture: CameraFunction {
    
    /// Functions for controlling the file format that the video will be captured in
    public struct FileFormat: CameraFunction {
        
        /// Values for Video Capture file format
        public enum Value: Int {
            case none
            case dvd
            case m2ps
            case avchd
            case mp4
            case dv
            case xavc
            case mxf
            case xavc_s_4k
            case xavc_s_hd
            case xavc_s
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Sets the file format for video recording
        public static let set = FileFormat(function: .setVideoFileFormat)
        
        /// Returns the current file format for video recording
        public static let get = FileFormat(function: .getVideoFileFormat)
    }
    
    /// Functions for controlling the quality of video recording
    public struct Quality: CameraFunction {
        
        /// Values for Video Capture file quality
        public enum Value {
            case none
            case ps
            case hq
            case std
            case vga
            case slow
            case sslow
            case hs120
            case hs100
            case hs240
            case hs200
            case _120p_50m
            case _100p_50m
            case _60p_50m
            case _50p_50m
            case _30p_50m
            case _25p_50m
            case _24p_50m
            case _120p_100m
            case _100p_100m
            case _120p_60m
            case _100p_60m
            case _240p_100m
            case _200p_100m
            case _240p_60m
            case _200p_60m
            case _30p_100m
            case _25p_100m
            case _24p_100m
            case _30p_60m
            case _25p_60m
            case _24p_60m
            case _60p_28m
            case _50p_28m
            case _60p_25m
            case _50p_25m
            case _30p_16m
            case _25p_16m
            case _30p_16m_alt
            case _25p_16m_alt
            case _30p_6m
            case _25p_6m
            case _60i_24m_fx
            case _50i_24m_fx
            case _60i_17m_fh
            case _50i_17m_fh
            case _60p_28m_ps
            case _50p_28m_ps
            case _24p_24m_fx
            case _25p_24m_fx
            case _24p_17m_fh
            case _25p_17m_fh
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Gets the current video recording quality
        public static let get = Quality(function: .getVideoQuality)
        
        /// Sets the video recording quality
        public static let set = Quality(function: .setVideoQuality)
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
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
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
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Starts a loop recording
    public static let start = LoopCapture(function: .startLoopRecording)
    
    /// Ends a loop recording
    public static let stop = LoopCapture(function: .endLoopRecording)
}

/// Functions for interacting with the camera's bulb capture API
public struct BulbCapture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Start capturing a bulb exposure
    public static let start = BulbCapture(function: .startBulbCapture)
    
    /// Stop capturing a bulb exposure
    public static let stop = BulbCapture(function: .endBulbCapture)
}
