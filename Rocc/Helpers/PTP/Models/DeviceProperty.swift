//
//  DeviceProperty.swift
//  Rocc
//
//  Created by Simon Mitchell on 05/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension _CameraFunction {
    
    /// Returns the matching ptp device property codes that are required for the function to be supported.
    /// - Note: This returns an array because some manufacturers use different codes for the same property
    var ptpDevicePropertyCodes: [PTP.DeviceProperty.Code]? {
        switch self {
        case .getAperture, .setAperture:
            return [.fNumber]
        case .getISO, .setISO:
            return [.ISO]
        case .getWhiteBalance, .setWhiteBalance:
            return [.whiteBalance]
        case .setShootMode, .getShootMode:
            return [.stillCaptureMode]
        case .setProgramShift, .getProgramShift:
            //TODO: Not sure if this matches up to anything
            return nil
        case .startZooming, .stopZooming:
            return [.digitalZoom]
        case .getExposureMode, .setExposureMode:
            return [.exposureProgramMode]
        case .getFocusMode, .setFocusMode:
            return [.focusMode]
        case .getExposureCompensation, .setExposureCompensation:
            return [.exposureBiasCompensation]
        case .getShutterSpeed, .setShutterSpeed:
            return [.shutterSpeed]
        case .getFlashMode, .setFlashMode:
            return [.flashMode]
        case .getStillSize, .setStillSize:
            return [.imageSize, .imageSizeSony]
        case .getStillQuality, .setStillQuality:
            //TODO: Might need to work out what this is represented by using WireShark and Sony's app
            return nil
        case .setCurrentTime:
            return [.dateTime]
        default:
            return nil
        }
    }
}

protocol PTPDevicePropertyDataType {
    
    static var dataType: PTP.DeviceProperty.DataType { get }
}

extension Int8: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .int8
    }
}

extension UInt8: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .uint8
    }
}

extension Int16: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .int16
    }
}

extension UInt16: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .uint16
    }
}

extension UInt32: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .uint32
    }
}

extension String: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .string
    }
}

protocol PTPDeviceProperty {
    
    associatedtype DataType: PTPDevicePropertyDataType
        
    init?(data: ByteBuffer)
    
    func toData() -> ByteBuffer
    
    var type: PTP.DeviceProperty.DataType { get set }
    
    var code: PTP.DeviceProperty.Code { get set }
    
    var currentValue: DataType { get set }
    
    var factoryValue: DataType { get set }
    
    var getSet: Word { get set }
    
    var length: UInt { get set }
}

// MARK: - Range Properties -

protocol PTPRangeDeviceProperty: PTPDeviceProperty {
    
    var min: DataType { get set }
    
    var max: DataType { get set }
    
    var step: DataType { get set }
}

extension PTPRangeDeviceProperty {
    
    init?(data: ByteBuffer) {
        
        self.init(data: data)
        
        guard let header: PTP.DeviceProperty.Header<DataType> = data.getDevicePropHeader() else { return nil }
        var offset: UInt = header.offset
        type = header.dataType
        code = header.code
        currentValue = header.current
        factoryValue = header.factory
        getSet = header.getSet
        
        guard let _min: DataType = data.getValue(at: offset) else { return nil }
        min = _min
        offset += UInt(MemoryLayout<DataType>.size)
        
        guard let _max: DataType = data.getValue(at: offset) else { return nil }
        max = _max
        offset += UInt(MemoryLayout<DataType>.size)
        
        guard let _step: DataType = data.getValue(at: offset) else { return nil }
        step = _step
        offset += UInt(MemoryLayout<DataType>.size)
        
        length = offset
    }
    
    func toData() -> ByteBuffer {
        
        var buffer = ByteBuffer()
        buffer.append(word: code.rawValue)
        buffer.append(word: type.rawValue)
        buffer.append(word: getSet)
        
        buffer.appendValue(factoryValue)
        buffer.appendValue(currentValue)
        
        buffer.append(byte: 0x01)
        
        buffer.appendValue(min)
        buffer.appendValue(max)
        buffer.appendValue(step)
        
        return buffer
    }
}

// MARK: - Enum Properties -

protocol PTPEnumDeviceProperty: PTPDeviceProperty {
    
    var available: [DataType] { get set }
    
    var supported: [DataType] { get set }
}

extension PTPEnumDeviceProperty {
    
    func toData() -> ByteBuffer {
        
        var buffer = ByteBuffer()
        buffer.append(word: code.rawValue)
        buffer.append(word: type.rawValue)
        buffer.append(word: getSet)
        
        buffer.appendValue(factoryValue)
        buffer.appendValue(currentValue)
        
        buffer.append(byte: 0x02)
        
        buffer.append(word: Word(available.count))
        available.forEach { (value) in
            buffer.appendValue(value)
        }
        
        buffer.append(word: Word(supported.count))
        supported.forEach { (value) in
            buffer.appendValue(value)
        }
        
        return buffer
    }
        
