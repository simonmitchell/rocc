//
//  ShutterSpeed+PTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension ShutterSpeed: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .shutterSpeed
        case .canon:
            return .shutterSpeed
            //TODO: [Canon] Implement
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let binaryInt = value.toInt else {
                return nil
            }
            
            var buffer = ByteBuffer()
            buffer.append(DWord(binaryInt))
            guard let denominator = buffer[word: 0] else {
                return nil
            }
            guard let numerator = buffer[word: 2] else {
                return nil
            }
            
            self.denominator = Double(denominator)
            self.numerator = Double(numerator)
        case .canon:
            //TODO: [Canon] Implement
            return nil
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            var data = ByteBuffer()
            // isBulb can be 0/0 or -1/-1 but PTP IP uses 0/0
            if isBulb {
                data.append(Word(0))
                data.append(Word(0))
            } else {
                data.append(Word(denominator))
                data.append(Word(numerator))
            }
            return data[dWord: 0] ?? DWord(value)
        case .canon:
            //TODO: [Canon] Implement
            return DWord(0)
        }
    }
}
