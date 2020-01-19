//
//  ShutterSpeed+SonyPTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension ShutterSpeed: SonyPTPPropValueConvertable {
    
    var type: PTP.DeviceProperty.DataType {
        return .uint32
    }
    
    var code: PTP.DeviceProperty.Code {
        return .shutterSpeed
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        
        guard let binaryInt = sonyValue.toInt else {
            return nil
        }
        
        var buffer = ByteBuffer()
        buffer.append(dWord: DWord(binaryInt))
        guard let denominator = buffer[word: 0] else {
            return nil
        }
        guard let numerator = buffer[word: 2] else {
            return nil
        }
        
        self.denominator = Double(denominator)
        self.numerator = Double(numerator)
        
        guard denominator == 0, numerator == 0 else {
            return
        }
        
        isBulb = true
    }
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        var data = ByteBuffer()
        data.append(word: Word(denominator))
        data.append(word: Word(numerator))
        return data[dWord: 0] ?? DWord(value)
    }
}
