//
//  Ping.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/06/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// A function to ping the camera to see if it is accessible
struct Ping: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    /// Performs a network ping to the camera
    public static let perform = Ping(function: .ping)
}
