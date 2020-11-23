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
            arguments: [0x00000005], // TODO: Magic number.. for now!
            transactionId: ptpIPClient?.getNextTransactionId() ?? 1
        )
        
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
            arguments: [0x00000001], // TODO: Magic number.. for now!
            transactionId: ptpIPClient?.getNextTransactionId() ?? 2
        )
        
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed(response.code), false)
                return
            }
            completion(nil, false)
            //TODO: Get initial event!
        })
    }
}
