//
//  Request.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation
import os.log

/// A `Request` object represents a URL load request to be made by an instance of `RequestController`
///
/// Generally `Request` objects are created automatically by `RequestController`, but you may with to manually construct one in certain cases
public class Request {

    /// The base URL for the request e.g. "https://api.mywebsite.com"
    public var baseURL: URL
    
    /// The path to be appended to the `baseURL`.
    ///
    /// This should exclude the first "/" as this is appended automatically.
    /// e.g: "users/list.php"
    public var path: String?
    
    /// The HTTP method for the request.
    public var method: HTTP.Method
    
    /// An object to be used as the body of the request
    public var body: RequestBody?
    
    /// URL query items to be sent with the request
    public var urlQueryItems: [URLQueryItem]?
    
    /// A dictionary to be used as the headers for the request
    public var headers: [String : String?] = [:]
    
    /// The content type override for the request, such as "application/json"
    public var contentType: String?
    
    /// The tag for the request
    /// This can be used to cancel multiple requests with the same tag.
    public var tag: Int?
    
    private var _log: Any? = nil
    @available(macOS 10.12, watchOSApplicationExtension 3.0, *)
    fileprivate var log: OSLog {
        if _log == nil {
            _log = OSLog(subsystem: "com.threesidedcube.ThunderRequest", category: "Request")
        }
        return _log as! OSLog
    }
    
    public init(baseURL: URL, path: String?, method: HTTP.Method, queryItems: [URLQueryItem]?) {
        
        self.path = path
        self.method = method
        self.baseURL = baseURL
        urlQueryItems = queryItems
    }
    
    /// Configures and returns an `NSMutableRequest` which can be used with an `NSURLSession`
    ///
    /// - Returns: Returns a valid request object
    func construct() throws -> URLRequest {
        
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw RequestError.invalidBaseURL
        }
        
        var allQueryItems = urlQueryItems
        
        // Make sure if base url is our full URL (incl. query items) we don't throw away it's query items!
        if let baseURLQueryItems = urlComponents.queryItems, !baseURLQueryItems.isEmpty {
            if allQueryItems == nil {
                allQueryItems = []
            }
            allQueryItems?.append(contentsOf: baseURLQueryItems)
        }
        
        if let path = path, let pathComponents = URLComponents(string: path) {
            
            // First let's construct urlComponents from the passed in path, if we just append the path itself,
            // and it already contains urlComponents, these are url encoded (i.e. ? => %3F) which breaks requests
            urlComponents.path = urlComponents.path.appending(pathComponents.path)
            if let pathQueryItems = pathComponents.queryItems, !pathQueryItems.isEmpty {
                if allQueryItems == nil {
                    allQueryItems = []
                }
                allQueryItems?.append(contentsOf: pathQueryItems)
            }
            
        } else if let path = path { // If we can't construct url components, just try
            urlComponents.path = urlComponents.path.appending(path)
        }
        
        // Set the query items, if this is an empty array `?` will be appended, if it's nil, nothing will
        urlComponents.queryItems = allQueryItems
        
        guard let url = urlComponents.url else {
            throw RequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.httpBody = body.payload()
        }
        
        // Don't set the content-type header for GET requests, as they shouldn't be sending data
        // Some APIs will error if you provide a content-type with no data!
        if method != .GET && request.httpBody != nil {
            let contentTypeString = contentType ?? body?.contentType
            request.setValue(contentTypeString, forHTTPHeaderField: "Content-Type")
            headers["Content-Type"] = contentTypeString
        }
        
        if method == .GET && request.httpBody != nil {
            if #available(OSX 10.12, watchOSApplicationExtension 3.0, *) {
                os_log("Invalid request to: %{public}@. Should not be sending a GET request with a non-nil body", log: log, type: .error, url.absoluteString)
            }
        }
        
        headers.forEach { (keyValue) in
            request.setValue(keyValue.value, forHTTPHeaderField: keyValue.key)
        }
        
        return request
    }
}

public enum RequestError: Error {
    case invalidBaseURL
    case invalidURL
    case invalidBody
}
