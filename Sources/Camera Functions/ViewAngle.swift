//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring the view angle of the camera, mainly used for action cams!
public struct ViewAngle: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Double
    
    public typealias ReturnType = Double
    
    /// Sets the view angle of the camera
    public static let set = ViewAngle(function: .setViewAngle)
    
    /// Returns the current view angle of the camera
    public static let get = ViewAngle(function: .getViewAngle)
}
