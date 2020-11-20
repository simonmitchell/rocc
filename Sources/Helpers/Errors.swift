//
//  Errors.swift
//  Rocc
//
//  Created by Simon Mitchell on 28/11/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// An enum representing errors which can be returned from the camera
///
/// - invalidResponse: The reponse given was illegal
/// - any: A generic error which could mean anything
/// - timeout: The action timed out on the camera
/// - illegalArgument: An invalid argument was sent to the camera
/// - illegalDataFormat: An invalid data format was sent to the camera
/// - illegalResponse: An invalid response was sent to the camera
/// - illegalRequest: An invalid body was sent to the camera
/// - illegalState: The camera is not in the correct state to perform the function
/// - illegalType: An invalid parameter type was sent to the camera
/// - outOfBounds: The index requested was out of bounds
/// - notAvailable: The function is not currently available, but could be in the future
/// - noSuchElement: The element requested doesn't exist
/// - noSuchField: The field requested doesn't exist
/// - noSuchMethod: The method performed doesn't exist
/// - nullPointer: The camera experienced a null pointer error
/// - unsupportedVersion: The specified version is not supported
/// - unsupportedOperation: The specified operation is not supported
/// - shootingFail: Capturing a still or other failed
/// - cameraNotReady: The camera has not been made ready. Try calling `connect` on it
/// - alreadyRunningPollingAPI: The camera is already running a polling API
/// - stillCapturingNotFinished: The camera has not finished capturing the previous still image yet
/// - someContentCouldNotBeDeleted: Some of the content that was attempted deletion could not be sucessfully deleted
public enum CameraError: LocalizedError {
    
    case invalidResponse(String)
    case any(String, String?)
    case timeout(String)
    case illegalArgument(String)
    case illegalDataFormat(String)
    case illegalResponse(String)
    case illegalRequest(String)
    case illegalState(String)
    case illegalType(String)
    case outOfBounds(String)
    case notAvailable(String)
    case noSuchElement(String)
    case noSuchField(String)
    case noSuchMethod(String)
    case nullPointer(String)
    case unsupportedVersion(String)
    case unsupportedOperation(String)
    case shootingFail(String)
    case cameraNotReady(String)
    case alreadyRunningPollingAPI(String)
    case stillCapturingNotFinished(String)
    case someContentCouldNotBeDeleted(String)
    
    var localizedDescription: String {
        return errorDescription ?? "Unknown Error"
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(let methodName):
            return "\(methodName): Invalid Response"
        case .any(let methodName, let error):
            return "\(methodName): \(error ?? "Unknown Error")"
        case .timeout(let methodName):
            return "\(methodName): The Request Timed Out"
        case .illegalArgument(let methodName):
            return "\(methodName): Illegal Argument"
        case .illegalDataFormat(let methodName):
            return "\(methodName): Illegal Data Format"
        case .illegalRequest(let methodName):
            return "\(methodName): Illegal Request"
        case .illegalResponse(let methodName):
            return "\(methodName): Illegal Response"
        case .illegalState(let methodName):
            return "\(methodName): Illegal State"
        case .illegalType(let methodName):
            return "\(methodName): Illegal Type"
        case .notAvailable(let methodName):
            return "\(methodName): Not available Now"
        case .outOfBounds(let methodName):
            return "\(methodName): Index Out Of Bounds"
        case .noSuchElement(let methodName):
            return "\(methodName): No Such Element"
        case .noSuchField(let methodName):
            return "\(methodName): No Such Field"
        case .noSuchMethod(let methodName):
            return "\(methodName): Camera doesn't support this method"
        case .nullPointer(let methodName):
            return "\(methodName): Null Pointer"
        case .unsupportedVersion(let methodName):
            return "\(methodName): Version Unsupported"
        case .unsupportedOperation(let methodName):
            return "\(methodName): Operation Unsupported"
        case .shootingFail(let methodName):
            return "\(methodName): Shooting Failed"
        case .cameraNotReady(let methodName):
            return "\(methodName): Camera Not Ready"
        case .alreadyRunningPollingAPI(let methodName):
            return "\(methodName): Already Running Polling API"
        case .stillCapturingNotFinished(let methodName):
            return "\(methodName): Hasn't Finished Capturing"
        case .someContentCouldNotBeDeleted(let methodName):
            return "\(methodName): Some Content Couldn't Be Deleted"
        }
    }
}

extension CameraError: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        return [
            NSLocalizedDescriptionKey: localizedDescription
        ]
    }
}
