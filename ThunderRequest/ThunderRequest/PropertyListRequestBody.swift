//
//  JSONRequestBody.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A request body struct which can be used to represent the payload of a
/// Plist object
public struct PropertyListRequestBody: RequestBody {
    
    /// The xml plist object that should be sent with the request
    let propertyList: Any
    
    /// The format to be used to write the plist data
    ///
    /// - xml: As XML
    /// - binary: As a binary file
    public enum Format {
        case xml
        case binary
        
        var plistFormat: PropertyListSerialization.PropertyListFormat {
            switch self {
            case .binary:
                return .binary
            case .xml:
                return .xml
            }
        }
        
        var contentType: String {
            switch self {
            case .xml:
                return "text/x-xml-plist"
            case .binary:
                return "application/x-plist"
            }
        }
    }
    
    /// The format to send the plist as
    let format: Format
    
    /// Creates a new Plist upload request body
    ///
    /// - Parameters:
    ///   - propertyList: The Plist to send
    ///   - format: (optional) How to format the plist
    public init(_ propertyList: Any, format: Format = .xml) {
        self.propertyList = propertyList
        self.format = format
    }
    
    public var contentType: String? {
        return format.contentType
    }
    
    public func payload() -> Data? {
        guard PropertyListSerialization.propertyList(propertyList, isValidFor: format.plistFormat) else {
            return nil
        }
        return try? PropertyListSerialization.data(fromPropertyList: propertyList, format: format.plistFormat, options: 0)
    }
}
