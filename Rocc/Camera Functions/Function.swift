//
//  Camera.swift
//  Rocc
//
//  Created by Simon Mitchell on 05/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for controlling the function of the camera (e.g. "Contents Transfer")
public struct Function: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    /// Sets the function of the camera
    public static let set = Function(function: .setCameraFunction)
    
    /// Returns the current function of the camera
    public static let get = Function(function: .getCameraFunction)
}
