//
//  ByteBuffer+DeviceProperty.swift
//  Rocc
//
//  Created by Simon Mitchell on 07/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTP.DeviceProperty {
    
    struct Header<T: PTPDevicePropertyDataType> {
        
        let code: PTP.DeviceProperty.Code
        
        let dataType: PTP.DeviceProperty.DataType
        
        let getSet: Word
        
        let factory: T
        
        let current: T
        
        let offset: UInt
    }
}

extension ByteBuffer {
    
    func getDevicePropHeader<T: PTPDevicePropertyDataType>() -> PTP.DeviceProperty.Header<T>? {
        
        var offset: UInt = 0
        
        guard let codeWord = self[word: offset], let code = PTP.DeviceProperty.Code(rawValue: codeWord) else {
            return nil
        }
        offset += UInt(MemoryLayout<Word>.size)
        
        guard let typeWord = self[word: offset], let type = PTP.DeviceProperty.DataType(rawValue: typeWord) else {
            return nil
        }
        offset += UInt(MemoryLayout<Word>.size)
        
        guard let getSet = self[word: offset] else { return nil }
        offset += UInt(MemoryLayout<Word>.size)
        
        guard let factoryValue: T = getValue(at: offset) else { return nil }
        offset += UInt(MemoryLayout<T>.size)
        
        guard let currentValue: T = getValue(at: offset) else { return nil }
        offset += UInt(MemoryLayout<T>.size)
        
        return PTP.DeviceProperty.Header(
            code: code,
            dataType: type,
            getSet: getSet,
            factory: factoryValue,
            current: currentValue,
            offset: offset + UInt(MemoryLayout<Word>.size)
        )
    }
        
    func getValue<T: PTPDevicePropertyDataType>(at offset: UInt) -> T? {
        switch T.dataType {
        case .int8:
            guard let byte = self[offset] else { return nil }
            return Int8(byte) as? T
        case .uint8:
            return self[offset] as? T
        case .int16:
            guard let word = self[word: offset] else { return nil }
            return Int16(word) as? T
        case .uint16:
            return self[word: offset] as? T
        case .uint32:
            return self[dWord: offset] as? T
        case .string:
            return self[wStringWithoutCount: offset] as? T
        }
    }
    
    mutating func appendValue<T: PTPDevicePropertyDataType>(_ value: T) {
        switch T.dataType {
        case .int8:
            guard let int8 = value as? Int8 else { return }
            append(byte: Byte(int8))
        case .uint8:
            guard let uint8 = value as? UInt8 else { return }
            append(byte: uint8)
        case .int16:
            guard let int16 = value as? Int16 else { return }
            append(word: Word(int16))
        case .uint16:
             guard let uint16 = value as? UInt16 else { return }
             append(word: uint16)
        case .uint32:
            guard let uint32 = value as? UInt32 else { return }
            append(dWord: uint32)
        case .string:
            guard let string = value as? String else { return }
            append(wString: string, includingLength: false)
        }
    }
    
    func getArrayValues<T: PTPDevicePropertyDataType>(at offset: UInt) -> (values: [T], length: UInt)? {
        
        guard let elements = self[word: offset] else { return nil }
        var offset: UInt = UInt(MemoryLayout<Word>.size)
        var values: [T] = []
        
        for _ in 0..<elements {
            guard let element: T = getValue(at: offset) else { return nil }
            values.append(element)
            offset += UInt(MemoryLayout<T>.size)
        }
        
        return (values, offset)
    }
    
    func getDeviceProperty(at offset: UInt) -> PTPDeviceProperty {
        
        
    }
}
