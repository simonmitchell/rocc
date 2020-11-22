//
//  URLRequest+Backgroundable.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 13/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension URLRequest {
    
    var backgroundable: URLRequest? {
        
        guard let url = url else { return nil }
        
        var backgroundableRequest = URLRequest(url: url)
        backgroundableRequest.httpMethod = httpMethod
        backgroundableRequest.httpBody = httpBody
        allHTTPHeaderFields?.forEach({ (keyValue) in
            backgroundableRequest.setValue(keyValue.value, forHTTPHeaderField: keyValue.key)
        })
        return backgroundableRequest
    }
}
