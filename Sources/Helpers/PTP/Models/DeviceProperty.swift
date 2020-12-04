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
        case .recordingDuration, .storageState, .liveViewURL:
            return nil
        default:
            //TODO: [Canon] Implement
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
        case .recordingDuration:
            return nil
        default:
            //TODO: [Canon] Implement
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

extension Int32: PTPDevicePropertyDataType {
    static var dataType: PTP.DeviceProperty.DataType {
        return .int32
    }
    
    var sizeOf: Int {
        return MemoryLayout<Int32>.size
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
        // by default return uint16String, even though some cameras
        // may use otherwise!
        return .uint16String
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
        buffer.append(code)
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
            
            init(_ convertable: PTPPropValueConvertable, manufacturer: Manufacturer) {
                self.code = Swift.type(of: convertable).devicePropertyCode(for: manufacturer)
                self.type = Swift.type(of: convertable).dataType(for: manufacturer)
                self.value = convertable.value(for: manufacturer)
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
                type = .uint16String
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
            case int32 = 0x5
            case uint32 = 0x6
            case int64 = 0x7
            case uint64 = 0x8
            case uint16String = 0xffff
            case uint8string = 0xf1f1
        }
                
        enum Code: DWord, ByteRepresentable {

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
            
            /* Canon extension device property codes */
            case beepModeCanon = 0xD001
            case batteryKindCanon = 0xD002
            case batteryStatusCanon = 0xD003
            case UILockTypeCanon = 0xD004
            case cameraModeCanon = 0xD005
            case imageQualityCanon = 0xD006
            case fullViewFileFormatCanon = 0xD007
            case imageSizeCanon = 0xD008
            case selfTimeCanon = 0xD009
            case flashModeCanon = 0xD00A
            case beepCanon = 0xD00B
            case shootingModeCanon = 0xD00C
            case imageModeCanon = 0xD00D
            case driveModeCanon = 0xD00E
            case EZoomCanon = 0xD00F
            case meteringModeCanon = 0xD010
            case AFDistanceCanon = 0xD011
            case focusingPointCanon = 0xD012
            case whiteBalanceCanon = 0xD013
            case slowShutterSettingCanon = 0xD014
            case AFModeCanon = 0xD015
            case imageStabilizationCanon = 0xD016
            case contrastCanon = 0xD017
            case colorGainCanon = 0xD018
            case sharpnessCanon = 0xD019
            case sensitivityCanon = 0xD01A
            case parameterSetCanon = 0xD01B
            case ISOSpeedCanon = 0xD01C
            case apertureCanon = 0xD01D
            case shutterSpeedCanon = 0xD01E
            case expCompensationCanon = 0xD01F
            case flashCompensationCanon = 0xD020
            case AEBExposureCompensationCanon = 0xD021
            case AvOpenCanon = 0xD023
            case AvMaxCanon = 0xD024
            case focalLengthCanon = 0xD025
            case focalLengthTeleCanon = 0xD026
            case focalLengthWideCanon = 0xD027
            case focalLengthDenominatorCanon = 0xD028
            case captureTransferModeCanon = 0xD029

            case zoomCanon = 0xD02A
            case namePrefixCanon = 0xD02B
            case sizeQualityModeCanon = 0xD02C
            case supportedThumbSizeCanon = 0xD02D
            case sizeOfOutputDataFromCameraCanon = 0xD02E
            case sizeOfInputDataToCameraCanon = 0xD02F
            case remoteAPIVersionCanon = 0xD030
            case firmwareVersionCanon = 0xD031
            case cameraModelCanon = 0xD032
            case cameraOwnerCanon = 0xD033
            case unixTimeCanon = 0xD034
            case cameraBodyIDCanon = 0xD035
            case cameraOutputCanon = 0xD036
            case dispAvCanon = 0xD037
            case AvOpenApexCanon = 0xD038
            case DZoomMagnificationCanon = 0xD039
            case MlSpotPosCanon = 0xD03A
            case dispAvMaxCanon = 0xD03B
            case AvMaxApexCanon = 0xD03C
            case EZoomStartPositionCanon = 0xD03D
            case focalLengthOfTeleCanon = 0xD03E
            case EZoomSizeOfTeleCanon = 0xD03F
            case photoEffectCanon = 0xD040
            case assistLightCanon = 0xD041
            case flashQuantityCountCanon = 0xD042
            case rotationAngleCanon = 0xD043
            case rotationSceneCanon = 0xD044
            case eventEmulateModeCanon = 0xD045
            case DPOFVersionCanon = 0xD046
            case typeOfSupportedSlideShowCanon = 0xD047
            case averageFilesizesCanon = 0xD048
            case modelIDCanon = 0xD049

            case powerZoomPositionCanonEOS = 0xD055
            case strobeSettingSimpleCanonEOS = 0xD056
            case connectTriggerCanonEOS = 0xD058
            case changeCameraModeCanonEOS = 0xD059

            /* From EOS 400D trace. */
            case apertureCanonEOS = 0xD101
            case shutterSpeedCanonEOS = 0xD102
            case ISOSpeedCanonEOS = 0xD103
            case expCompensationCanonEOS = 0xD104
            case autoExposureModeCanonEOS = 0xD105
            case driveModeCanonEOS = 0xD106
            case meteringModeCanonEOS = 0xD107
            case focusModeCanonEOS = 0xD108
            case whiteBalanceCanonEOS = 0xD109
            case colorTemperatureCanonEOS = 0xD10A
            case whiteBalanceAdjustACanonEOS = 0xD10B
            case whiteBalanceAdjustBCanonEOS = 0xD10C
            case whiteBalanceXACanonEOS = 0xD10D
            case whiteBalanceXBCanonEOS = 0xD10E
            case colorSpaceCanonEOS = 0xD10F
            case pictureStyleCanonEOS = 0xD110
            case batteryPowerCanonEOS = 0xD111
            case batterySelectCanonEOS = 0xD112
            case cameraTimeCanonEOS = 0xD113
            case autoPowerOffCanonEOS = 0xD114
            case ownerCanonEOS = 0xD115
            case modelIDCanonEOS = 0xD116
            case PTPExtensionVersionCanonEOS = 0xD119
            case DPOFVersionCanonEOS = 0xD11A
            case availableShotsCanonEOS = 0xD11B
            case captureDestHDCanonEOS = 4
            case captureDestinationCanonEOS = 0xD11C
            case bracketModeCanonEOS = 0xD11D
            case currentStorageCanonEOS = 0xD11E
            case currentFolderCanonEOS = 0xD11F
            case imageFormatCanonEOS = 0xD120    /* file setting */
            case imageFormatCFCanonEOS = 0xD121    /* file setting CF */
            case imageFormatSDCanonEOS = 0xD122    /* file setting SD */
            case imageFormatExtHDCanonEOS = 0xD123    /* file setting exthd */
            case refocusStateCanonEOS = 0xD124
            case cameraNicknameCanonEOS = 0xD125
            case stroboSettingExpCompositionControlCanonEOS = 0xD126
            case connectStatusCanonEOS = 0xD127
            case lensBarrelStatusCanonEOS = 0xD128
            case silentShutterSettingCanonEOS = 0xD129
            case LV_AF_EyeDetectCanonEOS = 0xD12C
            case autoTransMobileCanonEOS = 0xD12D
            case URLSupportFormatCanonEOS = 0xD12E
            case specialAccCanonEOS = 0xD12F
            case compressionSCanonEOS = 0xD130
            case compressionM1CanonEOS = 0xD131
            case compressionM2CanonEOS = 0xD132
            case compressionLCanonEOS = 0xD133
            case intervalShootSettingCanonEOS = 0xD134
            case intervalShootStateCanonEOS = 0xD135
            case pushModeCanonEOS = 0xD136
            case LvCFilterKindCanonEOS = 0xD137
            case AEModeDialCanonEOS = 0xD138
            case AEModeCustomCanonEOS = 0xD139
            case mirrorUpSettingCanonEOS = 0xD13A
            case highlightTonePriorityCanonEOS = 0xD13B
            case AFSelectFocusAreaCanonEOS = 0xD13C
            case HDRSettingCanonEOS = 0xD13D
            case timeShootSettingCanonEOS = 0xD13E
            case NFCApplicationInfoCanonEOS = 0xD13F
            case PCWhiteBalance1CanonEOS = 0xD140
            case PCWhiteBalance2CanonEOS = 0xD141
            case PCWhiteBalance3CanonEOS = 0xD142
            case PCWhiteBalance4CanonEOS = 0xD143
            case PCWhiteBalance5CanonEOS = 0xD144
            case MWhiteBalanceCanonEOS = 0xD145
            case MWhiteBalanceExCanonEOS = 0xD146
            case powerZoomSpeedCanonEOS = 0xD149
            case networkServerRegionCanonEOS = 0xD14A
            case GPSLogCtrlCanonEOS = 0xD14B
            case GPSLogListNumCanonEOS = 0xD14C
            case unknownPropD14DCanonEOS = 0xD14D  /*found in Canon EOS 5D M3*/
            case pictureStyleStandardCanonEOS = 0xD150
            case pictureStylePortraitCanonEOS = 0xD151
            case pictureStyleLandscapeCanonEOS = 0xD152
            case pictureStyleNeutralCanonEOS = 0xD153
            case pictureStyleFaithfulCanonEOS = 0xD154
            case pictureStyleBlackWhiteCanonEOS = 0xD155
            case pictureStyleAutoCanonEOS = 0xD156
            case pictureStyleExStandardCanonEOS = 0xD157
            case pictureStyleExPortraitCanonEOS = 0xD158
            case pictureStyleExLandscapeCanonEOS = 0xD159
            case pictureStyleExNeutralCanonEOS = 0xD15A
            case pictureStyleExFaithfulCanonEOS = 0xD15B
            case pictureStyleExBlackWhiteCanonEOS = 0xD15C
            case pictureStyleExAutoCanonEOS = 0xD15D
            case pictureStyleExFineDetailCanonEOS = 0xD15E
            case pictureStyleUserSet1CanonEOS = 0xD160
            case pictureStyleUserSet2CanonEOS = 0xD161
            case pictureStyleUserSet3CanonEOS = 0xD162
            case pictureStyleExUserSet1CanonEOS = 0xD163
            case pictureStyleExUserSet2CanonEOS = 0xD164
            case pictureStyleExUserSet3CanonEOS = 0xD165
            case movieAVModeFineCanonEOS = 0xD166
            case shutterReleaseCounterCanonEOS = 0xD167    /* perhaps send a requestdeviceprop ex ? */
            case availableImageSizeCanonEOS = 0xD168
            case errorHistoryCanonEOS = 0xD169
            case lensExchangeHistoryCanonEOS = 0xD16A
            case stroboExchangeHistoryCanonEOS = 0xD16B
            case pictureStyleParam1CanonEOS = 0xD170
            case pictureStyleParam2CanonEOS = 0xD171
            case pictureStyleParam3CanonEOS = 0xD172
            case movieRecordVolumeLineCanonEOS = 0xD174
            case networkCommunicationModeCanonEOS = 0xD175
            case canonLogGammaCanonEOS = 0xD176
            case smartphoneShowImageConfigCanonEOS = 0xD177
            case highISOSettingNoiseReductionCanonEOS = 0xD178
            case movieServoAFCanonEOS = 0xD179
            case continuousAFValidCanonEOS = 0xD17A
            case attenuatorCanonEOS = 0xD17B
            case UTCTimeCanonEOS = 0xD17C
            case timezoneCanonEOS = 0xD17D
            case summertimeCanonEOS = 0xD17E
            case flavorLUTParamsCanonEOS = 0xD17F
            case customFunc1CanonEOS = 0xD180
            case customFunc2CanonEOS = 0xD181
            case customFunc3CanonEOS = 0xD182
            case customFunc4CanonEOS = 0xD183
            case customFunc5CanonEOS = 0xD184
            case customFunc6CanonEOS = 0xD185
            case customFunc7CanonEOS = 0xD186
            case customFunc8CanonEOS = 0xD187
            case customFunc9CanonEOS = 0xD188
            case customFunc10CanonEOS = 0xD189
            case customFunc11CanonEOS = 0xD18a
            case customFunc12CanonEOS = 0xD18b
            case customFunc13CanonEOS = 0xD18c
            case customFunc14CanonEOS = 0xD18d
            case customFunc15CanonEOS = 0xD18e
            case customFunc16CanonEOS = 0xD18f
            case customFunc17CanonEOS = 0xD190
            case customFunc18CanonEOS = 0xD191
            case customFunc19CanonEOS = 0xD192
            case innerDevelopCanonEOS = 0xD193
            case multiAspectCanonEOS = 0xD194
            case movieSoundRecordCanonEOS = 0xD195
            case movieRecordVolumeCanonEOS = 0xD196
            case windCutCanonEOS = 0xD197
            case extenderTypeCanonEOS = 0xD198
            case OLCInfoVersionCanonEOS = 0xD199
            case unknownPropD19ACanonEOS = 0xD19A /*found in Canon EOS 5D M3*/
            case unknownPropD19CCanonEOS = 0xD19C /*found in Canon EOS 5D M3*/
            case unknownPropD19DCanonEOS = 0xD19D /*found in Canon EOS 5D M3*/
            case GPSDeviceActiveCanonEOS = 0xD19F
            case customFuncExCanonEOS = 0xD1a0
            case myMenuCanonEOS = 0xD1a1
            case myMenuListCanonEOS = 0xD1a2
            case wftStatusCanonEOS = 0xD1a3
            case wftInputTransmissionCanonEOS = 0xD1a4
            case HDDirectoryStructureCanonEOS = 0xD1a5
            case batteryInfoCanonEOS = 0xD1a6
            case adapterInfoCanonEOS = 0xD1a7
            case lensStatusCanonEOS = 0xD1a8
            case quickReviewTimeCanonEOS = 0xD1a9
            case cardExtensionCanonEOS = 0xD1aa
            case tempStatusCanonEOS = 0xD1ab
            case shutterCounterCanonEOS = 0xD1ac
            case specialOptionCanonEOS = 0xD1ad
            case photoStudioModeCanonEOS = 0xD1ae
            case serialNumberCanonEOS = 0xD1af
            case EVFOutputDeviceCanonEOS = 0xD1b0
            case EVFModeCanonEOS = 0xD1b1
            case depthOfFieldPreviewCanonEOS = 0xD1b2
            case EVFSharpnessCanonEOS = 0xD1b3
            case EVFWBModeCanonEOS = 0xD1b4
            case EVFClickWBCoeffsCanonEOS = 0xD1b5
            case EVFColorTempCanonEOS = 0xD1b6
            case exposureSimModeCanonEOS = 0xD1b7
            case EVFRecordStatusCanonEOS = 0xD1b8
            case LvAfSystemCanonEOS = 0xD1ba
            case movSizeCanonEOS = 0xD1bb
            case LvViewTypeSelectCanonEOS = 0xD1bc
            case mirrorDownStatusCanonEOS = 0xD1bd
            case movieParamCanonEOS = 0xD1be
            case mirrorLockupStateCanonEOS = 0xD1bf
            case flashChargingStateCanonEOS = 0xD1C0
            case aloModeCanonEOS = 0xD1C1
            case fixedMovieCanonEOS = 0xD1C2
            case oneShotRawOnCanonEOS = 0xD1C3
            case errorForDisplayCanonEOS = 0xD1C4
            case AEModeMovieCanonEOS = 0xD1C5
            case builtinStroboModeCanonEOS = 0xD1C6
            case stroboDispStateCanonEOS = 0xD1C7
            case stroboETTL2MeteringCanonEOS = 0xD1C8
            case continousAFModeCanonEOS = 0xD1C9
            case movieParam2CanonEOS = 0xD1CA
            case stroboSettingExpCompositionCanonEOS = 0xD1CB
            case movieParam3CanonEOS = 0xD1CC
            case movieParam4CanonEOS = 0xD1CD
            case LVMedicalRotateCanonEOS = 0xD1CF
            case artistCanonEOS = 0xD1d0
            case copyrightCanonEOS = 0xD1d1
            case bracketValueCanonEOS = 0xD1d2
            case focusInfoExCanonEOS = 0xD1d3
            case depthOfFieldCanonEOS = 0xD1d4
            case brightnessCanonEOS = 0xD1d5
            case lensAdjustParamsCanonEOS = 0xD1d6
            case EFCompCanonEOS = 0xD1d7
            case lensNameCanonEOS = 0xD1d8
            case AEBCanonEOS = 0xD1d9
            case stroboSettingCanonEOS = 0xD1da
            case stroboWirelessSettingCanonEOS = 0xD1db
            case stroboFiringCanonEOS = 0xD1dc
            case lensIDCanonEOS = 0xD1dd
            case LCDBrightnessCanonEOS = 0xD1de
            case CADarkBrightCanonEOS = 0xD1df

//            case CAssistPresetCanonEOS = 0xD201
            case CAssistBrightnessCanonEOS = 0xD202
//            case CAssistContrastCanonEOS = 0xD203
            case CAssistSaturationCanonEOS = 0xD204
            case CAssistColorBACanonEOS = 0xD205
            case CAssistColorMGCanonEOS = 0xD206
            case CAssistMonochromeCanonEOS = 0xD207
            case focusShiftSettingCanonEOS = 0xD208
            case movieSelfTimerCanonEOS = 0xD209
            case clarityCanonEOS = 0xD20B
            case twoGHDRSettingCanonEOS = 0xD20C
//            case movieParam5CanonEOS = 0xD20D
//            case HDRViewAssistModeRecCanonEOS = 0xD20E
            case propFinderAFFrameCanonEOS = 0xD214
//            case variableMovieRecSettingCanonEOS = 0xD215
//            case propAutoRotateCanonEOS = 0xD216
            case MFPeakingSettingCanonEOS = 0xD217
//            case movieSpatialOversamplingCanonEOS = 0xD218
            case movieCropModeCanonEOS = 0xD219
            case shutterTypeCanonEOS = 0xD21A
//            case WFTBatteryPowerCanonEOS = 0xD21B
//            case batteryInfoExCanonEOS = 0xD21C
            
            /* Sony Extensions */
            case DPCCompensation = 0xd200
            case dRangeOptimize = 0xd201
            case imageSizeSony = 0xd203
            case shutterSpeed = 0xd20d
            case unknown_0xd20e = 0xd20e
            case colorTemp = 0xd20f
            case cCFilter = 0xd210
            case aspectRatio = 0xd211
            case focusFound = 0xd213
            case objectInMemory = 0xd215
            case exposeIndex = 0xd216
            case batteryLevelSony = 0xd218
            case pictureEffect = 0xd21b
            case ABFilter = 0xd21c
            case ISO = 0xd21e
            case autoFocus = 0xd2c1
            case capture = 0xd2c2
            case movie = 0xd2c8
            case stillImage = 0xd2c7
            case movieFormat = 0xd241
            case movieQuality = 0xd242
            case storageState = 0xd248
            case remainingShots = 0xd249
            case remainingCaptureTime = 0xd24a
            case exposureSettingsLock = 0xd2d5
            case performZoom = 0xd2dd
            case exposureProgramModeControl = 0xd25a
            case zoomPosition = 0xd25d
            case stillQuality = 0xd252
            case stillFormat = 0xd253
            case exposureSettingsLockStatus = 0xd22a
            case liveViewURL = 0xd278
            case recordingDuration = 0xd261
            case liveViewQuality = 0xd26a
            
            /// Returns the PTP Prop data type for the given manufacturer
            /// - Parameter manufacturer: The manufacturer of the camera
            func dataType(for manufacturer: Manufacturer) -> PTP.DeviceProperty.DataType {
                switch manufacturer {
                case .sony:
                    switch self {
                    case .exposureProgramMode, .ISO, .shutterSpeed,
                         .stillCaptureMode:
                        return .uint32
                    case .flashMode, .fNumber, .focusMode,
                         .movieQuality, .whiteBalance:
                        return .uint16
                    case .exposureSettingsLock, .exposureProgramModeControl,
                         .focusFound, .liveViewQuality, .movieFormat,
                         .stillFormat, .stillQuality:
                        return .uint8
                    case .exposureBiasCompensation:
                        return .int16
                    default:
                        return .uint16
                    }
                case .canon:
                    switch self {
                    case .cameraTimeCanonEOS, .UTCTimeCanonEOS, .summertimeCanonEOS,
                         .availableShotsCanonEOS, .captureDestinationCanonEOS,
                         .whiteBalanceXACanonEOS, .whiteBalanceXBCanonEOS,
                         .currentStorageCanonEOS, .currentFolderCanonEOS,
                         .shutterCounterCanonEOS, .modelIDCanon, .lensIDCanonEOS,
                         .stroboFiringCanonEOS, .AFSelectFocusAreaCanonEOS,
                         .continousAFModeCanonEOS, .mirrorUpSettingCanonEOS,
                         .OLCInfoVersionCanonEOS, .powerZoomPositionCanonEOS,
                         .powerZoomSpeedCanonEOS, .builtinStroboModeCanonEOS,
                         .stroboETTL2MeteringCanonEOS, .colorTemperatureCanonEOS,
                         .fixedMovieCanonEOS:
                        return .uint32
                    case .autoExposureModeCanonEOS:
                        //TODO: [Canon] Never provided, but always available to set?
                        return .uint16
                    case .apertureCanonEOS, .apertureCanon, .shutterSpeedCanonEOS,
                         .shutterSpeedCanon, .ISOSpeedCanon, .ISOSpeedCanonEOS,
                         .focusModeCanonEOS, .colorSpaceCanonEOS, .batteryPowerCanonEOS,
                         .batterySelectCanonEOS, .PTPExtensionVersionCanonEOS,
                         .driveModeCanon, .driveModeCanonEOS, .AEBCanonEOS,
                         .bracketModeCanonEOS, .quickReviewTimeCanonEOS, .EVFModeCanonEOS,
                         .EVFOutputDeviceCanonEOS, .autoPowerOffCanonEOS,
                         .EVFRecordStatusCanonEOS, .highISOSettingNoiseReductionCanonEOS,
                         .multiAspectCanonEOS, .DPOFVersionCanonEOS, .DPOFVersionCanon:
                        return .uint16
                    case .pictureStyleCanonEOS, .whiteBalanceCanon, .whiteBalanceCanonEOS,
                         .meteringModeCanonEOS, .meteringModeCanon, .expCompensationCanon,
                         .expCompensationCanonEOS:
                        return .uint8
                    case .ownerCanonEOS, .artistCanonEOS, .copyrightCanonEOS,
                         .serialNumberCanonEOS, .lensNameCanonEOS:
                        return .uint8string
                    case .whiteBalanceAdjustACanonEOS, .whiteBalanceAdjustBCanonEOS:
                        return .int32
                    case .customFunc1CanonEOS, .customFunc2CanonEOS, .customFunc3CanonEOS,
                         .customFunc4CanonEOS, .customFunc5CanonEOS, .customFunc6CanonEOS,
                         .customFunc7CanonEOS, .customFunc8CanonEOS, .customFunc9CanonEOS,
                         .customFunc10CanonEOS, .customFunc11CanonEOS:
                        //TODO: [Canon] May need to handle specially!
                        return .uint8
                    case .imageFormatCanonEOS, .imageFormatCFCanonEOS, .imageFormatSDCanonEOS,
                         .imageFormatExtHDCanonEOS, .customFuncExCanonEOS, .focusInfoExCanonEOS:
                        //TODO: [Canon] All of these need special handling!
                        return .uint16
                    default:
                        // Unknown properties assume UInt32
                        return .uint32
                    }
                    //TODO: [Canon] Implement!
                    return .uint16
                }
            }
        }
    }
}
