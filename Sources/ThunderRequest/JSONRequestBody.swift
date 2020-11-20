//
//  JSONRequestBody.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A request body struct which can be used to represent the payload of a
/// JSON object
public struct JSONRequestBody: RequestBody {
    
    /// The json object that should be sent with the request
    let jsonObject: Any
    
    /// Creates a new JSON upload request body
    ///
    /// - Parameters:
    ///   - jsonObject: The JSON to send
    public init(_ jsonObject: Any) {
        self.jsonObject = jsonObject
    }
    
    public var contentType: String? {
        return "application/json"
    }
    
    public func payload() -> Data? {
        guard JSONSerialization.isValidJSONObject(jsonObject) else {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}
