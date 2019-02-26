//
//  FileSystem.swift
//  Rocc
//
//  Created by Simon Mitchell on 27/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring the flip setting (?) of the camera
public struct FlipSetting: CameraFunction {
        
    public typealias ReturnType = String
    
    public typealias SendType = String
    
    public var function: _CameraFunction
    
    /// Sets the flip setting of the camera
    public static let set = FlipSetting(function: .setFlipSetting)
    
    /// Returns the current flip setting of the camera
    public static let get = FlipSetting(function: .getFlipSetting)
}
