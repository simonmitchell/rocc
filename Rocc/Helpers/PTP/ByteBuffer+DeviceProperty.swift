//
//  ByteBuffer+DeviceProperty.swift
//  Rocc
//
//  Created by Simon Mitchell on 07/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTP.DeviceProperty {
    
    struct Header {
        
        let code: PTP.DeviceProperty.Code
        
        let dataType: PTP.DeviceProperty.DataType
        
        let getSetAvailable: PTP.DeviceProperty.GetSetAvailable
        
        let getSetSupported: PTP.DeviceProperty.GetSetSupported
                
        let factory: PTPDevicePropertyDataType
        
        let current: PTPDevicePropertyDataType
        
        let isRange: Bool
        
        let length: UInt
    }
}

extension ByteBuffer {
    
    func getDevicePropHeader(at offset: UInt = 0) -> PTP.DeviceProperty.Header? {
        
        var offset: UInt = offset
        
        guard let codeWord = self[word: offset] else {
            return nil
        }
        let code = PTP.DeviceProperty.Code(rawValue: codeWord) ?? .undefined
        offset += UInt(MemoryLayout<Word>.size)
        
        guard let typeWord = self[word: offset], let type = PTP.DeviceProperty.DataType(rawValue: typeWord) else {
            return nil
        }
        offset += UInt(MemoryLayout<Word>.size)
        
        guard let getSetSupportedByte = self[offset] else { return nil }
        let getSetSupported = PTP.DeviceProperty.GetSetSupported(rawValue: getSetSupportedByte) ?? .unknown
        offset += UInt(MemoryLayout<Byte>.size)
        
        guard let getSetAvailableByte = self[offset] else { return nil }
        let getSetAvailable = PTP.DeviceProperty.GetSetAvailable(rawValue: getSetAvailableByte) ?? .unknown
        offset += UInt(MemoryLayout<Byte>.size)
        
        guard let factoryValue: PTPDevicePropertyDataType = getValue(of: type, at: offset) else { return nil }
        offset += UInt(factoryValue.sizeOf)
        
        guard let currentValue: PTPDevicePropertyDataType = getValue(of: type, at: offset) else { return nil }
        offset += UInt(currentValue.sizeOf)
        
        return PTP.DeviceProperty.Header(
            code: code,
            dataType: type,
            getSetAvailable: getSetAvailable,
            getSetSupported: getSetSupported,
            factory: factoryValue,
            current: currentValue,
            isRange: self[offset] == 0x01,
            length: offset + UInt(MemoryLayout<Byte>.size)
        )
    }
        
    func getValue(of type: PTP.DeviceProperty.DataType, at offset: UInt) -> PTPDevicePropertyDataType? {
        switch type {
        case .int8:
            return self[int8: offset]
        case .uint8:
            return self[offset]
        case .int16:
            return self[int16: offset]
        case .uint16:
            return self[word: offset]
        case .uint32:
            return self[dWord: offset]
        case .string:
            return self[wStringWithoutCount: offset]
        }
    }
    
    mutating func appendValue(_ value: PTPDevicePropertyDataType, ofType type: PTP.DeviceProperty.DataType) {
        switch type {
        case .int8:
            guard let int8 = value as? Int8 else { return }
            append(int8: int8)
        case .uint8:
            guard let uint8 = value as? UInt8 else { return }
            append(byte: uint8)
        case .int16:
            guard let int16 = value as? Int16 else { return }
            append(int16: int16)
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
    
    func getArrayValues(of type: PTP.DeviceProperty.DataType, at offset: UInt) -> (values: [PTPDevicePropertyDataType], length: UInt)? {
        
        guard let elements = self[word: offset] else { return nil }
        var internalOffset: UInt = offset + UInt(MemoryLayout<Word>.size)
        var length: UInt = UInt(MemoryLayout<Word>.size)
        var values: [PTPDevicePropertyDataType] = []
        
        for _ in 0..<elements {
            guard let element: PTPDevicePropertyDataType = getValue(of: type, at: internalOffset) else { return nil }
            values.append(element)
            internalOffset += UInt(element.sizeOf)
            length += UInt(element.sizeOf)
        }
        
        return (values, length)
    }
    
    func getDeviceProperty(at offset: UInt) -> PTPDeviceProperty? {
        let slice = sliced(Int(offset))
        guard let header = slice.getDevicePropHeader() else { return nil }
        return header.isRange ? PTP.DeviceProperty.Range(data: slice) : PTP.DeviceProperty.Enum(data: slice)
    }
}
