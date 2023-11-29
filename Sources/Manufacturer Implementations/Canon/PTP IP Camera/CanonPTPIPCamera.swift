//
//  CanonPTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

internal final class CanonPTPIPCamera: PTPIPCamera {

    /// The last set of `CanonPTPEvent`s that we received from the camera
    /// retained because we don't receive a full list of events each time
    /// we fetch to to maintain the same eventing mechanism as other models
    /// we need to retain this and just update it with incoming events!
    var lastEventChanges: CanonPTPEvents?
        
    // TODO: Remove if we don't need
    override var ptpIPClient: PTPIPClient? {
        get {
            let client = super.ptpIPClient
            client?.sendSynchronously = true
            return client
        } set {
            super.ptpIPClient = newValue
        }
    }

    override var eventPollingMode: EventPollingMode {
        // We manually trigger event fetches on Canon, or manually pass events back to caller!
        return .cameraDriven
    }
    
    required init(dictionary: [AnyHashable : Any]) throws {
        
        do {
            try super.init(dictionary: dictionary)
        } catch let error {
            throw error
        }
        
        // Seems on Canon cameras this actually reflects the model of camera
        let _name = dictionary["modelName"] as? String
        let _modelEnum: Canon.Camera.Model?
        if let _name = _name {
            _modelEnum = Canon.Camera.Model(rawValue: _name)
        } else {
            _modelEnum = nil
        }
                
        name = _modelEnum?.friendlyName ?? _name
        model = _modelEnum
    }
    
    var isCanonEOSMLikeFirmware: Bool {
        guard let deviceInfo = deviceInfo else { return false }
        guard deviceInfo.supportedOperations.contains(.canonSetRemoteMode) else {
            return false
        }
        guard let model = deviceInfo.model else {
            return false
        }
        if model.starts(with: "Canon EOS M") {
            return true
        }
        
        return (model.starts(with: "Canon PowerShot SX") ||
            model.starts(with: "Canon PowerShot G") ||
            model.starts(with: "Canon Digital IXUS")) && deviceInfo.supportedOperations.contains(.canonRemoteReleaseOn)
    }
    
    override func performPostConnectCommands(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        
        // 1. https://github.com/gphoto/libgphoto2/blob/af2a91f82eb6b5acedc0ea04dd15b0fd1906c14a/camlibs/ptp2/library.c#L9726
        initialise { [weak self] error in
            guard let self = self, error == nil else {
                completion(error, false)
                return
            }
            // 2. https://github.com/gphoto/libgphoto2/blob/aecbc5d45577a94a1ce7ed1bbc47c90a3aba4704/camlibs/ptp2/config.c#L374
            prepareForCapture { error in
                completion(error, false)
            }
        }
    }
    
    override func deviceSpecificOpCode(for code: PTP.CommandCode) -> PTP.CommandCode {
        switch code {
        case .getStorageIds:
            return .canonGetStorageIDs
        default:
            return code
        }
    }
    
