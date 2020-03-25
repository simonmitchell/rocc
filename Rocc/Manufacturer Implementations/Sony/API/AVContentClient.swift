//
//  AVContentClient.swift
//  Rocc
//
//  Created by Simon Mitchell on 25/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import ThunderRequest

fileprivate extension File.Content {
    
    init(dictionary: [AnyHashable : Any]) {
        
        if let originalsArray = dictionary["original"] as? [[AnyHashable : Any]] {
            
            originals = originalsArray.compactMap({
                
                var url: URL?
                if let urlString = $0["url"] as? String {
                    url = URL(string: urlString)
                }
                
                return Original(fileName: $0["fileName"] as? String, fileType: $0["stillObject"] as? String, url: url)
            })
            
        } else {
            
            originals = []
        }
        
        smallURL = URL(string: dictionary["smallUrl"] as? String ?? "")
        largeURL = URL(string: dictionary["largeUrl"] as? String ?? "")
        thumbnailURL = URL(string: dictionary["thumbnailUrl"] as? String ?? "")
    }
}

fileprivate extension File {
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let _uri = dictionary["uri"] as? String else {
            return nil
        }
        
        uri = _uri
        
        if let createdString = dictionary["createdTime"] as? String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            created = dateFormatter.date(from: createdString)
            
        } else {
            
            created = nil
        }
        
        kind = dictionary["contentKind"] as? String
        
        if let contentDict = dictionary["content"] as? [AnyHashable : Any] {
            
            let tempContent = File.Content(dictionary: contentDict)
            var originals: [File.Content.Original] = []
            // For some reason using `map` here causes a compiler error... so back to good old for in!
            // Something to do with capturing `self.content` before it's been initialised, pretty
            // sure it's a red-herring but this fixes it for now!
            for tempOriginal in tempContent.originals {
                // If file type is missing (Only normally for video) then fill it in!
                if (tempOriginal.fileType ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    originals.append(File.Content.Original(
                        fileName: tempOriginal.fileName,
                        fileType: kind?.split(separator: "_").map({ String($0) }).last, // Should result in mp4 or xavcs
                        url: tempOriginal.url
                    ))
                } else {
                    originals.append(tempOriginal)
                }
            }
            content = File.Content(
                originals: originals,
                largeURL: tempContent.largeURL,
                smallURL: tempContent.smallURL,
                thumbnailURL: tempContent.thumbnailURL
            )
            
        } else {
            
            content = nil
        }
        
        folderNo = dictionary["folderNo"] as? String
        fileNo = dictionary["fileNo"] as? String
        isPlayable = dictionary["isPlayable"] as? Bool
        isBrowsable = dictionary["isBrowsable"] as? Bool
        isProtected = dictionary["isProtected"] as? Bool
    }
}

fileprivate extension FileRequest {
    var sonySerialised: [AnyHashable : Any] {
        
        var serialised: [AnyHashable : Any] = [
            "uri": uri,
            "stIdx": startIndex,
            "cnt": count,
        ]
        
        if let types = types {
            serialised["type"] = types
        }
        
        if let sortOrder = sort {
            switch sortOrder {
            case .ascending:
                serialised["sort"] = "ascending"
            case .descending:
                serialised["sort"] = "descending"
            }
        }
        
        switch view {
        case .date:
            serialised["view"] = "date"
        case .flat:
            serialised["view"] = "flat"
        }
        
        return serialised
    }
}

fileprivate extension CountRequest {
    
    var sonySerialised: [AnyHashable : Any] {
        
        var serialised: [AnyHashable : Any] = [
            "uri": uri,
            "target": target,
        ]
        
        if let types = types {
            serialised["type"] = types
        }
        
        switch view {
        case .date:
            serialised["view"] = "date"
        case .flat:
            serialised["view"] = "flat"
        }
        
        return serialised
    }
}

internal final class AVContentClient: ServiceClient {
    
    typealias GenericCompletion = (_ error: Error?) -> Void
    
    typealias CountCompletion = (_ result: Result<Int, Error>) -> Void
    
    typealias FilesCompletion = (_ result: Result<[File], Error>) -> Void
    
