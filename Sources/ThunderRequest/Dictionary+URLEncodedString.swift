//
//  Dictionary+URLEncodedString.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension Dictionary where Key == AnyHashable, Value == Any {
    
    init(urlEncodedString: String) {
        
        self.init()
        
        let string = URL(string: urlEncodedString)?.query ?? urlEncodedString
        let parameters = string.components(separatedBy: "&")
        
        parameters.forEach { (parameter) in
            let parts = parameter.components(separatedBy: "=")
            guard parts.count > 1 else { return }
            guard let key = parts[0].removingPercentEncoding else { return }
            guard let value = parts[1].removingPercentEncoding else { return }
            self[key] = value
        }
    }
}

extension Dictionary {
    
    /// Converts the dictionary to a query parameter string
    var queryParameterString: String? {
        
        guard !keys.isEmpty else {
            return nil
        }
        
        let parts: [String] = self.map { (keyValue) -> String in
            
            let keyString = String(describing: keyValue.key)
            let valueString = String(describing: keyValue.value)
            
            let part = "\(keyString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyString)=\(valueString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? valueString)"
            return part
        }
        
        return parts.joined(separator: "&")
    }
    
    /// Converts the dictionary to it's query parameter data with utf8 encoding
    var queryParameterData: Data? {
        return queryParameterString?.data(using: .utf8)
    }
}