    private func initialise(completion: @escaping (Error?) -> Void) {
        
        // getDeviceInfo already called during connection process prior to this
        
        guard deviceInfo?.supportedOperations.contains(.canonSetRemoteMode) == true else {
            initialiseFileSystem(completion: completion)
            return
        }
        
        // Calculate mode based on device model.
        // Also for EOS M and newer we use 0x15 and have to re-call ptp_getdeviceinfo because it changes when call canonSetRemoteMode
        
        var remoteMode: DWord = 1
        if isCanonEOSMLikeFirmware {
            remoteMode = 0x15
            switch deviceInfo?.model {
            case "Canon EOS M6 Mark II":
                remoteMode = 0x1
            case "Canon PowerShot SX540 HS", "Canon PowerShot SX720 HS", "Canon PowerShot G5 X":
                remoteMode = 0x11
                break
            default:
                break
            }
        }
        
        let packet = Packet.commandRequestPacket(
            code: .canonSetRemoteMode,
            arguments: [remoteMode],
            transactionId: ptpIPClient?.getNextTransactionId() ?? 1
        )

        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code))
                return
            }
            
            guard let self = self else { return }
            
            if isCanonEOSMLikeFirmware {
                getDeviceInfo { [weak self] deviceInfoResult in
                    guard let self = self else { return }
                    switch deviceInfoResult {
                    case .success:
                        initialiseFileSystem(completion: completion)
                    case .failure(let failure):
                        completion(failure)
                    }
                }
            } else {
                initialiseFileSystem(completion: completion)
            }
        })
    }
    
    private func prepareForCapture(completion: @escaping (Error?) -> Void) {
        
        guard deviceInfo?.supportedOperations.contains(.canonSetRemoteMode) == true else {
            setEventModeIfSupported(completion: completion)
            return
        }
        
        // Calculate mode based on device model.
        
        var remoteMode: DWord = deviceInfo?.model == "Canon EOS 4000D" ? 0x15 : 1
        if isCanonEOSMLikeFirmware {
            remoteMode = 0x15
            switch deviceInfo?.model {
            case "Canon EOS M6 Mark II":
                remoteMode = 0x1
            case "Canon PowerShot SX540 HS", "Canon PowerShot SX720 HS", "Canon PowerShot G5 X":
                remoteMode = 0x11
                break
            default:
                break
            }
        }
        
        let packet = Packet.commandRequestPacket(
            code: .canonSetRemoteMode,
            arguments: [remoteMode],
            transactionId: ptpIPClient?.getNextTransactionId() ?? 1
        )

        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code))
                return
            }
            
            guard let self = self else { return }
            
            // This call might not be necessary, but we'll make it anyway
            self.keepAlive { [weak self] _ in
                guard let self else { return }
                setEventModeIfSupported(completion: { [weak self] error in
                    guard let self else { return }
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    
                    sendSetDevicePropValue(
                        .init(
                            code: .EVFOutputDeviceCanonEOS,
                        type: .uint32,
                        value: DWord(8)
                    )) { retry in
                        return Double(retry + 1) * 0.75
                    } callback: { packet in
                        if response.code.isError {
                            completion(PTPError.commandRequestFailed(response.code))
                        } else {
                            completion(nil)
                        }
                    }
                })
            }
        })
    }
    
    func keepAlive(completion: @escaping (Error?) -> Void) {
        guard deviceInfo?.supportedOperations.contains(.canonKeepAlive) == true else {
            return
        }
        let keepAlivePacket = Packet.commandRequestPacket(
            code: .canonKeepAlive,
            arguments: nil,
            transactionId: self.ptpIPClient?.getNextTransactionId() ?? 2
        )
        
        self.ptpIPClient?.sendCommandRequestPacket(keepAlivePacket) { response in
            completion(response.code.isError ? PTPError.commandRequestFailed(response.code) : nil)
        }
    }
    
    private func setEventModeIfSupported(completion: @escaping (Error?) -> Void) {
        
        // TODO: Seperate out all this logic!
        let eventFetchCompletion: (Error?) -> Void = { [weak self] error in
            guard let self, error == nil else {
                completion(error)
                return
            }
            
            getDeviceMetadata { [weak self] in
                guard let self else { return }
                
                // TODO: If GetDeviceInfoEx supported, do it before awaitPropExists
                
                awaitPropExists(completion: { [weak self] in
                    
                    // Maybe? camera_canon_eos_update_capture_target: https://github.com/gphoto/libgphoto2/blob/aecbc5d45577a94a1ce7ed1bbc47c90a3aba4704/camlibs/ptp2/config.c#L286
                    
                    guard let self else { return }
                    
                    getDeviceInfo { [weak self] result in
                        
                        guard let self else { return }
                        
                        switch result {
                        case .success:
                            getStorageIds(completion: { [weak self] result in
                                
                                guard let self else {
                                    return
                                }
                                
                                switch result {
                                case .success(let success):
                                    guard let firstStorageId = success.first else {
                                        performInitialEventFetch { error, transferMode in
                                            // TODO: [Next] ptp_canon_eos_setdevicepropvalue EVFOutputDeviceCanonEOS with retry after x seconds
                                            completion(error)
                                        }
                                        return
                                    }
                                    getStorageInfo(
                                        storageId: firstStorageId
                                    ) { [weak self] error in
                                        
                                        guard let self, error == nil else {
                                            completion(error)
                                            return
                                        }
                                                                   
                                        performInitialEventFetch { error, transferMode in
                                            // TODO: [Next] ptp_canon_eos_setdevicepropvalue EVFOutputDeviceCanonEOS with retry after x seconds
                                            completion(error)
                                        }
                                    }

                                case .failure(let failure):
                                    completion(failure)
                                }
                            })
                        case .failure(let failure):
                            completion(failure)
                        }
                    }
                    
                    
                }, code: .EVFOutputDeviceCanonEOS)
                
                
            }
        }
        
        guard deviceInfo?.supportedOperations.contains(.canonSetEventMode) == true else {
            performInitialEventFetch { error, _ in
                eventFetchCompletion(error)
            }
            return
        }
        
        // libgphoto2 does this after all of the above, but can we do it here instead? Only time will tell!
        let packet = Packet.commandRequestPacket(
            code: .canonSetEventMode,
            arguments: [
                deviceInfo?.supportedEventCodes.contains(.requestGetEvent) == true ?
                0x00000002 : 0x00000001],
            transactionId: ptpIPClient?.getNextTransactionId() ?? 2
        )
        
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code))
                return
            }
            // TODO: Potentiatlly add SetRequestOLCInfoGroup if supported
            self?.performInitialEventFetch { error, _ in
                eventFetchCompletion(error)
            }
        })
    }
    
    private func awaitPropExists(
        completion: @escaping () -> Void,
        code: PTP.DeviceProperty.Code,
        retries: Int = 10,
        attempt: Int = 1
    ) {
        flushEventStream { [weak self] events in
            guard let self else {
                completion()
                return
            }
            guard !propExists(for: code), attempt <= retries else {
                completion()
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.awaitPropExists(
                    completion: completion,
                    code: code,
                    attempt: attempt + 1
                )
            }
        }
    }
    
    private func propExists(for code: PTP.DeviceProperty.Code) -> Bool {
        return lastEventChanges?.events.contains(where: { event in
            (event as? CanonPTPPropValueChange)?.code == code
        }) ?? false
    }
    
    private func getDeviceMetadata(completion: @escaping () -> Void) {
        // TODO: Get Owner, artist, copyright, serial number. Don't return error
        completion()
    }
        
    private func performPostListFolderInit(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        performInitialEventFetch(completion: { [weak self] error, transferMode in
            guard error == nil else {
                completion(error, transferMode)
                return
            }
            self?.getDeviceInfo { result in
                switch result {
                case .success(let deviceInfo):
                    completion(nil, transferMode)
                case .failure(let error):
                    completion(error, transferMode)
                }
            }
        })
    }
    
    internal override func listFolder(
        storageId: DWord?,
        handle: DWord?,
        completion: @escaping (Error?) -> Void
    ) {
        var handle = handle ?? 0
                
        if handle != 0 && handle != 0xffffffff {
            //ptp_object_want (params, handle, PTPOBJECT_OBJECTINFO_LOADED, &ob);
            return
        }
    
        guard let storageId else {
            handle = 0xffffffff
            getStorageIds { [weak self] response in
                switch response {
                case .success(let success):
                    self?.getObjectInfoEx(for: success, handle: handle) { error in
                        completion(error)
                    }
                case .failure(let failure):
                    completion(failure)
                }
            }
            return
        }
        
        getObjectInfoEx(for: [storageId], handle: handle) { error in
            completion(error)
        }
    }
    
    private func getObjectInfoEx(
        for storageIds: [DWord],
        handle: DWord,
        completion: @escaping (Error?) -> Void
    ) {
        storageIds.asyncForEach { element in
            try await withCheckedThrowingContinuation { continuation in
                
                guard element & 0xffff != 0 else {
                    // TODO: Log skipping invalid storage
                    continuation.resume(returning: Void())
                    return
                }
                
                self.getObjectInfoEx(
                    for: element,
                    handle: handle
                ) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: Void())
                    }
                }
            }
        } done: { error in
            completion(error)
        }
    }
    
    private func getObjectInfoEx(
        for storageId: DWord,
        handle: DWord,
        completion: @escaping (Error?) -> Void
    ) {
        let packet = Packet.commandRequestPacket(
            code: .canonGetObjectInfoEx,
            arguments: [storageId, handle, 0x1000000],
            transactionId: ptpIPClient?.getNextTransactionId() ?? 6
        )
        
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { result in
            switch result {
            case .success(_):
                // TODO: Parse data
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
        
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
    
    func getStorageInfo(storageId: DWord, completion: @escaping (Error?) -> Void) {
        
        let packet = Packet.commandRequestPacket(
            code: .canonGetStorageInfo,
            arguments: [storageId],
            transactionId: ptpIPClient?.getNextTransactionId() ?? 5
        )
        
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
        
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }

    override func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {

        switch function.function {
        case .getEvent:

            guard !imageURLs.isEmpty, var lastEvent = lastEvent else {

                flushEventStream { [weak self] result in

                    guard let self = self else { return }
                    switch result {
                    case .success(let events):
                        let event = self.handleLatestEvents(events)
                        callback(nil, event as? T.ReturnType)
                    case .failure(let error):
                        Logger.log(message: "Failed to get event data: \(error.localizedDescription)", category: "CanonPTPIPCamera")
                    }
                }

                return
            }

            lastEvent.postViewPictureURLs = self.imageURLs.compactMapValues({ (urls) -> [(postView: URL, thumbnail: URL?)]? in
                return urls.map({ ($0, nil) })
            })
            imageURLs = [:]
            callback(nil, lastEvent as? T.ReturnType)
        case .cancelHalfPressShutter, .halfPressShutter:
            // TODO: See if this exists/how this works for Canon
            // for now, disable so we can get past this point of connection
            callback(nil, nil)
        case .ping:
            keepAlive { error in
                callback(error, nil)
            }
        default:
            super.performFunction(function, payload: payload, callback: callback)
        }
    }

    func handleLatestEvents(_ canonEvents: CanonPTPEvents) -> CameraEvent {

        var events = canonEvents

        if let lastEvents = self.lastEventChanges {
            var lastEventEvents = lastEvents.events
            events.events.forEach { event in
                // If the property is already present in received properties,
                // just directly replace it
                if let existingIndex = lastEventEvents.firstIndex(where: { existingEvent in
                    // Quick check for performance!
                    guard type(of: existingEvent) == type(of: event) else {
                        return false
                    }
                    switch (existingEvent, event) {
                    // TODO: See if we can make this more generic! Perhaps add `code` param to protocol so can compare using that?
                    case (let existingPropChange as CanonPTPPropValueChange, let newPropChange as CanonPTPPropValueChange):
                        return existingPropChange.code == newPropChange.code
                    case (let existingAvailableValsPropChange as CanonPTPAvailableValuesChange, let newAvailableValsPropChange as CanonPTPAvailableValuesChange):
                        return existingAvailableValsPropChange.code == newAvailableValsPropChange.code
                    default: return false
                    }
                }) {
                    lastEventEvents[existingIndex] = event
                } else { // Otherwise append it to the array
                    lastEventEvents.append(event)
                }
            }
            events = CanonPTPEvents(events: lastEventEvents)
        }

        var event = CameraEvent.fromCanonPTPEvents(events)
        // TODO: [Canon] Remove print statement!
        print("Gotcanon events!", events)
        event.postViewPictureURLs = self.imageURLs.compactMapValues({ (urls) -> [(postView: URL, thumbnail: URL?)]? in
            return urls.map({ ($0, nil) })
        })
        self.imageURLs = [:]
        self.lastEvent = event
        self.lastEventChanges = events

        return event
    }

    /// Flushes the canon event stream by recursively calling .canonGetEvent
    /// until the camera returns an empty array of events
    /// - Parameters:
    ///   - completion: Closure called when we've flushed the queue
    ///   - previous: Events fetched on previous recursion
    func flushEventStream(completion: @escaping (Result<CanonPTPEvents, Error>) -> Void, previous: CanonPTPEvents? = nil) {

        let getEventPacket = Packet.commandRequestPacket(
            code: .canonGetEvent,
            arguments: nil,
            transactionId: ptpIPClient?.getNextTransactionId() ?? 4,
            dataPhaseInfo: 0x00000001
        )

        ptpIPClient?.awaitDataFor(transactionId: getEventPacket.transactionId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let events = try CanonPTPEvents(data: data.data)
                    var nextEvents = events.events
                    if let previous = previous {
                        nextEvents.append(contentsOf: previous.events)
                    }
                    let nextCanonEvents = CanonPTPEvents(events: nextEvents)
                    // Must be some better way to check we're flushed fully?
                    if events.events.isEmpty {
                        completion(.success(nextCanonEvents))
                        // Notifiy event handler of latest events!
                        let returnEvents = self.handleLatestEvents(events)
                        self.onEventAvailable?(returnEvents)
                    } else {
                        self.flushEventStream(completion: completion, previous: nextCanonEvents)
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }

        ptpIPClient?.sendCommandRequestPacket(getEventPacket, callback: nil)
    }

    override func disconnect(completion: @escaping PTPIPCamera.DisconnectedCompletion) {
//        https://github.com/gphoto/libgphoto2/blob/33372d3e2bcfafd0eea1ae2f8981a2bbb1a878d6/camlibs/ptp2/library.c#L3061
        super.disconnect(completion: completion)
    }

    override func sendSetDevicePropValue(
        _ value: PTP.DeviceProperty.Value,
        retryDurationProvider: @escaping (Int) -> TimeInterval = { _ in return 0.0013 },
        valueB: Bool = false,
        retry: Int = 0,
        callback: CommandRequestPacketResponse? = nil
    ) {
        
        // TODO: [Canon] Write test that covers this!
        var data = ByteBuffer()
        // Insert a Word at start, which we'll populate later with the length of `data`
        data.append(DWord(0x00000000))
        data.append(value.code.rawValue)
        data.appendValue(value.value, ofType: value.type)
        // Replace the empty Word at start of data with the length of data
        data[dWord: 0] = DWord(data.length)

        let transactionID = ptpIPClient?.getNextTransactionId() ?? 2
        let opRequestPacket = Packet.commandRequestPacket(
            code: .canonSetDevicePropValueEx,
            arguments: nil,
            transactionId: transactionID,
            dataPhaseInfo: 0x00000002
        )
        let dataPackets = Packet.dataSendPackets(data: data, transactionId: transactionID)

        ptpIPClient?.sendCommandRequestPacket(opRequestPacket, callback: { [weak self] response in
            
            guard let self = self else { return }
            
            if response.code == .deviceBusy, retry < 3 {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + retryDurationProvider(retry)) { [weak self] in
                    guard let self else { return }
                    sendSetDevicePropValue(
                        value,
                        retryDurationProvider: retryDurationProvider,
                        valueB: valueB,
                        retry: retry + 1,
                        callback: callback
                    )
                }
                
            } else {
                callback?(response)
            }
            
            guard response.code == .okay else { return }
            guard let lastEvents = self.lastEventChanges else {
                self.onEventAvailable?(nil)
                return
            }
            // We need to update self.lastEventChanges here and trigger an event
            // manually because the camera doesn't seem to let us know the property has changed, so we
            // may have to manually update the caller of this API. We do this in code rather than
            // asking the device for a new event ☺️
            let valueChanged = CanonPTPPropValueChange(code: value.code, value: value.value)
            var events = lastEvents.events
            if let existingIndex = events.firstIndex(where: { event in
                return (event as? CanonPTPPropValueChange)?.code == valueChanged.code
            }) {
                events[existingIndex] = valueChanged
            } else {
                events.append(valueChanged)
            }
            let ptpEvents = CanonPTPEvents(events: events)
            let event = CameraEvent.fromCanonPTPEvents(ptpEvents)
            self.lastEventChanges = ptpEvents
            self.onEventAvailable?(event)
        })
        dataPackets.forEach { [weak self] dataPacket in
            self?.ptpIPClient?.sendControlPacket(dataPacket)
        }
    }

    override func propCodesFor(function: _CameraFunction) -> Set<PTP.DeviceProperty.Code>? {
        // TODO: [Canon] Override these for Canon specific prop codes!
        let propCodes: Set<PTP.DeviceProperty.Code>
        switch function {
        case .getISO, .setISO:
            propCodes = [.ISOSpeedCanon, .ISOSpeedCanonEOS]
        default:
            return super.propCodesFor(function: function)
        }
        // Some Canon cameras use EOS prop codes, some don't so we'll cross-reference with deviceInfo.supportedCodes if available!
        if let supportedDeviceProps = deviceInfo?.supportedDeviceProperties {
            return propCodes.intersection(supportedDeviceProps)
        }
        // Otherwise fall back to all the available prop codes, which is a bit nasty
        // but should work possibly?
        return propCodes
    }

    override func startLiveView(callback: @escaping (Error?) -> Void) {
        sendSetDevicePropValue(
            .init(
                code: .EVFOutputDeviceCanonEOS,
                type: .uint32,
                value: DWord(8)
            )
        ) { response in
            if response.code.isError {
                callback(PTPError.commandRequestFailed(response.code))
            } else {
                callback(nil)
            }
        }
    }

    override func getViewfinderImage(callback: @escaping (Result<Image, Error>) -> Void) {

        guard deviceInfo?.supportedOperations.contains(.canonEOSGetViewFinderData) == true else {
            callback(.failure(PTPError.operationNotSupported))
            return
        }

        // TODO: [Canon] Important, set EVFOutputDeviceCanonEOS if not already set to correct value (0x08000000)

        // Canon cameras can return "not ready" when trying to fetch live view image,
        // based on the logic [libgphoto2](https://github.com/gphoto/libgphoto2/blob/33372d3e2bcfafd0eea1ae2f8981a2bbb1a878d6/camlibs/ptp2/library.c#L3355) provide, we try and implement something similar!

        var liveViewData: PTPIPClient.DataContainer?
        // Try maximum of 150 times
        var tries: Int = 150
        
        // Get EOS events until queue empty!
        flushEventStream { [weak self] eventResult in
            
            guard let self else { return }
            
            switch eventResult {
            case .success:
                
                DispatchQueue.global().asyncWhile({ [weak self] continueClosure in

                    guard let self = self else { return }
                        
                    let getViewFinderCommand = Packet.commandRequestPacket(
                        code: .canonEOSGetViewFinderData,
                        arguments: [0x00200000, 0x00000001, 0x00000000], // As seen on Canon EOS 4000D
                        transactionId: self.ptpIPClient?.getNextTransactionId() ?? 1
                    )
                    self.ptpIPClient?.awaitDataFor(transactionId: getViewFinderCommand.transactionId, callback: { result in
                        defer {
                            tries -= 1
                        }
                        switch result {
                        case .success(let data):
                            liveViewData = data
                        case .failure(let error):
                            var responseCode: CommandResponsePacket.Code?
                            switch error {
                            case let commandResponse as CommandResponsePacket.Code:
                                responseCode = commandResponse
                            case let ptpError as PTPError:
                                if case .commandRequestFailed(let code) = ptpError {
                                    responseCode = code
                                }
                            default:
                                break
                            }
                            guard let responseCode = responseCode else {
                                callback(.failure(error))
                                // Break the loop if it wasn't a PTPError
                                continueClosure(true)
                                return
                            }
                            switch responseCode {
                            // According to libgphoto2 we also need to check 0xa102 which
                            // we have as nikon_notReady case
                            case .deviceBusy, .notReady:
                                continueClosure(tries > 0 ? false : true)
                            default:
                                // Break the loop if it wasn't a deviceBusy or notReady code
                                continueClosure(true)
                            }
                        }
                    })
                    self.ptpIPClient?.sendCommandRequestPacket(getViewFinderCommand, callback: nil)
                    },
                    timeout: 3
                ) {

                    guard let liveViewData = liveViewData else {
                        callback(.failure(PTPError.commandRequestFailed(.deviceBusy)))
                        return
                    }

                    guard let image = try? self.parseLiveViewData(liveViewData.data) else {
                        callback(.failure(PTPError.operationNotSupported))
                        return
                    }
                    callback(.success(image))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }

        
    }

    private func parseLiveViewData(_ data: ByteBuffer) throws -> Image? {

        var offset: UInt = 0
        var imageData: Data = Data()
        let liveViewData = Data(data.bytes.compactMap({ $0 }))
        while offset < data.length - 1 {

            guard let length: DWord = data.read(offset: &offset),
                  let type: DWord = data.read(offset: &offset) else {
                break
            }

            switch type {
            case 9, 1, 11:
                if length > (UInt(data.length) - offset) {
                    break
                }
                let dataEndIndex = offset + UInt(length) - UInt(MemoryLayout<DWord>.size * 2)
                imageData.append(liveViewData[offset..<dataEndIndex])

                // dump the rest of the blobs
                break
            default:
                if length > (UInt(data.length) - offset) {
                    break
                }
                offset = offset + UInt(length) - UInt(MemoryLayout<DWord>.size * 2)
            }
        }

        return Image(data: imageData)
    }
}
