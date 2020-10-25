//
//  JSONRequestBody.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A request body struct which can be used to represent the payload of a form url encoded request
public struct FormURLEncodedRequestBody: RequestBody {
    
    /// The payload object that should be sent with the request
    public let payloadObject: [AnyHashable : Any]
    
    /// Creates a new form url encoded upload request body
    ///
    /// - Parameters:
    ///   - propertyList: The Plist to send
    public init(_ payload: [AnyHashable: Any]) {
        self.payloadObject = payload
    }
    
    public var contentType: String? {
        return "application/x-www-form-urlencoded"
    }
    
    public func payload() -> Data? {
        return payloadObject.queryParameterData
    }
}
