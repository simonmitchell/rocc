//
//  SonyPTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

internal final class SonyPTPIPCameraDevice: SonyCamera {
    
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
        
    var supportsPolledEvents: Bool = false
    
    var connectionMode: ConnectionMode = .remoteControl
    
    let apiDeviceInfo: ApiDeviceInfo
    
    var ptpIPClient: PTPIPClient?
    
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
        
//        apiClient = SonyCameraAPIClient(apiInfo: apiDeviceInfo)
//        apiVersion = apiDeviceInfo.version

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
    
    private func sendStartSessionPacket(completion: @escaping SonyPTPIPCameraDevice.ConnectedCompletion) {
        
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
    
    private func getDeviceInfo(completion: @escaping SonyPTPIPCameraDevice.ConnectedCompletion) {
        
        let packet = Packet.commandRequestPacket(code: .getDeviceInfo, arguments: nil, transactionId: 1)
        ptpIPClient?.awaitDataFor(transactionId: 1, callback: { [weak self] (dataContainer) in
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
        })
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
        
    private func performSdioConnect(completion: @escaping (Error?) -> Void, number: DWord, transactionId: DWord = 2) {
        
        //TODO: Try and find out what the arguments are for this!
        let packet = Packet.commandRequestPacket(code: .sdioConnect, arguments: [number, 0x0000, 0x0000], transactionId: transactionId)
        ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { (dataContainer) in
            completion(nil)
        })
        ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
    }
    
    private func getSdioExtDeviceInfo(completion: @escaping SonyPTPIPCameraDevice.ConnectedCompletion) {
        
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
                    let packet = Packet.commandRequestPacket(code: .sdioGetExtDeviceInfo, arguments: [0x0000012c], transactionId: 4)
                    _this.ptpIPClient?.awaitDataFor(transactionId: packet.transactionId, callback: { [weak _this] (dataContainer) in
                        guard let extDeviceInfo = PTP.SDIOExtDeviceInfo(data: dataContainer.data) else {
                            completion(PTPError.fetchSdioExtDeviceInfoFailed, false)
                            return
                        }
                        _this?.deviceInfo?.update(with: extDeviceInfo)
                        completion(nil, false)
                    })
                    _this.ptpIPClient?.sendCommandRequestPacket(packet, callback: nil)
                },
                number: 2,
                transactionId: 3
            )
        }, number: 1)
    }
    
    enum PTPError: Error {
        case commandRequestFailed
        case fetchDeviceInfoFailed
        case fetchSdioExtDeviceInfoFailed
        case deviceInfoNotAvailable
    }
}

//MARK: - Camera protocol conformance -

extension SonyPTPIPCameraDevice: Camera {
    
    func connect(completion: @escaping SonyPTPIPCameraDevice.ConnectedCompletion) {
        
        ptpIPClient = PTPIPClient(camera: self)
        ptpIPClient?.connect(callback: { [weak self] (error) in
            self?.sendStartSessionPacket(completion: completion)
        })
    }
    
    func supportsFunction<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
        //TODO: We shouldn't be dependent on this at this stage!
        guard let deviceInfo = deviceInfo else {
            callback(nil, PTPError.deviceInfoNotAvailable, nil)
            return
        }
                
        // If the function has a related PTP property value
        if let propTypeCodes = function.function.ptpDevicePropertyCodes {
            
            //TODO: When we pull and store the latest event, check that so we can send back supported values!
            
            // Check that the related property value is supported
            let supported = propTypeCodes.contains { (functionPropCode) -> Bool in
                return deviceInfo.supportedDeviceProperties.contains(functionPropCode)
            }
            callback(supported, nil, nil)
            return
        }
        
        // Fallback for functions that aren't related to a particular camera prop type, or that function differently to the PTP spec!
        switch function.function {
        case .ping:
            callback(true, nil, nil)
        //TODO: Finish implementing!
        default:
            callback(false, nil, nil)
        }
    }
    
    func isFunctionAvailable<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
    }
    
    func makeFunctionAvailable<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        
    }
    
    func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
    }
    
    func loadFilesToTransfer(callback: @escaping ((Error?, [File]?) -> Void)) {
        
    }
    
    func finishTransfer(callback: @escaping ((Error?) -> Void)) {
        
    }
    
    func handleEvent(event: CameraEvent) {
        
    }
}
