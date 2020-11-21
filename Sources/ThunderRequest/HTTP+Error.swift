//
//  HTTP+Error.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 18/04/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

public extension HTTP {
    
    /// Structural representation of a HTTP error
    struct Error: CustomisableRecoverableError {
        
        public var description: String?
        
        public var code: Int
        
        public var domain: String?
        
        public var failureReason: String?
        
        public var recoverySuggestion: String?
        
        public var options: [ErrorRecoveryOption] = []
        
        init(statusCode: HTTP.StatusCode, domain: String) {
            failureReason = statusCode.localizedDescription
            self.code = statusCode.rawValue
            self.domain = domain
        }
    }
}

extension HTTP.Error: CustomNSError {
    
    public var errorCode: Int {
        return code
    }
}
