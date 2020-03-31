//
//  SonyPTPIPCamera+TakePicture.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/01/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

extension SonyPTPIPDevice {
    
    typealias CaptureCompletion = (Result<URL?, Error>) -> Void
    
    func takePicture(completion: @escaping CaptureCompletion) {
        
        Logger.log(message: "Taking picture...", category: "SonyPTPIPCamera")
        os_log("Taking picture...", log: log, type: .debug)
        
        startCapturing { [weak self] (error) in
            
            guard let self = self else { return }
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            self.awaitFocusIfNeeded(completion: { [weak self] (objectId) in
                self?.cancelShutterPress(objectID: objectId, completion: completion)
            }, setAwaitingObject: true)
        }
    }
    
    func awaitFocusIfNeeded(completion: @escaping (_ objectId: DWord?) -> Void, setAwaitingObject: Bool = false) {
        
        guard let focusMode = self.lastEvent?.focusMode?.current else {
            
            self.performFunction(Focus.Mode.get, payload: nil) { [weak self] (_, focusMode) in
            
                guard let self = self else {
                    return
                }
                
                guard focusMode?.isAutoFocus == true else {
                    if setAwaitingObject {
                        self.isAwaitingObject = true
                    }
                    completion(nil)
                    return
                }
                
                self.awaitFocus(completion: completion)
            }
            
            return
        }
        
        guard focusMode.isAutoFocus else {
            if setAwaitingObject {
                self.isAwaitingObject = true
            }
            completion(nil)
            return
        }
        
        self.awaitFocus(completion: completion)
    }
 
    func startCapturing(completion: @escaping (Error?) -> Void) {
        
        Logger.log(message: "Starting capture...", category: "SonyPTPIPCamera")
        os_log("Starting capture...", log: self.log, type: .debug)
        
        ptpIPClient?.sendSetControlDeviceBValue(
            PTP.DeviceProperty.Value(
                code: .autoFocus,
                type: .uint16,
                value: Word(2)
            ),
            callback: { [weak self] (_) in
                
                guard let self = self else { return }
                
                self.ptpIPClient?.sendSetControlDeviceBValue(
                    PTP.DeviceProperty.Value(
                        code: .capture,
                        type: .uint16,
                        value: Word(2)
                    ),
                    callback: { (shutterResponse) in
                        guard !shutterResponse.code.isError else {
                            completion(PTPError.commandRequestFailed(shutterResponse.code))
                            return
                        }
                        completion(nil)
                    }
                )
            }
        )
    }
    
    func finishCapturing(completion: @escaping CaptureCompletion) {
        
        cancelShutterPress(objectID: nil, completion: completion)
    }
    
    func awaitFocus(completion: @escaping (_ objectId: DWord?) -> Void) {
        
        Logger.log(message: "Focus mode is AF variant awaiting focus...", category: "SonyPTPIPCamera")
        os_log("Focus mode is AF variant awaiting focus...", log: self.log, type: .debug)
        
        var newObject: DWord?
        self.isAwaitingObject = true
                    
        DispatchQueue.global().asyncWhile({ [weak self] (continueClosure) in
            
            guard let self = self else { return }
            
            if let lastEvent = self.lastEventPacket {
                
                // If code is property changed, and first variable == "Focus Found"
                if lastEvent.code == .propertyChanged, lastEvent.variables?.first == 0xD213 {
                    
                    Logger.log(message: "Got property changed event and was \"Focus Found\", continuing with capture process", category: "SonyPTPIPCamera")
                    os_log("Got property changed event and was \"Focus Found\", continuing with capture process", log: self.log, type: .debug)
                    continueClosure(true)
                    
                } else if lastEvent.code == .objectAdded {
                    
                    self.isAwaitingObject = false
                    Logger.log(message: "Got property changed event and was \"Object Added\", continuing with capture process", category: "SonyPTPIPCamera")
                    os_log("Got property changed event and was \"Object Added\", continuing with capture process", log: self.log, type: .debug)
                    newObject = lastEvent.variables?.first
                    continueClosure(true)
                    
                } else {
                    
                    continueClosure(false)
                }
                
            } else if let awaitingObjectId = self.awaitingObjectId {
                
                self.isAwaitingObject = false
                newObject = awaitingObjectId
                self.awaitingObjectId = nil
                continueClosure(true)
                
            } else {
                
                continueClosure(false)
            }
                        
        }, timeout: 1) { [weak self] in
            let awaitingObjectId = self?.awaitingObjectId
            self?.awaitingObjectId = nil
            completion(newObject ?? awaitingObjectId)
        }
    }
    
