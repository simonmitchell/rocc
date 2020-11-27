//
//  PropValueChange.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

/// A Canon PTP Event type for when a property value changes
struct CanonPTPPropValueChange: CanonPTPEvent {
    
    static let LogCategory = "CanonPTPPropValueChange"
    
    /// The code of the property that changed
    let code: PTP.DeviceProperty.Code
    
    let value: PTPDevicePropertyDataType
    
    init?(_ data: ByteBuffer) {
        
        var offset: UInt = 0
        guard let type: DWord = data.read(offset: &offset) else {
            return nil
        }
        guard let typeEnum = PTP.DeviceProperty.Code(rawValue: type) else {
            Logger.log(message: "Unknown prop type: \(type)", category: Self.LogCategory)
            return nil
        }
        
        code = typeEnum
        
        guard let value = data.readValue(of: typeEnum.dataType(for: .canon), at: &offset) else {
            Logger.log(message: "Failed to read value of prop type: \(typeEnum)", category: Self.LogCategory)
            return nil
        }
        
        self.value = value
    }
}
