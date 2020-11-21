//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring the shooting interval of the camera
public struct IntervalTime: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = TimeInterval
    
    public typealias ReturnType = TimeInterval
    
    /// Sets the interval duration of the camera
    public static let set = IntervalTime(function: .setIntervalTime)
    
    /// Returns the current interval duration of the camera
    public static let get = IntervalTime(function: .getIntervalTime)
}
