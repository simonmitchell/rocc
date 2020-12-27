//
//  PTPIPClient+DeviceProps.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension PTPIPClient {
    
    typealias DevicePropertyDescriptionCompletion = (_ result: Result<PTPDeviceProperty, Error>) -> Void
    
    typealias AllDevicePropertyDescriptionsCompletion = (_ result: Result<[PTPDeviceProperty], Error>) -> Void
    
    func getDevicePropDescFor(propCode: PTP.DeviceProperty.Code,  callback: @escaping DevicePropertyDescriptionCompletion) {
        
        let packet = Packet.commandRequestPacket(code: .getDevicePropDesc, arguments: [DWord(propCode.rawValue)], transactionId: getNextTransactionId())
        awaitDataFor(transactionId: packet.transactionId) { (dataResult) in
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
        sendCommandRequestPacket(packet, callback: nil)
    }

    /// Gets all device prop desc data from the camera
    /// - Parameters:
    ///   - callback: A closure called when the request has completed
    ///   - partial: Whether to only fetch the props which have changed since last calling, this
    ///   should be used with eventing mechanism!
    func getAllDevicePropDesc(
        callback: @escaping AllDevicePropertyDescriptionsCompletion,
        partial: Bool = false
    ) {
        
        let packet = Packet.commandRequestPacket(code: .getAllDevicePropData, arguments: [partial ? 1 : 0], transactionId: getNextTransactionId())
        awaitDataFor(transactionId: packet.transactionId, callback: { (dataResult) in
            
            switch dataResult {
            case .success(let data):
                guard let numberOfProperties = data.data[qWord: 0] else { return }
                var offset: UInt = UInt(MemoryLayout<QWord>.size)
                var properties: [PTPDeviceProperty] = []
                for _ in 0..<numberOfProperties {
                    guard let property = data.data.getDeviceProperty(at: offset) else {
                        break
                    }
                    properties.append(property)
                    offset += property.length
                }
                callback(Result.success(properties))
            case .failure(let error):
                callback(Result.failure(error))
            }
        })
        sendCommandRequestPacket(packet, callback: nil)
    }
}
