//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the exposure settings of the camera
public struct Exposure {
    
    /// Functions for locking in exposure settings, this seems to only be used for HFR shooting
    /// via PTP/IP on the RX100 VII, but may have other use-cases and therefore we've made it more generic for now.
    public struct SettingsLock: CameraFunction {
        
        public enum Status: CaseIterable {
            case normal
            case standby
            case locked
            case buffering
            case recording
        }
        
        public var function: _CameraFunction

        public typealias SendType = Status
        
        public typealias ReturnType = Status
        
        public static let set = SettingsLock(function: .setExposureSettingsLock)
        
        public static let get = SettingsLock(function: .getExposureSettingsLock)
    }
    
    /// Functions for configuring the exposure mode of the camera
    public struct Mode: CameraFunction {
        
        /// Functions for configuring what controls the exposure mode dial on the camera
        public struct DialControl: CameraFunction {
            
            public var function: _CameraFunction
            
            public typealias SendType = Value
            
            public typealias ReturnType = Value
            
            /// An enum representing the value of `DialControl` setting
            public enum Value: CaseIterable {
                /// The dial is controlled by the physical dial on the camera
                case camera
                /// The dial is controlled by the app
                case app
            }
            
            public static let set = DialControl(function: .setExposureModeDialControl)
            
            public static let get = DialControl(function: .getExposureModeDialControl)
        }
        
        public enum Value: Equatable {
            
            public enum Scene: CaseIterable {
                case portrait
                case sport
                case sunset
                case night
                case landscape
                case macro
                case handheldTwilight
                case nightPortrait
                case antiMotionBlur
                case pet
                case food
                case fireworks
                case highSensitivity
            }
            
            case programmedAuto
            case aperturePriority
            case shutterPriority
            case manual
            case panorama
            case videoProgrammedAuto
            case videoAperturePriority
            case videoShutterPriority
            case videoManual
            case slowAndQuickProgrammedAuto
            case slowAndQuickAperturePriority
            case slowAndQuickShutterPriority
            case slowAndQuickManual
            case intelligentAuto
            case superiorAuto
            case highFrameRateProgrammedAuto
            case highFrameRateAperturePriority
            case highFrameRateShutterPriority
            case highFrameRateManual
            case scene(Scene)
        }
    
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Set the exposure mode of the camera
        public static let set = Mode(function: .setExposureMode)
        
        /// Get the current exposure mode of the camera
        public static let get = Mode(function: .getExposureMode)
    }
    
    /// Functions for configuring the exposure compensation of the camera
    public struct Compensation: CameraFunction {
        
        /// A exposure compensation value
        public struct Value: Equatable {
            /// The double value the given exposure compensation represents
            public let value: Double

            public init(value: Double) {
                self.value = value
            }
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Sets the exposure compensation of the camera
        public static let set = Compensation(function: .setExposureCompensation)
        
        /// Gets the current exposure compensation of the camera
        public static let get = Compensation(function: .getExposureCompensation)
    }
}
