//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the Touch AF capability of a camera
public struct TouchAF: CameraFunction {
    
    /// Structural representation of information about the Touch AF setup
    public struct Information: Equatable {
        
        /// Whether Touch AF points are set
        let isSet: Bool
        
        /// The list of Touch AF points that have been set
        let points: [CGPoint]
    }
    
    /// Functions for interacting with the position of Touch AF points
    public struct Position: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = CGPoint
        
        public typealias ReturnType = Information
        
        /// Sets the Touch AF point to be used for focussing
        public static let set = Position(function: .setTouchAFPosition)
        
        /// Returns the current Touch AF point used for focussing
        public static let get = Position(function: .getTouchAFPosition)
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Stops Touch AF and removes all Touch AF points
    public static let cancel = TouchAF(function: .cancelTouchAFPosition)
}
