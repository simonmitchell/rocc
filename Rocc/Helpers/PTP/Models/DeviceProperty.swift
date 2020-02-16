//
//  DeviceProperty.swift
//  Rocc
//
//  Created by Simon Mitchell on 05/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTP.DeviceProperty.Code {
    
    var setFunctions: [_CameraFunction]? {
        switch self {
        case .exposureBiasCompensation:
            return [.setExposureCompensation]
        case .undefined:
            return nil
        case .batteryLevel:
            return nil
        case .functionalMode:
            //TODO: Unsure
            return nil
        case .imageSize:
            return [.setStillSize]
        case .compressionSetting:
            //TODO: Add function
            return nil
        case .whiteBalance:
            return [.setWhiteBalance]
        case .rgbGain:
            //TODO: Add function
            return nil
        case .fNumber:
            return [.setAperture]
        case .focalLength:
            //TODO: Add function
            return nil
        case .focusDistance:
            //TODO: Add function
            return nil
        case .focusMode:
            return [.setFocusMode]
        case .exposureMeteringMode:
            //TODO: Add function
            return nil
        case .flashMode:
            return [.setFlashMode]
        case .exposureTime:
            return [.setShutterSpeed]
        case .exposureProgramMode:
            return [.setExposureMode]
        case .exposureIndex:
            //TODO: Add function
            return nil
        case .dateTime:
            //TODO: Is this correct?
            return [.setCurrentTime]
        case .captureDelay:
            return [.setSelfTimerDuration]
        case .stillCaptureMode:
            return [.setShootMode]
        case .contrast:
            //TODO: Add function
            return nil
        case .sharpness:
            //TODO: Add function
            return nil
        case .digitalZoom, .performZoom, .zoomPosition:
            return [.startZooming, .stopZooming]
        case .effectMode:
            //TODO: Add function
            return nil
        case .burstNumber:
            //TODO: Add function
            return nil
        case .burstInterval:
            //TODO: Add function
            return nil
        case .timelapseNumber:
            //TODO: Add function
            return nil
        case .timelapseInterval:
            //TODO: Add function
            return nil
        case .focusMeteringMode:
            //TODO: Add function
            return nil
        case .uploadURL:
            return nil
        case .artist:
            return nil
        case .copyrightInfo:
            return nil
        case .DPCCompensation:
            //TODO: Add function
            return nil
        case .dRangeOptimize:
            //TODO: Add function
            return nil
        case .imageSizeSony:
            return [.setStillSize]
        case .shutterSpeed:
            return [.setShutterSpeed]
        case .unknown_0xd20e:
            return nil
        case .colorTemp:
            return nil
        case .cCFilter:
            //TODO: Add function
            return nil
        case .aspectRatio:
            //TODO: Add function
            return nil
        case .focusFound:
            return nil
        case .objectInMemory:
            return nil
        case .exposeIndex:
            //TODO: Add function?
            return nil
        case .batteryLevelSony:
            return nil
        case .pictureEffect:
            return nil
        case .ABFilter:
            return nil
        case .ISO:
            return [.setISO]
        case .movie:
            return nil
        case .stillImage:
            return nil
        case .autoFocus:
            return [.halfPressShutter, .cancelHalfPressShutter]
        case .capture:
            return [.takePicture]
        case .remainingShots:
            return nil
        case .stillQuality:
            return [.setStillQuality]
        }
    }
    
    var getFunction: _CameraFunction? {
        switch self {
        case .exposureBiasCompensation:
            return .getExposureCompensation
        case .undefined:
            return nil
        case .batteryLevel:
            return nil
        case .functionalMode:
            //TODO: Unsure
            return nil
        case .imageSize:
            return .getStillSize
        case .compressionSetting:
            //TODO: Add function
            return nil
        case .whiteBalance:
            return .getWhiteBalance
        case .rgbGain:
            //TODO: Add function
            return nil
        case .fNumber:
            return .getAperture
        case .focalLength:
            //TODO: Add function
            return nil
        case .focusDistance:
            //TODO: Add function
            return nil
        case .focusMode:
            return .getFocusMode
        case .exposureMeteringMode:
            //TODO: Add function
            return nil
        case .flashMode:
            return .getFlashMode
        case .exposureTime:
            return .getShutterSpeed
        case .exposureProgramMode:
            return .getExposureMode
        case .exposureIndex:
            //TODO: Add function
            return nil
        case .dateTime:
            return nil
        case .captureDelay:
            return .getSelfTimerDuration
        case .stillCaptureMode:
            return .getShootMode
        case .contrast:
            //TODO: Add function
            return nil
        case .sharpness:
            //TODO: Add function
            return nil
        case .digitalZoom:
            return nil
        case .effectMode:
            //TODO: Add function
            return nil
        case .burstNumber:
            //TODO: Add function
            return nil
        case .burstInterval:
            //TODO: Add function
            return nil
        case .timelapseNumber:
            //TODO: Add function
            return nil
        case .timelapseInterval:
            //TODO: Add function
            return nil
        case .focusMeteringMode:
            //TODO: Add function
            return nil
        case .uploadURL:
            return nil
        case .artist:
            return nil
        case .copyrightInfo:
            return nil
        case .DPCCompensation:
            //TODO: Add function
            return nil
        case .dRangeOptimize:
            //TODO: Add function
            return nil
        case .imageSizeSony:
            return .getStillSize
        case .shutterSpeed:
            return .getShutterSpeed
        case .unknown_0xd20e:
            return nil
        case .colorTemp:
            return nil
        case .cCFilter:
            //TODO: Add function
            return nil
        case .aspectRatio:
            //TODO: Add function
            return nil
        case .focusFound:
            return nil
        case .objectInMemory:
            return nil
        case .exposeIndex:
            //TODO: Add function?
            return nil
        case .batteryLevelSony:
            return nil
        case .pictureEffect:
            return nil
        case .ABFilter:
            return nil
        case .ISO:
            return .getISO
        case .movie:
            return nil
        case .stillImage:
            return nil
        case .autoFocus:
            return nil
        case .capture:
            return nil
        case .remainingShots:
            return nil
        case .performZoom:
            return nil
        case .zoomPosition:
            return nil
        case .stillQuality:
            return .getStillQuality
        }
    }
}

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
            return [.digitalZoom, .performZoom, .zoomPosition]
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
            return [.stillQuality]
        case .getStillFormat, .setStillFormat:
            //TODO: Implement next
            return nil
        case .setCurrentTime:
            return [.dateTime]
        case .cancelHalfPressShutter, .halfPressShutter:
            return [.autoFocus]
        case .takePicture:
            return [.capture]
        default:
            return nil
        }
    }
}

