//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for configuring post-view images from the camera
public struct PostViewImage {
    
    /// Functions for configuring the size of post-view image the camera sends
    public struct Size: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = String
        
        /// Sets the post-view image size
        public static let set = Size(function: .setPostviewImageSize)
        
        /// Returns the current post-view image size
        public static let get = Size(function: .getPostviewImageSize)
    }
}

