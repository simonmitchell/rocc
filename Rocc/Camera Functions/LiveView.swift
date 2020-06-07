//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for interacting with the live view of the camera
public struct LiveView: CameraFunction {
    
    /// Functions for configuring whether frame info (focus areas, faces e.t.c) should be sent from the camera
    struct SendFrameInfo: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = Bool
        
        public typealias ReturnType = Bool
        
        /// Sets whether frame info should be sent
        public static let set = SendFrameInfo(function: .setSendLiveViewFrameInfo)
        
        /// Returns whether frame info is being sent from the camera
        public static let get = SendFrameInfo(function: .getSendLiveViewFrameInfo)
    }
    
    /// Functions for configuring the image size of the live view stream
    struct Size: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = Wrapper<Void>
        
        public typealias ReturnType = String
        
        /// Returns the current live view size. N.B. there is no `set` method here as this is
        /// configured when starting the live view!
        public static let get = Size(function: .getLiveViewSize)
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = String
    
    public typealias ReturnType = URL
    
    /// Starts the live view stream
    public static let start = LiveView(function: .startLiveView)
    
    /// Stops the live view stream
    public static let stop = LiveView(function: .endLiveView)
    
    /// Starts the live view stream with a given image size
    public static let startWithSize = LiveView(function: .startLiveViewWithSize)
}
