//
//  ByteBuffer+DeviceProperty.swift
//  Rocc
//
//  Created by Simon Mitchell on 07/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTP.DeviceProperty {
    
    enum Structure: Byte {
        case other
        case range
        case enumeration
    }
    
    struct Header {
        
        let code: PTP.DeviceProperty.Code
        
        let dataType: PTP.DeviceProperty.DataType
        
        let getSetAvailable: PTP.DeviceProperty.GetSetAvailable
        
        let getSetSupported: PTP.DeviceProperty.GetSetSupported
                
        let factory: PTPDevicePropertyDataType
        
        let current: PTPDevicePropertyDataType
        
        let structure: Structure
        
        let length: UInt
    }
}

extension ByteBuffer {
    
    func getDevicePropHeader(at offset: UInt = 0) -> PTP.DeviceProperty.Header? {
        
        var offset: UInt = offset
        
        guard let codeWord: Word = read(offset: &offset) else {
            return nil
        }
        let code = PTP.DeviceProperty.Code(rawValue: codeWord) ?? .undefined
        
        guard let typeWord: Word = read(offset: &offset), let type = PTP.DeviceProperty.DataType(rawValue: typeWord) else {
            return nil
        }
        
        guard let getSetSupportedByte: Byte = read(offset: &offset) else {
            return nil
        }
        let getSetSupported = PTP.DeviceProperty.GetSetSupported(rawValue: getSetSupportedByte) ?? .unknown
        
        guard let getSetAvailableByte: Byte = read(offset: &offset) else {
            return nil
        }
        let getSetAvailable = PTP.DeviceProperty.GetSetAvailable(rawValue: getSetAvailableByte) ?? .unknown
        
        guard let factoryValue: PTPDevicePropertyDataType = readValue(of: type, at: &offset) else {
            return nil
        }
        
        guard let currentValue: PTPDevicePropertyDataType = readValue(of: type, at: &offset) else {
            return nil
        }
        
        guard let structureByte: Byte = read(offset: &offset), let structure = PTP.DeviceProperty.Structure(rawValue: structureByte) else {
            return nil
        }
        
        return PTP.DeviceProperty.Header(
            code: code,
            dataType: type,
            getSetAvailable: getSetAvailable,
            getSetSupported: getSetSupported,
            factory: factoryValue,
            current: currentValue,
            structure: structure,
            length: offset
        )
    }
        
    func readValue(of type: PTP.DeviceProperty.DataType, at offset: inout UInt) -> PTPDevicePropertyDataType? {
        switch type {
        case .int8:
            return read(offset: &offset) as Int8?
        case .uint8:
            return read(offset: &offset) as Byte?
        case .int16:
            return read(offset: &offset) as Int16?
        case .uint16:
            return read(offset: &offset) as Word?
        case .uint32:
            return read(offset: &offset) as DWord?
        case .uint64:
            return read(offset: &offset) as QWord?
        case .string:
            return read(offset: &offset) ?? ""
        }
    }
    
    mutating func appendValue(_ value: PTPDevicePropertyDataType, ofType type: PTP.DeviceProperty.DataType) {
        switch type {
        case .int8:
            guard let int8 = value as? Int8 else { return }
            append(int8)
        case .uint8:
            guard let uint8 = value as? UInt8 else { return }
            append(uint8)
        case .int16:
            guard let int16 = value as? Int16 else { return }
            append(int16)
        case .uint16:
            guard let uint16 = value as? UInt16 else { return }
            append(uint16)
        case .uint32:
            guard let uint32 = value as? UInt32 else { return }
            append(uint32)
        case .uint64:
            guard let uint64 = value as? UInt64 else { return }
            append(uint64)
        case .string:
            guard let string = value as? String else { return }
            append(wString: string, includingLength: false)
        }
    }
    
    func readArrayOfValues(of type: PTP.DeviceProperty.DataType, at offset: inout UInt) -> [PTPDevicePropertyDataType]? {
        
        guard let elements: Word = read(offset: &offset) else { return nil }
        var values: [PTPDevicePropertyDataType] = []
        
        for _ in 0..<elements {
            guard let element: PTPDevicePropertyDataType = readValue(of: type, at: &offset) else { return nil }
            values.append(element)
        }
        
        return values
    }
    
    func getDeviceProperty(at offset: UInt) -> PTPDeviceProperty? {
        let slice = sliced(Int(offset))
        guard let header = slice.getDevicePropHeader() else { return nil }
        switch header.structure {
        case .range:
            return PTP.DeviceProperty.Range(data: slice)
        case .enumeration:
            return PTP.DeviceProperty.Enum(data: slice)
        case .other:
            return PTP.DeviceProperty.Other(data: slice)
        }
    }
}
