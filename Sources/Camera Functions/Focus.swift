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
        
        public enum Value: CaseIterable {
            
            case auto
            case autoSingle
            case autoContinuous
            case autoFocusAuto // Switches between single and continuous intelligently
            case directManual
            case manual
            case powerFocus
            
            var isAutoFocus: Bool {
                return [.auto, .autoSingle, .autoContinuous].contains(self)
            }
        }
    
        public var function: _CameraFunction
        
        public typealias SendType = Value
        
        public typealias ReturnType = Value
        
        /// Sets the focus mode of the camera
        public static let set = Mode(function: .setFocusMode)
        
        /// Returns the current focus mode of the camera
        public static let get = Mode(function: .getFocusMode)
    }
}