protocol PTPDevicePropertyDataType {
    
    static var dataType: PTP.DeviceProperty.DataType { get }
    
    var sizeOf: Int { get }
    
    var toInt: Int? { get }
}

extension Int8: PTPDevicePropertyDataType {
    
    static var dataType: PTP.DeviceProperty.DataType {
        return .int8
    }
    
    var sizeOf: Int {
        return MemoryLayout<Int8>.size
    }
    
    var toInt: Int? {
        return Int(self)
    }
}

extension UInt8: PTPDevicePropertyDataType {
    
    static var dataType: PTP.DeviceProperty.DataType {
        return .uint8
    }
    
    var sizeOf: Int {
        return MemoryLayout<UInt8>.size
    }
    
    var toInt: Int? {
        return Int(self)
    }
}

extension Int16: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .int16
    }
    
    var sizeOf: Int {
        return MemoryLayout<Int16>.size
    }
    
    var toInt: Int? {
        return Int(self)
    }
}

extension UInt16: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .uint16
    }
    
    var sizeOf: Int {
        return MemoryLayout<UInt16>.size
    }
    
    var toInt: Int? {
        return Int(self)
    }
}

extension UInt32: PTPDevicePropertyDataType {
    
    static var dataType: PTP.DeviceProperty.DataType {
        return .uint32
    }
    
    var sizeOf: Int {
        return MemoryLayout<UInt32>.size
    }
    
    var toInt: Int? {
        return Int(self)
    }
}

extension UInt64: PTPDevicePropertyDataType {
    
    static var dataType: PTP.DeviceProperty.DataType {
        return .uint64
    }
    
    var sizeOf: Int {
        return MemoryLayout<UInt64>.size
    }
    
    var toInt: Int? {
        return Int(self)
    }
}

extension String: PTPDevicePropertyDataType {
    
    static var dataType: PTP.DeviceProperty.DataType {
        return .string
    }
    
    var sizeOf: Int {
        return isEmpty ? 1 : count * 2
    }
    
    var toInt: Int? {
        return Int(self)
    }
}

protocol PTPDeviceProperty {
            
    init?(data: ByteBuffer)
    
    init()
    
    func toData() -> ByteBuffer
    
