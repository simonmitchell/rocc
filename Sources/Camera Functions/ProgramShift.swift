//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Funcsions for configuring the program shift (Configuring aperture+shutter speed combination)
public struct ProgramShift: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Int
    
    public typealias ReturnType = Int
    
    /// Sets the program shift
    public static let set = TouchAF(function: .setProgramShift)
    
    /// Returns the current program shift
    public static let get = TouchAF(function: .getProgramShift)
}
