//
//  Data+MultipartFormElement.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension Data: MultipartFormElement {
    
    public func multipartDataWith(boundary: String, key: String) -> Data? {
        return multipartDataWith(boundary: boundary, key: key, contentType: mimeType, fileExtension: fileExtension)
    }
    
    func multipartDataWith(boundary: String, key: String, contentType: String, fileExtension: String?) -> Data? {
        
        var elementString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"; filename=\"filename\(fileExtension != nil ? ".\(fileExtension!)" : "")\"\r\n"
        elementString.append("Content-Type: \(contentType)\r\n")
        elementString.append("Content-Transfer-Encoding: binary\r\n\r\n")
        
        var data = elementString.data(using: .utf8)
        data?.append(self)
        data?.append("\r\n")
        data?.append("--\(boundary)")
        
        return data
    }
}
