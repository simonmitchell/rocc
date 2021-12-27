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
    
    override func performPostConnectCommands(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        
        guard deviceInfo?.supportedOperations.contains(.canonSetRemoteMode) == true else {
            setEventModeIfSupported(completion: completion)
            return
        }
        
        let packet = Packet.commandRequestPacket(
            code: .canonSetRemoteMode,
            arguments: [0x00000005], // TODO: Magic number.. for now! This is 0x00000015 on Canon EOS 400D, do we need to change?
            // Where do we find the correct value!?
            transactionId: ptpIPClient?.getNextTransactionId() ?? 1
        )

        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code), false)
                return
            }

            guard let self = self, self.deviceInfo?.supportedOperations.contains(.canonUnknownInitialisation) == true else {
                self?.setEventModeIfSupported(completion: completion)
                return
            }

            // This call might not be necessary, but we'll make it anyway
            let unknownInitPacket = Packet.commandRequestPacket(
                code: .canonUnknownInitialisation,
                arguments: [0x00000015],
                transactionId: self.ptpIPClient?.getNextTransactionId() ?? 2
            )

            self.ptpIPClient?.sendCommandRequestPacket(unknownInitPacket, callback: { [weak self] initResponse in
                self?.setEventModeIfSupported(completion: completion)
            })
        })
    }
    
    private func setEventModeIfSupported(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        
        guard deviceInfo?.supportedOperations.contains(.canonSetEventMode) == true else {
            performInitialEventFetch(completion: completion)
            return
        }
        
        let packet = Packet.commandRequestPacket(
            code: .canonSetEventMode,
            arguments: [0x00000001], // TODO: Magic number.. for now! EOS R sends this, EOS 400D sends 0x00000002?
            transactionId: ptpIPClient?.getNextTransactionId() ?? 2
        )
        
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code), false)
                return
            }
            self?.performInitialEventFetch(completion: completion)
        })
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
        valueB: Bool = false,
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
            callback?(response)
            guard let self = self else { return }
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

        // [TODO]:  Currently get notReady error when setting this when starting connection
        sendSetDevicePropValue(
            .init(
                code: .EVFOutputDeviceCanonEOS,
                type: .uint32,
                value: DWord(2)
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

        DispatchQueue.global().asyncWhile({ [weak self] continueClosure in

                guard let self = self else { return }

                // TODO: [Canon] Get EOS events until queue empty!
                self.flushEventStream { [weak self] eventResult in
                    guard let self = self else {
                        tries -= 1
                        continueClosure(true)
                        return
                    }
                    switch eventResult {
                    case .success(let canonEvents):

                        // Notifiy event handler of latest events!
                        let events = self.handleLatestEvents(canonEvents)
                        self.onEventAvailable?(events)

                        let getViewFinderCommand = Packet.commandRequestPacket(
                            code: .canonEOSGetViewFinderData,
                            arguments: [0x00002000, 0x01000000, 0x00000000], // As seen on Canon EOS 4000D
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
                                case .deviceBusy, .nikon_notReady:
                                    // TODO: May not be necessary once we've got this working?
                                    usleep(1300)
                                    continueClosure(tries > 0 ? false : true)
                                default:
                                    // Break the loop if it wasn't a deviceBusy or notReady code
                                    continueClosure(true)
                                }
                            }
                        })
                        self.ptpIPClient?.sendCommandRequestPacket(getViewFinderCommand, callback: nil)

                    case .failure(_):
                        continueClosure(false)
                    }
                }
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
