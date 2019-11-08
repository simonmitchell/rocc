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
        
        var supportedOperations: [CommandCode]
        
        var supportedEventCodes: [EventCode]
        
        var supportedDeviceProperties: [DeviceProperty.Code]
        
        let supportedCaptureFormats: [Word]
        
        let supportedImageFormats: [FileFormat]
        
        let manufacturer: String
        
        let model: String?
        
        let deviceVersion: String?
        
        let serialNumber: String?
                
        /// Allocates device info from a data buffer
        ///
        /// - Note: Credit to [libgphoto2](https://github.com/gphoto/libgphoto2/blob/f55306ff3cc054da193ee1d48c44c95ec283873f/camlibs/ptp2/ptp-pack.c#L369) for breaking down how this works
        /// - Parameter data: The data buffer that represents the device info
        init?(data: ByteBuffer) {
            
            var offset: UInt = 0
            
            guard let _version = data[word: offset] else { return nil }
            version = _version
            offset += UInt(MemoryLayout<Word>.size)
            
            guard let _vendorExtensionId = data[dWord: offset] else { return nil }
            vendorExtensionId = _vendorExtensionId
            offset += UInt(MemoryLayout<DWord>.size)
            
            guard let _vendorExtensionVersion = data[word: offset] else { return nil }
            vendorExtensionVersion = _vendorExtensionVersion
            offset += UInt(MemoryLayout<Word>.size)
            
            guard let _vendorExtensionDescription = data[wString:  offset] else { return nil }
            vendorExtensionDescription = _vendorExtensionDescription
            offset += UInt(MemoryLayout<Byte>.size) + UInt(_vendorExtensionDescription.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
            
            guard let _functionalMode = data[word: offset] else { return nil }
            functionalMode = _functionalMode
            offset += UInt(MemoryLayout<Word>.size)
            
            guard let supportedOperationWords = data[wordArray: offset] else { return nil }
            supportedOperations = supportedOperationWords.compactMap({ CommandCode(rawValue: $0) })
            offset += UInt(MemoryLayout<DWord>.size) + UInt(supportedOperationWords.count * MemoryLayout<Word>.size)
            
            guard let supportedEventWords = data[wordArray: offset] else { return nil }
            supportedEventCodes = supportedEventWords.compactMap({ EventCode(rawValue: $0) })
            offset += UInt(MemoryLayout<DWord>.size) + UInt(supportedEventWords.count * MemoryLayout<Word>.size)
            
            guard let _supportedDeviceProperties = data[wordArray: offset] else { return nil }
            supportedDeviceProperties = _supportedDeviceProperties.compactMap({ DeviceProperty.Code(rawValue: $0) })
            offset += UInt(MemoryLayout<DWord>.size) + UInt(_supportedDeviceProperties.count * MemoryLayout<Word>.size)
            
            guard let _supportedCaptureFormats = data[wordArray: offset] else { return nil }
            supportedCaptureFormats = _supportedCaptureFormats
            offset += UInt(MemoryLayout<DWord>.size) + UInt(supportedCaptureFormats.count * MemoryLayout<Word>.size)
            
            guard let _supportedImageFormats = data[wordArray: offset] else { return nil }
            supportedImageFormats = _supportedImageFormats.compactMap({ FileFormat(rawValue: $0) })
            offset += UInt(MemoryLayout<DWord>.size) + UInt(_supportedImageFormats.count * MemoryLayout<Word>.size)
            
            guard let _manufacturer = data[wString: offset] else { return nil }
            manufacturer = _manufacturer
            offset += UInt(MemoryLayout<Byte>.size) + UInt(_manufacturer.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
            
            // Above logic is a bit funny... we don't want to carry on if we can't parse the next element
            // because the PTP structure is very highly order-oriented
            
            guard let _model = data[wString: offset] else {
                model = nil
                deviceVersion = nil
                serialNumber = nil
                return
            }
            offset += UInt(MemoryLayout<Byte>.size) + UInt(_model.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
            model = _model
            
            guard let _deviceVersion = data[wString: offset] else {
                deviceVersion = nil
                serialNumber = nil
                return
            }
            offset += UInt(MemoryLayout<Byte>.size) + UInt(_deviceVersion.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
            deviceVersion = _deviceVersion
            
            guard let _serialNumber = data[wString: offset] else {
                serialNumber = nil
                return
            }
            offset += UInt(MemoryLayout<Byte>.size) + UInt(_deviceVersion.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
            serialNumber = _serialNumber
        }
    }
}
