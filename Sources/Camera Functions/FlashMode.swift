//
//  FlashMode.swift
//  Rocc
//
//  Created by Simon Mitchell on 11/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

/// Function for interacting with the flash mode of the camera
public struct Flash {
    
    /// Functions for configuring the exposure mode of the camera
    public struct Mode: CameraFunction {
        
        public enum Value {
            case fill
            case slowSynchro
            case rearSync
            case auto
            case off
            case forcedOn
            case wireless
        }
    
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Set the exposure mode of the camera
        public static let set = Flash.Mode(function: .setFlashMode)
        
        /// Get the current exposure mode of the camera
        public static let get = Flash.Mode(function: .getFlashMode)
    }
}
