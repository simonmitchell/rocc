//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the storage of the camera
public struct Storage: CameraFunction {
    
    public var function: _CameraFunction
    
    public typealias SendType = Void
    
    public typealias ReturnType = [StorageInformation]
    
    /// Returns information about the current storage capabilities of the camera
    public static let getInformation = Storage(function: .getStorageInformation)
}

/// A structural representation of information about camera storage
public struct StorageInformation {
    
    /// A description of the storage option
    let description: String?
    
    /// The amount of space available for storage of images on the storage
    let spaceForImages: Int?
    
    /// Whether the storage can be recorded to
    let recordTarget: Bool
    
    /// The amount of recorded footage that can be stored
    let recordableTime: Int?
    
    /// The unique ID of the storage
    let id: String?
}
