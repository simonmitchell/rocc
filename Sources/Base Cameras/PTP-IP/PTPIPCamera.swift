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

    var eventVersion: String? = nil
    
    var model: CameraModel?
    
    var baseURL: URL?
                
    var firmwareVersion: String? = nil
        
    var remoteAppVersion: String? = nil
    
    var latestRemoteAppVersion: String? = nil
    
    var lensModelName: String? = nil
    
    var onEventAvailable: ((CameraEvent?) -> Void)?

    var onLiveViewImageAvailable: ((Image) -> Bool)?

    var onLiveViewFramesAvailable: (([FrameInfo]) -> Bool)?

    var liveViewMode: LiveViewStream.Mode {
        return .fetch
    }
    
    var onDisconnected: (() -> Void)?
    
    var zoomingDirection: Zoom.Direction?
    
    var highFrameRateCallback: ((Result<HighFrameRateCapture.Status, Error>) -> Void)?
        
    var eventPollingMode: EventPollingMode {
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
            self?.getDeviceInfo(completion: { result in
                
                switch result {
                case .success(let deviceInfo):
                    // Only get SDIO Ext Device Info if it's supported!
                    self?.deviceInfo = deviceInfo
                    guard deviceInfo.supportedOperations.contains(.sdioGetExtDeviceInfo) else {
                        completion(nil, false)
                        return
                    }
                    self?.getSdioExtDeviceInfo(completion: completion)
                case .failure(let error):
                    completion(error, false)
                }
            })
        }, callCallbackForAnyResponse: true)
    }
    
    internal func getDeviceInfo(completion: @escaping (Result<PTP.DeviceInfo, Error>) -> Void) {
        
        let packet = Packet.commandRequestPacket(code: .getDeviceInfo, arguments: nil, transactionId: ptpIPClient?.getNextTransactionId() ?? 1)
        
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { (dataResult) in
            
            switch dataResult {
            case .success(let dataContainer):
                guard let deviceInfo = PTP.DeviceInfo(data: dataContainer.data) else {
                    completion(.failure(PTPError.fetchDeviceInfoFailed))
                    return
                }
                completion(.success(deviceInfo))
            case .failure(let error):
                completion(.failure(error))
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
                            completion: { _ in
                                // Think we can ignore this final error
                                completion(nil, false)
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
    
    func performInitialEventFetch(completion: @escaping PTPIPCamera.ConnectedCompletion) {

        self.performFunction(Event.get, payload: nil, callback: { [weak self] (error, event) in
            
            self?.lastEvent = event
            // Can ignore errors as we don't really require this event for the connection process to complete!
            completion(nil, false)
        })
    }

    func getDeviceValueFor<T: PTPPropValueConvertable>(
        function: _CameraFunction,
        callback: @escaping (Result<T, Error>) -> Void
    ) {
        guard let propCodes = propCodesFor(function: function), !propCodes.isEmpty else {
            callback(.failure(PTPError.propCodeNotFound))
            return
        }
        let manufacturer = manufacturer
        getDevicePropValuesFor(propCodes: propCodes) { [weak self] result in
            switch result {
            case .success(let values):
                guard let value = T(values: values, manufacturer: manufacturer) else {
                    callback(.failure(PTPError.propCodeInvalid))
                    return
                }
                callback(.success(value))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    /// Gets raw device prop value for the given prop codes
    /// - Parameters:
    ///   - propCodes: The prop codes to return for
    ///   - callback: Closure called once done
    func getDevicePropValuesFor(
        propCodes: Set<PTP.DeviceProperty.Code>,
        callback: @escaping PTPIPClient.DevicePropertyValuesCompletion
    ) {
        guard let ptpIPClient = ptpIPClient else { return }
        guard !propCodes.isEmpty else {
            callback(.success([:]))
            return
        }

        guard deviceInfo?.supportedOperations.contains(.getDevicePropValue) ?? false else {

            // If the .getDevicePropValue not supported, fall back to
            // .getDevicePropDescriptionsFor
            getDevicePropDescriptionsFor(
                propCodes: propCodes
            ) { propDescriptionCodesResult in
                switch propDescriptionCodesResult {
                case .success(let deviceProperties):
                    var returnValues: [PTP.DeviceProperty.Code: PTPDevicePropertyDataType] = [:]
                    deviceProperties.forEach { deviceProperty in
                        returnValues[deviceProperty.code] = deviceProperty.currentValue
                    }
                    callback(.success(returnValues))
                case .failure(let error):
                    callback(.failure(error))
                }
            }

            return
        }

        // TODO: [Canon] Add override for canon cameras which uses eventing mechanism? :vomit: or perhaps
        // just rely on last received event

        var remainingCodes = propCodes
        var returnProperties: [PTP.DeviceProperty.Code: PTPDevicePropertyDataType] = [:]

        propCodes.forEach { propCode in

            let dataType = propCode.dataType(for: manufacturer)
            let requestPacket = Packet.commandRequestPacket(
                code: .getDevicePropValue,
                arguments: [propCode.rawValue],
                transactionId: ptpIPClient.getNextTransactionId()
            )

            ptpIPClient.awaitDataFor(transactionId: requestPacket.transactionId) { result in
                remainingCodes.remove(propCode)
                switch result {
                case .success(let data):
                    var offset: UInt = 0
                    guard let property = data.data.readValue(of: dataType, at: &offset) else { break }
                    returnProperties[propCode] = property
                case .failure(_):
                    break
                }

                guard remainingCodes.isEmpty else { return }
                callback(
                    returnProperties.count == propCodes.count ?
                        Result.success(returnProperties) :
                        Result.failure(PTPError.propCodeNotFound)
                )
            }
            ptpIPClient.sendControlPacket(requestPacket)
        }
    }
    
    func getDevicePropDescriptionsFor(propCodes: Set<PTP.DeviceProperty.Code>, callback: @escaping PTPIPClient.AllDevicePropertyDescriptionsCompletion) {
        
        guard let ptpIPClient = ptpIPClient else { return }
        guard !propCodes.isEmpty else {
            callback(.success([]))
            return
        }

        // TODO: Add check first to check if the required properties are all contained
        // in deviceInfo?.deviceProperties.
        
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
            
        } else if deviceInfo?.supportedOperations.contains(.getDevicePropDesc) ?? false {
            
            var remainingCodes = propCodes
            var returnProperties: [PTPDeviceProperty] = []
            
            propCodes.forEach { (propCode) in
                
                ptpIPClient.getDevicePropDescFor(propCode: propCode) { (result) in

                    remainingCodes.remove(propCode)

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

        getDevicePropDescriptionsFor(propCodes: [propCode]) { result in
            switch result {
            case .success(let properties):
                guard let match = properties.first(where: { $0.code == propCode }) else {
                    callback(Result.failure(PTPError.propCodeNotFound))
                    return
                }
                callback(Result.success(match))
            case .failure(let error):
                callback(Result.failure(error))
            }
        }
    }

    /// Returns whether a function is supported based on a set of supported device properties
    /// and required device properties. This is a function as some cameras/functions may
    /// require all of the required device properties to be present, and some may just
    /// require one or other of the properties to be present
    ///
    /// For example Canon has multiple PTP.DeviceProperty.Codes for the same function such as
    /// ISOCanon and ISOCanonEOS for get/set ISO
    ///
    /// - Parameters:
    ///   - function: The function that we are checking if is supported
    ///   - supportedDeviceProperties: The device properties that are supported on the camera
    ///   - requiredDeviceProperties: The device properties that are required from the camera
    /// - Returns: Whether the function is supported!
    func isFunctionSupportedBy(
        _ function: _CameraFunction,
        supportedDeviceProperties: Set<PTP.DeviceProperty.Code>,
        requiredDeviceProperties: Set<PTP.DeviceProperty.Code>
    ) -> Bool {
        return requiredDeviceProperties.isSubset(of: supportedDeviceProperties)
    }

    /// Gets the given PTP device property codes for the required camera function. This can be overriden by subclasses
    /// to provide custom logic such as Canon models which have multiple codes for the same params such as ISO
    /// - Parameter function: The function that wants to be performed
    /// - Returns: The relevant device property code
    func propCodesFor(function: _CameraFunction) -> Set<PTP.DeviceProperty.Code>? {
        switch function {
        case .setISO, .getISO:
            return [.ISO]
        case .getShutterSpeed, .setShutterSpeed:
            return [.shutterSpeed]
        case .getAperture, .setAperture:
            return [.fNumber]
        case .getExposureCompensation, .setExposureCompensation:
            return [.exposureBiasCompensation]
        case .getFocusMode, .setFocusMode:
            return [.focusMode]
        case .getExposureMode, .setExposureMode:
            return [.exposureProgramMode]
        case .getExposureModeDialControl, .setExposureModeDialControl:
            return [.exposureProgramModeControl]
        case .getFlashMode, .setFlashMode:
            return [.flashMode]
        case .getSingleBracketedShootingBracket, .getContinuousBracketedShootingBracket, .getSelfTimerDuration, .getContinuousShootingMode, .setContinuousShootingMode, .getContinuousShootingSpeed, .setContinuousShootingSpeed:
            return [.stillCaptureMode]
        case .getWhiteBalance, .setWhiteBalance:
            return [.whiteBalance, .colorTemp]
        case .getLiveViewQuality, .setLiveViewQuality, .startLiveViewWithQuality:
            return [.liveViewQuality]
        case .setStillQuality, .getStillQuality:
            return [.stillQuality]
        case .getVideoFileFormat, .setVideoFileFormat:
            return [.movieFormat]
        case .getVideoQuality, .setVideoQuality:
            return [.movieQuality]
        case .getStorageInformation:
            return [.remainingShots, .remainingCaptureTime]
        case .getStillFormat, .setStillFormat:
            return [.stillFormat]
        case .getExposureSettingsLock:
            return [.exposureSettingsLockStatus]
        case .setExposureSettingsLock:
            return [.exposureSettingsLock]
        case .setShootMode, .getShootMode:
            return [.stillCaptureMode]
        case .startZooming, .stopZooming:
            // TODO: Check which of these are required? All? Or just one?
            return [.digitalZoom, .performZoom, .zoomPosition]
        case .getStillSize, .setStillSize:
            return [.imageSize]
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
    
    var isAwaitingObject: Bool = false
    
    var awaitingObjectId: DWord?
    
    fileprivate func handlePTPIPEvent(_ event: EventPacket) {
        
        lastEventPacket = event
        
        switch event.code {
        case .propertyChanged, .requestGetEvent:
            onEventAvailable?(nil)
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
        case propCodeInvalid
    }
    
    func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
        switch function.function {
        case .getEvent:
            
            guard !imageURLs.isEmpty, var lastEvent = lastEvent else {
                // TODO: Implement - Get first event from camera
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
            guard let value = payload as? PTPPropValueConvertable else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            sendSetDevicePropValue(
                PTP.DeviceProperty.Value(value, manufacturer: manufacturer)) { response in
                callback(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil, nil)
            }
        case .getISO:
            // TODO: [Canon] Perhaps override these on Sony to use the original!
//            getDevicePropDescriptionFor(propCode: .shutterSpeed, callback: { (result) in
//                switch result {
//                case .success(let property):
//                    let event = CameraEvent.fromSonyDeviceProperties([property]).event
//                    callback(nil, event.shutterSpeed?.current as? T.ReturnType)
//                case .failure(let error):
//                    callback(error, nil)
//                }
//            })
            getDeviceValueFor(function: function.function) { (result: Result<ISO.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getShutterSpeed:
            getDeviceValueFor(function: function.function) { (result: Result<ShutterSpeed, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getAperture:
            getDeviceValueFor(function: function.function) { (result: Result<Aperture.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getExposureCompensation:
            getDeviceValueFor(function: function.function) { (result: Result<Exposure.Compensation.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getFocusMode:
            getDeviceValueFor(function: function.function) { (result: Result<Focus.Mode.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getExposureMode:
            getDeviceValueFor(function: function.function) { (result: Result<Exposure.Mode.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getExposureModeDialControl:
            // TODO: [Canon] Add PTPPropValueConvertable struct for exposure program mode control
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
            getDeviceValueFor(function: function.function) { (result: Result<Flash.Mode.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getSingleBracketedShootingBracket:
            getDeviceValueFor(function: function.function) { (result: Result<SingleBracketCapture.Bracket.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getContinuousBracketedShootingBracket:
            getDeviceValueFor(function: function.function) { (result: Result<ContinuousBracketCapture.Bracket.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .setStillSize:
            guard let stillSize = payload as? StillCapture.Size.Value else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            // TODO: Implement default!

        case .getStillSize:
            // TODO: Implement default!
            break
        case .setSelfTimerDuration:
            // TODO: Implement default
            break
        case .getSelfTimerDuration:

            // TODO: [Canon] Update to add new logic!
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

            // TODO: [Canon] Move to SonyPTPIPCamera as this isn't default behaviour
            guard let value = payload as? WhiteBalance.Value else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            sendSetDevicePropValue(
                PTP.DeviceProperty.Value(value.mode, manufacturer: manufacturer)
            )
            guard let colorTemp = value.temperature else { return }
            // TODO: Check on Canon to see if logic matches!
            sendSetDevicePropValue(PTP.DeviceProperty.Value(
                code: .colorTemp,
                type: .uint16,
                value: Word(colorTemp)
            ))

        case .getWhiteBalance:
            // TODO: You are here!
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
            // TODO: Check logic on Canon to see if same
            sendSetDevicePropValue(
                PTP.DeviceProperty.Value(
                    code: .movie,
                    type: .uint16,
                    value: Word(2)
                ),
                valueB: true
            ) { videoResponse in
                guard !videoResponse.code.isError else {
                    callback(PTPError.commandRequestFailed(videoResponse.code), nil)
                    return
                }
                callback(nil, nil)
            }
        case .recordHighFrameRateCapture:
            sendSetDevicePropValue(
                PTP.DeviceProperty.Value(
                    code: .movie,
                    type: .uint16,
                    value: Word(2)
                ),
                valueB: true
            ) { [weak self] videoResponse in
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
        case .endVideoRecording:
            // TODO: Check logic on Canon to see if same
            sendSetDevicePropValue(
                PTP.DeviceProperty.Value(
                    code: .movie,
                    type: .uint16,
                    value: Word(1)
                ),
                valueB: true
            ) { videoResponse in
                guard !videoResponse.code.isError else {
                    callback(PTPError.commandRequestFailed(videoResponse.code), nil)
                    return
                }
                callback(nil, nil)
            }
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
        case .startLiveView, .startLiveViewWithQuality:
            startLiveView { [weak self] startLiveViewError in
                guard let self = self else { return }
                if let error = startLiveViewError {
                    callback(error, nil)
                } else {
                    callback(nil, nil)
                    self.getViewfinderImage { result in
                        // TODO: [Canon] NEXT get image in loop!
                        switch result {
                        case .success(let image):
                            print(image.size)
                            break
                        case .failure(let error):
                            callback(error, nil)
                        }
                    }
                }
            }
            callback(nil, nil)
        case .endLiveView:
            callback(nil, nil)
        case .getLiveViewQuality:
            getDeviceValueFor(function: function.function) { (result: Result<LiveView.Quality, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
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
            // TODO: Check logic on Canon to see if same
            sendSetDevicePropValue(
                PTP.DeviceProperty.Value(
                    code: .autoFocus,
                    type: .uint16,
                    value: function.function == .halfPressShutter ? Word(2) : Word(1)
                ),
                valueB: true
            ) { response in
                callback(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil, nil)
            }
        case .setTouchAFPosition, .getTouchAFPosition, .cancelTouchAFPosition, .startTrackingFocus, .stopTrackingFocus, .setTrackingFocus, .getTrackingFocus:
            // Doesn't seem to be available via PTP/IP
            callback(FunctionError.notSupportedByAvailableVersion, nil)
        case .getContinuousShootingMode:
            // TODO: [Canon] conform ContinuousCapture.Mode.Value to PTPPropValueConvertable
//            getDeviceValueFor(function: function.function) { (result: Result<ContinuousCapture.Mode.Value, Error>) in
//                switch result {
//                case .success(let value):
//                    callback(nil, value as? T.ReturnType)
//                case .failure(let error):
//                    callback(error, nil)
//                }
//            }
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

            break
        case .getContinuousShootingSpeed:
            getDeviceValueFor(function: function.function) { (result: Result<ContinuousCapture.Speed.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getStillQuality:
            getDeviceValueFor(function: function.function) { (result: Result<StillCapture.Quality.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getPostviewImageSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .setPostviewImageSize:
            //TODO: Unable to reverse engineer as not supported on RX100 VII
            callback(nil, nil)
        case .getVideoFileFormat:
            getDeviceValueFor(function: function.function) { (result: Result<VideoCapture.FileFormat.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getVideoQuality:
            getDeviceValueFor(function: function.function) { (result: Result<VideoCapture.Quality.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
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
            // TODO: [Canon] Conform StorageInformation to PTPPropValueConvertable
//            getDeviceValueFor(function: function.function) { (result: Result<StorageInformation, Error>) in
//                switch result {
//                case .success(let value):
//                    callback(nil, value as? T.ReturnType)
//                case .failure(let error):
//                    callback(error, nil)
//                }
//            }
            break
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
            getDeviceValueFor(function: function.function) { (result: Result<StillCapture.Format.Value, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .getExposureSettingsLock:
            getDeviceValueFor(function: function.function) { (result: Result<Exposure.SettingsLock.Status, Error>) in
                switch result {
                case .success(let value):
                    callback(nil, value as? T.ReturnType)
                case .failure(let error):
                    callback(error, nil)
                }
            }
        case .setExposureSettingsLock:

            // TODO: Check if same on Canon!
            // This may seem strange, that to move to standby we set this value twice, but this is what works!
            // It doesn't seem like we actually need the value at all, it just toggles it on this camera...
            sendSetDevicePropValue(
                PTP.DeviceProperty.Value(
                    Exposure.SettingsLock.Status.normal,
                    manufacturer: manufacturer
                ),
                valueB: true
            ) { [weak self] response in
                guard let self = self else { return }
                guard !response.code.isError else {
                    callback(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil, nil)
                    return
                }
                self.sendSetDevicePropValue(
                    PTP.DeviceProperty.Value(
                        Exposure.SettingsLock.Status.standby,
                        manufacturer: self.manufacturer
                    ),
                    valueB: true
                ) { innerResponse in
                    callback(innerResponse.code.isError ? PTPError.commandRequestFailed(innerResponse.code) : nil, nil)
                }
            }
            
        default:
            break
        }
    }

    /// Call to send set device prop value request to the camera.
    /// - Parameters:
    ///   - value: The value to set the prop to
    ///   - valueB: Used for Sony cameras, some props require using a different command code (setValueB rather than setValueA)
    ///   - callback: Closure to call when done
    func sendSetDevicePropValue(_ value: PTP.DeviceProperty.Value, valueB: Bool = false, retry: Int = 0, callback: CommandRequestPacketResponse? = nil) {

        // TODO: Implement default PTP/IP function for this (So far Sony and Canon are bespoke)
    }
    
    //MARK: - Camera protocol conformance -
    
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
                guard let self = self else { return }
                guard error == nil else {
                    retriableCompletion(error, false)
                    return
                }
                // Order is different here on Canon packet dump, calls `getDeviceInfo` and
                // THEN `startSession` but libgphoto2 seems to call in "wrong"
                // order (like we are) so we'll keep like this for now
                self.sendStartSessionPacket(completion: { [weak self] (startSessionError, transferMode) in
                    guard startSessionError == nil else {
                        retriableCompletion(startSessionError, false)
                        return
                    }
                    self?.performPostConnectCommands(completion: retriableCompletion)
                })
            })
        }, attempts: 3)
    }
    
    /// Perform any non-standard PTP IP Commands that should occur after connection
    /// has been established. By default this fetches initial event
    /// - Parameter completion: The closure to call when done
    func performPostConnectCommands(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        performInitialEventFetch(completion: completion)
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

        // TODO: Check if same logic on canon!
        sendSetDevicePropValue(
            PTP.DeviceProperty.Value(
                code: Exposure.Mode.Value.devicePropertyCode(for: manufacturer),
                type: Exposure.Mode.Value.dataType(for: manufacturer),
                value: mode.value(for: manufacturer)
            )
        ) { response in
            completion(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil)
        }
    }
    
    func setStillCaptureMode(_ mode: SonyStillCaptureMode, _ completion: @escaping ((Error?) -> Void)) {

        // TODO: Check if same logic on canon!
        sendSetDevicePropValue(
            PTP.DeviceProperty.Value(
                code: SonyStillCaptureMode.devicePropertyCode(for: manufacturer),
                type: SonyStillCaptureMode.dataType(for: manufacturer),
                value: mode.value(for: manufacturer)
            )
        ) { response in
            completion(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil)
        }
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

    typealias CaptureCompletion = (Result<URL?, Error>) -> Void

    func startLiveView(callback: @escaping (_ error: Error?) -> Void) {
        callback(nil)
    }

    /// Gets the current viewfinder image from the camera
    /// - Parameter callback: A closure called once the image has been fetched
    func getViewfinderImage(callback: @escaping (Result<Image, Error>) -> Void) {

    }

    func takePicture(completion: @escaping CaptureCompletion) {

        Logger.log(message: "Taking picture...", category: "SonyPTPIPCamera", level: .debug)
        os_log("Taking picture...", log: log, type: .debug)

        self.isAwaitingObject = true

        startCapturing { [weak self] (error) in

            guard let self = self else { return }
            if let error = error {
                self.isAwaitingObject = false
                completion(Result.failure(error))
                return
            }

            self.awaitFocusIfNeeded(completion: { [weak self] (objectId) in
                self?.cancelShutterPress(objectID: objectId, completion: completion)
            })
        }
    }

    func awaitFocusIfNeeded(completion: @escaping (_ objectId: DWord?) -> Void) {

        guard let focusMode = self.lastEvent?.focusMode?.current else {

            self.performFunction(Focus.Mode.get, payload: nil) { [weak self] (_, focusMode) in

                guard let self = self else {
                    return
                }

                guard focusMode?.isAutoFocus == true else {
                    completion(nil)
                    return
                }

                self.awaitFocus(completion: completion)
            }

            return
        }

        guard focusMode.isAutoFocus else {
            completion(nil)
            return
        }

        self.awaitFocus(completion: completion)
    }

    func startCapturing(completion: @escaping (Error?) -> Void) {

        Logger.log(message: "Starting capture...", category: "PTPIPCamera", level: .debug)
        os_log("Starting capture...", log: self.log, type: .debug)

        // TODO: Implement standard approach
    }

    func finishCapturing(awaitObjectId: Bool = true, completion: @escaping CaptureCompletion) {

        cancelShutterPress(objectID: nil, awaitObjectId: awaitObjectId, completion: completion)
    }

    func awaitFocus(completion: @escaping (_ objectId: DWord?) -> Void) {

        Logger.log(message: "Focus mode is AF variant awaiting focus...", category: "SonyPTPIPCamera", level: .debug)
        os_log("Focus mode is AF variant awaiting focus...", log: self.log, type: .debug)

        var newObject: DWord? = awaitingObjectId

        DispatchQueue.global().asyncWhile({ [weak self] (continueClosure) in

            guard let self = self else { return }

            // If code is property changed, and first variable == "Focus Found"
            if let lastEvent = self.lastEventPacket, lastEvent.code == .propertyChanged, lastEvent.variables?.first == 0xD213 {

                Logger.log(message: "Got property changed event and was \"Focus Found\", continuing with capture process", category: "SonyPTPIPCamera", level: .debug)
                os_log("Got property changed event and was \"Focus Found\", continuing with capture process", log: self.log, type: .debug)
                continueClosure(true)

            } else if let lastEvent = self.lastEventPacket, lastEvent.code == .objectAdded, let objectId = lastEvent.variables?.first {

                self.isAwaitingObject = false
                self.awaitingObjectId = nil
                Logger.log(message: "Got property changed event and was \"Object Added\", continuing with capture process", category: "SonyPTPIPCamera", level: .debug)
                os_log("Got property changed event and was \"Object Added\", continuing with capture process", log: self.log, type: .debug)
                newObject = objectId
                continueClosure(true)

            } else if let awaitingObjectId = self.awaitingObjectId {

                Logger.log(message: "Got object ID from elsewhere whilst awaiting focus", category: "SonyPTPIPCamera", level: .debug)
                os_log("Got object ID from elsewhere whilst awaiting focus", log: self.log, type: .debug)

                self.isAwaitingObject = false
                newObject = awaitingObjectId
                self.awaitingObjectId = nil
                continueClosure(true)

            } else {

                continueClosure(false)
            }

        }, timeout: 1) { [weak self] in

            guard let self = self else { return }

            Logger.log(message: "Focus awaited \(newObject != nil ? "\(newObject!)" : "null")", category: "SonyPTPIPCamera", level: .debug)
            os_log("Focus awaited %@", log: self.log, type: .debug, newObject != nil ? "\(newObject!)" : "null")

            let awaitingObjectId = self.awaitingObjectId
            self.awaitingObjectId = nil
            completion(newObject ?? awaitingObjectId)
        }
    }

    func cancelShutterPress(objectID: DWord?, awaitObjectId: Bool = true, completion: @escaping CaptureCompletion) {

        Logger.log(message: "Cancelling shutter press \(objectID != nil ? "\(objectID!)" : "null")", category: "SonyPTPIPCamera", level: .debug)
        os_log("Cancelling shutter press %@", log: self.log, type: .debug, objectID != nil ? "\(objectID!)" : "null")

        // TODO: Implement default PTP IP Approach
    }

    func awaitObjectId(completion: @escaping CaptureCompletion) {

        var newObject: DWord?

        // TODO: Check/implement on Canon

        Logger.log(message: "Awaiting Object ID", category: "SonyPTPIPCamera", level: .debug)
        os_log("Awaiting Object ID", log: self.log, type: .debug)

        // If we already have an awaitingObjectId! For some reason this isn't caught if we jump into asyncWhile...
        guard awaitingObjectId == nil else {

            awaitingObjectId = nil
            isAwaitingObject = false
            // If we've got an object ID successfully then we captured an image, and we can callback, it's not necessary to transfer image to carry on.
            // We will transfer the image when the event is received...
            completion(Result.success(nil))

            return
        }

        DispatchQueue.global().asyncWhile({ [weak self] (continueClosure) in

            guard let self = self else { return }

            if let lastEvent = self.lastEventPacket, lastEvent.code == .objectAdded {

                Logger.log(message: "Got property changed event and was \"Object Added\", continuing with capture process", category: "SonyPTPIPCamera", level: .debug)
                os_log("Got property changed event and was \"Object Added\", continuing with capture process", log: self.log, type: .debug)
                self.isAwaitingObject = false
                newObject = lastEvent.variables?.first ?? self.awaitingObjectId
                self.awaitingObjectId = nil
                continueClosure(true)
                return

            } else if let awaitingObjectId = self.awaitingObjectId {

                Logger.log(message: "\"Object Added\" event was intercepted elsewhere, continuing with capture process", category: "SonyPTPIPCamera", level: .debug)
                os_log("\"Object Added\" event was intercepted elsewhere, continuing with capture process", log: self.log, type: .debug)

                self.isAwaitingObject = false
                newObject = awaitingObjectId
                self.awaitingObjectId = nil
                continueClosure(true)
                return
            }

            Logger.log(message: "Getting device prop description for 'objectInMemory'", category: "SonyPTPIPCamera", level: .debug)
            os_log("Getting device prop description for 'objectInMemory'", log: self.log, type: .debug)

            self.getDevicePropDescriptionFor(propCode: .objectInMemory, callback: { (result) in

                Logger.log(message: "Got device prop description for 'objectInMemory'", category: "SonyPTPIPCamera", level: .debug)
                os_log("Got device prop description for 'objectInMemory'", log: self.log, type: .debug)

                switch result {
                case .failure(_):
                    continueClosure(false)
                case .success(let property):
                    // if prop 0xd215 > 0x8000, the object in RAM is available at location 0xffffc001
                    // This variable also turns to 1 , but downloading then will crash the firmware
                    // we seem to need to wait for 0x8000 (See https://github.com/gphoto/libgphoto2/blob/de98b151bce6b0aa70157d6c0ebb7f59b4da3792/camlibs/ptp2/library.c#L4330)
                    guard let value = property.currentValue.toInt, value >= 0x8000 else {
                        continueClosure(false)
                        return
                    }

                    Logger.log(message: "objectInMemory >= 0x8000, object in memory at 0xffffc001", category: "SonyPTPIPCamera", level: .debug)
                    os_log("objectInMemory >= 0x8000, object in memory at 0xffffc001", log: self.log, type: .debug)

                    self.isAwaitingObject = false
                    self.awaitingObjectId = nil
                    newObject = 0xffffc001
                    continueClosure(true)
                }
            })

        }, timeout: 35) { [weak self] in

            self?.awaitingObjectId = nil
            self?.isAwaitingObject = false

            guard newObject != nil else {
                completion(Result.failure(PTPError.objectNotFound))
                return
            }

            // If we've got an object ID successfully then we captured an image, and we can callback, it's not necessary to transfer image to carry on.
            // We will transfer the image when the event is received...
            completion(Result.success(nil))
        }
    }

    func handleObjectId(objectID: DWord, shootingMode: ShootingMode, completion: @escaping CaptureCompletion) {

        Logger.log(message: "Got object with id: \(objectID)", category: "SonyPTPIPCamera", level: .debug)
        os_log("Got object ID", log: log, type: .debug)

        ptpIPClient?.getObjectInfoFor(objectId: objectID, callback: { [weak self] (result) in

            guard let self = self else { return }

            switch result {
            case .success(let info):
                // Call completion as technically now ready to take an image!
                completion(Result.success(nil))
                self.getObjectWith(info: info, objectID: objectID, shootingMode: shootingMode, completion: completion)
            case .failure(_):
                // Doesn't really matter if this part fails, as image already taken
                completion(Result.success(nil))
            }
        })
    }

    private func getObjectWith(info: PTP.ObjectInfo, objectID: DWord, shootingMode: ShootingMode, completion: @escaping CaptureCompletion) {

        Logger.log(message: "Getting object of size: \(info.compressedSize) with id: \(objectID)", category: "SonyPTPIPCamera", level: .debug)
        os_log("Getting object", log: log, type: .debug)

        let packet = Packet.commandRequestPacket(
            code: .getPartialObject,
            arguments: [objectID, 0, info.compressedSize],
            transactionId: ptpIPClient?.getNextTransactionId() ?? 2
        )
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.handleObjectData(data.data, shootingMode: shootingMode, fileName: info.fileName ?? "\(ProcessInfo().globallyUniqueString).jpg")
            case .failure(let error):
                Logger.log(message: "Failed to get object: \(error.localizedDescription)", category: "SonyPTPIPCamera", level: .error)
                os_log("Failed to get object", log: self.log, type: .error)
            }
        })
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }

    private func handleObjectData(_ data: ByteBuffer, shootingMode: ShootingMode, fileName: String) {

        Logger.log(message: "Got object data!: \(data.length). Attempting to save as image", category: "SonyPTPIPCamera", level: .debug)
        os_log("Got object data! Attempting to save as image", log: self.log, type: .debug)

        // Check for a new object, in-case we missed the event for it!
        getDevicePropDescriptionFor(propCode: .objectInMemory, callback: { [weak self] (result) in

            guard let self = self else { return }

            switch result {
            case .failure(_):
                break
            case .success(let property):
                // if prop 0xd215 > 0x8000, the object in RAM is available at location 0xffffc001
                // This variable also turns to 1 , but downloading then will crash the firmware
                // we seem to need to wait for 0x8000 (See https://github.com/gphoto/libgphoto2/blob/de98b151bce6b0aa70157d6c0ebb7f59b4da3792/camlibs/ptp2/library.c#L4330)
                guard let value = property.currentValue.toInt, value >= 0x8000 else {
                    return
                }
                self.handleObjectId(objectID: 0xffffc001, shootingMode: shootingMode) { (_) in

                }
            }
        })

        let imageData = Data(data)
        guard Image(data: imageData) != nil else {
            Logger.log(message: "Image data not valid", category: "SonyPTPIPCamera", level: .error)
            os_log("Image data not valud", log: self.log, type: .error)
            return
        }

        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let imageURL = temporaryDirectoryURL.appendingPathComponent(fileName)
        do {
            try imageData.write(to: imageURL)
            imageURLs[shootingMode, default: []].append(imageURL)
            // Trigger dummy event
            onEventAvailable?(nil)
        } catch let error {
            Logger.log(message: "Failed to save image to disk: \(error.localizedDescription)", category: "SonyPTPIPCamera", level: .error)
            os_log("Failed to save image to disk", log: self.log, type: .error)
        }
    }
}
