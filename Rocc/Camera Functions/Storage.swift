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
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = [StorageInformation]
    
    /// Returns information about the current storage capabilities of the camera
    public static let getInformation = Storage(function: .getStorageInformation)
}

/// A structural representation of information about camera storage
public struct StorageInformation: Equatable {
    
    /// A description of the storage option
    public let description: String?
    
    /// The amount of space available for storage of images on the storage
    public let spaceForImages: Int?
    
    /// Whether the storage can be recorded to
    public let recordTarget: Bool
    
    /// The amount of recorded footage that can be stored
    public let recordableTime: Int?
    
    /// The unique ID of the storage
    public let id: String?
    
    /// Whether the storage has no SD card or other media inserted
    public let noMedia: Bool
}
