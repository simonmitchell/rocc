//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

public struct Aperture: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = String
    
    public static let set = Aperture(function: .setAperture)
    
    public static let get = Aperture(function: .getAperture)
}
