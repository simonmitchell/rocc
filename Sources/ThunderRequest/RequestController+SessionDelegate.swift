//
//  RequestController+SessionDelegate.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension RequestController: SessionDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        callTransferCompletionHandlersFor(taskIdentifier: downloadTask.taskIdentifier, downloadedFileURL: location, error: nil, response: downloadTask.response)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
        callProgressHandlerFor(taskIdentifier: downloadTask.taskIdentifier, progress: progress, totalBytes: totalBytesExpectedToWrite, progressBytes: totalBytesWritten)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent)/Double(totalBytesExpectedToSend)
        callProgressHandlerFor(taskIdentifier: task.taskIdentifier, progress: progress, totalBytes: totalBytesExpectedToSend, progressBytes: totalBytesSent)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        callTransferCompletionHandlersFor(taskIdentifier: task.taskIdentifier, downloadedFileURL: nil, error: error, response: task.response)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        redirectResponses[task.taskIdentifier] = response
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard challenge.previousFailureCount == 0 else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        completionHandler(.useCredential, sharedRequestCredentials?.credential)
    }
}
