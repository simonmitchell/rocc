//
//  URLSessionDelegate.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

protocol SessionDelegate {
    
    //MARK: - Download Delegate -
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    
    //MARK: - Upload Delegate -
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    
    //MARK: - URL Session Delegate -
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void)
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

class SessionDelegateProxy: NSObject, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    
    let delegate: SessionDelegate
    
    init(delegate: SessionDelegate) {
        self.delegate = delegate
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        delegate.urlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        delegate.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        delegate.urlSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate.urlSession(session, task: task, didCompleteWithError: error)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        delegate.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        delegate.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }
}
