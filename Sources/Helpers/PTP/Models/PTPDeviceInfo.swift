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
        
        var supportedOperations: Set<CommandCode>
        
        var supportedEventCodes: Set<EventCode>
        
        var supportedDeviceProperties: Set<DeviceProperty.Code>
        
        let supportedCaptureFormats: Set<Word>
        
        let supportedImageFormats: Set<FileFormat>
        
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
            
            guard let _version: Word = data.read(offset: &offset) else {
                return nil
            }
            version = _version
            
            guard let _vendorExtensionId: DWord = data.read(offset: &offset) else {
                return nil
            }
            vendorExtensionId = _vendorExtensionId
            
            guard let _vendorExtensionVersion: Word = data.read(offset: &offset) else {
                return nil
            }
            vendorExtensionVersion = _vendorExtensionVersion
            
            guard let _vendorExtensionDescription: String = data.read(offset: &offset) else {
                return nil
            }
            vendorExtensionDescription = _vendorExtensionDescription
            
            guard let _functionalMode: Word = data.read(offset: &offset) else {
                return nil
            }
            functionalMode = _functionalMode
            
            guard let supportedOperationWords: [Word] = data.read(offset: &offset) else {
                return nil
            }
            supportedOperations = Set(supportedOperationWords.compactMap({ CommandCode(rawValue: $0) }))
            
            guard let supportedEventWords: [Word] = data.read(offset: &offset) else {
                return nil
            }
            supportedEventCodes = Set(supportedEventWords.compactMap({ EventCode(rawValue: $0) }))
            
            guard let _supportedDeviceProperties: [Word] = data.read(offset: &offset) else {
                return nil
            }
            supportedDeviceProperties = Set(_supportedDeviceProperties.compactMap({ DeviceProperty.Code(rawValue: DWord($0)) }))
            
            guard let _supportedCaptureFormats: [Word] = data.read(offset: &offset) else {
                return nil
            }
            supportedCaptureFormats = Set(_supportedCaptureFormats)
            
            guard let _supportedImageFormats: [Word] = data.read(offset: &offset) else {
                return nil
            }
            supportedImageFormats = Set(_supportedImageFormats.compactMap({ FileFormat(rawValue: $0) }))
            
            guard let _manufacturer: String = data.read(offset: &offset) else {
                return nil
            }
            manufacturer = _manufacturer
            
            // Above logic is a bit funny... we don't want to carry on if we can't parse the next element
            // because the PTP structure is very highly order-oriented
            
            guard let _model: String = data.read(offset: &offset) else {
                model = nil
                deviceVersion = nil
                serialNumber = nil
                return
            }
            model = _model
            
            guard let _deviceVersion: String = data.read(offset: &offset) else {
                deviceVersion = nil
                serialNumber = nil
                return
            }
            deviceVersion = _deviceVersion
            
            guard let _serialNumber: String = data.read(offset: &offset) else {
                serialNumber = nil
                return
            }
            serialNumber = _serialNumber
        }
    }
}
