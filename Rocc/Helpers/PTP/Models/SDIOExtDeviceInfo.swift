//
//  SDIOExtDeviceInfo.swift
//  Rocc
//
//  Created by Simon Mitchell on 05/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTP {
    
    struct SDIOExtDeviceInfo {
        
        //TODO: Work out how this works! Seems to be related to the initial request...
        let unknownWord: Word
        
        let supportedPropCodes: [Word]
        
        init?(data: ByteBuffer) {
            
            var offset: UInt = 0
            
            guard let _unknownWord = data[word: offset] else { return nil }
            unknownWord = _unknownWord
            offset += UInt(MemoryLayout<Word>.size)
            
            var _supportedPropCodes: [Word] = []
            
            guard let aPropertiesWordArray = data[wordArray: offset] else { return nil }
            _supportedPropCodes.append(contentsOf: aPropertiesWordArray)
            offset += UInt(MemoryLayout<DWord>.size + (MemoryLayout<Word>.size * aPropertiesWordArray.count))
            
            guard let bPropertiesWordArray = data[wordArray: offset] else {
                supportedPropCodes = _supportedPropCodes
                return
            }
            
            _supportedPropCodes.append(contentsOf: bPropertiesWordArray)
            supportedPropCodes = _supportedPropCodes
        }
    }
}
