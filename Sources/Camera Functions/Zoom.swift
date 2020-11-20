//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for controlling the digital zoom of a camera
public struct Zoom: CameraFunction {
    
    /// Functions for controlling the zoom setting of a camera
    public struct Settings: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Sets the zoom setting
        public static let set = Zoom(function: .setZoomSetting)
        
        /// Returns the current zoom setting
        public static let get = Zoom(function: .getZoomSetting)
    }
    
    /// Enum representing a zoom direction
    ///
    /// - `in`: Zooming in
    /// - out: Zooming out
    public enum Direction: String {
        case `in`
        case out
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = Direction
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Begins a zoom in a given direction
    public static let start = Zoom(function: .startZooming)
    
    /// Ends a zoom action
    public static let stop = Zoom(function: .stopZooming)
}
