//
//  String+Regex.swift
//  Rocc
//
//  Created by Simon Mitchell on 24/10/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

internal extension String {
    
    struct CheckingResult {
        
        let match: String
        
        private let captures: [String]
        
        func capture(at: Int) -> String? {
            guard at < captures.count else { return nil }
            return captures[at]
        }
        
        init?(_ textCheckingResult: NSTextCheckingResult, in string: String) {
            
            guard let range = Range(textCheckingResult.range, in: string) else { return nil }
            
            match = String(string[range])
            
            var _captures: [String] = []
            for i in 0..<textCheckingResult.numberOfRanges {
                guard let captureRange = Range(textCheckingResult.range(at: i), in: string) else { continue }
                _captures.append(String(string[captureRange]))
            }
            captures = _captures
        }
    }
    
    func matches(for regex: String, at: Int = 0) throws -> [CheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(startIndex..., in: self))
            return results.compactMap {
                return CheckingResult($0, in: self)
            }
        } catch let error {
            throw error
        }
    }
}
