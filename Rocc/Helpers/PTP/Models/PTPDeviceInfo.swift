//
//  PTPDeviceInfo.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTP {
    
    /// A structural representation of a PTP device's info
    struct DeviceInfo {
        
        let version: Word
        
        let vendorExtensionId: DWord
        
        let vendorExtensionVersion: Word
        
        let vendorExtensionDescription: String
        
        let functionalMode: Word
        
        let supportedOperations: [PTP.CommandCode]
        
        /// Allocates device info from a data buffer
        ///
        /// - Note: Credit to [libgphoto2](https://github.com/gphoto/libgphoto2/blob/f55306ff3cc054da193ee1d48c44c95ec283873f/camlibs/ptp2/ptp-pack.c#L369) for breaking down how this works
        /// - Parameter data: The data buffer that represents the device info
        init?(data: ByteBuffer) {
            
            var offset: UInt = 0
            
            guard let _version = data[word: offset] else { return nil }
            version = _version
            offset += 2
            
            guard let _vendorExtensionId = data[dWord: offset] else { return nil }
            vendorExtensionId = _vendorExtensionId
            offset += 4
            
            guard let _vendorExtensionVersion = data[word: offset] else { return nil }
            vendorExtensionVersion = _vendorExtensionVersion
            offset += 2
            
            guard let _vendorExtensionDescription = data[wString:  offset] else { return nil }
            vendorExtensionDescription = _vendorExtensionDescription
            offset += 1 + UInt(_vendorExtensionDescription.count * 2) + 2
            
            guard let _functionalMode = data[word: offset] else { return nil }
            functionalMode = _functionalMode
            offset += 2
            
            guard let supportedOperationWords = data[wordArray: offset] else { return nil }
            supportedOperations = supportedOperationWords.compactMap({ PTP.CommandCode(rawValue: $0) })
            offset += 1 + UInt(supportedOperationWords.count * 2)
        }
    }
}
