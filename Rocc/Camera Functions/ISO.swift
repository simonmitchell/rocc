//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for controlling the ISO of the camera
public struct ISO: CameraFunction {
    
    public enum Value: Equatable {
        
        case auto
        case extended(Int)
        case native(Int)
        case multiFrameNRAuto
        case multiFrameNR(Int)
        case multiFrameNRHiAuto
        case multiFrameNRHi(Int)
        
        public static func == (lhs: ISO.Value, rhs: ISO.Value) -> Bool {
            switch (lhs, rhs) {
            case (.auto, .auto):
                return true
            case (.extended(let lhsExtended), .extended(let rhsExtended)):
                return lhsExtended == rhsExtended
            case (.native(let lhsNative), .native(let rhsNative)):
                return lhsNative == rhsNative
            case (.multiFrameNR(let lhsMFNR), .multiFrameNR(let rhsMFNR)):
                return lhsMFNR == rhsMFNR
            case (.multiFrameNRHi(let lhsMFNRHi), .multiFrameNRHi(let rhsMFNRHi)):
                return lhsMFNRHi == rhsMFNRHi
            case (.multiFrameNRAuto, .multiFrameNRAuto):
                return true
            case (.multiFrameNRHiAuto, .multiFrameNRHiAuto):
                return true
            default:
                return false
            }
        }
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = ISO.Value
    
    public typealias ReturnType = ISO.Value
    
    /// Sets the ISO of the camera
    public static let set = ISO(function: .setISO)
    
    /// Returns the current ISO of the camera
    public static let get = ISO(function: .getISO)
}
