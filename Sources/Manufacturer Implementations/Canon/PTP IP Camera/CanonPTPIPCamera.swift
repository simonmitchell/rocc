//
//  CanonPTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

internal final class CanonPTPIPCamera: PTPIPCamera {
    
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

        // EOS 400D sends 0x902f at this point, with value of 0x00000002 but this doesn't seem to be necessary!
        
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
            //TODO: Get initial event!
            completion(nil, false)
            return
        }
        
        let packet = Packet.commandRequestPacket(
            code: .canonSetEventMode,
            arguments: [0x00000001], // TODO: Magic number.. for now! EOS R sends this, EOS 400D sends 0x00000003?
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
                // TODO: Implement - Get first event from camera

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
                            let events = try CanonPTPEvents(data: data.data)
                            var event = CameraEvent.fromCanonPTPEvents(events)
                            print("Gotcanon events!", events)
                            event.postViewPictureURLs = self.imageURLs.compactMapValues({ (urls) -> [(postView: URL, thumbnail: URL?)]? in
                                return urls.map({ ($0, nil) })
                            })
                            self.imageURLs = [:]
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
}
