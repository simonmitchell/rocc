//
//  ISOValue+SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension ISO.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .ISO
        case .canon:
            return .ISO
            //TODO: [Canon] Implement
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let binaryInt = value.toInt else {
                return nil
            }
            
            switch binaryInt {
            case 0x00ffffff:
                self = .auto
            case 0x01ffffff:
                self = .multiFrameNRAuto
            case 0x02ffffff:
                self = .multiFrameNRHiAuto
            default:
                var buffer = ByteBuffer()
                buffer.append(DWord(binaryInt))
                guard let value = buffer[word: 0] else {
                    return nil
                }
                guard let type = buffer[word: 2] else {
                    self = .native(Int(value))
                    return
                }
                switch type {
                case 0x0000:
                    self = .native(Int(value))
                case 0x1000:
                    self = .extended(Int(value))
                case 0x0100:
                    self = .multiFrameNR(Int(value))
                case 0x0200:
                    self = .multiFrameNRHi(Int(value))
                default:
                    self = .native(Int(value))
                }
            }
        case .canon:
            return nil
            //TODO: [Canon] Implement
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            switch self {
            case .auto:
                return DWord(0x00ffffff)
            case .multiFrameNRAuto:
                return DWord(0x01ffffff)
            case .multiFrameNRHiAuto:
                return DWord(0x02ffffff)
            case .extended(let value):
                var data = ByteBuffer()
                data.append(Word(value))
                data.append(Word(0x1000))
                return data[dWord: 0] ?? DWord(value)
            case .native(let value):
                var data = ByteBuffer()
                data.append(Word(value))
                data.append(Word(0x0000))
                return data[dWord: 0] ?? DWord(value)
            case .multiFrameNR(let value):
                var data = ByteBuffer()
                data.append(Word(value))
                data.append(Word(0x0100))
                return data[dWord: 0] ?? DWord(value)
            case .multiFrameNRHi(let value):
                var data = ByteBuffer()
                data.append(Word(value))
                data.append(Word(0x0200))
                return data[dWord: 0] ?? DWord(value)
            }
        case .canon:
            //TODO: [Canon] Implement
            return DWord(0)
        }
    }
}