    init?(data: ByteBuffer) {
        
        self.init(data: data)
        
        guard let header: PTP.DeviceProperty.Header<DataType> = data.getDevicePropHeader() else { return nil }
        var offset: UInt = header.offset
        type = header.dataType
        code = header.code
        currentValue = header.current
        factoryValue = header.factory
        getSet = header.getSet
        
        guard let available: (values: [DataType], length: UInt) = data.getArrayValues(at: offset) else { return nil }
        offset += available.length
        self.available = available.values
        
        guard let supported: (values: [DataType], length: UInt) = data.getArrayValues(at: offset) else { return nil }
        offset += supported.length
        self.supported = supported.values
        
        length = offset
    }
}

extension PTP {
    
    struct Int8RangeDeviceProperty: PTPRangeDeviceProperty {
                
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var min: DataType
        
        var max: DataType
        
        var step: DataType
        
        typealias DataType = Int8
    }
    
    struct UInt8RangeDeviceProperty: PTPRangeDeviceProperty {
                
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var min: DataType
        
        var max: DataType
        
        var step: DataType
        
        typealias DataType = UInt8
    }
    
    struct Int16RangeDeviceProperty: PTPRangeDeviceProperty {
                
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var min: DataType
        
        var max: DataType
        
        var step: DataType
        
        typealias DataType = Int16
    }
    
    struct UInt16RangeDeviceProperty: PTPRangeDeviceProperty {
                
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var min: DataType
        
        var max: DataType
        
        var step: DataType
        
        typealias DataType = UInt16
    }
    
    struct UInt32RangeDeviceProperty: PTPRangeDeviceProperty {
                
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var min: DataType
        
        var max: DataType
        
        var step: DataType
        
        typealias DataType = UInt32
    }
    
    struct StringRangeDeviceProperty: PTPRangeDeviceProperty {
                
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var min: DataType
        
        var max: DataType
        
        var step: DataType
        
        typealias DataType = String
    }
    
    struct Int8EnumDeviceProperty: PTPEnumDeviceProperty {
        
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var available: [DataType]
        
        var supported: [DataType]
        
        typealias DataType = Int8
    }
    
    struct UInt8EnumDeviceProperty: PTPEnumDeviceProperty {
        
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var available: [DataType]
        
        var supported: [DataType]
        
        typealias DataType = UInt8
    }
    
    struct Int16EnumDeviceProperty: PTPEnumDeviceProperty {
        
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var available: [DataType]
        
        var supported: [DataType]
        
        typealias DataType = Int16
    }
    
    struct UInt16EnumDeviceProperty: PTPEnumDeviceProperty {
        
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var available: [DataType]
        
        var supported: [DataType]
        
        typealias DataType = UInt16
    }
    
    struct UInt32EnumDeviceProperty: PTPEnumDeviceProperty {
        
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var available: [DataType]
        
        var supported: [DataType]
        
        typealias DataType = UInt32
    }
    
    struct StringEnumDeviceProperty: PTPEnumDeviceProperty {
        
        var type: PTP.DeviceProperty.DataType
        
        var code: PTP.DeviceProperty.Code
        
        var currentValue: DataType
        
        var factoryValue: DataType
        
        var getSet: Word
        
        var length: UInt
        
        var available: [DataType]
        
        var supported: [DataType]
        
        typealias DataType = String
    }
    
    struct DeviceProperty {
        
        enum DataType: Word {
            case int8 = 0x1
            case uint8 = 0x2
            case int16 = 0x3
            case uint16 = 0x4
            case uint32 = 0x6
            case string = 0xffff
        }
        
        enum Code: Word {
            case undefined = 0x5000
            case batteryLevel = 0x5001
            case functionalMode = 0x5002
            case imageSize = 0x5003
            case compressionSetting = 0x5004
            case whiteBalance = 0x5005
            case rgbGain = 0x5006
            case fNumber = 0x5007
            case focalLength = 0x5008
            case focusDistance = 0x5009
            case focusMode = 0x500a
            case exposureMeteringMode = 0x500b
            case flashMode = 0x500c
            case exposureTime = 0x500d
            case exposureProgramMode = 0x500e
            case exposureIndex = 0x500f
            case exposureBiasCompensation = 0x5010
            case dateTime = 0x5011
            case captureDelay = 0x5012
            case stillCaptureMode = 0x5013
            case contrast = 0x5014
            case sharpness = 0x5015
            case digitalZoom = 0x5016
            case effectMode = 0x5017
            case burstNumber = 0x5018
            case burstInterval = 0x5019
            case timelapseNumber = 0x501a
            case timelapseInterval = 0x501b
            case focusMeteringMode = 0x501c
            case uploadURL = 0x501d
            case artist = 0x501e
            case copyrightInfo = 0x501f
            /* Sony Extensions */
            case DPCCompensation = 0xD200
            case dRangeOptimize = 0xD201
            case imageSizeSony = 0xD203
            case shutterSpeed = 0xD20D
            case unknown_0xd20e = 0xD20E
            case colorTemp = 0xD20F
            case cCFilter = 0xD210
            case aspectRatio = 0xD211
            case focusFound = 0xD213
            case objectInMemory = 0xD215
            case exposeIndex = 0xD216
            case batteryLevelSony = 0xD218
            case pictureEffect = 0xD21B
            case ABFilter = 0xD21C
            case ISO = 0xD21E
            case movie = 0xD2C8
            case stillImage = 0xD2C7
        }
    }
}
