//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the time of the camera
public struct CurrentTime: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = (date: Date, timeZone: TimeZone)
    
    public typealias ReturnType = Void
    
    /// Sets the current time on the camera
    public static let set = CurrentTime(function: .setCurrentTime)
}
