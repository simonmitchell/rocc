//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring shutter parameters on the camera
public struct Shutter: CameraFunction {
    
    /// Functions for configuring the shutter speed of the camera
    public struct Speed: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = ShutterSpeed
        
        public typealias ReturnType = ShutterSpeed
        
        /// Sets the shutter speed of the camera
        public static let set = Speed(function: .setShutterSpeed)
        
        /// Returns the current shutter speed of the camera
        public static let get = Speed(function: .getShutterSpeed)
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Performs a half-press of the shutter button
    public static let halfPress = Shutter(function: .halfPressShutter)
    
    /// Cancels a half-press of the shutter button
    public static let cancelHalfPress = Shutter(function: .cancelHalfPressShutter)
}
