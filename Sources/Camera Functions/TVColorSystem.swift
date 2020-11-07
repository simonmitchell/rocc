//
//  FileSystem.swift
//  Rocc
//
//  Created by Simon Mitchell on 27/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for controlling the TV output color system
public struct TVColorSystem: CameraFunction {
        
    public typealias ReturnType = String
    
    public typealias SendType = String
    
    public var function: _CameraFunction
    
    /// Sets the color system
    public static let set = TVColorSystem(function: .setTVColorSystem)
    
    /// Returns the current color system
    public static let get = TVColorSystem(function: .getTVColorSystem)
}
