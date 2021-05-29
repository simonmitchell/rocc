//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for controlling the Aperture (F Stop) of the camera
public struct Aperture: CameraFunction {
    
    public struct Value {
                        
        public let value: Double
        internal let decimalSeperator: String?

        public init(value: Double, decimalSeperator: String? = nil) {
            self.value = value
            self.decimalSeperator = decimalSeperator
        }
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = Aperture.Value
    
    public typealias ReturnType = Aperture.Value
    
    /// Set's the aperture of the camera
    public static let set = Aperture(function: .setAperture)
    
    /// Returns the current aperture of the camera
    public static let get = Aperture(function: .getAperture)
}

extension Aperture.Value: Equatable {
    public static func ==(lhs: Aperture.Value, rhs: Aperture.Value) -> Bool {
        return lhs.value == rhs.value
    }
}
