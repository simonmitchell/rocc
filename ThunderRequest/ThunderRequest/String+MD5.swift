//
//  String+MD5.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation
import CommonCrypto

public extension String {
    
    /// Returns the md5 data for the string
    var md5: Data? {
        
        guard let messageData = data(using:.utf8) else {
            return nil
        }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes { (digestBody: UnsafeMutableRawBufferPointer) in
            
            guard let baseAddress = digestBody.baseAddress, digestBody.count > 0 else {
                return
            }
            
            let digestBytes = baseAddress.assumingMemoryBound(to: UInt8.self)
            
            messageData.withUnsafeBytes { (messageBody: UnsafeRawBufferPointer) in
                
                guard let messageBaseAddress = messageBody.baseAddress, messageBody.count > 0 else {
                    return
                }
                    
                let messageBytes = messageBaseAddress.assumingMemoryBound(to: UInt8.self)
            
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    /// Returns HEX md5 string of self
    var md5Hex: String? {
        return md5?.map { String(format: "%02hhx", $0) }.joined()
    }
}
