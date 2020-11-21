//
//  RequestResponse+Codable.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension RequestResponse {
    
    /// Attempts to decode the response data as a given type
    ///
    /// First attempts using JSONDecoder, then falls back to PropertyListDecoder
    ///
    /// - Returns: The decoded object, if parsing was sucessful
    public func decoded<T: Decodable>() -> T? {
        
        guard let data = data else { return nil }
        
        let jsonDecoder = JSONDecoder()
        if let jsonResult = try? jsonDecoder.decode(T.self, from: data) {
            return jsonResult
        }
        
        let plistDecoder = PropertyListDecoder()
        return try? plistDecoder.decode(T.self, from: data)
    }
}
