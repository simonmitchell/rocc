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
    
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Set the exposure mode of the camera
        public static let set = Mode(function: .setExposureMode)
        
        /// Get the current exposure mode of the camera
        public static let get = Mode(function: .getExposureMode)
    }
    
    /// Functions for configuring the exposure compensation of the camera
    public struct Compensation: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = Double
        
        public typealias ReturnType = Double
        
        /// Sets the exposure compensation of the camera
        public static let set = Compensation(function: .setExposureCompensation)
        
        /// Gets the current exposure compensation of the camera
        public static let get = Compensation(function: .getExposureCompensation)
    }
}
