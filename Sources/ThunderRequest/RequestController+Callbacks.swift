//
//  RequestController+Callbacks.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation
import os.log

public struct RequestNotificationKey {
    public static let request = "TSCRequestNotificationRequestKey"
    public static let response = "TSCRequestNotificationResponseKey"
}

extension RequestController {
    
    public static let ErrorDomain = "com.threesidedcube.ThunderRequest"
    
    public static let DidReceiveResponseNotificationName = Notification.Name(rawValue: "TSCRequestDidReceiveResponse")
    
    public static let DidErrorNotificationName = Notification.Name("TSCRequestServerError")
    
    func add(completionHandler: TransferCompletion?, progressHandler: ProgressHandler?, forTaskId taskId: Int) {
        
        if transferCompletionHandlers[taskId] != nil {
            if #available(OSX 10.12, watchOSApplicationExtension 3.0, *) {
                os_log("Error: Got multiple handlers for a single task identifier. This should not happen.", log: requestLog, type: .error)
            }
        }
        
        transferCompletionHandlers[taskId] = completionHandler
        
        if progressHandlers[taskId] != nil {
            if #available(OSX 10.12, watchOSApplicationExtension 3.0, *) {
                os_log("Error: Got multiple progress handlers for a single task identifier.  This should not happen.", log: requestLog, type: .error)
            }
        }
        
        progressHandlers[taskId] = progressHandler
    }
    
    func callProgressHandlerFor(taskIdentifier: Int, progress: Double, totalBytes: Int64, progressBytes: Int64) {
        progressHandlers[taskIdentifier]?(progress, totalBytes, progressBytes)
    }
    
    func callTransferCompletionHandlersFor(taskIdentifier: Int, downloadedFileURL fileURL: URL?, error: Error?, response: URLResponse?) {
        
        var requestResponse: RequestResponse?
        if let urlResponse = response {
            requestResponse = RequestResponse(response: urlResponse, data: nil, fileURL: fileURL)
        }
        
        transferCompletionHandlers[taskIdentifier]?(requestResponse, fileURL, error)
        transferCompletionHandlers[taskIdentifier] = nil
        progressHandlers[taskIdentifier] = nil
    }
    
    func callCompletionHandlersFor(request: Request, urlRequest: URLRequest, data: Data?, response urlResponse: URLResponse?, error: Error?, completion: RequestCompletion?) {
        
        var response: RequestResponse?
        if let urlResponse = urlResponse {
            response = RequestResponse(response: urlResponse, data: data)
        }
        
        if let redirectResponse = redirectResponses[urlRequest.taskIdentifier] {
            response?.originalResponse = redirectResponse
        }
        
        var requestInfo: [AnyHashable : Any] = [:]
        requestInfo[RequestNotificationKey.request] = request
        requestInfo[RequestNotificationKey.response] = response
        
        NotificationCenter.default.post(name: RequestController.DidReceiveResponseNotificationName, object: nil, userInfo: requestInfo)
        
        if response?.status.isConsideredError == true {
            NotificationCenter.default.post(name: RequestController.DidErrorNotificationName, object: nil, userInfo: requestInfo)
        }
        
        defer {
            logResponse(error, request: request, urlRequest: urlRequest, response: response)
        }
        
        guard error != nil || response?.status.isConsideredError == true else {
            (callbackQueue ?? DispatchQueue.main).async {
                completion?(response, error)
            }
            return
        }
        
        var recoverableError: CustomisableRecoverableError
        if let error = error {
            recoverableError = AnyCustomisableRecoverableError(error)
        } else {
            recoverableError = HTTP.Error(statusCode: response?.status ?? .unknownError, domain: RequestController.ErrorDomain)
        }
        
        recoverableError.add(option: ErrorRecoveryOption(title: "Retry", style: .retry, handler: { (_, _) in
            self.schedule(request: request, completion: completion)
        }))
        
        recoverableError.add(option: ErrorRecoveryOption(title: "Cancel", style: .cancel))
        
        (callbackQueue ?? DispatchQueue.main).async {
            completion?(response, recoverableError)
        }
    }
    
    private func logResponse(_ error: Error?, request: Request, urlRequest: URLRequest, response: RequestResponse?) {
        
        if let error = error {
            if #available(OSX 10.12, watchOSApplicationExtension 3.0, *) {
                os_log("Request: %@", log: requestLog, type: .debug, urlRequest.debugDescription)
                os_log("""
                        
                        URL: %@
                        Method:%@
                        Request Headers:%@
                        Body: %@

                        Response Status: FAILURE
                        Error Description: %@
                        """,
                       log: requestLog,
                       type: .error,
                       urlRequest.url?.description ?? request.baseURL.description,
                       request.method.rawValue,
                       urlRequest.allHTTPHeaderFields ?? "",
                       urlRequest.httpBody != nil ? String(data: urlRequest.httpBody!, encoding: .utf8) ?? "" : "",
                       error.localizedDescription
                )
                
                log("""
                    
                    URL: \(urlRequest.url?.description ?? request.baseURL.description)
                    Method: \(request.method.rawValue)
                    Request Headers: \(urlRequest.allHTTPHeaderFields ?? [:])
                    Body: \(urlRequest.httpBody != nil ? String(data: urlRequest.httpBody!, encoding: .utf8) ?? "" : "")
                    
                    Response Status: FAILURE
                    Error Description: \(error.localizedDescription)
                    
                    """,
                    level: .error
                )
            }
            
        } else {
            
            if #available(OSX 10.12, watchOSApplicationExtension 3.0, *) {
                log("Request: \(urlRequest.debugDescription)", level: .debug)
                log("""
                    
                    URL: \(urlRequest.url?.description ?? request.baseURL.description)
                    Method: \(request.method.rawValue)
                    Request Headers: \(urlRequest.allHTTPHeaderFields ?? [:])
                    Body: \(urlRequest.httpBody != nil ? String(data: urlRequest.httpBody!, encoding: .utf8) ?? "" : "")
                    
                    Response Status: \(response?.status.rawValue ?? 999)
                    Response Body: \(response?.string ?? "")
                    
                    """,
                    level: .error
                )
                os_log("Request: %@", log: requestLog, type: .debug, urlRequest.debugDescription)
                os_log("""
                            
                            URL: %@
                            Method: %@
                            Request Headers: %@
                            Body: %@

                            Response Status: %li
                            Response Body: %@

                            """,
                       log: requestLog,
                       type: .error,
                       urlRequest.url?.description ?? request.baseURL.description,
                       request.method.rawValue,
                       urlRequest.allHTTPHeaderFields ?? "",
                       urlRequest.httpBody != nil ? String(data: urlRequest.httpBody!, encoding: .utf8) ?? "" : "",
                       response?.status.rawValue ?? 999,
                       response?.string ?? ""
                )
            }
        }
    }
}
