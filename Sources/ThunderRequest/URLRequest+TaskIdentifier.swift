//
//  URLRequest+TaskIdentifier.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

private var identifierKey: UInt8 = 0

extension URLRequest {
    
    /// This is an additional property which is used internally to hookup a `URLRequest` object
    /// with it's session task in order to call completion blocks upon it finishing!
    var taskIdentifier: Int? {
        get {
            return (objc_getAssociatedObject(self, &identifierKey) as? NSNumber)?.intValue
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &identifierKey, NSNumber(integerLiteral: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &identifierKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
