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
        return errorDescription ?? NSLocalizedString("error_unknown", comment: "")
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(_):
            return NSLocalizedString("error_invalidresponse", comment: "")
        case .any(_, let error):
            return error ?? NSLocalizedString("error_unknown", comment: "")
        case .timeout(_):
            return NSLocalizedString("error_timeout", comment: "")
        case .illegalArgument(_):
            return NSLocalizedString("error_illegalargument", comment: "")
        case .illegalDataFormat(_):
            return NSLocalizedString("error_illegaldataformat", comment: "")
        case .illegalRequest(_):
            return NSLocalizedString("error_illegalrequest", comment: "")
        case .illegalResponse(_):
            return NSLocalizedString("error_illegalresponse", comment: "")
        case .illegalState(_):
            return NSLocalizedString("error_illegalstate", comment: "")
        case .illegalType(_):
            return NSLocalizedString("error_illegaltype", comment: "")
        case .notAvailable(_):
            return NSLocalizedString("error_unavailable", comment: "")
        case .outOfBounds(_):
            return NSLocalizedString("error_outofbounds", comment: "")
        case .noSuchElement(_):
            return NSLocalizedString("error_nosuchelement", comment: "")
        case .noSuchField(_):
            return NSLocalizedString("error_nosuchfield", comment: "")
        case .noSuchMethod(_):
            return NSLocalizedString("error_unsupported", comment: "")
        case .nullPointer(_):
            return NSLocalizedString("error_nullpointer", comment: "")
        case .unsupportedVersion(_):
            return NSLocalizedString("error_invalidversion", comment: "")
        case .unsupportedOperation(_):
            return NSLocalizedString("error_operationunsupported", comment: "")
        case .shootingFail(_):
            return NSLocalizedString("error_shootingfailure", comment: "")
        case .cameraNotReady(_):
            return NSLocalizedString("error_cameranotready", comment: "")
        case .alreadyRunningPollingAPI(_):
            return NSLocalizedString("error_alreadypolling", comment: "")
        case .stillCapturingNotFinished(_):
            return NSLocalizedString("error_capturenotfinished", comment: "")
        case .someContentCouldNotBeDeleted(_):
            return NSLocalizedString("error_contentnotdeleted", comment: "")
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
