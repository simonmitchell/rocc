//
//  RequestResponse.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A more useful representation of a `URLResponse` object.
///
/// This class contains useful properties to help access response data from a HTTP request with ease
public class RequestResponse {
    
    /// A dictionary representation of the headers the server responded with
    public var headers: [AnyHashable : Any]? {
        return httpResponse?.allHeaderFields
    }
    
    /// File url the response's data was saved to. This is only present for file downloads and is useful
    /// to get around the `40mb` memory limit which the Apple background service imposes on background download daemon
    public let fileURL: URL?
    
    /// Raw data returned from the server
    public let data: Data?
    
    /// The `HTTPURLResponse` object returned from the request. Contains info such as the response code.
    public let httpResponse: HTTPURLResponse?
    
    /// The original response of the request
    /// If the request was redirected, this represents the URLResponse for the original request
    public var originalResponse: HTTPURLResponse?
    
    /// Initialises a new request response from a given `URLResponse` and `Data`
    /// - Parameter response: The response to populate properties with
    /// - Parameter data: The data that was returned with the response
    /// - Parameter fileURL: The file url that the responses download was saved to (Only present for download tasks!)
    public init(response: URLResponse, data: Data?, fileURL: URL? = nil) {
        httpResponse = response as? HTTPURLResponse
        self.data = data
        self.fileURL = fileURL
    }
    
    /// The status of the HTTP request as an enum
    public var status: HTTP.StatusCode {
        guard let httpResponse = httpResponse else {
            return .unknownError
        }
        return HTTP.StatusCode(rawValue: httpResponse.statusCode) ?? .unknownError
    }
    
    /// The status of the HTTP request as a raw integer value
    public var statusCode: Int {
        return httpResponse?.statusCode ?? -1
    }
    
    /// Attempts to parse the response data to `Any`
    public var object: Any? {
        guard let data = data else { return nil }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
            return jsonObject
        }
        return try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil)
    }
    
    /// Returns the response data as a dictionary if available
    public var dictionary: [AnyHashable : Any]? {
        return object as? [AnyHashable : Any]
    }
    
    /// Returns the response data as an array if available
    public var array: [Any]? {
        return object as? [Any]
    }
    
    /// Returns the response data as a string if available
    public var string: String? {
        guard let data = data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Returns the response data as a string using the given encoding
    ///
    /// - Parameter encoding: The encoding to try and decode the data using
    /// - Returns: The string response encoded using the given method
    public func string(encoding: String.Encoding = .utf8) -> String? {
        guard let data = data else { return nil }
        return String(data: data, encoding: encoding)
    }
}
