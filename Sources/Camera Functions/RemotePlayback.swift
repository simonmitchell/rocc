//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for working with the remote playback capabilities of a camera
public struct RemotePlayback: CameraFunction {
    
    /// Functions for configuring the remote playback position of an item
    public struct Position: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = Wrapper<Void>
        
        public typealias ReturnType = TimeInterval
        
        /// Seeks to a particular playback position of a playable item
        public static let seek = Content(function: .seekStreamingPosition)
    }
    
    /// Functions for getting the status of a remote playback session
    public struct Status: CameraFunction {
        
        public struct Value: Equatable {
            
            public let status: String
            
            public let factor: String?
        }
        
        public var function: _CameraFunction
        
        public typealias SendType = Bool
        
        public typealias ReturnType = Value
        
        /// Returns the current streaming status for remote playback
        public static let get = Content(function: .getStreamingStatus)
    }
    
    /// Functions for interacting with the content that is being streamed via remote playback
    public struct Content: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = String
        
        public typealias ReturnType = URL
        
        /// Sets the streaming content returning the URL it can be streamed fom
        public static let set = Content(function: .setStreamingContent)
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = Wrapper<Void>
    
    public typealias ReturnType = Wrapper<Void>
    
    /// Starts remote playback
    public static let start = RemotePlayback(function: .startStreaming)
    
    /// Paused remote playback
    public static let pause = RemotePlayback(function: .pauseStreaming)
    
    /// Stops remote playback
    public static let stop = RemotePlayback(function: .stopStreaming)
}