    private func cancelShutterPress(objectID: DWord?, completion: @escaping CaptureCompletion) {
        
        Logger.log(message: "Cancelling shutter press", category: "SonyPTPIPCamera")
        os_log("Cancelling shutter press", log: self.log, type: .debug)
                
        ptpIPClient?.sendSetControlDeviceBValue(
            PTP.DeviceProperty.Value(
                code: .capture,
                type: .uint16,
                value: Word(1)
            ),
            callback: { [weak self] response in
                
                guard let self = self else { return }
                
                self.ptpIPClient?.sendSetControlDeviceBValue(
                    PTP.DeviceProperty.Value(
                        code: .autoFocus,
                        type: .uint16,
                        value: Word(1)
                    ),
                    callback: { [weak self] (_) in
                        guard let self = self else { return }
                        guard objectID != nil else {
                            self.awaitObjectId(completion: completion)
                            return
                        }
                        completion(Result.success(nil))
                    }
                )
            }
        )
    }
    
    private func awaitObjectId(completion: @escaping CaptureCompletion) {
        
        var newObject: DWord?
        
        DispatchQueue.global().asyncWhile({ [weak self] (continueClosure) in
            
            guard let self = self else { return }
            
            if let lastEvent = self.lastEventPacket, lastEvent.code == .objectAdded {
                
                Logger.log(message: "Got property changed event and was \"Object Added\", continuing with capture process", category: "SonyPTPIPCamera")
                os_log("Got property changed event and was \"Object Added\", continuing with capture process", log: self.log, type: .debug)
                self.isAwaitingObject = false
                newObject = lastEvent.variables?.first ?? self.awaitingObjectId
                self.awaitingObjectId = nil
                continueClosure(true)
                return
                
            } else if let awaitingObjectId = self.awaitingObjectId {
                
                Logger.log(message: "\"Object Added\" event was intercepted elsewhere, continuing with capture process", category: "SonyPTPIPCamera")
                os_log("\"Object Added\" event was intercepted elsewhere, continuing with capture process", log: self.log, type: .debug)
                
                self.isAwaitingObject = false
                newObject = awaitingObjectId
                self.awaitingObjectId = nil
                continueClosure(true)
                return
            }
            
            self.getDevicePropDescriptionFor(propCode: .objectInMemory, callback: { (result) in
                
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
        
        Logger.log(message: "Got object with id: \(objectID)", category: "SonyPTPIPCamera")
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
        
        Logger.log(message: "Getting object of size: \(info.compressedSize) with id: \(objectID)", category: "SonyPTPIPCamera")
        os_log("Getting object", log: log, type: .debug)
        
        let packet = Packet.commandRequestPacket(code: .getPartialObject, arguments: [objectID, 0, info.compressedSize], transactionId: ptpIPClient?.getNextTransactionId() ?? 2)
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.handleObjectData(data.data, shootingMode: shootingMode, fileName: info.fileName ?? "\(ProcessInfo().globallyUniqueString).jpg")
            case .failure(let error):
                Logger.log(message: "Failed to get object: \(error.localizedDescription)", category: "SonyPTPIPCamera")
                os_log("Failed to get object", log: self.log, type: .error)
                break
            }
        })
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
    
    private func handleObjectData(_ data: ByteBuffer, shootingMode: ShootingMode, fileName: String) {
        
        Logger.log(message: "Got object data!: \(data.length). Attempting to save as image", category: "SonyPTPIPCamera")
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
        guard UIImage(data: imageData) != nil else {
            Logger.log(message: "Image data not valid", category: "SonyPTPIPCamera")
            os_log("Image data not valud", log: self.log, type: .error)
            return
        }
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let imageURL = temporaryDirectoryURL.appendingPathComponent(fileName)
        do {
            try imageData.write(to: imageURL)
            imageURLs[shootingMode, default: []].append(imageURL)
            // Trigger dummy event
            onEventAvailable?()
        } catch let error {
            Logger.log(message: "Failed to save image to disk: \(error.localizedDescription)", category: "SonyPTPIPCamera")
            os_log("Failed to save image to disk", log: self.log, type: .error)
        }
    }
}