    typealias SourcesCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias SchemesCompletion = (_ result: Result<[String], Error>) -> Void
    
    internal convenience init?(apiInfo: SonyAPICameraDevice.ApiDeviceInfo) {
        guard let cameraService = apiInfo.services.first(where: { $0.type == "avContent" }) else { return nil }
        self.init(service: cameraService)
    }
    
    func getSchemeList(completion: SchemesCompletion?) {
        
        let body = SonyRequestBody(method: "getSchemeList", params: [], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSchemeList") {
                completion?(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let first = result.first else {
                completion?(Result.failure(CameraError.invalidResponse("getSchemeList")))
                return
            }
            
            completion?(Result.success(first.compactMap({ $0["scheme"] as? String })))
        }
    }
    
    func getSourceListFor(scheme: String, completion: @escaping SourcesCompletion) {
        
        let body = SonyRequestBody(method: "getSourceList", params: [["scheme":scheme]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSourceList") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let first = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSourceList")))
                return
            }
            
            completion(Result.success(first.compactMap({ $0["source"] as? String })))
        }
    }
    
    func getContentListFor(request: FileRequest, completion: @escaping FilesCompletion) {
        
        let body = SonyRequestBody(method: "getContentList", params: [request.sonySerialised], id: 1, version: "1.3")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getContentList") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let first = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getContentList")))
                return
            }
            
            completion(Result.success(first.compactMap({ File(dictionary: $0) })))
        }
    }
    
    func getContentCountFor(request: CountRequest, completion: @escaping CountCompletion) {
        
        let body = SonyRequestBody(method: "getContentCount", params: [request.sonySerialised], id: 1, version: "1.2")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getContentCount") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let count = result.first?["count"] as? Int else {
                completion(Result.failure(CameraError.invalidResponse("getContentCount")))
                return
            }
            
            completion(Result.success(count))
        }
    }
    
    func deleteContent(uris: [String], completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "deleteContent", params: [["uri" : uris]], id: 1, version: "1.1")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName:"deleteContent"))
        }
    }
    
    //MARK: - Streaming -
    
    typealias StreamingContentCompletion = (_ result: Result<URL, Error>) -> Void
    
    typealias StreamingPositionCompletion = (_ result: Result<TimeInterval, Error>) -> Void
    
    typealias StreamingStatusCompletion = (_ result: Result<(status: String, factor: String?), Error>) -> Void
    
    func setStreamingContent(_ content: String, completion: @escaping StreamingContentCompletion) {
        
        let body = SonyRequestBody(method: "setStreamingContent", params: [["remotePlayType": "simpleStreaming", "uri": content]], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setStreamingContent") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let urlString = result.first?["playbackUrl"] as? String, let url = URL(string: urlString) else {
                completion(Result.failure(CameraError.invalidResponse("setStreamingContent")))
                return
            }
            
            completion(Result.success(url))
        }
    }
    
    func startStreaming(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "startStreaming")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startStreaming"))
        }
    }
    
    func pauseStreaming(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "pauseStreaming")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "pauseStreaming"))
        }
    }
    
    func stopStreaming(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopStreaming")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopStreaming"))
        }
    }
    
    func seekStreamingPosition(_ completion: @escaping StreamingPositionCompletion) {
        
        let body = SonyRequestBody(method: "seekStreamingPosition")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "seekStreamingPosition") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let milliseconds = result.first?["positionMsec"] as? Int else {
                completion(Result.failure(CameraError.invalidResponse("seekStreamingPosition")))
                return
            }
            
            completion(Result.success(Double(milliseconds) / 1000))
        }
    }
    
    func getStreamingStatus(polling: Bool, completion: @escaping StreamingStatusCompletion) {
        
        let body = SonyRequestBody(method: "requestToNotifyStreamingStatus", params: [["polling" : polling]], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "requestToNotifyStreamingStatus") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let firstResult = result.first, let status = firstResult["status"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("requestToNotifyStreamingStatus")))
                return
            }
            
            completion(Result.success((status, firstResult["factor"] as? String)))
        }
    }
}
