//
//  Data+RequestBody.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension Data: RequestBody {
    
    public var contentType: String? {
        return mimeType
    }
    
    public func payload() -> Data? {
        return self
    }
}
