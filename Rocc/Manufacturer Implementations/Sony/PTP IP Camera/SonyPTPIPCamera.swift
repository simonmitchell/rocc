//
//  SonyPTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

internal final class SonyPTPIPDevice: SonyCamera {
    
    var ipAddress: sockaddr_in? = nil
    
    var apiVersion: String? = nil
    
    var baseURL: URL?
    
    var manufacturer: String
    
    var name: String?
    
    var model: String? = nil
    
    var firmwareVersion: String? = nil
    
    public var latestFirmwareVersion: String? {
        return modelEnum?.latestFirmwareVersion
    }
    
    var remoteAppVersion: String? = nil
    
    var latestRemoteAppVersion: String? = nil
    
    var lensModelName: String? = nil
    
    var onEventAvailable: (() -> Void)?
        
    var eventPollingMode: PollingMode {
        guard let deviceInfo = deviceInfo else { return .timed }
        return deviceInfo.supportedEventCodes.contains(.propertyChanged) ? .cameraDriven : .timed
    }
    
    var connectionMode: ConnectionMode = .remoteControl
    
    let apiDeviceInfo: ApiDeviceInfo
    
    private var cachedPTPIPClient: PTPIPClient?
    
    var ptpIPClient: PTPIPClient? {
        get {
            if let cachedPTPIPClient = cachedPTPIPClient {
                return cachedPTPIPClient
            }
            cachedPTPIPClient = PTPIPClient(camera: self)
            return cachedPTPIPClient
        }
        set {
            cachedPTPIPClient = newValue
        }
    }
    
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
    
    //MARK: - Initialisation -
    
    override init?(dictionary: [AnyHashable : Any]) {
        
        guard let apiDeviceInfoDict = dictionary["av:X_ScalarWebAPI_DeviceInfo"] as? [AnyHashable : Any], let apiInfo = ApiDeviceInfo(dictionary: apiDeviceInfoDict) else {
            return nil
        }
        
        apiDeviceInfo = apiInfo
        manufacturer = dictionary["manufacturer"] as? String ?? "Sony"
        
        super.init(dictionary: dictionary)
        
        name = dictionary["friendlyName"] as? String

        if let model = model {
            modelEnum = Model(rawValue: model)
        } else {
            modelEnum = nil
        }

        model = modelEnum?.friendlyName
    }
    
    var isConnected: Bool = false
    
    var deviceInfo: PTP.DeviceInfo?
    
    var lastEvent: CameraEvent?
        
    override func update(with deviceInfo: SonyDeviceInfo?) {
        name = modelEnum == nil ? name : (deviceInfo?.model?.friendlyName ?? name)
        modelEnum = deviceInfo?.model ?? modelEnum
        if let modelEnum = deviceInfo?.model {
            model = modelEnum.friendlyName
        }
        lensModelName = deviceInfo?.lensModelName
        firmwareVersion = deviceInfo?.firmwareVersion
    }
    
    //MARK: - Handshake methods -
    
    private func sendStartSessionPacket(completion: @escaping SonyPTPIPDevice.ConnectedCompletion) {
        
        // First argument here is the session ID. We don't need a transaction ID because this is the "first"
        // command we send and so we can use the default 0 value the function provides.
        let packet = Packet.commandRequestPacket(code: .openSession, arguments: [0x00000001])
        ptpIPClient?.sendCommandRequestPacket(packet, callback: { [weak self] (response) in
            guard response.code == .okay else {
                completion(PTPError.commandRequestFailed, false)
                return
            }
            self?.getDeviceInfo(completion: completion)
        }, callCallbackForAnyResponse: true)
    }
    
    private func getDeviceInfo(completion: @escaping SonyPTPIPDevice.ConnectedCompletion) {
        
        let packet = Packet.commandRequestPacket(code: .getDeviceInfo, arguments: nil, transactionId: ptpIPClient?.getNextTransactionId() ?? 1)
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak self] (dataResult) in
            
