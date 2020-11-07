//
//  PTPObjectInfo.swift
//  Rocc
//
//  Created by Simon Mitchell on 23/01/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTP {
    
    /// Allocates object info from a data buffer
    ///
    /// - Parameter data: The data buffer that represents the device info
    struct ObjectInfo {
        
        let storageID: DWord
        
        let format: Word
        
        let protectionStatus: Word
        
        let compressedSize: DWord
        
        let thumbnailFormat: Word
        
        let thumbnailCompressedSize: DWord
        
        let thumbnailSize: CGSize
        
        let imageSize: CGSize
        
        let bitDepth: DWord
        
        let parentObject: DWord
        
        let associationType: Word
        
        let associationDescription: DWord
        
        let sequenceNumber: DWord
        
        let fileName: String?
                
        init?(data: ByteBuffer) {
            
            var offset: UInt = 0
            
            guard let _storageID: DWord = data.read(offset: &offset) else {
                return nil
            }
            storageID = _storageID
            
            guard let _format: Word = data.read(offset: &offset) else {
                return nil
            }
            format = _format
            
            guard let _protectionStatus: Word = data.read(offset: &offset) else {
                return nil
            }
            protectionStatus = _protectionStatus
            
            guard let _compressedSize: DWord = data.read(offset: &offset) else {
                return nil
            }
            compressedSize = _compressedSize
            
            guard let _thumbnailFormat: Word = data.read(offset: &offset) else {
                return nil
            }
            thumbnailFormat = _thumbnailFormat
            
            guard let _thumbnailCompressedSize: DWord = data.read(offset: &offset) else {
                return nil
            }
            thumbnailCompressedSize = _thumbnailCompressedSize
            
            guard let thumbWidth: DWord = data.read(offset: &offset), let thumbHeight: DWord = data.read(offset: &offset) else {
                return nil
            }
            thumbnailSize = CGSize(width: Int(thumbWidth), height: Int(thumbHeight))
            
            guard let imageWidth: DWord = data.read(offset: &offset), let imageHeight: DWord = data.read(offset: &offset) else {
                return nil
            }
            imageSize = CGSize(width: Int(imageWidth), height: Int(imageHeight))
            
            guard let _bitDepth: DWord = data.read(offset: &offset) else {
                return nil
            }
            bitDepth = _bitDepth
            
            guard let _parentObject: DWord = data.read(offset: &offset) else {
                return nil
            }
            parentObject = _parentObject
            
            guard let _associationType: Word = data.read(offset: &offset) else {
                return nil
            }
            associationType = _associationType
            
            guard let _associationDescription: DWord = data.read(offset: &offset) else {
                return nil
            }
            associationDescription = _associationDescription
            
            guard let _sequenceNumber: DWord = data.read(offset: &offset) else {
                return nil
            }
            sequenceNumber = _sequenceNumber
            
            fileName = data.read(offset: &offset)
        }
    }
}
