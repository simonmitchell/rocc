//
//  SonyPTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

internal final class SonyPTPIPCamera: PTPIPCamera {
    
    struct ApiDeviceInfo {
        
        let liveViewURL: URL
        
        var defaultFunction: String?
                
        init?(dictionary: [AnyHashable : Any]) {
            
            guard let imagingDevice = dictionary["av:X_ScalarWebAPI_ImagingDevice"] as? [AnyHashable : Any] else {
                return nil
            }
            
            guard let liveViewURLString = imagingDevice["av:X_ScalarWebAPI_LiveView_URL"] as? String else {
                return nil
            }
            guard let liveViewURL = URL(string: liveViewURLString) else {
                return nil
            }
            
            self.liveViewURL = liveViewURL
            defaultFunction = imagingDevice["av:X_ScalarWebAPI_DefaultFunction"] as? String
        }
    }
    
    let apiDeviceInfo: ApiDeviceInfo
    
    required init(dictionary: [AnyHashable : Any]) throws {
        
        guard let apiDeviceInfoDict = dictionary["av:X_ScalarWebAPI_DeviceInfo"] as? [AnyHashable : Any], let apiInfo = ApiDeviceInfo(dictionary: apiDeviceInfoDict) else {
            throw CameraDiscoveryError.invalidXML("av:X_ScalarWebAPI_DeviceInfo key missing")
        }
        
        apiDeviceInfo = apiInfo
        
        do {
            try super.init(dictionary: dictionary)
        } catch let error {
            throw error
        }
        
        let _name = dictionary["friendlyName"] as? String
        let _modelEnum: Sony.Camera.Model?
        if let _name = _name {
            _modelEnum = Sony.Camera.Model(rawValue: _name)
        } else {
            _modelEnum = nil
        }
                
        name = _modelEnum?.friendlyName ?? _name
        model = _modelEnum
    }

    /// The last set of `PTPDeviceProperty`s that we received from the camera
    /// retained so we can avoid asking the camera for the full array every time
    /// we need to fetch an event
    var lastAllDeviceProps: [PTPDeviceProperty]?
    
    override func update(with deviceInfo: SSDPCameraInfo) {
        
        guard let sonyDeviceInfo = deviceInfo as? SonyDeviceInfo else { return }
        
        name = model == nil ? name : (sonyDeviceInfo.model?.friendlyName ?? name)
        model = sonyDeviceInfo.model ?? model
        lensModelName = sonyDeviceInfo.lensModelName
        firmwareVersion = sonyDeviceInfo.firmwareVersion
    }
    
