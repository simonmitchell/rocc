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
            
            guard let _unknownWord = data[word: 0] else { return nil }
            unknownWord = _unknownWord
            
            guard let propertiesWordArray = data[wordArray: UInt(MemoryLayout<Word>.size)] else { return nil }
            supportedPropCodes = propertiesWordArray
        }
    }
}
