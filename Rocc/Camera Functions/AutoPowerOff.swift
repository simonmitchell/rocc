//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring the duration of the auto-power off function of the camera.
public struct AutoPowerOff: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = TimeInterval
    
    public typealias ReturnType = TimeInterval
    
    /// Sets the duration of the auto power off function.
    public static let set = AutoPowerOff(function: .setAutoPowerOff)
    
    /// Returns the current duration of the auto power off function.
    public static let get = AutoPowerOff(function: .getAutoPowerOff)
}