    override func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
        switch function.function {
        case .getEvent:
            guard !imageURLs.isEmpty, var lastEvent = lastEvent else {

                ptpIPClient?.getAllDevicePropDesc(callback: { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(var properties):

                        if var lastProperties = self.lastAllDeviceProps {
                            properties.forEach { (property) in
                                // If the property is already present in received properties, just directly replace it!
                                if let existingIndex = lastProperties.firstIndex(where: { (existingProperty) -> Bool in
                                    return property.code == existingProperty.code
                                }) {
                                    lastProperties[existingIndex] = property
                                } else { // Otherwise append it to the array
                                    lastProperties.append(property)
                                }
                            }
                            properties = lastProperties
                        }

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
                }, partial: lastAllDeviceProps != nil)

                return
            }

            lastEvent.postViewPictureURLs = self.imageURLs.compactMapValues({ (urls) -> [(postView: URL, thumbnail: URL?)]? in
                return urls.map({ ($0, nil) })
            })
            imageURLs = [:]
            callback(nil, lastEvent as? T.ReturnType)
        case .startLiveView, .startLiveViewWithQuality, .endLiveView:
            getDevicePropDescriptionFor(propCode: .liveViewURL) { [weak self] (result) in
                
                guard let self = self else { return }
                switch result {
                case .success(let property):
                    
                    var url: URL = self.apiDeviceInfo.liveViewURL
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
                    
                case .failure(_):
                    callback(nil, self.apiDeviceInfo.liveViewURL as? T.ReturnType)
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
                sendSetDevicePropValue(
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

            sendSetDevicePropValue(
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
            sendSetDevicePropValue(PTP.DeviceProperty.Value(value, manufacturer: manufacturer))
        default:
            super.performFunction(function, payload: payload, callback: callback)
        }
    }

    override func sendSetDevicePropValue(
        _ value: PTP.DeviceProperty.Value,
        valueB: Bool = false,
        callback: CommandRequestPacketResponse? = nil
    ) {

        let transactionID = ptpIPClient?.getNextTransactionId() ?? 2
        let opRequestPacket = Packet.commandRequestPacket(
            code: valueB ? .setControlDeviceB : .setControlDeviceA,
            arguments: [DWord(value.code.rawValue)],
            transactionId: transactionID,
            dataPhaseInfo: 2
        )
        var data = ByteBuffer()
        data.appendValue(value.value, ofType: value.type)
        let dataPackets = Packet.dataSendPackets(data: data, transactionId: transactionID)

        ptpIPClient?.sendCommandRequestPacket(opRequestPacket, callback: callback)
        dataPackets.forEach { dataPacket in
            ptpIPClient?.sendControlPacket(dataPacket)
        }
    }
    
    override func performInitialEventFetch(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        
        // Sony PTP/IP cameras perform this unknown handshake request before fetching initial event!
        self.ptpIPClient?.sendCommandRequestPacket(Packet.commandRequestPacket(
            code: .unknownHandshakeRequest,
            arguments: nil,
            transactionId: self.ptpIPClient?.getNextTransactionId() ?? 7
        ), callback: { (response) in
            super.performInitialEventFetch(completion: completion)
        })
    }

    override func connect(completion: @escaping PTPIPCamera.ConnectedCompletion) {
        lastAllDeviceProps = nil
        super.connect(completion: completion)
    }

    override func startCapturing(completion: @escaping (Error?) -> Void) {

        Logger.log(message: "Starting capture...", category: "SonyPTPIPCamera", level: .debug)
        os_log("Starting capture...", log: self.log, type: .debug)

        sendSetDevicePropValue(
            PTP.DeviceProperty.Value(
                code: .autoFocus,
                type: .uint16,
                value: Word(2)
            ),
            valueB: true
        ) { [weak self] _ in
            guard let self = self else { return }

            self.sendSetDevicePropValue(
                PTP.DeviceProperty.Value(
                    code: .capture,
                    type: .uint16,
                    value: Word(2)
                ),
                valueB: true
            ) { shutterResponse in
                guard !shutterResponse.code.isError else {
                    completion(PTPError.commandRequestFailed(shutterResponse.code))
                    return
                }
                completion(nil)
            }
        }
    }

    override func cancelShutterPress(objectID: DWord?, awaitObjectId: Bool = true, completion: @escaping PTPIPCamera.CaptureCompletion) {

        sendSetDevicePropValue(
            PTP.DeviceProperty.Value(
                code: .capture,
                type: .uint16,
                value: Word(1)
            ),
            valueB: true
        ) { [weak self] response in
            guard let self = self else { return }

            Logger.log(message: "Shutter press set to 1", category: "SonyPTPIPCamera", level: .debug)
            os_log("Shutter press set to 1", log: self.log, type: .debug, objectID != nil ? "\(objectID!)" : "null")

            self.sendSetDevicePropValue(
                PTP.DeviceProperty.Value(
                    code: .autoFocus,
                    type: .uint16,
                    value: Word(1)
                ),
                valueB: true
            ) { [weak self] _ in
                guard let self = self else { return }

                Logger.log(message: "Autofocus set to 1 \(objectID ?? 0)", category: "SonyPTPIPCamera", level: .debug)
                os_log("Autofocus set to 1", log: self.log, type: .debug, objectID != nil ? "\(objectID!)"
                    : "null")
                guard objectID != nil || !awaitObjectId else {
                    self.awaitObjectId(completion: completion)
                    return
                }
                completion(Result.success(nil))
            }
        }
    }
}
