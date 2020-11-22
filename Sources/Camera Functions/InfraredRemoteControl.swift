//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the IR remote control setting of the camera
public struct InfraredRemoteControl: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    /// Sets the IR remote control setting of the camera
    public static let set = InfraredRemoteControl(function: .setInfraredRemoteControl)
    
    /// Returns the current IR remote control setting of the camera
    public static let get = InfraredRemoteControl(function: .getInfraredRemoteControl)
}
