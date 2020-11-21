//
//  ContentType+Data.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

public extension Data {
    
    /// Returns the estimated mime type of the data based on it's first byte
    var mimeType: String {
        
        guard count > 0 else { return "application/octet-stream" }
        let firstByte = self[0]
        switch firstByte {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        case 0x00:
            return "video/quicktime"
        case 0x44:
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }
    
    /// Returns the appropriate file extension for the data based on it's mimeType
    var fileExtension: String? {
        
        switch mimeType {
        case "image/jpeg":
            return "jpg"
        case "image/png":
            return "png"
        case "image/gif":
            return "gif"
        case "image/tiff":
            return "tiff"
        case "text/plain":
            return "txt"
        case "video/quicktime":
            return "mov"
        default:
            return nil
        }
    }
}
