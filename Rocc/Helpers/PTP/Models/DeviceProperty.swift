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
        case .exposureProgramModeControl:
            return [.setExposureModeDialControl]
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
        case .liveViewQuality:
            return [.setLiveViewQuality, .startLiveViewWithQuality]
        case .movie:
            return [.startVideoRecording, .endVideoRecording]
        case .movieFormat:
            return [.setVideoFileFormat]
        case .movieQuality:
            return [.setVideoQuality]
        case .stillImage:
            return nil
        case .autoFocus:
            return [.halfPressShutter, .cancelHalfPressShutter]
        case .capture:
            return [.takePicture]
        case .remainingShots, .remainingCaptureTime:
            return nil
        case .stillQuality:
            return [.setStillQuality]
        case .stillFormat:
            return [.setStillFormat]
        case .exposureSettingsLockStatus:
            return [.setExposureSettingsLock]
            // This is a devie B value, so shouldn't appear here and may be used for some other A property
        case .exposureSettingsLock:
            return nil
        case .recordingDuration, .storageState, .liveViewURL, .videoRecordStatusSony:
            return nil
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
        case .exposureProgramModeControl:
            return .getExposureModeDialControl
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
        case .movieFormat:
            return .getVideoFileFormat
        case .movieQuality:
            return .getVideoQuality
        case .stillImage:
            return nil
        case .autoFocus:
            return nil
        case .capture:
            return nil
        case .remainingShots, .remainingCaptureTime, .storageState:
            return .getStorageInformation
        case .performZoom:
            return nil
        case .zoomPosition:
            return nil
        case .stillQuality:
            return .getStillQuality
        case .stillFormat:
            return .getStillFormat
        case .exposureSettingsLockStatus, .exposureSettingsLock:
            return .getExposureSettingsLock
        case .liveViewURL:
            return nil
        case .liveViewQuality:
            return .getLiveViewQuality
        case .recordingDuration, .videoRecordStatusSony:
            return nil
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
            // Not available natively with PTP/IP
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
            return [.stillFormat]
        case .getLiveViewQuality, .setLiveViewQuality, .startLiveViewWithQuality:
            return [.liveViewQuality]
        case .setCurrentTime:
            return [.dateTime]
        case .cancelHalfPressShutter, .halfPressShutter:
            return [.autoFocus]
        case .takePicture:
            return [.capture]
        // These are a bit strange, because setting the exposure lock uses a different parameter (setDeviceBProp)
        // to getting the value!
        case .getExposureSettingsLock:
            return [.exposureSettingsLockStatus]
        case .setExposureSettingsLock:
            return [.exposureSettingsLock]
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

extension Int64: PTPDevicePropertyDataType {
    
    static var dataType: PTP.DeviceProperty.DataType {
        return .int64
    }
    
    var sizeOf: Int {
        return MemoryLayout<Int64>.size
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

protocol PTPDeviceProperty: CustomStringConvertible {
            
    init?(data: ByteBuffer)
    
    init()
    
    func toData() -> ByteBuffer
    
    var type: PTP.DeviceProperty.DataType { get set }
    
    var rawCode: Word { get set }
    
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
        rawCode = header.rawCode
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
        rawCode = header.rawCode
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
        rawCode = header.rawCode
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
            
            var description: String {
                
                let codeString: String
                if code != .undefined {
                    codeString = "\(code)"
                } else {
                    var codeBuffer = ByteBuffer()
                    codeBuffer[word: 0] = rawCode
                    codeString = "\(codeBuffer.toHex)".trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                var currentBuffer = ByteBuffer()
                currentBuffer.appendValue(currentValue, ofType: type)
                let currentString = currentBuffer.toHex
                
                return """
                        {
                            "code": \"\(codeString)\",
                            "current": \"\(currentString)\",
                            "getSetAvailable": \"\(getSetAvailable)\",
                            "getSetSupported": \"\(getSetSupported)\"
                        }
                        """
            }
            
            var type: DataType
            
            var code: Code
            
            var rawCode: Word
            
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
                rawCode = 0
            }
        }
        
        struct Range: PTPRangeDeviceProperty {
            
            init() {
                type = .int16
                code = .undefined
                rawCode = 0
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
            
            var rawCode: Word
            
            var currentValue: PTPDevicePropertyDataType
            
            var factoryValue: PTPDevicePropertyDataType
            
            var getSetAvailable: PTP.DeviceProperty.GetSetAvailable
            
            var getSetSupported: PTP.DeviceProperty.GetSetSupported
            
            var length: UInt
            
            var min: PTPDevicePropertyDataType
            
            var max: PTPDevicePropertyDataType
            
            var step: PTPDevicePropertyDataType
            
            var description: String {
                
                let codeString: String
                if code != .undefined {
                    codeString = "\(code)"
                } else {
                    var codeBuffer = ByteBuffer()
                    codeBuffer[word: 0] = rawCode
                    codeString = "\(codeBuffer.toHex)".trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                var currentBuffer = ByteBuffer()
                currentBuffer.appendValue(currentValue, ofType: type)
                let currentString = currentBuffer.toHex
                
                return """
                        {
                            "code": \"\(codeString)\",
                            "current": \"\(currentString)\",
                            "getSetAvailable": \"\(getSetAvailable)\",
                            "getSetSupported": \"\(getSetSupported)\"
                        }
                        """
            }
        }
        
        struct Enum: PTPEnumDeviceProperty {
            
            init() {
                type = .int16
                code = .undefined
                rawCode = 0
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
            
            var rawCode: Word
            
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
            
            var description: String {
                
                let codeString: String
                if code != .undefined {
                    codeString = "\(code)"
                } else {
                    var codeBuffer = ByteBuffer()
                    codeBuffer[word: 0] = rawCode
                    codeString = "\(codeBuffer.toHex)".trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                var currentBuffer = ByteBuffer()
                currentBuffer.appendValue(currentValue, ofType: type)
                let currentString = currentBuffer.toHex
                
                return """
                        {
                            "code": \"\(codeString)\",
                            "current": \"\(currentString)\",
                            "getSetAvailable": \"\(getSetAvailable)\",
                            "getSetSupported": \"\(getSetSupported)\",
                            "available": \(available),
                            "supported": \(supported)
                        }
                        """
            }
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
            case int64 = 0x7
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
            case DPCCompensation = 0xd200
            case dRangeOptimize = 0xd201
            case imageSizeSony = 0xd203
            case shutterSpeed = 0xd20d
            case colorTemp = 0xd20f
            case cCFilter = 0xd210
            case aspectRatio = 0xd211
            case focusFound = 0xd213
            case objectInMemory = 0xd215
            case exposeIndex = 0xd216
            case batteryLevelSony = 0xd218
            case pictureEffect = 0xd21b
            case ABFilter = 0xd21c
            case videoRecordStatusSony = 0xd21d
            case ISO = 0xd21e
            case exposureSettingsLockStatus = 0xd22a
            case movieFormat = 0xd241
            case movieQuality = 0xd242
            case storageState = 0xd248
            case remainingShots = 0xd249
            case remainingCaptureTime = 0xd24a
            case stillQuality = 0xd252
            case stillFormat = 0xd253
            case exposureProgramModeControl = 0xd25a
            case zoomPosition = 0xd25d
            case recordingDuration = 0xd261
            case liveViewQuality = 0xd26a
            case liveViewURL = 0xd278
            case autoFocus = 0xd2c1
            case capture = 0xd2c2
            case stillImage = 0xd2c7
            case movie = 0xd2c8
            case exposureSettingsLock = 0xd2d5
            case performZoom = 0xd2dd
        }
    }
}
