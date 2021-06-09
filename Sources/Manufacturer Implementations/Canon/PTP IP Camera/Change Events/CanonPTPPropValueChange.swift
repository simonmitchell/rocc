//
//  PropValueChange.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

/// A Canon PTP Event type for when a property's value changes
struct CanonPTPPropValueChange: CanonPTPEvent {
    
    static let LogCategory = "CanonPTPPropValueChange"
    
    /// The code of the property that changed
    let code: PTP.DeviceProperty.Code
    
    /// The value of the property
    let value: PTPDevicePropertyDataType

    init(code: PTP.DeviceProperty.Code, value: PTPDevicePropertyDataType) {
        self.code = code
        self.value = value
    }
    
    init?(_ data: ByteBuffer) {
        
        var offset: UInt = 0
        guard let code: DWord = data.read(offset: &offset) else {
            return nil
        }
        guard let codeEnum = PTP.DeviceProperty.Code(rawValue: code) else {
            Logger.log(message: "Unknown prop code: \(code)", category: Self.LogCategory)
            return nil
        }
        
        self.code = codeEnum
        
        guard let value = data.readValue(of: codeEnum.dataType(for: .canon), at: &offset) else {
            Logger.log(message: "Failed to read value of prop type: \(code)", category: Self.LogCategory)
            return nil
        }
        
        self.value = value
    }
}
