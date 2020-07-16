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
    
    /// Functions for configuring the image quality of the live view stream
    public struct QualityGet: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = Wrapper<Void>
        
        public typealias ReturnType = LiveView.Quality
        
        /// Returns the current live view size. N.B. there is no `set` method here as this is
        /// configured when starting the live view!
        public static let get = QualityGet(function: .getLiveViewQuality)
    }
    
    public struct QualitySet: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = LiveView.Quality
        
        public typealias ReturnType = URL
        
        /// - Note: I recommend not directly interacting with this and instead using `LiveViewStreaming.set(quality:)` instead.
        /// This is because on some cameras this requires starting and stopping the live view, which you will
        /// have to handle yourself if not using the `LiveViewStreaming` class
        public static let set = QualitySet(function: .setLiveViewQuality)
        
        /// Starts the live view stream with a given image quality.
        /// - Note: I recommend not directly interacting with this and instead using `LiveViewStreaming.set(quality:)`
        public static let startWithQuality = LiveView(function: .startLiveViewWithQuality)
    }
    
    public enum Quality {
        case imageQuality // On Sony API is "L", PTP is 0d26a -> 0x0d
        case displaySpeed // On Sony API is "M", PTP is 0xd26a -> 0x01
    }
        
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = URL
    
    /// Starts the live view stream
    /// - Note: I recommend not directly interacting with this and instead using `LiveViewStreaming.start()`
    public static let start = LiveView(function: .startLiveView)
    
    /// Stops the live view stream
    /// - Note: I recommend not directly interacting with this and instead using `LiveViewStreaming.stop()`
    public static let stop = LiveView(function: .endLiveView)
}
