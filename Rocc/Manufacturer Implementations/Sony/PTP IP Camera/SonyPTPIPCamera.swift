//
//  SonyPTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

internal final class SonyPTPIPDevice: SonyCamera {
    
    var ipAddress: sockaddr_in? = nil
    
    var apiVersion: String? = nil
    
    var baseURL: URL?
    
    var manufacturer: String
    
    var name: String?
    
    var model: String? = nil
    
    var firmwareVersion: String? = nil
    
    public var latestFirmwareVersion: String? {
        return modelEnum?.latestFirmwareVersion
    }
    
    var remoteAppVersion: String? = nil
    
    var latestRemoteAppVersion: String? = nil
    
    var lensModelName: String? = nil
    
    var onEventAvailable: (() -> Void)?
        
    var eventPollingMode: PollingMode {
        guard let deviceInfo = deviceInfo else { return .timed }
        return deviceInfo.supportedEventCodes.contains(.propertyChanged) ? .cameraDriven : .timed
    }
    
    var connectionMode: ConnectionMode = .remoteControl
    
    let apiDeviceInfo: ApiDeviceInfo
    
    var ptpIPClient: PTPIPClient?
    
    struct ApiDeviceInfo {
        
        let liveViewURL: URL
        
        var defaultFunction: String?
                
        init?(dictionary: [AnyHashable : Any]) {
            
            guard let imagingDevice = dictionary["av:X_ScalarWebAPI_ImagingDevice"] as? [AnyHashable : Any] else {
                return nil
            }
            
            guard let liveViewURLString = imagingDevice["av:X_ScalarWebAPI_LiveView_URL"] as? String else {
                return nil
            }
            guard let liveViewURL = URL(string: liveViewURLString) else {
                return nil
            }
            
            self.liveViewURL = liveViewURL
            defaultFunction = imagingDevice["av:X_ScalarWebAPI_DefaultFunction"] as? String
        }
    }
    
    //MARK: - Initialisation -
    
    override init?(dictionary: [AnyHashable : Any]) {
        
        guard let apiDeviceInfoDict = dictionary["av:X_ScalarWebAPI_DeviceInfo"] as? [AnyHashable : Any], let apiInfo = ApiDeviceInfo(dictionary: apiDeviceInfoDict) else {
            return nil
        }
        
        apiDeviceInfo = apiInfo
        manufacturer = dictionary["manufacturer"] as? String ?? "Sony"
        
        super.init(dictionary: dictionary)

        name = dictionary["friendlyName"] as? String

        if let model = model {
            modelEnum = Model(rawValue: model)
        } else {
            modelEnum = nil
        }

        model = modelEnum?.friendlyName
    }
    
    var isConnected: Bool = false
    
    var deviceInfo: PTP.DeviceInfo?
    
    var lastEvent: CameraEvent?
        
    override func update(with deviceInfo: SonyDeviceInfo?) {
        name = modelEnum == nil ? name : (deviceInfo?.model?.friendlyName ?? name)
        modelEnum = deviceInfo?.model ?? modelEnum
        if let modelEnum = deviceInfo?.model {
            model = modelEnum.friendlyName
        }
        lensModelName = deviceInfo?.lensModelName
        firmwareVersion = deviceInfo?.firmwareVersion
    }
    
    //MARK: - Handshake methods -
    
