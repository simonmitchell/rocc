//
//  SonyPTPIPCamera+Zoom.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/02/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension Zoom.Direction {
    
    var value: PTPDevicePropertyDataType {
        switch self {
        case .in:
            return Byte(0x01)
        default:
            return Byte(0xff)
        }
    }
}

extension SonyPTPIPDevice {
    
    func startZooming(direction: Zoom.Direction, callback: @escaping (Error?) -> Void) {
        
        guard direction != zoomingDirection else {
            callback(nil)
            return
        }
        
        zoomingDirection = direction
        
        ptpIPClient?.sendSetControlDeviceBValue(
            PTP.DeviceProperty.Value(
                code: .performZoom,
                type: .uint8,
                value: direction.value
            ),
            callback: { (response) in
                if response.code.isError {
                    callback(PTPError.commandRequestFailed(response.code))
                } else {
                    callback(nil)
                }
            }
        )
    }
    
    func stopZooming(callback: @escaping (Error?) -> Void) {
        
        guard let ptpIPClient = ptpIPClient else { return }
        
        // Simple, this will just mean on the next zoom completion, we'll stop hitting the camera to zoom
        zoomingDirection = nil
        
        // Seems like to stop zooming we send `setControlDeviceBValue` but don't send any data afterwards!
        let transactionID = ptpIPClient.getNextTransactionId()
        
        let opRequestPacket = Packet.commandRequestPacket(code: .setControlDeviceB, arguments: [DWord(PTP.DeviceProperty.Code.performZoom.rawValue)], transactionId: transactionID, dataPhaseInfo: 2)
        
        ptpIPClient.sendCommandRequestPacket(
            opRequestPacket,
            callback: { (response) in
                if response.code.isError {
                    callback(PTPError.commandRequestFailed(response.code))
                } else {
                    callback(nil)
                }
            },
            callCallbackForAnyResponse: true
        )
    }
}