    var type: PTP.DeviceProperty.DataType { get set }
    
    var code: PTP.DeviceProperty.Code { get set }
    
    var currentValue: PTPDevicePropertyDataType { get set }
    
    var factoryValue: PTPDevicePropertyDataType { get set }
    
    var getSetAvailable: PTP.DeviceProperty.GetSetAvailable { get set }
    
    var getSetSupported: PTP.DeviceProperty.GetSetSupported { get set }
    
    var length: UInt { get set }
}

// MARK: - Range Properties -

protocol PTPRangeDeviceProperty: PTPDeviceProperty {
    
    var min: PTPDevicePropertyDataType { get set }
    
    var max: PTPDevicePropertyDataType { get set }
    
    var step: PTPDevicePropertyDataType { get set }
}

extension PTPRangeDeviceProperty {
    
    init?(data: ByteBuffer) {
        
        self.init()
                
        guard let header: PTP.DeviceProperty.Header = data.getDevicePropHeader() else {
            return nil
        }
        var offset: UInt = header.length
        type = header.dataType
        code = header.code
        currentValue = header.current
        factoryValue = header.factory
        getSetAvailable = header.getSetAvailable
        getSetSupported = header.getSetSupported
        
        guard let _min: PTPDevicePropertyDataType = data.readValue(of: type, at: &offset) else {
            return nil
        }
        min = _min
        
        guard let _max: PTPDevicePropertyDataType = data.readValue(of: type, at: &offset) else {
            return nil
        }
        max = _max
        
        guard let _step: PTPDevicePropertyDataType = data.readValue(of: type, at: &offset) else {
            return nil
        }
        step = _step
        
        length = offset
    }
    
    func toData() -> ByteBuffer {
        
        var buffer = ByteBuffer()
        buffer.append(code.rawValue)
        buffer.append(type.rawValue)
        buffer.append(getSetSupported.rawValue)
        buffer.append(getSetAvailable.rawValue)
        
        buffer.appendValue(factoryValue, ofType: type)
        buffer.appendValue(currentValue, ofType: type)

        buffer.append(Byte(0x01))
        
        buffer.appendValue(min, ofType: type)
        buffer.appendValue(max, ofType: type)
        buffer.appendValue(step, ofType: type)
        
        return buffer
    }
}

// MARK: - Enum Properties -

protocol PTPEnumDeviceProperty: PTPDeviceProperty {
    
    var available: [PTPDevicePropertyDataType] { get set }
    
    var supported: [PTPDevicePropertyDataType] { get set }
}

extension PTPEnumDeviceProperty {
    
    func toData() -> ByteBuffer {
        
        var buffer = ByteBuffer()
        buffer.append(code.rawValue)
        buffer.append(type.rawValue)
        buffer.append(getSetSupported.rawValue)
        buffer.append(getSetAvailable.rawValue)
        
        buffer.appendValue(factoryValue, ofType: type)
        buffer.appendValue(currentValue, ofType: type)
        
        buffer.append(Byte(0x02))
        
        buffer.append(Word(available.count))
        available.forEach { (value) in
            buffer.appendValue(value, ofType: type)
        }
        
        buffer.append(Word(supported.count))
        supported.forEach { (value) in
            buffer.appendValue(value, ofType: type)
        }
        
        return buffer
    }
        
    init?(data: ByteBuffer) {
        
        self.init()
                
        guard let header: PTP.DeviceProperty.Header = data.getDevicePropHeader() else {
            return nil
        }
        var offset: UInt = header.length
        type = header.dataType
        code = header.code
        currentValue = header.current
        factoryValue = header.factory
        getSetSupported = header.getSetSupported
        getSetAvailable = header.getSetAvailable
        
        guard let available = data.readArrayOfValues(of: type, at: &offset) else {
            return nil
        }
        self.available = available
        
        guard let supported = data.readArrayOfValues(of: type, at: &offset) else {
            return nil
        }
        self.supported = supported
        
        length = offset
    }
}

// MARK: - Properties that are neither enum nor range! -

protocol PTPOtherDeviceProperty: PTPDeviceProperty {
    
}

extension PTPOtherDeviceProperty {
    
    func toData() -> ByteBuffer {
        
        var buffer = ByteBuffer()
        buffer.append(code.rawValue)
        buffer.append(type.rawValue)
        buffer.append(getSetSupported.rawValue)
        buffer.append(getSetAvailable.rawValue)
        
        buffer.appendValue(factoryValue, ofType: type)
        buffer.appendValue(currentValue, ofType: type)
        
        buffer.append(0x00)
        
        return buffer
    }
        
