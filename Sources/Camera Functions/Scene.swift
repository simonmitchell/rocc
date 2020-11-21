//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring the "scene" selection for shooting
public struct Scene: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    /// Sets the shooting "scene" (i.e. underwater)
    public static let set = Scene(function: .setScene)
    
    /// Gets the current shooting scene
    public static let get = Scene(function: .getScene)
}
