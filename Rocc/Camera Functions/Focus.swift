//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the focal settings of the camera
public struct Focus {
    
    /// Functions for controlling the focus mode of the camera
    public struct Mode: CameraFunction {
    
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Sets the focus mode of the camera
        public static let set = Mode(function: .setFocusMode)
        
        /// Returns the current focus mode of the camera
        public static let get = Mode(function: .getFocusMode)
    }
}