            switch dataResult {
            case .success(let dataContainer):
                guard let deviceInfo = PTP.DeviceInfo(data: dataContainer.data) else {
                    completion(PTPError.fetchDeviceInfoFailed, false)
                    return
                }
                self?.deviceInfo = deviceInfo
                // Only get SDIO Ext Device Info if it's supported!
                guard deviceInfo.supportedOperations.contains(.sdioGetExtDeviceInfo) else {
                    completion(nil, false)
                    return
                }
                self?.getSdioExtDeviceInfo(completion: completion)
            case .failure(let error):
                completion(error, false)
            }
        })
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
        
    private func performSdioConnect(completion: @escaping (Error?) -> Void, number: DWord, transactionId: DWord) {
        
        //TODO: Try and find out what the arguments are for this!
        let packet = Packet.commandRequestPacket(code: .sdioConnect, arguments: [number, 0x0000, 0x0000], transactionId: transactionId)
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { (dataContainer) in
            completion(nil)
        })
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
    
    private func getSdioExtDeviceInfo(completion: @escaping SonyPTPIPDevice.ConnectedCompletion) {
        
        // 1. call sdio connect twice
        // 2. call sdio get ext device info
        // 3. call sdio connect once more
        
        performSdioConnect(completion: { [weak self] (error) in
            guard let this = self else { return }
            //TODO: Handle errors
            this.performSdioConnect(
                completion: { [weak this] (secondaryError) in
                    
                    guard let _this = this else { return }
                    
                    // One parameter into this call, not sure what it represents!
                    let packet = Packet.commandRequestPacket(code: .sdioGetExtDeviceInfo, arguments: [0x0000012c], transactionId: _this.ptpIPClient?.getNextTransactionId() ?? 4)
                    _this.ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak _this] (dataResult) in
                        
                        switch dataResult {
                        case .success(let dataContainer):
                            guard let extDeviceInfo = PTP.SDIOExtDeviceInfo(data: dataContainer.data) else {
                                completion(PTPError.fetchSdioExtDeviceInfoFailed, false)
                                return
                            }
                            _this?.deviceInfo?.update(with: extDeviceInfo)
                            _this?.performSdioConnect(
                                completion: { _ in
                                    completion(nil, false)
                                },
                                number: 3,
                                transactionId: _this?.ptpIPClient?.getNextTransactionId() ?? 5
                            )
    //                        _this?.performFunction(Event.get, payload: nil, callback: { (error, event) in
    //                            print("Got event", event)
    //                        })
                        case .failure(let error):
                            completion(error, false)
                        }
                    })
                    _this.ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
                },
                number: 2,
                transactionId: this.ptpIPClient?.getNextTransactionId() ?? 3
            )
        }, number: 1, transactionId: ptpIPClient?.getNextTransactionId() ?? 2)
    }
    
    enum PTPError: Error {
        case commandRequestFailed
        case fetchDeviceInfoFailed
        case fetchSdioExtDeviceInfoFailed
        case deviceInfoNotAvailable
    }
}

//MARK: - Camera protocol conformance -

extension SonyPTPIPDevice: Camera {
        
    func connect(completion: @escaping SonyPTPIPDevice.ConnectedCompletion) {
        
        ptpIPClient?.connect(callback: { [weak self] (error) in
            self?.sendStartSessionPacket(completion: completion)
        })
        ptpIPClient?.onEvent = { [weak self] (event) in
            guard event.code == .propertyChanged else { return }
            self?.onEventAvailable?()
        }
    }
    
    func makeFunctionAvailable<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        //TODO: Implement this properly!
        callback(nil)
    }
    
    func loadFilesToTransfer(callback: @escaping ((Error?, [File]?) -> Void)) {
        
    }
    
    func finishTransfer(callback: @escaping ((Error?) -> Void)) {
        
    }
    
    func handleEvent(event: CameraEvent) {
        lastEvent = event
    }
}