    init?(data: ByteBuffer) {
        
        self.init()
                
        guard let header: PTP.DeviceProperty.Header = data.getDevicePropHeader() else {
            return nil
        }
        type = header.dataType
        code = header.code
        currentValue = header.current
        factoryValue = header.factory
        getSetSupported = header.getSetSupported
        getSetAvailable = header.getSetAvailable
        length = header.length
    }
}

extension PTP {
    
    struct DeviceProperty {
        
        struct Value {
            
            var code: Code
            
            var type: DataType
            
            var value: PTPDevicePropertyDataType
            
            init(_ convertable: SonyPTPPropValueConvertable) {
                self.code = convertable.code
                self.type = convertable.type
                self.value = convertable.sonyPTPValue
            }
            
            init(code: Code, type: DataType, value: PTPDevicePropertyDataType) {
                self.code = code
                self.type = type
                self.value = value
            }
        }
        
        struct Other: PTPOtherDeviceProperty {
            
            var type: DataType
            
            var code: Code
            
            var currentValue: PTPDevicePropertyDataType
            
            var factoryValue: PTPDevicePropertyDataType
            
            var getSetAvailable: PTP.DeviceProperty.GetSetAvailable
            
            var getSetSupported: PTP.DeviceProperty.GetSetSupported
            
            var length: UInt
            
            init() {
                type = .string
                code = .undefined
                currentValue = UInt8(0)
                factoryValue = UInt8(0)
                getSetSupported = .unknown
                getSetAvailable = .unknown
                length = 0
            }
        }
        
        struct Range: PTPRangeDeviceProperty {
            
            init() {
                type = .int16
                code = .undefined
                currentValue = UInt8(0)
                factoryValue = UInt8(0)
                getSetSupported = .unknown
                getSetAvailable = .unknown
                length = 0
                min = UInt8(0)
                max = UInt8(0)
                step = UInt8(0)
            }
                    
            var type: DataType
            
            var code: Code
            
            var currentValue: PTPDevicePropertyDataType
            
            var factoryValue: PTPDevicePropertyDataType
            
            var getSetAvailable: PTP.DeviceProperty.GetSetAvailable
            
            var getSetSupported: PTP.DeviceProperty.GetSetSupported
            
            var length: UInt
            
            var min: PTPDevicePropertyDataType
            
            var max: PTPDevicePropertyDataType
            
            var step: PTPDevicePropertyDataType
        }
        
        struct Enum: PTPEnumDeviceProperty {
            
            init() {
                type = .int16
                code = .undefined
                currentValue = UInt8(0)
                factoryValue = UInt8(0)
                getSetSupported = .unknown
                getSetAvailable = .unknown
                unknown = 0
                length = 0
                available = []
                supported = []
            }
            
            var type: DataType
            
            var code: Code
            
            var currentValue: PTPDevicePropertyDataType
            
            var factoryValue: PTPDevicePropertyDataType
            
            // 0x00, 0x00: Hidden entirely
            // 0x00, 0x01: Entirely interactable
            // 0x00, 0x02: Highly translucent
            // 0x01, 0x00: Hidden entirely
            // 0x01, 0x01: Entirely interactable
            // 0x01, 0x02: Highly translucent
            // get set supported, get set available?
            var getSetSupported: GetSetSupported
            
            var getSetAvailable: GetSetAvailable
            
            var unknown: Byte
            
            var length: UInt
            
            var available: [PTPDevicePropertyDataType]
            
            var supported: [PTPDevicePropertyDataType]
        }
        
        enum GetSetSupported: Byte {
            case get = 0x00
            case getSet = 0x01
            case unknown
        }
        
        enum GetSetAvailable: Byte {
            case unavailable = 0x00
            case getSet = 0x01
            case get = 0x02
            case unknown
        }
        
        enum DataType: Word {
            case int8 = 0x1
            case uint8 = 0x2
            case int16 = 0x3
            case uint16 = 0x4
            case uint32 = 0x6
            case uint64 = 0x8
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
            case autoFocus = 0xD2C1
            case capture = 0xD2C2
            case movie = 0xD2C8
            case stillImage = 0xD2C7
            case remainingShots = 0xd249
            case performZoom = 0xd2dd
            case zoomPosition = 0xd25d
            case stillQuality = 0xd252
        }
    }
}
