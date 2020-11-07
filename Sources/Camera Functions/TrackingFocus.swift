//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring tracking focus on the camera
public struct TrackingFocus: CameraFunction {
    
    /// Functions for enabling and disabling tracking focus
    public struct Setting: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Sets the tracking focus setting
        public static let set = Setting(function: .setTrackingFocus)
        
        /// Returns the current tracking focus setting
        public static let get = Setting(function: .getTrackingFocus)
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = CGPoint
    
    public typealias ReturnType = CGPoint?
    
    /// Starts focus tracking at a given point
    public static let start = TrackingFocus(function: .startTrackingFocus)
    
    /// Stops focus tracking and removes all points
    public static let stop = TrackingFocus(function: .stopTrackingFocus)
}
