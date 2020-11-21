//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring the steady mode of the camera
public struct SteadyMode: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    /// Sets the steady mode of the camera
    public static let set = SteadyMode(function: .setSteadyMode)
    
    /// Returns the current steady mode of the camera
    public static let get = SteadyMode(function: .getSteadyMode)
}
