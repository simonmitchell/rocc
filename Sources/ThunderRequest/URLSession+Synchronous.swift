//
//  NSURLSession+Synchronous.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension URLSession {
    
    //MARK: - Data Tasks -
    
    func sendSynchronousDataTaskWith(request: inout URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        
        let taskSemaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?
        var response: URLResponse?
        
        let task = dataTask(with: request) { (responseData, returnResponse, taskError) in
            
            data = responseData
            response = returnResponse
            error = taskError
            
            taskSemaphore.signal()
        }
        
        request.taskIdentifier = task.taskIdentifier
        task.resume()
        
        _ = taskSemaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
    
    func sendSynchronousDataTaskWith(url: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        
        var urlRequest = URLRequest(url: url)
        return sendSynchronousDataTaskWith(request: &urlRequest)
    }
    
    //MARK: - Upload Tasks -
    
    func sendSynchronousUploadTaskWith(request: inout URLRequest, uploadData: Data) -> (data: Data?, response: URLResponse?, error: Error?) {
        
        let taskSemaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?
        var response: URLResponse?
        
        let task = uploadTask(with: request, from: uploadData) { (responseData, returnResponse, taskError) in
            
            data = responseData
            response = returnResponse
            error = taskError
            
            taskSemaphore.signal()
        }
        
        request.taskIdentifier = task.taskIdentifier
        task.resume()
        
        _ = taskSemaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
    
    func sendSynchronousUploadTaskWith(request: inout URLRequest, fileURL: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        
        let taskSemaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?
        var response: URLResponse?
        
        let task = uploadTask(with: request, fromFile: fileURL) { (responseData, returnResponse, taskError) in
            
            data = responseData
            response = returnResponse
            error = taskError
            
            taskSemaphore.signal()
        }
        
        request.taskIdentifier = task.taskIdentifier
        task.resume()
        
        _ = taskSemaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
    
    //MARK: - Download Tasks -
    
    func sendSynchronousDownloadTaskWith(request: inout URLRequest) -> (downloadURL: URL?, response: URLResponse?, error: Error?) {
        
        let taskSemaphore = DispatchSemaphore(value: 0)
        var location: URL?
        var error: Error?
        var response: URLResponse?
        
        let task = downloadTask(with: request) { (responseLocation, returnResponse, taskError) in
            
            location = responseLocation
            response = returnResponse
            error = taskError
            
            taskSemaphore.signal()
        }
        
        request.taskIdentifier = task.taskIdentifier
        task.resume()
        
        _ = taskSemaphore.wait(timeout: .distantFuture)
        
        return (location, response, error)
    }
    
    func sendSynchronousDownloadTaskWith(url: URL) -> (downloadURL: URL?, response: URLResponse?, error: Error?) {
        
        var urlRequest = URLRequest(url: url)
        return sendSynchronousDownloadTaskWith(request: &urlRequest)
    }
    
    func sendSynchronousDownloadTaskWith(resumeData: Data) -> (downloadURL: URL?, response: URLResponse?, error: Error?) {
        
        let taskSemaphore = DispatchSemaphore(value: 0)
        var location: URL?
        var error: Error?
        var response: URLResponse?
        
        let task = downloadTask(withResumeData: resumeData) { (responseLocation, returnResponse, taskError) in
            
            location = responseLocation
            response = returnResponse
            error = taskError
            
            taskSemaphore.signal()
        }
        
        task.resume()
        
        _ = taskSemaphore.wait(timeout: .distantFuture)
        
        return (location, response, error)
    }
}
