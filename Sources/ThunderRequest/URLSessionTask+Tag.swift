//
//  URLSessionTask+Identifier.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

private var tagKey: UInt8 = 0

extension URLSessionTask {
    
    /// This is an additional property on `URLSessionTask` which can be used to tag tasks.
    /// This allows for the cancellation of particular requests using tagging.
    var tag: Int? {
        get {
            return (objc_getAssociatedObject(self, &tagKey) as? NSNumber)?.intValue
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &tagKey, NSNumber(integerLiteral: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &tagKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
