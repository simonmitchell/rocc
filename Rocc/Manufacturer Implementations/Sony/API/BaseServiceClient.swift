//
//  BaseClient.swift
//  Rocc
//
//  Created by Simon Mitchell on 25/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

#if os(macOS)
import ThunderRequestMac
#else
import ThunderRequest
#endif

internal struct SonyRequestBody {
    
    let method: String
    
    let params: [Any]
    
    let id: Int
    
    let version: String
    
    init(method: String, params: [Any] = [], id: Int = 1, version: String = "1.0") {
        
        self.method = method
        self.params = params
        self.id = id
        self.version = version
    }
    
    var requestSerialised: RequestBody {
        return JSONRequestBody([
            "method": method,
            "params": params,
            "id": id,
            "version": version
        ])
    }
}

internal class ServiceClient {
    
    typealias VersionsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias MethodTypesCompletion = (_ result: Result<[Any], Error>) -> Void
    
    typealias AvailableApiListCompletion = (_ result: Result<[String], Error>) -> Void

    internal let requestController: RequestController
    
    internal let service: SonyAPICameraDevice.ApiDeviceInfo.Service
    
    internal var versions: [String]?
    
    internal var methodTypes: [Any]?
    
    internal var availableApiList: [String]?
    
    internal init?(service: SonyAPICameraDevice.ApiDeviceInfo.Service) {
        requestController = RequestController(baseURL: service.url)
        requestController.logger = Logger.shared
        self.service = service
    }
    
    func getVersions(_ completion: VersionsCompletion? = nil) {
        
        let body = SonyRequestBody(method: "getVersions")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { [weak self] (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getVersions") {
                completion?(Result.failure(error))
                return
            }
            
            guard let responseDictionary = response?.dictionary else {
                completion?(Result.failure(CameraError.invalidResponse("getVersions")))
                return
            }
            
            guard let result = responseDictionary["result"] as? [[String]], let firstResult = result.first else {
                completion?(Result.failure(CameraError.invalidResponse("getVersions")))
                return
            }
            
            self?.versions = firstResult
            completion?(Result.success(firstResult))
        }
    }
    
    func getMethodTypesFor(version: String?, completion: MethodTypesCompletion? = nil) {
        
        let body = SonyRequestBody(method: "getMethodTypes", params: [version ?? ""], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getMethodTypes") {
                completion?(Result.failure(error))
                return
            }
            
            guard let responseDictionary = response?.dictionary, let result = responseDictionary["results"] as? [[Any]] else {
                completion?(Result.failure(CameraError.invalidResponse("getMethodTypes")))
                return
            }
            
            completion?(Result.success(result))
        }
    }
    
    func getAvailableApiList(completion: AvailableApiListCompletion? = nil) {
        
        let body = SonyRequestBody(method: "getAvailableApiList")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { [weak self] (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableApiList") {
                completion?(Result.failure(error))
                return
            }
            
            guard let responseDictionary = response?.dictionary else {
                completion?(Result.failure(CameraError.invalidResponse("getAvailableApiList")))
                return
            }
            guard let result = responseDictionary["result"] as? [[String]], let firstResult = result.first else {
                completion?(Result.failure(CameraError.invalidResponse("getAvailableApiList")))
                return
            }
            
            self?.availableApiList = firstResult
            completion?(Result.success(firstResult))
        }
    }
}

extension CameraError {
    
    init?(responseDictionary: [AnyHashable : Any]?, methodName: String) {
        
        guard let responseDictionary = responseDictionary else { return nil }
        guard let error = responseDictionary["error"] as? [Any] else { return nil }
        guard let code = error.first as? Int else { return nil }
        
        if let message = error.last as? String {
            switch message.lowercased() {
            case "not available now":
                self = .notAvailable(message)
                return
            default:
                break
            }
        }
        
        switch code {
        case 0:
            return nil
        case 1:
            self = .any(methodName, error.last as? String)
        case 2:
            self = .timeout(methodName)
        case 3:
            self = .illegalArgument(methodName)
        case 4:
            self = .illegalDataFormat(methodName)
        case 5:
            self = .illegalRequest(methodName)
        case 6:
            self = .illegalResponse(methodName)
        case 7:
            self = .illegalState(methodName)
        case 8:
            self = .illegalType(methodName)
        case 9:
            self = .outOfBounds(methodName)
        case 10:
            self = .noSuchElement(methodName)
        case 11:
            self = .noSuchField(methodName)
        case 12:
            self = .noSuchMethod(methodName)
        case 13:
            self = .nullPointer(methodName)
        case 14:
            self = .unsupportedVersion(methodName)
        case 15:
            self = .unsupportedOperation(methodName)
        case 40400:
            self = .shootingFail(methodName)
        case 40401:
            self = .cameraNotReady(methodName)
        case 40402:
            self = .alreadyRunningPollingAPI(methodName)
        case 40403:
            self = .stillCapturingNotFinished(methodName)
        case 41003:
            self = .someContentCouldNotBeDeleted(methodName)
        default:
            return nil
        }
    }
}
