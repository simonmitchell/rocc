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
    
    /// Functions for configuring the exposure mode of the camera
    public struct Mode: CameraFunction {
        
        public enum Value {
            case programmedAuto
            case aperturePriority
            case shutterPriority
            case manual
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
        public struct Value {
            /// The double value the given exposure compensation represents
            public let value: Double
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
