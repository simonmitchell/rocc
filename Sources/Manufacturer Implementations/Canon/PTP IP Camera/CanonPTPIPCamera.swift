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

    override var eventPollingMode: PollingMode {
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

        // EOS 400D sends 0x902f at this point, with value of 0x00000002 but this doesn't seem to be necessary?
        
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code), false)
                return
            }
            self?.setEventModeIfSupported(completion: completion)
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

                let getEventPacket = Packet.commandRequestPacket(
                    code: .canonGetEvent,
                    arguments: nil,
                    transactionId: ptpIPClient?.getNextTransactionId() ?? 4,
                    dataPhaseInfo: 0x00000001
                )

                ptpIPClient?.awaitDataFor(transactionId: getEventPacket.transactionId, callback: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let data):
                        do {
                            var events = try CanonPTPEvents(data: data.data)

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
                            self.lastEventChanges = events
                            callback(nil, event as? T.ReturnType)
                        } catch {
                            callback(error, nil)
                        }
                    case .failure(let error):
                        Logger.log(message: "Failed to get event data: \(error.localizedDescription)", category: "CanonPTPIPCamera")
                    }
                })

                ptpIPClient?.sendCommandRequestPacket(getEventPacket, callback: nil)

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

    // TODO: YOU WERE HERE SIMON!
//    getDe
}
