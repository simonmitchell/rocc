//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for controlling the ISO of the camera
public struct ISO: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    /// Sets the ISO of the camera
    public static let set = ISO(function: .setISO)
    
    /// Returns the current ISO of the camera
    public static let get = ISO(function: .getISO)
}
