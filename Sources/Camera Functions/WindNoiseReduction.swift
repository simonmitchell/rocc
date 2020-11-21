//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring the wind noise reduction setting of a camera
public struct WindNoiseReduction: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    /// Sets the wind noise reduction setting
    public static let set = WindNoiseReduction(function: .setWindNoiseReduction)
    
    /// Returns the wind noise reduction setting
    public static let get = WindNoiseReduction(function: .getWindNoiseReduction)
}
