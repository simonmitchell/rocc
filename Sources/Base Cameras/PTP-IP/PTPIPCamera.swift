//
//  PTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

internal class PTPIPCamera: BaseSSDPCamera, SSDPCamera {
        
    let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "PTPIPCamera")
    
    var ipAddress: sockaddr_in? = nil
    
    var apiVersion: String? = nil
    
    var model: CameraModel?
    
    var baseURL: URL?
                
    var firmwareVersion: String? = nil
        
    var remoteAppVersion: String? = nil
    
    var latestRemoteAppVersion: String? = nil
    
    var lensModelName: String? = nil
    
    var onEventAvailable: (() -> Void)?
    
    var onDisconnected: (() -> Void)?
    
    var zoomingDirection: Zoom.Direction?
    
    var highFrameRateCallback: ((Result<HighFrameRateCapture.Status, Error>) -> Void)?
        
    var eventPollingMode: PollingMode {
        guard let deviceInfo = deviceInfo else { return .timed }
        return deviceInfo.supportedEventCodes.contains(.propertyChanged) ? .cameraDriven : .timed
    }
    
    var connectionMode: ConnectionMode = .remoteControl
        
    private var cachedPTPIPClient: PTPIPClient?
    
    var ptpIPClient: PTPIPClient? {
        get {
            if let cachedPTPIPClient = cachedPTPIPClient {
                return cachedPTPIPClient
            }
            guard let stream = InputOutputPacketStream(camera: self, port: 15740) else {
                return nil
            }
            cachedPTPIPClient = PTPIPClient(camera: self, packetStream: stream)
            return cachedPTPIPClient
        }
        set {
            cachedPTPIPClient = newValue
        }
    }
    
    //MARK: - Initialisation -
    
    required override init(dictionary: [AnyHashable : Any]) throws {
            
        do {
            try super.init(dictionary: dictionary)
        } catch let error {
            throw error
        }
    }
    
    var isConnected: Bool = false
    
    var deviceInfo: PTP.DeviceInfo?
    
    var lastEventPacket: EventPacket?
    
    var lastEvent: CameraEvent?
    
    var lastStillCaptureModes: (available: [SonyStillCaptureMode], supported: [SonyStillCaptureMode])?
    
    var imageURLs: [ShootingMode : [URL]] = [:]
    
    func update(with deviceInfo: SSDPCameraInfo) {
        
    }
    
    //MARK: - Handshake methods -
    
    private func sendStartSessionPacket(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        
        // First argument here is the session ID.
        let packet = Packet.commandRequestPacket(
            code: .openSession,
            arguments: [0x00000001],
            transactionId: ptpIPClient?.getNextTransactionId() ?? 0
        )
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code), false)
                return
            }
            self?.getDeviceInfo(completion: completion)
        }, callCallbackForAnyResponse: true)
    }
    
    private func getDeviceInfo(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        
        let packet = Packet.commandRequestPacket(code: .getDeviceInfo, arguments: nil, transactionId: ptpIPClient?.getNextTransactionId() ?? 1)
        
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak self] (dataResult) in
            
            switch dataResult {
            case .success(let dataContainer):
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
            case .failure(let error):
                completion(error, false)
            }
        })
        
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
        
    private func performSdioConnect(completion: @escaping (Error?) -> Void, number: DWord, transactionId: DWord) {
        
        let packet = Packet.commandRequestPacket(code: .sdioConnect, arguments: [number, 0x0000, 0x0000], transactionId: transactionId)
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code))
                return
            }
            completion(nil)
        }, callCallbackForAnyResponse: true)
    }

    private func performCloseSession(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        let packet = Packet.commandRequestPacket(code: .closeSession, arguments: nil, transactionId: ptpIPClient?.getNextTransactionId() ?? 1)
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { (response) in
            completion(PTPError.anotherSessionOpen, false)
        }, callCallbackForAnyResponse: true)
    }
    
    private func getSdioExtDeviceInfo(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        
        // 1. call sdio connect twice
        // 2. call sdio get ext device info
        // 3. call sdio connect once more
        
        performSdioConnect(completion: { [weak self] (error) in
            guard let self = self else { return }

            if let ptpError = error as? PTPError, case PTPError.commandRequestFailed(.sony_anotherSessionOpen) = ptpError {
                return self.performCloseSession(completion: completion)
            }

            self.performSdioConnect(
                completion: { [weak self] (secondaryError) in
                    
                    guard let self = self else { return }

                    if let ptpError = secondaryError as? PTPError, case PTPError.commandRequestFailed(.sony_anotherSessionOpen) = ptpError {
                        return self.performCloseSession(completion: completion)
                    }
                    
                    // One parameter into this call, not sure what it represents!
                    let packet = Packet.commandRequestPacket(code: .sdioGetExtDeviceInfo, arguments: [0x0000012c], transactionId: self.ptpIPClient?.getNextTransactionId() ?? 4)
                    self.ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak self] (dataResult) in
                        
                        switch dataResult {
                        case .success(let dataContainer):
                            
                            guard let self = self else { return }
                            guard let extDeviceInfo = PTP.SDIOExtDeviceInfo(data: dataContainer.data) else {
                                completion(PTPError.fetchSdioExtDeviceInfoFailed, false)
                                return
                            }
                            self.deviceInfo?.update(with: extDeviceInfo)
                        case .failure(let error):
                            completion(error, false)
                        }
                    })
                    self.ptpIPClient?.sendCommandRequestPacket(packet, callback: { (response) in
                        guard response.code == .okay else {
                            completion(PTPError.commandRequestFailed(response.code), false)
                            return
                        }
                        // Sony app seems to jump current transaction ID back to 2 here, so we'll do the same
                        self.ptpIPClient?.resetTransactionId(to: 1)
                        self.performSdioConnect(
                            completion: { [weak self] _ in
                                self?.performInitialEventFetch(completion: completion)
                            },
                            number: 3,
                            transactionId: self.ptpIPClient?.getNextTransactionId() ?? 2
                        )
                    })
                },
                number: 2,
                transactionId: self.ptpIPClient?.getNextTransactionId() ?? 3
            )
        }, number: 1, transactionId: ptpIPClient?.getNextTransactionId() ?? 2)
    }
    
    private func performInitialEventFetch(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        
        self.ptpIPClient?.sendCommandRequestPacket(Packet.commandRequestPacket(
            code: .unknownHandshakeRequest,
            arguments: nil,
            transactionId: self.ptpIPClient?.getNextTransactionId() ?? 7
        ), callback: { (response) in
            
            self.performFunction(Event.get, payload: nil, callback: { [weak self] (error, event) in
                
                self?.lastEvent = event
                // Can ignore errors as we don't really require this event for the connection process to complete!
                completion(nil, false)
            })
        })
    }
    
    func getDevicePropDescriptionsFor(propCodes: [PTP.DeviceProperty.Code], callback: @escaping PTPIPClient.AllDevicePropertyDescriptionsCompletion) {
        
        guard let ptpIPClient = ptpIPClient else { return }
        
        if deviceInfo?.supportedOperations.contains(.getAllDevicePropData) ?? false {
            
            ptpIPClient.getAllDevicePropDesc(callback: { (result) in
                switch result {
                case .success(let properties):
                    let returnProperties = properties.filter({ propCodes.contains($0.code) })
                    guard !returnProperties.isEmpty else {
                        callback(Result.failure(PTPError.propCodeNotFound))
                        return
                    }
                    callback(Result.success(returnProperties))
                case .failure(let error):
                    callback(Result.failure(error))
                }
            })
            
        } else if deviceInfo?.supportedOperations.contains(.sonyGetDevicePropDesc) ?? false {
            
            var remainingCodes = propCodes
            var returnProperties: [PTPDeviceProperty] = []
            
            propCodes.forEach { (propCode) in
                
                let packet = Packet.commandRequestPacket(code: .sonyGetDevicePropDesc, arguments: [DWord(propCode.rawValue)], transactionId: ptpIPClient.getNextTransactionId())
                ptpIPClient.awaitDataFor(transactionId: packet.transactionId) { (dataResult) in
                    
                    remainingCodes.removeAll(where: { $0 == propCode })
                    
                    switch dataResult {
                    case .success(let data):
                        guard let property = data.data.getDeviceProperty(at: 0) else {
                            callback(Result.failure(PTPIPClientError.invalidResponse))
                            return
                        }
                        returnProperties.append(property)
                    case .failure(_):
                        break
                    }
                    
                    guard remainingCodes.isEmpty else { return }
                    callback(returnProperties.count == propCodes.count ? Result.success(returnProperties) : Result.failure(PTPError.propCodeNotFound))
                }
                ptpIPClient.sendCommandRequestPacket(packet, callback: nil)
            }
            
            
        } else if deviceInfo?.supportedOperations.contains(.getDevicePropDesc) ?? false {
            
            var remainingCodes = propCodes
            var returnProperties: [PTPDeviceProperty] = []
            
            propCodes.forEach { (propCode) in
                
                ptpIPClient.getDevicePropDescFor(propCode: propCode) { (result) in
                    
                    remainingCodes.removeAll(where: { $0 == propCode })

                    switch result {
                    case .success(let property):
                        returnProperties.append(property)
                    case .failure(_):
                        break
                    }
                    
                    guard remainingCodes.isEmpty else { return }
                    callback(returnProperties.count == propCodes.count ? Result.success(returnProperties) : Result.failure(PTPError.propCodeNotFound))
                }
            }
                        
        } else {
            
            callback(Result.failure(PTPError.operationNotSupported))
        }
    }
    
    func getDevicePropDescriptionFor(propCode: PTP.DeviceProperty.Code,  callback: @escaping PTPIPClient.DevicePropertyDescriptionCompletion) {
        
        guard let ptpIPClient = ptpIPClient else { return }
        
        if deviceInfo?.supportedOperations.contains(.getAllDevicePropData) ?? false {
            
            ptpIPClient.getAllDevicePropDesc(callback: { (result) in
                switch result {
                case .success(let properties):
                    guard let property = properties.first(where: { $0.code == propCode }) else {
                        callback(Result.failure(PTPError.propCodeNotFound))
                        return
                    }
                    callback(Result.success(property))
                case .failure(let error):
                    callback(Result.failure(error))
                }
            })
            
        } else if deviceInfo?.supportedOperations.contains(.sonyGetDevicePropDesc) ?? false {
            
            let packet = Packet.commandRequestPacket(code: .sonyGetDevicePropDesc, arguments: [DWord(propCode.rawValue)], transactionId: ptpIPClient.getNextTransactionId())
            ptpIPClient.awaitDataFor(transactionId: packet.transactionId) { (dataResult) in
                switch dataResult {
                case .success(let data):
                    guard let property = data.data.getDeviceProperty(at: 0) else {
                        callback(Result.failure(PTPIPClientError.invalidResponse))
                        return
                    }
                    callback(Result.success(property))
                case .failure(let error):
                    callback(Result.failure(error))
                }
            }
            ptpIPClient.sendCommandRequestPacket(packet, callback: nil)
            
        } else if deviceInfo?.supportedOperations.contains(.getDevicePropDesc) ?? false {
            
            ptpIPClient.getDevicePropDescFor(propCode: propCode, callback: callback)
            
        } else {
            
            callback(Result.failure(PTPError.operationNotSupported))
        }
    }
    
    var isAwaitingObject: Bool = false
    
    var awaitingObjectId: DWord?
    
    fileprivate func handlePTPIPEvent(_ event: EventPacket) {
        
        lastEventPacket = event
        
        switch event.code {
        case .propertyChanged:
            onEventAvailable?()
        case .objectAdded:
            guard let objectID = event.variables?.first else {
                return
            }
            if isAwaitingObject {
                awaitingObjectId = objectID
            }
            Logger.log(message: "Handling \"Object Added\" event, initiating transfer", category: "SonyPTPIPCamera", level: .debug)
            os_log("Handling \"Object Added\" event, initiating transfer. Awaiting object: %@", log: self.log, type: .debug, isAwaitingObject ? "true" : "false")
            handleObjectId(objectID: objectID, shootingMode: lastEvent?.shootMode?.current ?? .photo) { (result) in
                
            }
            break
        case .objectRemoved:
            // If object was removed, we are done with capture
            break
        default:
            break
        }
    }
    
    enum PTPError: Error {
        case commandRequestFailed(CommandResponsePacket.Code)
        case fetchDeviceInfoFailed
        case fetchSdioExtDeviceInfoFailed
        case deviceInfoNotAvailable
        case objectNotFound
        case propCodeNotFound
        case anotherSessionOpen
        case operationNotSupported
    }
    
    func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
        switch function.function {
        case .getEvent:
            
            guard !imageURLs.isEmpty, var lastEvent = lastEvent else {
                
                ptpIPClient?.getAllDevicePropDesc(callback: { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let properties):
                        let eventAndStillModes = CameraEvent.fromSonyDeviceProperties(properties)
                        var event = eventAndStillModes.event
//                        print("""
//                                GOT EVENT:
//                                \(properties)
//                                """)
                        self.lastStillCaptureModes = eventAndStillModes.stillCaptureModes
                        event.postViewPictureURLs = self.imageURLs.compactMapValues({ (urls) -> [(postView: URL, thumbnail: URL?)]? in
                            return urls.map({ ($0, nil) })
                        })
                        self.imageURLs = [:]
                        callback(nil, event as? T.ReturnType)
                    case .failure(let error):
                        callback(error, nil)
                    }
                })
                
                return
            }
            
            lastEvent.postViewPictureURLs = self.imageURLs.compactMapValues({ (urls) -> [(postView: URL, thumbnail: URL?)]? in
                return urls.map({ ($0, nil) })
            })
            imageURLs = [:]
            callback(nil, lastEvent as? T.ReturnType)
            
        case .setShootMode:
            guard let value = payload as? ShootingMode else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            guard let stillCapMode = bestStillCaptureMode(for: value) else {
                guard let exposureProgrammeMode = self.bestExposureProgrammeModes(for: value, currentExposureProgrammeMode: self.lastEvent?.exposureMode?.current)?.first else {
                    callback(FunctionError.notAvailable, nil)
                    return
                }
                self.setExposureProgrammeMode(exposureProgrammeMode) { (programmeError) in
                    // We return error here, as if callers obey the available shoot modes they shouldn't be calling this with an invalid value
                    callback(programmeError, nil)
                }
                return
            }
            setStillCaptureMode(stillCapMode) { [weak self] (error) in
                guard let self = self, error == nil, let exposureProgrammeMode = self.bestExposureProgrammeModes(for: value, currentExposureProgrammeMode: self.lastEvent?.exposureMode?.current)?.first else {
                    callback(error, nil)
                    return
                }
                self.setExposureProgrammeMode(exposureProgrammeMode) { (programmeError) in
                    // We return error here, as if callers obey the available shoot modes they shouldn't be calling this with an invalid value
                    callback(programmeError, nil)
                }
            }
        case .getShootMode:
            getDevicePropDescriptionsFor(propCodes: [.stillCaptureMode, .exposureProgramMode]) { (result) in
             
                switch result {
                case .success(let properties):
                    let event = CameraEvent.fromSonyDeviceProperties(properties).event
                    callback(nil, event.shootMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .setContinuousShootingMode:
            // This isn't a thing via PTP according to Sony's app (Instead we just have multiple continuous shooting speeds) so we just don't do anything!
            callback(nil, nil)
        case .setISO, .setShutterSpeed, .setAperture, .setExposureCompensation, .setFocusMode, .setExposureMode, .setExposureModeDialControl, .setFlashMode, .setContinuousShootingSpeed, .setStillQuality, .setStillFormat, .setVideoFileFormat, .setVideoQuality, .setContinuousBracketedShootingBracket, .setSingleBracketedShootingBracket, .setLiveViewQuality:
            guard let value = payload as? SonyPTPPropValueConvertable else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(value),
                callback: { (response) in
                    callback(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil, nil)
                }
            )
        case .getISO:
            getDevicePropDescriptionFor(propCode: .ISO, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.iso?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getShutterSpeed:
            getDevicePropDescriptionFor(propCode: .shutterSpeed, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.shutterSpeed?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getAperture:
            getDevicePropDescriptionFor(propCode: .fNumber, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.aperture?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getExposureCompensation:
            getDevicePropDescriptionFor(propCode: .exposureBiasCompensation, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.aperture?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getFocusMode:
            getDevicePropDescriptionFor(propCode: .focusMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.focusMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getExposureMode:
            getDevicePropDescriptionFor(propCode: .exposureProgramMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.exposureMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getExposureModeDialControl:
            getDevicePropDescriptionFor(propCode: .exposureProgramModeControl, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.exposureMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getFlashMode:
            getDevicePropDescriptionFor(propCode: .flashMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.flashMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getSingleBracketedShootingBracket:
            getDevicePropDescriptionFor(propCode: .stillCaptureMode) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.singleBracketedShootingBrackets?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getContinuousBracketedShootingBracket:
            getDevicePropDescriptionFor(propCode: .stillCaptureMode) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.continuousBracketedShootingBrackets?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .setStillSize:
            guard let stillSize = payload as? StillCapture.Size.Value else {
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
            
        case .getStillSize:
            
            // Still size requires still size and ratio codes to be fetched!
            // Still size requires still size and ratio codes to be fetched!
            getDevicePropDescriptionsFor(propCodes: [.imageSizeSony, .aspectRatio]) { (result) in
                switch result {
                case .success(let properties):
                    let event = CameraEvent.fromSonyDeviceProperties(properties).event
                    callback(nil, event.stillSizeInfo?.stillSize as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
            
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
                value = .timer10
            default:
                value = .single
            }
            ptpIPClient?.sendSetControlDeviceAValue(
                PTP.DeviceProperty.Value(value)
            )
        case .getSelfTimerDuration:
            
            getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.selfTimer?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
            
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
            
        case .getWhiteBalance:
            
            // White balance requires white balance and colorTemp codes to be fetched!
            getDevicePropDescriptionsFor(propCodes: [.whiteBalance, .colorTemp]) { (result) in
                switch result {
                case .success(let properties):
                    let event = CameraEvent.fromSonyDeviceProperties(properties).event
                    callback(nil, event.whiteBalance?.whitebalanceValue as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .setupCustomWhiteBalanceFromShot:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setProgramShift, .getProgramShift:
            // Not available natively with PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .takePicture, .takeSingleBracketShot:
            takePicture { (result) in
                switch result {
                case .success(let url):
                    callback(nil, url as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .startContinuousShooting, .startContinuousBracketShooting:
            startCapturing { (error) in
                callback(error, nil)
            }
            callback(nil, nil)
        case .endContinuousShooting, .stopContinuousBracketShooting:
            // Only await image if we're continuous shooting, continuous bracket behaves strangely
            // in that the user must manually trigger the completion and so `ObjectID` event will have been received
            // long ago!
            finishCapturing(awaitObjectId: function.function == .endContinuousShooting) { (result) in
                switch result {
                case .failure(let error):
                    callback(error, nil)
                case .success(let url):
                    callback(nil, url as? T.ReturnType)
                }
            }
        case .startVideoRecording:
            self.ptpIPClient?.sendSetControlDeviceBValue(
                PTP.DeviceProperty.Value(
                    code: .movie,
                    type: .uint16,
                    value: Word(2)
                ),
                callback: { (videoResponse) in
                    guard !videoResponse.code.isError else {
                        callback(PTPError.commandRequestFailed(videoResponse.code), nil)
                        return
                    }
                    callback(nil, nil)
                }
            )
        case .recordHighFrameRateCapture:
            self.ptpIPClient?.sendSetControlDeviceBValue(
                PTP.DeviceProperty.Value(
                    code: .movie,
                    type: .uint16,
                    value: Word(2)
                ),
                callback: { [weak self] (videoResponse) in
                    guard !videoResponse.code.isError else {
                        callback(PTPError.commandRequestFailed(videoResponse.code), HighFrameRateCapture.Status.idle as? T.ReturnType)
                        return
                    }
                    callback(nil, HighFrameRateCapture.Status.buffering as? T.ReturnType)
                    guard let self = self else { return }
                    self.highFrameRateCallback = { [weak self] result in
                        switch result {
                        case .success(let status):
                            callback(nil, status as? T.ReturnType)
                            if status == .idle {
                                self?.highFrameRateCallback = nil
                            }
                        case .failure(let error):
                            callback(error, nil)
                            self?.highFrameRateCallback = nil
                        }
                    }
                }
            )
        case .endVideoRecording:
            self.ptpIPClient?.sendSetControlDeviceBValue(
                PTP.DeviceProperty.Value(
                    code: .movie,
                    type: .uint16,
                    value: Word(1)
                ),
                callback: { (videoResponse) in
                    guard !videoResponse.code.isError else {
                        callback(PTPError.commandRequestFailed(videoResponse.code), nil)
                        return
                    }
                    callback(nil, nil)
                }
            )
        case .startAudioRecording, .endAudioRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .startIntervalStillRecording, .endIntervalStillRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .startLoopRecording, .endLoopRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .startBulbCapture:
            startCapturing { [weak self] (error) in
                
                guard error == nil else {
                    callback(error, nil)
                    return
                }
                
                self?.awaitFocusIfNeeded { (_) in
                    callback(nil, nil)
                }
            }
        case .endBulbCapture:
            finishCapturing() { (result) in
                switch result {
                case .failure(let error):
                    callback(error, nil)
                case .success(let url):
                    callback(nil, url as? T.ReturnType)
                }
            }
        case .startLiveView, .startLiveViewWithQuality, .endLiveView:
            getDevicePropDescriptionFor(propCode: .liveViewURL) { [weak self] (result) in
                
                guard let self = self else { return }
                switch result {
                case .success(let property):
                    
                    var url: URL?
                    if let string = property.currentValue as? String, let returnedURL = URL(string: string) {
                        url = returnedURL
                    }
                    
                    guard function.function == .startLiveViewWithQuality, let quality = payload as? LiveView.Quality else {
                        callback(nil, url as? T.ReturnType)
                        return
                    }
                    
                    self.performFunction(
                        LiveView.QualitySet.set,
                        payload: quality) { (_, _) in
                        callback(nil, url as? T.ReturnType)
                    }
                    
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getLiveViewQuality:
            getDevicePropDescriptionFor(propCode: .liveViewQuality, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.liveViewQuality?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .setSendLiveViewFrameInfo:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .getSendLiveViewFrameInfo:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .startZooming:
            guard let direction = payload as? Zoom.Direction else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            startZooming(direction: direction) { (error) in
                callback(error, nil)
            }
        case .stopZooming:
            stopZooming { (error) in
                callback(error, nil)
            }
        case .setZoomSetting, .getZoomSetting:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .halfPressShutter, .cancelHalfPressShutter:
            ptpIPClient?.sendSetControlDeviceBValue(
                PTP.DeviceProperty.Value(
                    code: .autoFocus,
                    type: .uint16,
                    value: function.function == .halfPressShutter ? Word(2) : Word(1)
                ), callback: { response in
                    callback(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil, nil)
                }
            )
        case .setTouchAFPosition, .getTouchAFPosition, .cancelTouchAFPosition, .startTrackingFocus, .stopTrackingFocus, .setTrackingFocus, .getTrackingFocus:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .getContinuousShootingMode:
            getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.continuousShootingMode?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
            callback(nil, nil)
        case .getContinuousShootingSpeed:
            getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.continuousShootingSpeed?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getStillQuality:
            getDevicePropDescriptionFor(propCode: .stillQuality, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.stillQuality?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getPostviewImageSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setPostviewImageSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getVideoFileFormat:
            getDevicePropDescriptionFor(propCode: .movieFormat, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.videoFileFormat?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getVideoQuality:
            getDevicePropDescriptionFor(propCode: .movieQuality, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.videoQuality?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .setSteadyMode:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getSteadyMode:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setViewAngle:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getViewAngle:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setScene:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getScene:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setColorSetting:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getColorSetting:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setIntervalTime, .getIntervalTime:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setLoopRecordDuration, .getLoopRecordDuration:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setWindNoiseReduction:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getWindNoiseReduction:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setAudioRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getAudioRecording:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setFlipSetting, .getFlipSetting:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setTVColorSystem, .getTVColorSystem:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .listContent, .getContentCount, .listSchemes, .listSources, .deleteContent, .setStreamingContent, .startStreaming, .pauseStreaming, .seekStreamingPosition, .stopStreaming, .getStreamingStatus:
            // Not available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .getInfraredRemoteControl, .setInfraredRemoteControl:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setAutoPowerOff, .getAutoPowerOff:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setBeepMode, .getBeepMode:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setCurrentTime:
            //TODO: Implement
            callback(nil, nil)
        case .getStorageInformation:
            // Requires either remaining shots or remaining capture time to function
            getDevicePropDescriptionsFor(propCodes: [.remainingShots, .remainingCaptureTime, .storageState]) { (result) in
                switch result {
                case .success(let properties):
                    let event = CameraEvent.fromSonyDeviceProperties(properties).event
                    callback(nil, event.storageInformation as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .setCameraFunction:
            callback(CameraError.noSuchMethod("setCameraFunction"), nil)
        case .getCameraFunction:
            callback(CameraError.noSuchMethod("getCameraFunction"), nil)
        case .ping:
            ptpIPClient?.ping(callback: { (error) in
                callback(nil, nil)
            })
        case .startRecordMode:
            callback(CameraError.noSuchMethod("startRecordMode"), nil)
        case .getStillFormat:
            getDevicePropDescriptionFor(propCode: .stillFormat, callback: { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.stillFormat?.current as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            })
        case .getExposureSettingsLock:
            getDevicePropDescriptionFor(propCode: .exposureSettingsLockStatus) { (result) in
                switch result {
                case .success(let property):
                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
                    callback(nil, event.exposureSettingsLockStatus as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .setExposureSettingsLock:

            // This may seem strange, that to move to standby we set this value twice, but this is what works!
            // It doesn't seem like we actually need the value at all, it just toggles it on this camera...
            ptpIPClient?.sendSetControlDeviceBValue(
                PTP.DeviceProperty.Value(
                    code: .exposureSettingsLock,
                    type: .uint16,
                    value: Word(0x01)
                ),
                callback: { [weak self] (response) in
                    guard let self = self else { return }
                    guard !response.code.isError else {
                        callback(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil, nil)
                        return
                    }
                    self.ptpIPClient?.sendSetControlDeviceBValue(
                        PTP.DeviceProperty.Value(
                            code: .exposureSettingsLock,
                            type: .uint16,
                            value: Word(0x02)
                        ),
                        callback: { (innerResponse) in
                            callback(innerResponse.code.isError ? PTPError.commandRequestFailed(innerResponse.code) : nil, nil)
                        }
                    )
                }
            )
        }
    }
}

//MARK: - Camera protocol conformance -

extension PTPIPCamera {
    
    var isInBeta: Bool {
        return false
    }
        
    func connect(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        lastEvent = nil
        lastEventPacket = nil
        lastStillCaptureModes = nil
        zoomingDirection = nil
        highFrameRateCallback = nil
        
        // Set these first because tests that rely on these being set
        // run synchronously!
        ptpIPClient?.onEvent = { [weak self] (event) in
            self?.handlePTPIPEvent(event)
        }
        ptpIPClient?.onDisconnect = { [weak self] in
            self?.onDisconnected?()
        }

        retry(work: { [weak self] (anotherAttemptMaybeSuccessful, attemptNumber) in
            guard let self = self else { return }

            Logger.log(message: "PTP/IP Connection attempt: \(attemptNumber)", category: "SonyPTPIPCamera", level: .debug)
            os_log("PTP/IP Connection attempt: %d", log: self.log, type: .debug, attemptNumber)

            let retriableCompletion: PTPIPCamera.ConnectedCompletion = { (_ error: Error?, _ transferMode: Bool) in
                var retriable = false

                if let ptpError = error as? PTPError {
                    switch ptpError {
                    case .anotherSessionOpen, .operationNotSupported:
                        retriable = true
                    default:
                        retriable = false
                    }
                }

                if !anotherAttemptMaybeSuccessful(retriable) {
                    completion(error, transferMode)
                }
            }
            self.ptpIPClient?.connect(callback: { [weak self] (error) in
                self?.sendStartSessionPacket(completion: retriableCompletion)
            })
        }, attempts: 3)
    }
    
    func disconnect(completion: @escaping DisconnectedCompletion) {
        ptpIPClient?.onDisconnect = nil
        ptpIPClient?.disconnect()
        completion(nil)
    }
    
    func makeFunctionAvailable<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        
        switch function.function {
        case .startContinuousShooting:
            
            setShutterSpeedAwayFromBulbIfRequired { [weak self] (_) in
                
                guard let self = self else { return }
                
                // On PTP IP cameras still capture mode gives us both continuous shooting speed, and it's mode too
                self.getDevicePropDescriptionFor(propCode: .stillCaptureMode, callback: { [weak self] (result) in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let property):
                        
                        let event = CameraEvent.fromSonyDeviceProperties([property]).event
                        guard let firstMode = event.continuousShootingMode?.available.first(where: { $0 != .single }) ?? event.continuousShootingMode?.available.first else {
                            callback(nil)
                            return
                        }
                        
                        self.performFunction(ContinuousCapture.Mode.set, payload: firstMode) { [weak self] (error, _) in

                            guard error == nil else {
                                callback(error)
                                return
                            }
                            
                            guard let self = self else { return }
                            
                            guard let firstSpeed = event.continuousShootingSpeed?.available.first else {
                                callback(nil)
                                return
                            }
                            
                            self.performFunction(ContinuousCapture.Speed.set, payload: firstSpeed) { (error, _) in
                                callback(error)
                            }
                        }
                    case .failure(let error):
                        callback(error)
                    }
                })
            }
        case .startBulbCapture:
            performFunction(Shutter.Speed.set, payload: ShutterSpeed.bulb) { [weak self] (shutterSpeedError, _) in
                guard shutterSpeedError == nil else {
                    callback(shutterSpeedError)
                    return
                }
                // We need to do this otherwise the camera can get stuck in continuous shooting mode!
                self?.performFunction(ShootMode.set, payload: .photo) { (_, _) in
                    callback(nil)
                }
            }
        case .takePicture:
            setShutterSpeedAwayFromBulbIfRequired() { [weak self] (_) in
                self?.performFunction(ShootMode.set, payload: .photo) { (_, _) in
                    callback(nil)
                }
            }
        case .startIntervalStillRecording:
            setShutterSpeedAwayFromBulbIfRequired() { [weak self] (_) in
                self?.setToShootModeIfRequired(.interval, callback)
            }
        case .startAudioRecording:
            setShutterSpeedAwayFromBulbIfRequired() { [weak self] (_) in
                self?.setToShootModeIfRequired(.audio, callback)
            }
        case .startVideoRecording:
            setShutterSpeedAwayFromBulbIfRequired() { [weak self] (_) in
                self?.setToShootModeIfRequired(.video, callback)
            }
        case .startLoopRecording:
            setShutterSpeedAwayFromBulbIfRequired() { [weak self] (_) in
                self?.setToShootModeIfRequired(.loop, callback)
            }
        case .recordHighFrameRateCapture:
            setShutterSpeedAwayFromBulbIfRequired() { [weak self] (_) in
                self?.setToShootModeIfRequired(.highFrameRate, callback)
            }
        case .startContinuousBracketShooting:
            setShutterSpeedAwayFromBulbIfRequired { [weak self] (_) in
                self?.setToShootModeIfRequired(.continuousBracket, callback)
            }
        case .takeSingleBracketShot:
            setShutterSpeedAwayFromBulbIfRequired { [weak self] (_) in
                self?.setToShootModeIfRequired(.singleBracket, callback)
            }
        default:
            callback(nil)
        }
    }
    
    func bestStillCaptureMode(for shootMode: ShootingMode) -> SonyStillCaptureMode? {
                
        switch shootMode {
        case .video:
            return .single
        case .audio, .loop, .interval, .highFrameRate:
            return nil
        case .photo, .timelapse, .bulb:
            return .single
        case .continuous:
            guard let continuousShootingModes = lastStillCaptureModes?.available.filter({
                $0.shootMode == .continuous
            }) else {
                return .continuous
            }
            return continuousShootingModes.first
        case .singleBracket:
            return lastStillCaptureModes?.available.filter({
                $0.shootMode == .singleBracket
            }).first
        case .continuousBracket:
            return lastStillCaptureModes?.available.filter({
                $0.shootMode == .continuousBracket
            }).first
        }
    }
    
    func bestExposureProgrammeModes(for shootMode: ShootingMode, currentExposureProgrammeMode: Exposure.Mode.Value?) -> [Exposure.Mode.Value]? {
        
        var modes: [Exposure.Mode.Value]?
        let defaultModes: [Exposure.Mode.Value] = [.intelligentAuto, .programmedAuto, .aperturePriority, .shutterPriority, .manual, .superiorAuto, .slowAndQuickProgrammedAuto, .slowAndQuickAperturePriority, .slowAndQuickShutterPriority, .slowAndQuickManual]
        
        // For Video -> Photo or Photo -> Video there are equivalents, so Aperture Priority has Video Aperture Priority e.t.c. so we should prioritise these...
        switch shootMode {
        case .highFrameRate:
            let defaultHFRModes: [Exposure.Mode.Value] = [.highFrameRateProgrammedAuto, .highFrameRateAperturePriority, .highFrameRateShutterPriority, .highFrameRateManual]
            switch currentExposureProgrammeMode {
            case .aperturePriority, .slowAndQuickAperturePriority, .videoAperturePriority:
                modes = defaultHFRModes.bringingToFront(.videoAperturePriority)
            case .programmedAuto, .intelligentAuto, .slowAndQuickProgrammedAuto, .videoProgrammedAuto:
                modes = defaultHFRModes.bringingToFront(.videoProgrammedAuto)
            case .shutterPriority, .slowAndQuickShutterPriority, .videoShutterPriority:
                modes = defaultHFRModes.bringingToFront(.videoShutterPriority)
            case .manual, .slowAndQuickManual, .videoManual:
                modes = defaultHFRModes.bringingToFront(.videoManual)
            default:
                modes = defaultHFRModes
            }
        case .video:
            let defaultVideoModes: [Exposure.Mode.Value] = [.videoProgrammedAuto, .videoAperturePriority, .videoShutterPriority, .videoManual]
            switch currentExposureProgrammeMode {
            case .aperturePriority, .slowAndQuickAperturePriority, .highFrameRateAperturePriority:
                modes = defaultVideoModes.bringingToFront(.videoAperturePriority)
            case .programmedAuto, .intelligentAuto, .slowAndQuickProgrammedAuto, .highFrameRateProgrammedAuto:
                modes = defaultVideoModes.bringingToFront(.videoProgrammedAuto)
            case .shutterPriority, .slowAndQuickShutterPriority, .highFrameRateShutterPriority:
                modes = defaultVideoModes.bringingToFront(.videoShutterPriority)
            case .manual, .slowAndQuickManual, .highFrameRateManual:
                modes = defaultVideoModes.bringingToFront(.videoManual)
            default:
                modes = defaultVideoModes
            }
        case .photo, .timelapse, .singleBracket, .continuousBracket:
            switch currentExposureProgrammeMode {
            case .videoShutterPriority:
                modes = defaultModes.bringingToFront(.slowAndQuickShutterPriority).bringingToFront(.shutterPriority)
            case .videoProgrammedAuto:
                modes = defaultModes.bringingToFront(.intelligentAuto).bringingToFront(.superiorAuto).bringingToFront(.slowAndQuickProgrammedAuto).bringingToFront(.programmedAuto)
            case .videoAperturePriority:
                modes = defaultModes.bringingToFront(.slowAndQuickAperturePriority).bringingToFront(.aperturePriority)
            case .videoManual:
                modes = defaultModes.bringingToFront(.slowAndQuickManual).bringingToFront(.manual)
            case .some(let currentMode):
                modes = defaultModes.bringingToFront(currentMode)
            default:
                // Don't need to worry about sorting here, as we'll already be in the required mode
                modes = defaultModes
            }
            break
        case .bulb:
            // If we're in BULB then we need to return either M or Shutter Priority
            switch currentExposureProgrammeMode {
            case .videoShutterPriority:
                modes = [.shutterPriority, .slowAndQuickShutterPriority, .manual, .slowAndQuickManual]
            case .videoManual:
                modes = [.manual, .slowAndQuickManual, .shutterPriority, .slowAndQuickShutterPriority]
            default:
                modes = [.shutterPriority, .slowAndQuickShutterPriority, .manual, .slowAndQuickManual]
            }
        default:
            return nil
        }
        
        if let availableModes = lastEvent?.exposureMode?.available {
            modes = modes?.filter({ availableModes.contains($0) })
        }
        
        return modes
    }
    
    private func setToExposureProgrammgeModeIfRequired(for shootMode: ShootingMode, _ completion: @escaping ((Error?) -> Void)) {
        
        guard let exposureProgrammeModes = self.bestExposureProgrammeModes(for: shootMode, currentExposureProgrammeMode: self.lastEvent?.exposureMode?.current), let firstMode = exposureProgrammeModes.first else {
            completion(nil)
            return
        }
        // If our preffered exposure programme modes already contains the current one, we don't need to do anything
        if let current = lastEvent?.exposureMode?.current, exposureProgrammeModes.contains(current) {
            completion(nil)
            return
        }
        
        // Make sure this is available, as it isn't always!
        isFunctionAvailable(Exposure.Mode.set) { [weak self] (available, _, _) in
            guard let self = self else {
                completion(nil)
                return
            }
            guard let _available = available, _available else {
                completion(nil)
                return
            }
            self.setExposureProgrammeMode(firstMode, completion)
        }
    }
    
    private func setToShootModeIfRequired(_ shootMode: ShootingMode, _ completion: @escaping ((Error?) -> Void)) {
        
        // Last shoot mode should be up to date so do a quick check if we're already in the correct shoot mode
        guard lastEvent?.shootMode?.current != shootMode else {
            completion(nil)
            return
        }
        
        guard let stillCaptureMode = bestStillCaptureMode(for: shootMode) else {
            setToExposureProgrammgeModeIfRequired(for: shootMode, completion)
            return
        }
        
        setStillCaptureMode(stillCaptureMode) { [weak self] (error) in
            guard let self = self, error == nil else {
                completion(error)
                return
            }
            self.setToExposureProgrammgeModeIfRequired(for: shootMode, completion)
        }
    }
    
    func setExposureProgrammeMode(_ mode: Exposure.Mode.Value, _ completion: @escaping ((Error?) -> Void)) {
        
        ptpIPClient?.sendSetControlDeviceAValue(
            PTP.DeviceProperty.Value(
                code: .exposureProgramMode,
                type: .uint32,
                value: mode.sonyPTPValue
            ),
            callback: { (response) in
                completion(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil)
            }
        )
    }
    
    func setStillCaptureMode(_ mode: SonyStillCaptureMode, _ completion: @escaping ((Error?) -> Void)) {
        
        ptpIPClient?.sendSetControlDeviceAValue(
            PTP.DeviceProperty.Value(
                code: .stillCaptureMode,
                type: .uint32,
                value: mode.rawValue
            ),
            callback: { (response) in
                completion(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil)
            }
        )
    }
    
    private func setShutterSpeedAwayFromBulbIfRequired(_ callback: @escaping ((Error?) -> Void)) {
        
        // We need to do this otherwise the camera can get stuck in continuous shooting mode!
        // If the shutter speed is BULB then we need to set it to something else!
        guard self.lastEvent?.shutterSpeed?.current.isBulb == true else {
            callback(nil)
            return
        }
        
        // Get available shutter speeds
        getDevicePropDescriptionFor(propCode: .shutterSpeed) { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let property):
                let event = CameraEvent.fromSonyDeviceProperties([property]).event
                guard let firstNonBulbShutterSpeed = event.shutterSpeed?.available.first(where: { !$0.isBulb }) else {
                    callback(nil)
                    return
                }
                // Set shutter speed to non-bulb
                self.performFunction(Shutter.Speed.set, payload: firstNonBulbShutterSpeed) { (error, _) in
                    callback(error)
                }
            case .failure(let error):
                callback(error)
            }
        }
    }
    
    func loadFilesToTransfer(callback: @escaping ((Error?, [File]?) -> Void)) {
        
    }
    
    func finishTransfer(callback: @escaping ((Error?) -> Void)) {
        
    }
    
    func handleEvent(event: CameraEvent) {
        defer {
            lastEvent = event
        }
        guard let highFrameRateStatus = event.highFrameRateCaptureStatus, highFrameRateStatus != lastEvent?.highFrameRateCaptureStatus else { return }
        highFrameRateCallback?(Result.success(highFrameRateStatus))
    }
}
