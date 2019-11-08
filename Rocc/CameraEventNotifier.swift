//
//  CameraEventNotifier.swift
//  Rocc
//
//  Created by Simon Mitchell on 13/05/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// A delegate protocol used to provide camera events to a listener
public protocol CameraEventNotifierDelegate {
    /// Called when an event notifier received a new camera event
    ///
    /// - Parameters:
    ///   - notifier: The notifier which received the event
    ///   - event: The event which was received
    func eventNotifier(_ notifier: CameraEventNotifier, receivedEvent event: CameraEvent)
    
    /// Called if an event notifier errors
    ///
    /// - Parameters:
    ///   - notifier: The notifier which errored
    ///   - error: The error which occured
    func eventNotifier(_ notifier: CameraEventNotifier, didError error: Error)
}

/// A class for subscribing to events from a particular instance of a Camera.
///
/// This class will be entirely responsible for fetching up-to-date events from the camera and providing
/// them back to the callee through a delegate based (Or NotificationCenter if you wish) approach
public final class CameraEventNotifier {
    
    /// A delegate which will be notified of events the camera sends
    public var delegate: CameraEventNotifierDelegate?
    
    /// The camera which should have events fetched from
    public let camera: Camera
    
    /// Initialises a new notifier with a given camera and delegate
    ///
    /// - Parameters:
    ///   - camera: The camera to receive notifications for
    ///   - delegate: The delegate to be notified of camera events
    public init(camera: Camera, delegate: CameraEventNotifierDelegate?) {
        
        self.delegate = delegate
        self.camera = camera
    }
    
    private var eventTimer: Timer?
    
    /// Call this to start polling for camera events.
    ///
    /// - Important: To avoid polling errors, if you are unsure if you are already being notified please only call this once per instance of `CameraEventNotifier`
    public func startNotifying() {
        
        switch camera.eventPollingMode {
        case .none:
            break
        case .continuous:
            fetchEvent(true)
        case .cameraDriven:
            fetchEvent(true)
            camera.onEventAvailable = { [weak self] in
                self?.fetchEvent()
            }
        case .timed:
            fetchEvent(true)
            eventTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { [weak self] (timer) in
                self?.fetchEvent()
            })
        }
    }
    
    func fetchEvent(_ isInitial: Bool = false) {
        
        // Don't poll with the initial event so we get full information
        camera.performFunction(Event.get, payload: isInitial ? false : camera.eventPollingMode == .continuous) { [weak self] (error, event) in
            
            guard let self = self else { return }
            
            if let error = error {
                
                if let cameraError = error as? CameraError {
                    switch cameraError {
                    case .timeout(_):
                        // If we timed out, then re-fetch as the API docs suggest!
                        self.fetchEvent(isInitial)
                        return
                    default:
                        break
                    }
                }
                
                if (error as NSError).code == NSURLErrorTimedOut {
                    self.fetchEvent(isInitial)
                    return
                }
                
                self.delegate?.eventNotifier(self, didError: error)
            } else if let _event = event {
                self.delegate?.eventNotifier(self, receivedEvent: _event)
                self.camera.handleEvent(event: _event)
            }
            
            guard self.camera.eventPollingMode == .continuous, event != nil else {
                return
            }
            
            self.fetchEvent()
        }
    }
}
