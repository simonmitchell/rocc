//
//  CanonPTPAvailableValuesChange.swift
//  Rocc
//
//  Created by Simon Mitchell on 30/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

struct CanonPTPAvailableValuesChange: CanonPTPEvent {
    
    static let LogCategory = "CanonPTPAvailableValuesChange"
    
    /// The code of property that available values changed for
    let code: PTP.DeviceProperty.Code
    
    /// The available value of the property
    let availableValues: [PTPDevicePropertyDataType]
    
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
        
        guard let type: DWord = data.read(offset: &offset) else {
            Logger.log(message: "Failed to read type of prop type: \(codeEnum)", category: Self.LogCategory)
            return nil
        }
        
        guard let count: DWord = data.read(offset: &offset) else {
            Logger.log(message: "Failed to read count of available props: \(codeEnum)", category: Self.LogCategory)
            return nil
        }
        
        // For some reason the values in here are stored under different types
        // to how they are defined in `PTP.DeviceProperty.Code` so we have to
        // do some munging sillyness! According to [libgphoto2](https://github.com/gphoto/libgphoto2/blob/cc002f314e8ed555966f2f8202dac02948f83968/camlibs/ptp2/ptp-pack.c#L2122) both 1 and 3
        // are uint16 and we can ignore any other type codes
        switch type {
        case 3, 1:
            var values: [PTPDevicePropertyDataType] = []
            for i in 0..<Int(count) {
                var arrayOffset: UInt = offset + UInt(i * MemoryLayout<DWord>.size)
                if let value = data.readValue(of: codeEnum.dataType(for: .canon), at: &arrayOffset) {
                    values.append(value)
                }
            }
            availableValues = values
        default:
            availableValues = []
            Logger.log(message: "Unsupported type for code \(codeEnum)", category: Self.LogCategory)
        }
    }
}
