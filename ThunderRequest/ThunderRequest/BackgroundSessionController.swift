//
//  BackgroundSessionController.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/04/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// BackgroundRequestController is a helper class for setting up a URLSession object returned from a background task via a session identifier.
///
/// The helper wraps NSURLConnectionDownloadDelegate and calls a provided handler with the results of any requests as `TSCRequestResponse` objects
public class BackgroundRequestController: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    public typealias ResponseHandler = (_ task: URLSessionTask, _ response: RequestResponse?, _ error: Error?) -> Void
    
    public typealias FinishHandler = (_ session: URLSession) -> Void
    
    /// A closure called for each request that occured.
    public var responseHandler: ResponseHandler?
    
    /// A closure called when all requests have been sent to the responseHandler.
    public var finishedHandler: FinishHandler?
    
    private let sessionConfiguration: URLSessionConfiguration
    
    private var urlSession: URLSession?
    
    private let readData: Bool
    
    /// Creates a new request controller with a background session configuration identifier passed by the OS.
    ///
    /// - Parameters:
    ///   - identifier: The identifier to re-create the `URLSessionConfiguration` using.
    ///   - responseHandler: A closure called with the response to each background request.
    ///   - finishedHandler: A closure called when all background events have finished.
    ///   - queue: The operation queue to call back on.
    ///   - readDataAutomatically: Setting this to false allows you to stop the downloaded file's data being read from disk.
    ///   Reading from disk can cause problems with large background downloads as the background Daemon has a ~40mb memory limit
    ///   before being killed by the OS!
    public init(identifier: String, responseHandler: ResponseHandler?, finishedHandler: FinishHandler?, readDataAutomatically: Bool = true, queue: OperationQueue? = nil) {
        
        readData = readDataAutomatically
        self.responseHandler = responseHandler
        self.finishedHandler = finishedHandler
        sessionConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)
        
        super.init()
        
        urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: queue)
    }
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        finishedHandler?(session)
    }
    #endif
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let taskResponse = downloadTask.response else {
            responseHandler?(downloadTask, nil, nil)
            return
        }
        var data: Data?
        if readData {
            data = try? Data(contentsOf: location)
        }
        let response = RequestResponse(response: taskResponse, data: data, fileURL: location)
        responseHandler?(downloadTask, response, nil)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        responseHandler?(task, nil, error)
    }
}
