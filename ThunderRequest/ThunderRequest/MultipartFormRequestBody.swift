//
//  MultipartFormBody.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A protocol which can be conformed by anything to represent a part of a
/// multi-part form request payload
public protocol MultipartFormElement {
    /// Return the data to be appended to the request as a whole for this
    /// particular element
    ///
    /// - Parameters:
    ///   - boundary: The boundary which separates this element from the next. This should normally be appended and pre-pended to the returned data.
    ///   - key: The key for this part of the multi-part form data. This would normally be added as the "name" part of the returned data.
    /// - Returns: The data to append to the payload
    func multipartDataWith(boundary: String, key: String) -> Data?
}

/// A request body struct which can be used to represent the payload of a
/// multi-part form data request
public struct MultipartFormRequestBody: RequestBody {
    
    /// A dictionary comprising of the multi-part elements to be sent with the request
    let parts: [String : MultipartFormElement]
    
    /// The boundary for the request
    let boundary: String
    
    /// Creates a new multi-part form body with the given elements and boundary
    ///
    /// - Parameters:
    ///   - parts: A dictionary comprising the multi-part elements to be sent with the request
    ///   - boundary: (Optional) the boundary to use to separate elements in `object`
    public init(parts: [String : MultipartFormElement], boundary: String? = nil) {
        self.parts = parts
        self.boundary = boundary ?? "----TSCRequestController" + (String(describing: parts).md5Hex ?? "")
    }
    
    public var contentType: String? {
        return "multipart/form-data; boundary=\(boundary)"
    }
    
    public func payload() -> Data? {
        var returnData = Data()
        parts.forEach { (keyValue) in
            guard let partData = keyValue.value.multipartDataWith(boundary: boundary, key: keyValue.key) else {
                return
            }
            returnData.append(partData)
        }
        return returnData
    }
}
