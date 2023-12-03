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
            return .ISOSpeedCanonEOS
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
            guard let binaryInt = value.toInt else {
                return nil
            }
            switch binaryInt {
            case 0x0000:
                self = .auto
            case 0x0040:
                self = .extended(50)
            case 0x0048:
                self = .native(100)
            case 0x004b:
                self = .native(125)
            case 0x004d:
                self = .native(160)
            case 0x0050:
                self = .native(200)
            case 0x0053:
                self = .native(250)
            case 0x0055:
                self = .native(320)
            case 0x0058:
                self = .native(400)
            case 0x005b:
                self = .native(500)
            case 0x005d:
                self = .native(640)
            case 0x0060:
                self = .native(800)
            case 0x0063:
                self = .native(1000)
            case 0x0065:
                self = .native(1250)
            case 0x0068:
                self = .native(1600)
            case 0x0070:
                self = .native(3200)
            case 0x0073:
                self = .native(4000)
            case 0x0075:
                self = .native(5000)
            case 0x0078:
                self = .native(6400)
            case 0x007b:
                self = .native(8000)
            case 0x007d:
                self = .native(10000)
            case 0x0080:
                self = .native(12800)
            case 0x0083:
                self = .native(16000)
            case 0x0085:
                self = .native(20000)
            case 0x0088:
                self = .native(25600)
            case 0x008b:
                // TODO: [Canon] Check these values with testers!
                self = .extended(51200)
            case 0x008d:
                // TODO: [Canon] Check these values with testers!
                self = .extended(102400)
            default:
                return nil
            }
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
            switch self {
            case .extended(let iso):
                switch iso {
                case 50:
                    return DWord(0x0040)
                case 51200:
                    // TODO: [Canon] Check these values with testers!
                    return DWord(0x008b)
                case 102400:
                    // TODO: [Canon] Check these values with testers!
                    return DWord(0x008d)
                default:
                    // Default to auto
                    return DWord(0x00000000)
                }
            case .native(let iso):
                switch iso {
                case 50:
                    return DWord(0x0040)
                case 100:
                    return DWord(0x0048)
                case 125:
                    return DWord(0x004b)
                case 160:
                    return DWord(0x004d)
                case 200:
                    return DWord(0x0050)
                case 250:
                    return DWord(0x0053)
                case 320:
                    return DWord(0x0055)
                case 400:
                    return DWord(0x0058)
                case 500:
                    return DWord(0x005b)
                case 640:
                    return DWord(0x005d)
                case 800:
                    return DWord(0x0060)
                case 1000:
                    return DWord(0x0063)
                case 1250:
                    return DWord(0x0065)
                case 1600:
                    return DWord(0x0068)
                case 3200:
                    return DWord(0x0070)
                case 4000:
                    return DWord(0x0073)
                case 5000:
                    return DWord(0x0075)
                case 6400:
                    return DWord(0x0078)
                case 8000:
                    return DWord(0x007b)
                case 10000:
                    return DWord(0x007d)
                case 12800:
                    return DWord(0x0080)
                case 16000:
                    return DWord(0x0083)
                case 20000:
                    return DWord(0x0085)
                case 25600:
                    return DWord(0x0088)
                default:
                    // Default to auto
                    return DWord(0x00000000)
                }
            case .auto:
                return DWord(0x00000000)
            default:
                // Default to auto
                return DWord(0x00000000)
            }
        }
    }
}