    private func sendStartSessionPacket(completion: @escaping SonyPTPIPDevice.ConnectedCompletion) {
        
        // First argument here is the session ID. We don't need a transaction ID because this is the "first"
        // command we send and so we can use the default 0 value the function provides.
        let packet = Packet.commandRequestPacket(code: .openSession, arguments: [0x00000001])
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed, false)
                return
            }
            self?.getDeviceInfo(completion: completion)
        }, callCallbackForAnyResponse: true)
    }
    
    private func getDeviceInfo(completion: @escaping SonyPTPIPDevice.ConnectedCompletion) {
        
        let packet = Packet.commandRequestPacket(code: .getDeviceInfo, arguments: nil, transactionId: ptpIPClient?.getNextTransactionId() ?? 1)
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak self] (dataContainer) in
            guard let deviceInfo = PTP.DeviceInfo(data: dataContainer.data) else {
                completion(PTPError.fetchDeviceInfoFailed, false)
                return
            }
            self?.deviceInfo = deviceInfo
            // Only get SDIO Ext Device Info if it's supported!
            guard deviceInfo.supportedOperations.contains(.sdioGetExtDeviceInfo) else {
                completion(nil, false)
                return
            }
            self?.getSdioExtDeviceInfo(completion: completion)
        })
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
        
    private func performSdioConnect(completion: @escaping (Error?) -> Void, number: DWord, transactionId: DWord) {
        
        //TODO: Try and find out what the arguments are for this!
        let packet = Packet.commandRequestPacket(code: .sdioConnect, arguments: [number, 0x0000, 0x0000], transactionId: transactionId)
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { (dataContainer) in
            completion(nil)
        })
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
    
    private func getSdioExtDeviceInfo(completion: @escaping SonyPTPIPDevice.ConnectedCompletion) {
        
        // 1. call sdio connect twice
        // 2. call sdio get ext device info
        // 3. call sdio connect once more
        
        performSdioConnect(completion: { [weak self] (error) in
            guard let this = self else { return }
            //TODO: Handle errors
            this.performSdioConnect(
                completion: { [weak this] (secondaryError) in
                    
                    guard let _this = this else { return }
                    
                    // One parameter into this call, not sure what it represents!
                    let packet = Packet.commandRequestPacket(code: .sdioGetExtDeviceInfo, arguments: [0x0000012c], transactionId: _this.ptpIPClient?.getNextTransactionId() ?? 4)
                    _this.ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak _this] (dataContainer) in
                        guard let extDeviceInfo = PTP.SDIOExtDeviceInfo(data: dataContainer.data) else {
                            completion(PTPError.fetchSdioExtDeviceInfoFailed, false)
                            return
                        }
                        _this?.deviceInfo?.update(with: extDeviceInfo)
                        _this?.performSdioConnect(completion: { _ in }, number: 3, transactionId: _this?.ptpIPClient?.getNextTransactionId() ?? 5)
//                        _this?.performFunction(Event.get, payload: nil, callback: { (error, event) in
//                            print("Got event", event)
//                        })
                        completion(nil, false)
                    })
                    _this.ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
                },
                number: 2,
                transactionId: this.ptpIPClient?.getNextTransactionId() ?? 3
            )
        }, number: 1, transactionId: ptpIPClient?.getNextTransactionId() ?? 2)
    }
    
    enum PTPError: Error {
        case commandRequestFailed
        case fetchDeviceInfoFailed
        case fetchSdioExtDeviceInfoFailed
        case deviceInfoNotAvailable
    }
}

//MARK: - Camera protocol conformance -

extension SonyPTPIPDevice: Camera {
        
    func connect(completion: @escaping SonyPTPIPDevice.ConnectedCompletion) {
        
        ptpIPClient = PTPIPClient(camera: self)
        ptpIPClient?.connect(callback: { [weak self] (error) in
            self?.sendStartSessionPacket(completion: completion)
        })
        ptpIPClient?.onEvent = { [weak self] (event) in
            guard event.code == .propertyChanged else { return }
            self?.onEventAvailable?()
        }
    }
    
    func supportsFunction<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
        var supported: Bool = false
                
        // If the function has a related PTP property value
        if let deviceInfo = deviceInfo, let propTypeCodes = function.function.ptpDevicePropertyCodes {
                        
            // Check that the related property value is supported
            supported = propTypeCodes.contains { (functionPropCode) -> Bool in
                return deviceInfo.supportedDeviceProperties.contains(functionPropCode)
            }
            if !supported {
                callback(false, nil, nil)
                return
            }
        }
                
        if let latestEvent = lastEvent, let _ = latestEvent.supportedFunctions {
            latestEvent.supportsFunction(function, callback: callback)
            return
        }
        
        // Fallback for functions that aren't related to a particular camera prop type, or that function differently to the PTP spec!
        switch function.function {
        case .ping:
            callback(true, nil, nil)
        //TODO: Finish implementing!
        default:
            callback(false, nil, nil)
        }
    }
    
    func isFunctionAvailable<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
                        
        if let latestEvent = lastEvent, let _ = latestEvent.availableFunctions {
            latestEvent.isFunctionAvailable(function, callback: callback)
            return
        }
        
