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
        
        let unknownWord: Word
        
        let supportedPropCodes: [Word]
        
        init?(data: ByteBuffer) {
            
            var offset: UInt = 0
            
            guard let _unknownWord: Word = data.read(offset: &offset) else { return nil }
            unknownWord = _unknownWord
            
            var _supportedPropCodes: [Word] = []
            
            guard let aPropertiesWordArray: [Word] = data.read(offset: &offset) else { return nil }
            _supportedPropCodes.append(contentsOf: aPropertiesWordArray)
            
            guard let bPropertiesWordArray: [Word] = data.read(offset: &offset) else {
                supportedPropCodes = _supportedPropCodes
                return
            }
            
            _supportedPropCodes.append(contentsOf: bPropertiesWordArray)
            supportedPropCodes = _supportedPropCodes
        }
    }
}
