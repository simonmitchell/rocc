//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the color setting of the camera
public struct ColorSetting: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    /// Gets the current color setting
    public static let get = ColorSetting(function: .getColorSetting)
    
    /// Sets the color setting
    public static let set = ColorSetting(function: .setColorSetting)
}