//        ptpIPClient?.getDevicePropDescFor(propCode: <#Code#>, callback: { (result) in
//            switch result {
//            case .success(let property):
//                let event = CameraEvent(sonyDeviceProperties: [property])
//                callback(event.availableFunctions?.contains(function.function), nil, event.<#Property#>?.available as? [T.SendType])
//            case .failure(let error):
//                callback(false, error, nil)
//            }
//        })
        
        // Fallback for functions that aren't related to a particular camera prop type, or that function differently to the PTP spec!
        // We re-use the `CameraEvent` logic which parses and munges the response into the correct types here. Really should be moved to a formatter!
        switch function.function {
        case .ping:
            callback(true, nil, nil)
        case .setAperture, .getAperture:
            ptpIPClient?.getDevicePropDescFor(propCode: .fNumber, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.aperture?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setISO, .getISO:
            ptpIPClient?.getDevicePropDescFor(propCode: .ISO, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.iso?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setWhiteBalance, .getWhiteBalance:
            // White balance requires white balance and colorTemp codes to be fetched!
            ptpIPClient?.getDevicePropDescFor(propCode: .whiteBalance, callback: { [weak self] (wbResult) in
                
                guard let this = self else {
                    callback(false, nil, nil)
                    return
                }
                
                switch wbResult {
                case .success(let wbProperty):
                    this.ptpIPClient?.getDevicePropDescFor(propCode: .colorTemp, callback: { (ctResult) in
                        switch ctResult {
                        case .success(let ctProperty):
                            let event = CameraEvent(sonyDeviceProperties: [wbProperty, ctProperty])
                            callback(event.availableFunctions?.contains(function.function), nil, event.whiteBalance?.available as? [T.SendType])
                        case .failure(let error):
                            callback(false, error, nil)
                        }
                    })
                    
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setupCustomWhiteBalanceFromShot:
            //TODO: Implement
            callback(false, nil, nil)
            break
        case .setShootMode, .getShootMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.shootMode?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setProgramShift, .getProgramShift:
            //TODO: Implement
            callback(false, nil, nil)
        case .takePicture:
            //TODO: Implement
            callback(false, nil, nil)
        case .startContinuousShooting, .endContinuousShooting:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, nil)
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .startVideoRecording, .endVideoRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .startAudioRecording, .endAudioRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .startIntervalStillRecording, .endIntervalStillRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .startBulbCapture, .endBulbCapture:
            //TODO: Implement
            callback(false, nil, nil)
        case .startLoopRecording, .endLoopRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .startLiveView:
            //TODO: Implement
            callback(false, nil, nil)
        case .startLiveViewWithSize:
            //TODO: Implement
            callback(false, nil, nil)
        case .endLiveView:
            //TODO: Implement
            callback(false, nil, nil)
        case .getLiveViewSize:
            //TODO: Implement
            callback(false, nil, nil)
        case .setSendLiveViewFrameInfo, .getSendLiveViewFrameInfo:
            //TODO: Implement
            callback(false, nil, nil)
        case .startZooming, .stopZooming:
            //TODO: Implement
            callback(false, nil, nil)
        case .setZoomSetting, .getZoomSetting:
            //TODO: Implement
            callback(false, nil, nil)
        case .halfPressShutter:
            //TODO: Implement
            callback(false, nil, nil)
        case .cancelHalfPressShutter:
            //TODO: Implement
            callback(false, nil, nil)
        case .setTouchAFPosition, .getTouchAFPosition, .cancelTouchAFPosition:
            //TODO: Implement
            callback(false, nil, nil)
        case .startTrackingFocus, .stopTrackingFocus:
            //TODO: Implement
            callback(false, nil, nil)
        case .setTrackingFocus, .getTrackingFocus:
            //TODO: Implement
            callback(false, nil, nil)
        case .setContinuousShootingMode, .getContinuousShootingMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.continuousShootingMode?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.continuousShootingSpeed?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setSelfTimerDuration, .getSelfTimerDuration:
            ptpIPClient?.getDevicePropDescFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.selfTimer?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureMode, .getExposureMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .exposureProgramMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.exposureMode?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setFocusMode, .getFocusMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .focusMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.focusMode?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setExposureCompensation, .getExposureCompensation:
            ptpIPClient?.getDevicePropDescFor(propCode: .exposureBiasCompensation, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.exposureCompensation?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setShutterSpeed, .getShutterSpeed:
            ptpIPClient?.getDevicePropDescFor(propCode: .shutterSpeed, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.shutterSpeed?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setFlashMode, .getFlashMode:
            ptpIPClient?.getDevicePropDescFor(propCode: .flashMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent(sonyDeviceProperties: [property])
                    callback(event.availableFunctions?.contains(function.function), nil, event.flashMode?.available as? [T.SendType])
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setStillSize, .getStillSize:
            // Still size requires still size and ratio codes to be fetched!
            ptpIPClient?.getDevicePropDescFor(propCode: .imageSizeSony, callback: { [weak self] (imageSizeResult) in
                
                guard let this = self else {
                    callback(false, nil, nil)
                    return
                }
                
                switch imageSizeResult {
                case .success(let imageSizeProperty):
                    this.ptpIPClient?.getDevicePropDescFor(propCode: .aspectRatio, callback: { (aspectResult) in
                        switch aspectResult {
                        case .success(let aspectProperty):
                            let event = CameraEvent(sonyDeviceProperties: [imageSizeProperty, aspectProperty])
                            callback(event.availableFunctions?.contains(function.function), nil, event.stillSizeInfo?.available as? [T.SendType])
                        case .failure(let error):
                            callback(false, error, nil)
                        }
                    })
                    
                case .failure(let error):
                    callback(false, error, nil)
                }
            })
        case .setStillQuality, .getStillQuality:
            //TODO: Implement
            callback(false, nil, nil)
        case .getPostviewImageSize, .setPostviewImageSize:
            //TODO: Implement
            callback(false, nil, nil)
        case .setVideoFileFormat, .getVideoFileFormat:
            //TODO: Implement
            callback(false, nil, nil)
        case .setVideoQuality, .getVideoQuality:
            //TODO: Implement
            callback(false, nil, nil)
        case .setSteadyMode, .getSteadyMode:
            //TODO: Implement
            callback(false, nil, nil)
        case .setViewAngle, .getViewAngle:
            //TODO: Implement
            callback(false, nil, nil)
        case .setScene, .getScene:
            //TODO: Implement
            callback(false, nil, nil)
        case .setColorSetting, .getColorSetting:
            //TODO: Implement
            callback(false, nil, nil)
        case .setIntervalTime, .getIntervalTime:
            //TODO: Implement
            callback(false, nil, nil)
        case .setLoopRecordDuration, .getLoopRecordDuration:
            //TODO: Implement
            callback(false, nil, nil)
        case .setWindNoiseReduction, .getWindNoiseReduction:
            //TODO: Implement
            callback(false, nil, nil)
        case .setAudioRecording, .getAudioRecording:
            //TODO: Implement
            callback(false, nil, nil)
        case .setFlipSetting, .getFlipSetting:
            //TODO: Implement
            callback(false, nil, nil)
        case .setTVColorSystem, .getTVColorSystem:
            //TODO: Implement
            callback(false, nil, nil)
        case .listContent:
            //TODO: Implement
            callback(false, nil, nil)
        case .getContentCount:
            //TODO: Implement
            callback(false, nil, nil)
        case .listSchemes:
            //TODO: Implement
            callback(false, nil, nil)
        case .listSources:
            //TODO: Implement
            callback(false, nil, nil)
        case .deleteContent:
            //TODO: Implement
            callback(false, nil, nil)
        case .setStreamingContent:
            //TODO: Implement
            callback(false, nil, nil)
        case .startStreaming:
            //TODO: Implement
            callback(false, nil, nil)
        case .pauseStreaming:
            //TODO: Implement
            callback(false, nil, nil)
        case .seekStreamingPosition:
            //TODO: Implement
            callback(false, nil, nil)
        case .stopStreaming:
            //TODO: Implement
            callback(false, nil, nil)
        case .getStreamingStatus:
            //TODO: Implement
            callback(false, nil, nil)
        case .setInfraredRemoteControl, .getInfraredRemoteControl:
            //TODO: Implement
            callback(false, nil, nil)
        case .setAutoPowerOff, .getAutoPowerOff:
            //TODO: Implement
            callback(false, nil, nil)
        case .setBeepMode, .getBeepMode:
            //TODO: Implement
            callback(false, nil, nil)
        case .setCurrentTime:
            //TODO: Implement
            callback(false, nil, nil)
        case .getStorageInformation:
            //TODO: Implement
            callback(false, nil, nil)
        case .getEvent, .setCameraFunction, .getCameraFunction, .startRecordMode:
            callback(true, nil, nil)
        }
    }
    
    func makeFunctionAvailable<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        //TODO: Implement this properly!
        callback(nil)
    }
    
    func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
        switch function.function {
        case .getEvent:
            let packet = Packet.commandRequestPacket(code: .getAllDevicePropData, arguments: [0], transactionId: ptpIPClient?.getNextTransactionId() ?? 0)
            ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { (data) in
                guard let numberOfProperties = data.data[qWord: 0] else { return }
                var offset: UInt = UInt(MemoryLayout<QWord>.size)
                var properties: [PTPDeviceProperty] = []
                for _ in 0..<numberOfProperties {
                    guard let property = data.data.getDeviceProperty(at: offset) else { break }
                    properties.append(property)
                    offset += property.length
                }
                let event = CameraEvent(sonyDeviceProperties: properties)
                callback(nil, event as? T.ReturnType)
            })
            ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
        case .setShootMode:
            guard let value = payload as? ShootingMode else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            //TODO: Implement when we have better grasp of available shoot modes
        case .setContinuousShootingMode:
            // This isn't a thing via PTP according to Sony's app (Instead we just have multiple continuous shooting speeds) so we just don't do anything!
            callback(nil, nil)
        case .setISO, .setShutterSpeed, .setAperture, .setExposureCompensation, .setFocusMode, .setExposureMode, .setFlashMode, .setContinuousShootingSpeed:
            guard let value = payload as? SonyPTPPropValueConvertable else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(value)
            )
        case .setStillSize:
            guard let stillSize = payload as? StillSize else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            var stillSizeByte: Byte? = nil
            switch stillSize.size {
            case "L":
                stillSizeByte = 0x01
            case "M":
                stillSizeByte = 0x02
            case "S":
                stillSizeByte = 0x03
            default:
                break
            }
            
            if let _stillSizeByte = stillSizeByte {
                ptpIPClient?.sendSetControlDeviceAValue(
                    PTP.DeviceProperty.Value(
                        code: .imageSizeSony,
                        type: .uint8,
                        value: _stillSizeByte
                    )
                )
            }
            
            guard let aspect = stillSize.aspectRatio else { return }
            
            var aspectRatioByte: Byte? = nil
            switch aspect {
            case "3:2":
                aspectRatioByte = 0x01
            case "16:9":
                aspectRatioByte = 0x02
            case "1:1":
                aspectRatioByte = 0x04
            default:
                break
            }
            
            guard let _aspectRatioByte = aspectRatioByte else { return }
            
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(
                    code: .imageSizeSony,
                    type: .uint8,
                    value: _aspectRatioByte
                )
            )
            
        case .setSelfTimerDuration:
            guard let timeInterval = payload as? TimeInterval else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            let value: SonyStillCaptureMode
            switch timeInterval {
            case 0.0:
                value = .single
            case 2.0:
                value = .timer2
            case 5.0:
                value = .timer5
            case 10.0:
                //TODO: Pick out the one which is available! How!?
                value = .timer10_a
            default:
                value = .single
            }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(value)
            )
        case .setWhiteBalance:
            guard let value = payload as? WhiteBalance.Value else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(value.mode)
            )
            guard let colorTemp = value.temperature else { return }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(
                    code: .colorTemp,
                    type: .uint16,
                    value: Word(colorTemp)
                )
            )
        default:
            return
        }
    }
    
    func loadFilesToTransfer(callback: @escaping ((Error?, [File]?) -> Void)) {
        
    }
    
    func finishTransfer(callback: @escaping ((Error?) -> Void)) {
        
    }
    
    func handleEvent(event: CameraEvent) {
        lastEvent = event
    }
}
