//
//  Codable+RequestBody.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A request body struct which can be used to represent the payload of
/// anything that conforms to Encodable!
public struct EncodableRequestBody<T: Encodable>: RequestBody {
    
    /// Enum representation of the encoding that should be used to prep data for the request
    ///
    /// - json: Encode to json
    /// - plist: Encode to plist
    public enum Encoding {
        case json
        case plist
        
        var contentType: String {
            switch self {
            case .json:
                return "application/json"
            case .plist:
                return "text/x-xml-plist"
            }
        }
    }
    
    /// The encoding type that should be used when converting to data for use with `URLSession`
    let encoding: Encoding
    
    /// The json object that should be sent with the request
    let encodableObject: T
    
    /// Creates a new Encodable upload request body
    ///
    /// - Parameters:
    ///   - jsonObject: The JSON to send
    public init(_ encodableObject: T, encoding: Encoding = .json) {
        self.encodableObject = encodableObject
        self.encoding = encoding
    }
    
    public var contentType: String? {
        return encoding.contentType
    }
    
    public func payload() -> Data? {
        switch encoding {
        case .json:
            return try? JSONEncoder().encode(encodableObject)
        case .plist:
            return try? PropertyListEncoder().encode(encodableObject)
        }
    }
}
