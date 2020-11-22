//
//  Camera.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Enum representing the current status of the camera
///
/// - error: Something has gone wrong and the camera is in a state of error.
/// - notReady: The camera is not ready to be communicated with or take photos/video e.t.c.
/// - idle: The camera is idle and is ready to start being interacted with.
/// - capturingStill: The camera is capturing a still photo.
/// - savingStill: The camera is saving a still photo.
/// - startingMovieRecording: The camera is starting to record video.
/// - recordingMovie: The camera is recording video.
/// - stoppingMovieRecording: The camera is ending a video recording.
/// - savingMovie: The camera is saving a video.
/// - startingAudioRecording: The camera is starting to record audio.
/// - recordingAudio: The camera is recording audio.
/// - stoppingAudioRecording: The camera is ending an audio recording.
/// - savingAudio: The camera is saving an audio recording.
/// - startingIntervalStillCapture: The camera is starting to capture interval stills.
/// - capturingIntervalStills: The camera is capturing interval stills.
/// - stoppingIntervalStillCapture: The camera is stopping recording interval stills.
/// - startingLoopRecording: The camera is starting a loop recording.
/// - recordingLoop: The camera is recording a loop.
/// - stoppingLoopRecording: The camera is ending a loop recording.
/// - savingLoop: The camera is saving a loop recording.
/// - capturingWhiteBalanceSetupStill: The camera is capturing a still for white balance setup.
/// - readyForContentsTransfer: The camera is ready for transfer of files.
/// - streamingMovie: The camera is streaming a video from the user's recorded videos.
/// - deletingContent: The camera is deleting some content.
public enum CameraStatus {
    case error
    case notReady
    case idle
    case capturingStill
    case savingStill
    case startingMovieRecording
    case recordingMovie
    case stoppingMovieRecording
    case savingMovie
    case startingAudioRecording
    case recordingAudio
    case stoppingAudioRecording
    case savingAudio
    case startingIntervalStillCapture
    case capturingIntervalStills
    case stoppingIntervalStillCapture
    case startingLoopRecording
    case recordingLoop
    case stoppingLoopRecording
    case savingLoop
    case capturingWhiteBalanceSetupStill
    case readyForContentsTransfer
    case streamingMovie
    case deletingContent
}

/// The connection mode of the camera, this represents the core functionality that
/// is available from the camera.
///
/// - remoteControl: Full control of the camera is available (Live view, exposure control e.t.c)
/// - contentsTransfer: Only contents transfer is available, so only the transfer methods are available. The associated boolean determines whether the files to transfer are pre-selected on the camera. If true then no UI should be shown to pick photos!
public enum ConnectionMode {
    case remoteControl
    case contentsTransfer(Bool)
}

/// The polling mode of the camera
///
/// - continuous: We should continually call get event and the camera will respond when ready
/// - timer: We should fetch events on a timed basis
/// - cameraDriven: The camera will let us know when events are available
public enum PollingMode {
    case continuous
    case timed
    case cameraDriven
    case none
}

/// A protocol which defines the base functionality of a camera.
public protocol Camera: class {
    
    typealias ConnectedCompletion = (_ error: Error?, _ transferMode: Bool) -> Void
    
    typealias DisconnectedCompletion = (_ error: Error?) -> Void
    
    /// The IP address of the camera
    var ipAddress: sockaddr_in? { get }
    
    /// The API version of the software running on the camera
    var apiVersion: String? { get }
    
    /// The base url of the camera
    var baseURL: URL? { get set }
    
    /// The manufacturer of the camera.
    var manufacturer: String { get }
    
    /// The name of the camera. A friendly version of the model.
    var name: String? { get }
    
    /// The model of the camera.
    var model: String? { get }
    
    /// The firmware version of the camera.
    var firmwareVersion: String? { get }
    
    /// The latest firmware update available for the camera.
    var latestFirmwareVersion: String? { get }
    
    /// The version of the remote app running on the camera.
    var remoteAppVersion: String? { get }
    
    /// The latest version of the remote app runnable on the camera.
    var latestRemoteAppVersion: String? { get }

    /// The latest version of the getEvent API
    var eventVersion: String? { get }

    /// The lens connected to the camera.
    var lensModelName: String? { get }
    
    /// The unique identifier of the camera
    var identifier: String { get }
    
