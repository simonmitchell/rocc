//
//  String+MultipartFormElement.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension String: MultipartFormElement {
    
    public func multipartDataWith(boundary: String, key: String) -> Data? {
        return "--\(boundary)\r\nContent-Disposition: form-   ;name=\"\(key)\"\r\n\(self)\r\n".data(using: .utf8)
    }
}