    /// The event polling method of the camera.
    var eventPollingMode: PollingMode { get }
    
    /// Called by the camera when an event is available.
    var onEventAvailable: (() -> Void)? { get set }
    
    /// Called by the camera when it was disconnected.
    var onDisconnected: (() -> Void)? { get set }
    
    /// The connection mode of the camera, this determines the core functionality that is available
    /// on the camera once it has been connected.
    var connectionMode: ConnectionMode { get }
    
    /// Whether the camera is in beta support!
    var isInBeta: Bool { get }
    
    /// Connects to the camera and makes it ready for communication.
    ///
    /// - Parameter completion: A closure to be called once the camera is connected to.
    func connect(completion: @escaping ConnectedCompletion)
    
    /// Disconnects from the camera.
    ///
    /// - Parameter completion: A closure to be called once the camera is disconnected.
    func disconnect(completion: @escaping DisconnectedCompletion)
    
    /// Whether the camera is connected and ready to have functions called on it.
    var isConnected: Bool { get }
    
    /// Returns information about whether the camera supports a specific function, whether it is currently available via the API or not.
    ///
    /// It is important to note that whilst some camera functions are supported by a camera they may not be currently available. You should try and make them currently available by using the `makeFunctionAvailable` API.
    ///
    /// - Parameters:
    ///   - function: The function to check if the camera supports.
    ///   - callback: A closure called once the check has been made.
    func supportsFunction<T: CameraFunction>(_ function: T, callback: @escaping ((_ supported: Bool?, _ error: Error?, _ values: [T.SendType]?) -> Void))
    
    /// Returns whether a camera function is currently available via the API. If the method is not currently available, then a call to `makeFunctionAvailable` will try to make it available.
    ///
    /// - Parameters:
    ///   - function: The function to check for current API availability.
    ///   - callback: A closure called once the check has been made.
    func isFunctionAvailable<T: CameraFunction>(_ function: T, callback: @escaping ((_ available: Bool?, _ error: Error?, _ values: [T.SendType]?) -> Void))
    
    /// Attempts to make a particular `CameraFunction` available via the API.
    ///
    /// - Warning: Please be warned, this may disable other functions that you have already checked for Availability, so if un-sure
    /// please check them again by calling the `available(function:)` function
    ///
    /// - Parameters:
    ///   - function: The function to attempt to make available via the API.
    ///   - callback: A closure called with whether the function was enabled or not.
    func makeFunctionAvailable<T: CameraFunction>(_ function: T, callback: @escaping ((_ error: Error?) -> Void))
    
    /// Performs a given function by communicating with the camera.
    ///
    /// - Parameters:
    ///   - function: The function to perform.
    ///   - payload: The payload to send with the performed function.
    ///   - callback: A callback called when the function was performed.
    func performFunction<T: CameraFunction>(_ function: T, payload: T.SendType?, callback: @escaping ((_ error: Error?, _ value: T.ReturnType?) -> Void))
    
    /// Loads the files to transfer!
    ///
    /// - Parameters:
    ///   - callback: A closure called once the files have been loaded
    func loadFilesToTransfer(callback: @escaping ((_ error: Error?, _ files: [File]?) -> Void))
    
    /// Finishes automatic transfer initiated by loadFilesToTransfer
    ///
    /// - Parameter callback: A closure called once the transfer has finished
    func finishTransfer(callback: @escaping ((_ error: Error?) -> Void))
    
    /// Passes an event from a `CameraEventNotifier` to the camera it's notifying
    ///
    /// - Parameter event: The event that occured
    func handleEvent(event: CameraEvent)
    
    /// The last event which occured
    var lastEvent: CameraEvent? { get }
}

/// An error for local issues before the API request has been made to the camera
///
/// - notReady: We detected the camera is not ready for interaction. Please try calling `connect`
/// - notAvailable: We detected the function is not available. Please try calling `makeFunctionAvailable`
/// - invalidPayload: The payload is invalid for the function called, check your payload type
/// - invalidResponse: The response from the Camera was invalid, please create an issue on GitHub with details
/// - notSupportedByAvailableVersion: The function called is not supported by the API versions available on the camera
public enum FunctionError: Error {
    case notReady
    case notAvailable
    case invalidPayload
    case invalidResponse
    case notSupportedByAvailableVersion
}
