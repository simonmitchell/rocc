//
//  SonyCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

extension Double {
    
    func withPrecision(_ value: Int = 1) -> Double {
        let offset = pow(10, Double(value))
        return (self * offset).rounded() / offset
    }
    
    static func equal(_ lhs: Double, _ rhs: Double, precision value: Int? = nil) -> Bool {
        guard let value = value else {
            return lhs == rhs
        }
        return lhs.withPrecision(value) == rhs.withPrecision(value)
    }
}

internal extension FileRequest {
    static let sonyDefault = FileRequest(uri: "storage:memoryCard1", startIndex: 0, count: 50, view: .flat, sort: nil, types: nil)
}

fileprivate extension CountRequest {
    static let sonyDefault = CountRequest(uri: "storage:memoryCard1", view: .flat, target: "all", types: nil)
}

internal final class SonyAPICameraDevice: SonyCamera {
    
    private let apiClient: SonyCameraAPIClient
    
    fileprivate var lastShutterSpeed: ShutterSpeed?
    
    fileprivate var lastShootMode: ShootingMode?
    
    var lastEvent: CameraEvent? {
        return nil
    }
    
    struct ApiDeviceInfo {
        
        struct Service {
            
            let type: String
            
            let url: URL
            
            let accessType: String?
            
            init?(dictionary: [AnyHashable : Any], model: SonyCamera.Model?) {
                
                guard let _type = dictionary["av:X_ScalarWebAPI_ServiceType"] as? String else {
                    return nil
                }
                guard let urlString = dictionary["av:X_ScalarWebAPI_ActionList_URL"] as? String else {
                    return nil
                }
                guard var _url = URL(string: urlString) else {
                    return nil
                }
                
                if let model = model, model.usesLegacyAPI {
                    _url = _url.deletingLastPathComponent()
                }
                
                url = _url
                type = _type
                accessType = dictionary["av:X_ScalarWebAPI_AccessType"] as? String
            }
        }
        
        let version: String
        
        let services: [Service]
        
        init?(dictionary: [AnyHashable : Any], model: SonyCamera.Model?) {
            
            guard let versionString = dictionary["av:X_ScalarWebAPI_Version"] as? String else { return nil }
            version = versionString
            guard let serviceList = dictionary["av:X_ScalarWebAPI_ServiceList"] as? [[AnyHashable : Any]] else {
                services = []
                return
            }
            services = serviceList.compactMap({ Service(dictionary: $0, model: model) })
        }
    }
    
    /// Callbacks for when the camera's focus status changes. These return true to be removed from the pending array.
    var focusChangeAwaitingCallbacks: [(_ focusStatus: FocusStatus?) -> Bool] = []
    
    var lastNonNilFocusState: FocusStatus?
    
    var focusStatus: FocusStatus? {
        didSet {
            focusChangeAwaitingCallbacks = focusChangeAwaitingCallbacks.filter { (callback) -> Bool in
                return !callback(focusStatus)
            }
            guard focusStatus != nil else { return }
            lastNonNilFocusState = focusStatus
        }
    }
    
    var focusMode: Focus.Mode.Value?
        
    var type: String?
    
    public var onEventAvailable: (() -> Void)?
    
    public var onDisconnected: (() -> Void)?
    
    public var apiVersion: String?
    
    public var name: String?
        
    public var model: String?
    
    public var manufacturer: String
    
    public var ipAddress: sockaddr_in?
                
    let apiDeviceInfo: ApiDeviceInfo
    
    public var firmwareVersion: String?
    
    public var latestFirmwareVersion: String? {
        return modelEnum?.latestFirmwareVersion
    }
    
    public var remoteAppVersion: String?
    
    public var latestRemoteAppVersion: String? {
        return modelEnum?.latestRemoteAppVersion ?? "4.30"
    }

    public var eventVersion: String?
    
    public var lensModelName: String?
    
    public var baseURL: URL? {
        get {
            return apiDeviceInfo.services.first?.url
        }
        set { }
    }
        
    var connectionMode: ConnectionMode {
        return .remoteControl
    }
    
    override init?(dictionary: [AnyHashable : Any]) {
        
        let _name = dictionary["friendlyName"] as? String
        let _modelEnum: SonyCamera.Model?
        if let _name = _name {
            _modelEnum = SonyCamera.Model(rawValue: _name)
        } else {
            _modelEnum = nil
        }
                
        guard let apiDeviceInfoDict = dictionary["av:X_ScalarWebAPI_DeviceInfo"] as? [AnyHashable : Any], let apiInfo = ApiDeviceInfo(dictionary: apiDeviceInfoDict, model: _modelEnum) else {
            return nil
        }
        
        apiDeviceInfo = apiInfo
        apiClient = SonyCameraAPIClient(apiInfo: apiDeviceInfo)
        apiVersion = apiDeviceInfo.version
        
        name = _modelEnum?.friendlyName ?? _name
        manufacturer = dictionary["manufacturer"] as? String ?? "Sony"
        
        super.init(dictionary: dictionary)
        
        modelEnum = _modelEnum
        model = modelEnum?.friendlyName
    }
    
    override func update(with deviceInfo: SonyDeviceInfo?) {
        
        // Keep name if modelEnum currently nil as user has renamed camera!
        name = modelEnum == nil ? name : (deviceInfo?.model?.friendlyName ?? name)
        modelEnum = deviceInfo?.model ?? modelEnum
        model = modelEnum?.friendlyName ?? model
        lensModelName = deviceInfo?.lensModelName
        firmwareVersion = deviceInfo?.firmwareVersion
        remoteAppVersion = deviceInfo?.installedPlayMemoriesApps.first(
            where: {
                $0.name.lowercased() == "smart remote control" ||
                $0.name.lowercased() == "smart remote embedded" ||
                $0.name.lowercased().contains("smart remote")
            }
        )?.version
    }
}

extension SonyAPICameraDevice: Camera {
    
    var isInBeta: Bool {
        return false
    }
        
    func finishTransfer(callback: @escaping ((Error?) -> Void)) {
        callback(CameraError.noSuchMethod("Finish Transfer"))
    }
    
    func handleEvent(event: CameraEvent) {
        focusStatus = event.focusStatus
        if let currentFocusMode = event.focusMode?.current {
            focusMode = currentFocusMode
        }
    }
    
    func loadFilesToTransfer(callback: @escaping ((Error?, [File]?) -> Void)) {
        callback(CameraError.noSuchMethod("Transfer Files"), nil)
    }
    
    private func onFocusChange(_ callback: @escaping (_ focusStatus: FocusStatus?) -> Bool) {
        focusChangeAwaitingCallbacks.append(callback)
    }
    
    var eventPollingMode: PollingMode {
        return .continuous
    }
    
    private func getInTransferMode(callback: @escaping (Result<Bool, Error>) -> Void) {
        
        guard let cameraClient = apiClient.camera else {
            callback(Result.failure(CameraError.cameraNotReady("getVersions")))
            return
        }
        
        // If the camera model doesn't support getVersions then we don't need to worry!
        if let modelEnum = modelEnum, modelEnum.usesLegacyAPI {
            callback(Result.success(false))
        } else {
            cameraClient.getVersions { (result) in
                
                // Ignore 404 in case we're on an unknown camera or user has renamed camera
                if case let .failure(error) = result, (error as NSError).code != 404 {
                    callback(Result.failure(error))
                    return
                } else if case let .success(versions) = result {
                    self.eventVersion = versions.map { Double($0) }.compactMap { $0 }.max().map { String($0) }
                }
                    
                guard let avClient = self.apiClient.avContent else {
                    callback(Result.success(false))
                    return
                }
                
                avClient.getVersions { (avResult) in
                    
                    // Ignore 404 in case we're on an unknown camera or user has renamed camera
                    if case let .failure(error) = avResult, (error as NSError).code != 404 {
                        callback(Result.failure(error))
                        return
                    }
                        
                    cameraClient.getCameraFunction({ (functionResult) in
                        
                        switch functionResult {
                        case .failure(_): // If we can't get camera function then check what it currently
                            // is, and if it's "contents transfer" we know that we're in "Send to Smartphone" mode!
                            
                            // Get event, because getCameraFunction failed!
                            cameraClient.getEvent(polling: false, { (eventResult) in
                                
                                var isInTransferMode: Bool = false
                                
                                switch eventResult {
                                case .failure(_):
                                    callback(Result.success(false))
                                    break
                                case .success(let event):
                                    if let function = event.function?.current {
                                        isInTransferMode = function.lowercased() == "contents transfer"
                                    }
                                }
                                
                                callback(Result.success(isInTransferMode))
                            })
                        case .success(_): // If we can get camera function, we're not in "Send to Smartphone" mode!
                            callback(Result.success(false))
                        }
                    })
                }
            }
        }
    }
    
    public func connect(completion: @escaping Camera.ConnectedCompletion) {
        
        guard let cameraClient = apiClient.camera else {
            completion(nil, false)
            return
        }
        
        getInTransferMode { (result) in
            
            switch result {
            case .failure(let error):
                completion(error, false)
            case .success(let inTransferMode):
                
                guard self.modelEnum == nil || SonyCamera.Model.supporting(function: .startRecordMode).contains(self.modelEnum!) else {
                    completion(nil, inTransferMode)
                    return
                }
                
                cameraClient.startRecordMode() { (error) in
                    var _error = error
                    // Ignore no such method errors because in that case we simply never needed to call this method in the first place!
                    if let clientError = error as? CameraError, case .noSuchMethod(_) = clientError {
                        _error = nil
                        // Also ignore 404 as this is what cameras like RX100 M2 return!
                    } else if (error as NSError?)?.code == 404 {
                        _error = nil
                    }
                    completion(_error, inTransferMode)
                }
            }
        }
    }
    
    func disconnect(completion: @escaping DisconnectedCompletion) {
        completion(nil)
    }
    
    public var isConnected: Bool {
        // Make sure no clients where APIVersion hasn't been found
        return [apiClient.camera, apiClient.avContent].first(where: {
            guard let client = $0 else { return false }
            return client.versions == nil
        }) == nil
    }
    
    public func makeFunctionAvailable<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        
        guard let camera = apiClient.camera else {
            callback(FunctionError.notAvailable)
            return
        }
        
        switchCameraToRequiredFunctionFor(function) { [weak self] (fnError) in
            
            guard let this = self, fnError == nil else {
                callback(fnError)
                return
            }
            
            switch function.function {
            case .takePicture, .startContinuousShooting, .startBulbCapture:
                
                this.setToShootModeIfRequired(camera: camera, shootMode: .photo) { [weak this] (error) in
                                        
                    switch function.function {
                    case .startContinuousShooting:
                        this?.setShutterSpeedAwayFromBulbIfRequired(camera: camera, { (_) in
                            
                            camera.getAvailableContinuousShootingModes({ (result) in
                                
                                switch result {
                                case .success(let modes):
                                    
                                    guard let firstMode = modes.first(where: { $0 != .single }) ?? modes.first else { return }
                                    
                                    camera.setContinuousShootingMode(firstMode, { (error) in
                                        
                                        guard error == nil else {
                                            callback(error)
                                            return
                                        }
                                        
                                        camera.getAvailableContinuousShootingSpeeds({ (result) in
                                            
                                            switch result {
                                            case .success(let speeds):
                                                
                                                guard let firstSpeed = speeds.first else { return }
                                                camera.setContinuousShootingSpeed(firstSpeed, { (error) in
                                                    callback(error)
                                                })
                                                
                                            case .failure(let error):
                                                callback(error)
                                            }
                                        })
                                        
                                    })
                                    
                                case .failure(let error):
                                    callback(error)
                                }
                            })
                        })
                    case .startBulbCapture:
                        camera.setShutterSpeed(ShutterSpeed.bulb, completion: { (shutterSpeedError) in
                            guard shutterSpeedError == nil else {
                                callback(error)
                                return
                            }
                            // We need to do this otherwise the camera can get stuck in continuous shooting mode!
                            camera.setContinuousShootingMode(.single, { (_) in
                                callback(error)
                            })
                        })
                    default:
                        
                        this?.setShutterSpeedAwayFromBulbIfRequired(camera: camera, { (_) in
                            camera.setContinuousShootingMode(.single, { (_) in
                                callback(error)
                            })
                        })
                    }
                }
                
            case .startIntervalStillRecording:
                this.setShutterSpeedAwayFromBulbIfRequired(camera: camera, { [weak this] (_) in
                    this?.setToShootModeIfRequired(camera: camera, shootMode: .interval, callback)
                })
            case .startAudioRecording:
                this.setShutterSpeedAwayFromBulbIfRequired(camera: camera, { [weak this] (_) in
                    this?.setToShootModeIfRequired(camera: camera, shootMode: .audio, callback)
                })
            case .startVideoRecording:
                this.setShutterSpeedAwayFromBulbIfRequired(camera: camera, { [weak this] (_) in
                    this?.setToShootModeIfRequired(camera: camera, shootMode: .video, callback)
                })
            case .startLoopRecording:
                this.setShutterSpeedAwayFromBulbIfRequired(camera: camera, { [weak this] (_) in
                    this?.setToShootModeIfRequired(camera: camera, shootMode: .loop, callback)
                })
            default:
                callback(nil)
            }
        }
    }
    
    private func setToShootModeIfRequired(camera: CameraClient, shootMode: ShootingMode, _ completion: @escaping ((Error?) -> Void)) {
        
        // Last shoot mode should be up to date so do a quick check if we're already in the correct shoot mode
        guard lastShootMode != shootMode else {
            completion(nil)
            return
        }
        
        // Some cameras throw error if we try and set shoot mode to it's current value, so let's do a last-ditch attempt to check current shoot mode before changing
        camera.getShootMode { (result) in
            switch result {
            case .success(let currentMode):
                guard currentMode != shootMode else {
                    completion(nil)
                    return
                }
                camera.setShootMode(shootMode, completion: { [weak self] (error) in
                    completion(error)
                    guard error == nil else {
                        return
                    }
                    self?.lastShootMode = shootMode
                })
            case .failure(_):
                camera.setShootMode(shootMode, completion: { [weak self] (error) in
                    completion(error)
                    guard error == nil else {
                        return
                    }
                    self?.lastShootMode = shootMode
                })
            }
        }
    }
    
    private func setShutterSpeedAwayFromBulbIfRequired(camera: CameraClient, _ callback: @escaping ((Error?) -> Void)) {
        
        // We need to do this otherwise the camera can get stuck in continuous shooting mode!
        // If the shutter speed is BULB then we need to set it to something else!
        guard self.lastShutterSpeed?.isBulb == true else {
            callback(nil)
            return
        }
        
        // Get available shutter speeds
        camera.getAvailableShutterSpeeds({ (shutterSpeedResults) in
            switch shutterSpeedResults {
            case .failure(let error):
                callback(error)
            case .success(let availableShutterSpeeds):
                // Find a shutter speed that isn't bulb
                guard let firstNonBulbShutterSpeed = availableShutterSpeeds.first(where: { !$0.isBulb }) else {
                    callback(nil)
                    return
                }
                // Set shutter speed to non-bulb
                camera.setShutterSpeed(firstNonBulbShutterSpeed, completion: { (error) in
                    callback(error)
                })
            }
        })
    }
    
    private func switchCameraToRequiredFunctionFor<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        
        guard let camera = apiClient.camera else {
            callback(FunctionError.notAvailable)
            return
        }
        
        // Ignore models which don't require/support this...
        guard let model = modelEnum, SonyCamera.Model.supporting(function: .getCameraFunction).contains(model) else {
            callback(nil)
            return
        }
    
        let requiredFunction: String = function.function.isAVContentFunction ? "Contents Transfer" : "Remote Shooting"
        
        camera.getCameraFunction { (result) in
            switch result {
            case .failure(let error):
                switch error {
                    // Let's be cautious here, the a6300 even though it's listed as supporting `getCameraFunction` sometimes seems to
                    // throw `noSuchMethod` here!
                case CameraError.noSuchMethod(_):
                    camera.setCameraFunction(requiredFunction) { (setError) in
                        
                        guard let _setError = setError else {
                            callback(nil)
                            return
                        }
                        
                        switch _setError {
                        // Let's be cautious here, the a6300 even though it's listed as supporting `setCameraFunction` sometimes seems to
                        // throw `noSuchMethod` here!
                        case CameraError.noSuchMethod(_):
                            callback(nil)
                        default:
                            callback(setError)
                        }
                    }
                default:
                    callback(error)
                }
            case .success(let function):
                
                guard function != requiredFunction else {
                    callback(nil)
                    return
                }
                
                camera.setCameraFunction(requiredFunction) { (error) in
                    callback(error)
                }
            }
        }
    }
    
    public func supportsFunction<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
        guard isConnected else {
            callback(nil, FunctionError.notReady, nil)
            return
        }
        
        // If not supported, don't bother getting values
        if let model = modelEnum, !SonyCamera.Model.supporting(function: function.function).contains(model) && !function.function.requiresAPICheckForSupport {
            callback(false, nil, nil)
            return
        }

        guard modelEnum == nil else {
            getSupportedValues(function, callback: callback)
            return
        }

        guard let apiMethodName = function.function.sonyCameraMethodName else {
            callback(false, nil, nil)
            return
        }
        
        // If we don't have a model enum (Can happen if user has changed the name of their camera), then we have to hit the API to get supported functions
        let client = function.function.isAVContentFunction ? apiClient.avContent : apiClient.camera
        
        guard let _client = client else {
            callback(false, nil, nil)
            return
        }
        
        // According to docs, if the client is `camera` we should check if available rather than if supported, which seems strange... so we'll check both! If it's available, it's safe to assume that it's supported!
        
        let availableCallback: (_ available: Bool?) -> Void = { available in
            
            // Get method types!
            _client.getMethodTypesFor(version: nil) { (result) in
                
                switch result {
                case let .success(types):
                    
                    let supported = types.first(where: { (supported) -> Bool in
                        guard let array = supported as? [Any] else { return false }
                        guard let apiName = array.first as? String else { return false }
                        return apiName == apiMethodName
                    })
                    
                    // If we have `supported` or available is true, attempt to fetch supported values
                    guard supported != nil || available == true else {
                        // If available is set, then return that!
                        callback(available ?? false, nil, nil)
                        break
                    }
                    
                    self.getSupportedValues(function, callback: callback)
                    
                case let .failure(error):
                    callback(available ?? false, error, nil)
                }
            }
        }
        
        if _client is CameraClient {
            
            _client.getAvailableApiList { (result) in
                
                guard case let .success(availableApis) = result else {
                    availableCallback(nil)
                    return
                }
                
                availableCallback(availableApis.contains(apiMethodName))
            }
            
        } else {
            
            availableCallback(nil)
        }
    }
    
    private func getSupportedValues<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T: CameraFunction {
        
        switch function.function {
        case .setShootMode, .getShootMode:
            apiClient.camera?.getSupportedShootModes({ (result) in
                guard case let .success(shootModes) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, shootModes as? [T.SendType])
            })
        case .startLiveViewWithQuality, .setLiveViewQuality:
            apiClient.camera?.getSupportedLiveViewSizes({ (result) in
                guard case let .success(whiteBalances) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, whiteBalances as? [T.SendType])
            })
        case .getZoomSetting, .setZoomSetting:
            apiClient.camera?.getSupportedZoomSettings({ (result) in
                guard case let .success(whiteBalances) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, whiteBalances as? [T.SendType])
            })
        case .getTrackingFocus, .setTrackingFocus:
            apiClient.camera?.getSupportedTrackingFocusses({ (result) in
                guard case let .success(trackingFocusses) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, trackingFocusses as? [T.SendType])
            })
        case .getContinuousShootingMode, .setContinuousShootingMode:
            apiClient.camera?.getSupportedContinuousShootingModes({ (result) in
                guard case let .success(modes) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, modes as? [T.SendType])
            })
        case .getContinuousShootingSpeed, .setContinuousShootingSpeed:
            apiClient.camera?.getSupportedContinuousShootingSpeeds({ (result) in
                guard case let .success(speeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, speeds as? [T.SendType])
            })
        case .getSelfTimerDuration, .setSelfTimerDuration:
            apiClient.camera?.getSupportedSelfTimerDurations({ (result) in
                guard case let .success(speeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, speeds as? [T.SendType])
            })
        case .getExposureMode, .setExposureMode:
            apiClient.camera?.getSupportedExposureModes({ (result) in
                guard case let .success(speeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, speeds as? [T.SendType])
            })
        case .getFocusMode, .setFocusMode:
            apiClient.camera?.getSupportedFocusModes({ (result) in
                guard case let .success(speeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, speeds as? [T.SendType])
            })
        case .getExposureCompensation, .setExposureCompensation:
            apiClient.camera?.getSupportedExposureCompensations() { (result) in
                guard case let .success(apertures) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, apertures as? [T.SendType])
            }
        case .getAperture, .setAperture:
            apiClient.camera?.getSupportedApertures() { (result) in
                guard case let .success(apertures) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, apertures as? [T.SendType])
            }
        case .getWhiteBalance, .setWhiteBalance:
            apiClient.camera?.getSupportedWhiteBalances({ (result) in
                guard case let .success(whiteBalances) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, whiteBalances as? [T.SendType])
            })
        case .getISO, .setISO:
            apiClient.camera?.getSupportedISOValues({ (result) in
                guard case let .success(whiteBalances) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, whiteBalances as? [T.SendType])
            })
        case .getShutterSpeed, .setShutterSpeed:
            apiClient.camera?.getSupportedShutterSpeeds({ (result) in
                guard case let .success(shutterSpeeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, shutterSpeeds as? [T.SendType])
            })
        case .setProgramShift:
            apiClient.camera?.getSupportedProgramShifts({ (result) in
                guard case let .success(shutterSpeeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, shutterSpeeds as? [T.SendType])
            })
        case .getFlashMode, .setFlashMode:
            apiClient.camera?.getSupportedFlashModes({ (result) in
                guard case let .success(shutterSpeeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, shutterSpeeds as? [T.SendType])
            })
        case .getStillSize, .setStillSize:
            apiClient.camera?.getSupportedStillQualities({ (result) in
                guard case let .success(shutterSpeeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, shutterSpeeds as? [T.SendType])
            })
        case .getStillQuality, .setStillQuality:
            apiClient.camera?.getSupportedStillQualities({ (result) in
                guard case let .success(stillQualities) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, stillQualities as? [T.SendType])
            })
        case .getStillFormat, .setStillFormat:
            apiClient.camera?.getSupportedStillFormats({ (result) in
                guard case let .success(stillQualities) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, stillQualities as? [T.SendType])
            })
        case .getPostviewImageSize, .setPostviewImageSize:
            apiClient.camera?.getSupportedPostviewImageSizes({ (result) in
                guard case let .success(shutterSpeeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, shutterSpeeds as? [T.SendType])
            })
        case .getVideoFileFormat, .setVideoFileFormat:
            apiClient.camera?.getSupportedMovieFileFormats({ (result) in
                guard case let .success(shutterSpeeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, shutterSpeeds as? [T.SendType])
            })
        case .getVideoQuality, .setVideoQuality:
            apiClient.camera?.getSupportedMovieQualities({ (result) in
                guard case let .success(shutterSpeeds) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, shutterSpeeds as? [T.SendType])
            })
        case .getSteadyMode, .setSteadyMode:
            apiClient.camera?.getSupportedSteadyModes({ (result) in
                guard case let .success(modes) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, modes as? [T.SendType])
            })
        case .getViewAngle, .setViewAngle:
            apiClient.camera?.getSupportedViewAngles({ (result) in
                guard case let .success(angles) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, angles as? [T.SendType])
            })
        case .getScene, .setScene:
            apiClient.camera?.getSupportedSceneSelections({ (result) in
                guard case let .success(scenes) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, scenes as? [T.SendType])
            })
        case .getColorSetting, .setColorSetting:
            apiClient.camera?.getSupportedColorSettings({ (result) in
                guard case let .success(settings) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, settings as? [T.SendType])
            })
        case .getIntervalTime, .setIntervalTime:
            apiClient.camera?.getSupportedIntervalTimes({ (result) in
                guard case let .success(settings) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, settings as? [T.SendType])
            })
        case .getLoopRecordDuration, .setLoopRecordDuration:
            apiClient.camera?.getSupportedLoopDurations({ (result) in
                guard case let .success(durations) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, durations as? [T.SendType])
            })
        case .getWindNoiseReduction, .setWindNoiseReduction:
            apiClient.camera?.getSupportedWindNoiseReductions({ (result) in
                guard case let .success(settings) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, settings as? [T.SendType])
            })
        case .getAudioRecording, .setAudioRecording:
            apiClient.camera?.getSupportedAudioRecordingSettings({ (result) in
                guard case let .success(settings) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, settings as? [T.SendType])
            })
        case .getFlipSetting, .setFlipSetting:
            apiClient.camera?.getSupportedFlipSettings({ (result) in
                guard case let .success(settings) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, settings as? [T.SendType])
            })
        case .getTVColorSystem, .setTVColorSystem:
            apiClient.camera?.getSupportedTVColorSystems({ (result) in
                guard case let .success(settings) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, settings as? [T.SendType])
            })
        case .getCameraFunction, .setCameraFunction:
            apiClient.camera?.getSupportedCameraFunctions({ (result) in
                guard case let .success(functions) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, functions as? [T.SendType])
            })
        case .getInfraredRemoteControl, .setInfraredRemoteControl:
            apiClient.camera?.getSupportedInfraredRemoteControls({ (result) in
                guard case let .success(functions) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, functions as? [T.SendType])
            })
        case .getAutoPowerOff, .setAutoPowerOff:
            apiClient.camera?.getSupportedAutoPowerOffs({ (result) in
                guard case let .success(intervals) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, intervals as? [T.SendType])
            })
        case .getBeepMode, .setBeepMode:
            apiClient.camera?.getSupportedBeepModes({ (result) in
                guard case let .success(modes) = result else {
                    callback(true, nil, nil)
                    return
                }
                callback(true, nil, modes as? [T.SendType])
            })
        default:
            callback(true, nil, nil)
        }
    }
    
    public func isFunctionAvailable<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
        guard let methodName = function.function.sonyCameraMethodName else {
            callback(false, nil, nil)
            return
        }
        
        if let model = modelEnum, !SonyCamera.Model.supporting(function: function.function).contains(model) && !function.function.requiresAPICheckForSupport {
            callback(false, nil, nil)
            return
        }
        
        guard function.function != .setCurrentTime else {
            
            guard apiClient.system != nil else {
                callback(false, nil, nil)
                return
            }
            
            supportsFunction(function) { (supported, error, sendType) in
                callback(supported, error, sendType)
            }
            
            return
        }
        
        guard !function.function.isAVContentFunction else {
            
            guard let avCamera = apiClient.avContent else {
                callback(false, nil, nil)
                return
            }
            
            supportsFunction(function) { (supported, error, sendType) in
                
                guard let _supported = supported, _supported else {
                    callback(false, nil, nil)
                    return
                }
                
                switch function.function {
                case .listSchemes, .listSources, .setStreamingContent:
                    callback(true, nil, nil)
                    
                case .startStreaming:
                    
                    self.checkCameraStatus(is: .readyForContentsTransfer, andShootModeIs: nil, with: { (error, matches) in
                        if let error = error {
                            callback(false, error, nil)
                        } else {
                            callback(matches, nil, nil)
                        }
                    })
                    
                case .pauseStreaming, .seekStreamingPosition, .stopStreaming, .getStreamingStatus:
                    
                    self.checkCameraStatus(is: .streamingMovie, andShootModeIs: nil, with: { (error, matches) in
                        if let error = error {
                            callback(false, error, nil)
                        } else {
                            callback(matches, nil, nil)
                        }
                    })
                    
                case .getContentCount:
                    
                    guard let versions = avCamera.versions, versions.contains("1.2") else {
                        callback(false, FunctionError.notSupportedByAvailableVersion, nil)
                        return
                    }
                    
                    self.checkCameraFunctionIs("Contents Transfer", with: { (error, matches) in
                        callback(matches, error, nil)
                    })
                    
                case .listContent:
                    
                    guard let versions = avCamera.versions, versions.contains("1.3") else {
                        callback(false, FunctionError.notSupportedByAvailableVersion, nil)
                        return
                    }
                    
                    self.checkCameraFunctionIs("Contents Transfer", with: { (error, matches) in
                        callback(matches, error, nil)
                    })
                    
                case .deleteContent:
                    
                    guard let versions = avCamera.versions, versions.contains("1.1") else {
                        callback(false, FunctionError.notSupportedByAvailableVersion, nil)
                        return
                    }
                    
                    self.checkCameraStatus(is: .readyForContentsTransfer, andShootModeIs: nil, with: { (error, matches) in
                        if let error = error {
                            callback(false, error, nil)
                        } else {
                            callback(matches, nil, nil)
                        }
                    })
                    
                default:
                    callback(false, nil, nil)
                }
            }
            
            return
        }
        
        guard let camera = apiClient.camera else {
            callback(false, nil, nil)
            return
        }
        
        camera.getAvailableApiList { (result) in
            
            guard case let .success(apiList) = result else {
                
                if case let .failure(error) = result {
                    callback(false, error, nil)
                } else {
                    callback(false, nil, nil)
                }
                return
            }
            
            // If we don't have a sony camera method name for it, then it isn't available!
            guard apiList.contains(methodName) else {
                callback(false, nil, nil)
                return
            }
            
            // Try and get the available values so we can send them back to the caller
            switch function.function {
                
            case .setShootMode:
                
                self.apiClient.camera?.getAvailableShootModes() { (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                }
                
            case .takePicture, .startContinuousShooting, .endContinuousShooting, .startBulbCapture:
                
                self.checkCameraStatus(is: .idle, andShootModeIs: .photo, with: { (error, matches) in
                    if let error = error {
                        callback(false, error, nil)
                    } else {
                        callback(matches, nil, nil)
                    }
                })
                
            case .startVideoRecording, .endVideoRecording:
                
                self.checkCameraStatus(is: .idle, andShootModeIs: .video, with: { (error, matches) in
                    if let error = error {
                        callback(false, error, nil)
                    } else {
                        callback(matches, nil, nil)
                    }
                })
                
            case .startAudioRecording, .endAudioRecording:
                
                self.checkCameraStatus(is: .idle, andShootModeIs: .audio, with: { (error, matches) in
                    if let error = error {
                        callback(false, error, nil)
                    } else {
                        callback(matches, nil, nil)
                    }
                })
                
            case .startIntervalStillRecording, .endIntervalStillRecording:
                
                self.checkCameraStatus(is: .idle, andShootModeIs: .interval, with: { (error, matches) in
                    if let error = error {
                        callback(false, error, nil)
                    } else {
                        callback(matches, nil, nil)
                    }
                })
                
            case .startLoopRecording, .endLoopRecording:
                
                self.checkCameraStatus(is: .idle, andShootModeIs: .loop, with: { (error, matches) in
                    if let error = error {
                        callback(false, error, nil)
                    } else {
                        callback(matches, nil, nil)
                    }
                })
                
            case .startLiveViewWithQuality, .setLiveViewQuality:
                
                self.apiClient.camera?.getAvailableLiveViewSizes({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setZoomSetting:
                
                self.apiClient.camera?.getAvailableZoomSettings({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setTrackingFocus:
                
                self.apiClient.camera?.getAvailableTrackingFocusses({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setContinuousShootingMode:
                
                self.apiClient.camera?.getAvailableContinuousShootingModes({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setContinuousShootingSpeed:
                
                self.apiClient.camera?.getAvailableContinuousShootingSpeeds({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setSelfTimerDuration:
                
                self.apiClient.camera?.getAvailableSelfTimerDurations({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setExposureMode:
                
                self.apiClient.camera?.getAvailableExposureModes({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setFocusMode:
                
                self.apiClient.camera?.getAvailableFocusModes({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setExposureCompensation:
                
                self.apiClient.camera?.getAvailableExposureCompensations({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setAperture:
                
                self.apiClient.camera?.getAvailableApertures() { (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                }
                
            case .setWhiteBalance:
                
                self.apiClient.camera?.getAvailableWhiteBalances({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setISO:
                
                self.apiClient.camera?.getAvailableISOValues({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setShutterSpeed:
                
                self.apiClient.camera?.getAvailableShutterSpeeds({ (response) in
                    guard case let .success(values) = response, let _values = values as? [T.SendType] else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, _values)
                })
                
            case .setProgramShift:
                
                self.apiClient.camera?.getSupportedProgramShifts({ (result) in
                    guard case let .success(shifts) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, shifts as? [T.SendType])
                })
                
            case .setFlashMode:
                
                self.apiClient.camera?.getAvailableFlashModes({ (result) in
                    guard case let .success(flashModes) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, flashModes as? [T.SendType])
                })
                
            case .setStillSize:
                
                self.apiClient.camera?.getAvailableStillSizes({ (result) in
                    guard case let .success(sizes) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, sizes as? [T.SendType])
                })
                
            case .setStillQuality:
                
                self.apiClient.camera?.getAvailableStillQualities({ (result) in
                    guard case let .success(qualities) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, qualities as? [T.SendType])
                })
                
            case .setStillFormat:
                
                self.apiClient.camera?.getAvailableStillFormats({ (result) in
                    guard case let .success(formats) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, formats as? [T.SendType])
                })
                
            case .setPostviewImageSize:
                
                self.apiClient.camera?.getAvailablePostviewImageSizes({ (result) in
                    guard case let .success(qualities) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, qualities as? [T.SendType])
                })
                
            case .setVideoFileFormat:
                
                self.apiClient.camera?.getAvailableMovieFileFormats({ (result) in
                    guard case let .success(formats) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, formats as? [T.SendType])
                })
                
            case .setVideoQuality:
                
                self.apiClient.camera?.getAvailableMovieQualities({ (result) in
                    guard case let .success(qualities) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, qualities as? [T.SendType])
                })
                
            case .setSteadyMode:
                
                self.apiClient.camera?.getAvailableSteadyModes({ (result) in
                    guard case let .success(modes) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, modes as? [T.SendType])
                })
                
            case .setViewAngle:
                
                self.apiClient.camera?.getAvailableViewAngles({ (result) in
                    guard case let .success(angles) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, angles as? [T.SendType])
                })
                
            case .setScene:
                
                self.apiClient.camera?.getAvailableSceneSelections({ (result) in
                    guard case let .success(scenes) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, scenes as? [T.SendType])
                })
                
            case .setColorSetting:
                
                self.apiClient.camera?.getAvailableColorSettings({ (result) in
                    guard case let .success(settings) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, settings as? [T.SendType])
                })
                
            case .setIntervalTime:
                
                self.apiClient.camera?.getAvailableIntervalTimes({ (result) in
                    guard case let .success(times) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, times as? [T.SendType])
                })
                
            case .setLoopRecordDuration:
                
                self.apiClient.camera?.getAvailableLoopDurations({ (result) in
                    guard case let .success(durations) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, durations as? [T.SendType])
                })
                
            case .setWindNoiseReduction:
                
                self.apiClient.camera?.getAvailableWindNoiseReductions({ (result) in
                    guard case let .success(settings) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, settings as? [T.SendType])
                })
                
            case .setAudioRecording:
                
                self.apiClient.camera?.getAvailableAudioRecordingSettings({ (result) in
                    guard case let .success(settings) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, settings as? [T.SendType])
                })
                
            case .setFlipSetting:
                
                self.apiClient.camera?.getAvailableFlipSettings({ (result) in
                    guard case let .success(settings) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, settings as? [T.SendType])
                })
                
            case .setTVColorSystem:
                
                self.apiClient.camera?.getAvailableTVColorSystems({ (result) in
                    guard case let .success(settings) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, settings as? [T.SendType])
                })
                
            case .setCameraFunction:
                
                self.apiClient.camera?.getAvailableCameraFunctions({ (result) in
                    guard case let .success(functions) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, functions as? [T.SendType])
                })
                
            case .setInfraredRemoteControl:

                self.apiClient.camera?.getAvailableInfraredRemoteControls({ (result) in
                    guard case let .success(functions) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, functions as? [T.SendType])
                })
                
            case .setAutoPowerOff:
                
                self.apiClient.camera?.getAvailableAutoPowerOffs({ (result) in
                    guard case let .success(durations) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, durations as? [T.SendType])
                })
                
            case .setBeepMode:
                
                self.apiClient.camera?.getAvailableBeepModes({ (result) in
                    guard case let .success(modes) = result else {
                        callback(true, nil, nil)
                        return
                    }
                    callback(true, nil, modes as? [T.SendType])
                })
                
            default:
                callback(true, nil, nil)
            }
        }
    }
    
    private func checkCameraStatus(is status: CameraStatus, andShootModeIs shootMode: ShootingMode?, with completion: @escaping (Error?, Bool) -> Void) {
        
        guard let cameraClient = apiClient.camera else {
            completion(FunctionError.notAvailable, false)
            return
        }
        
        cameraClient.getEvent(polling: false) { (result) in
            
            switch result {
            case .success(let event):
                
                guard let shootMode = shootMode else {
                    completion(nil, status == event.status)
                    return
                }
                
                guard let eventShootMode = event.shootMode else {
                    completion(nil, false)
                    return
                }
                
                completion(nil, status == event.status && eventShootMode.current == shootMode)
                
            case .failure(let error):
                completion(error, false)
            }
        }
    }
    
    private func checkCameraFunctionIs(_ function: String, with completion: @escaping (Error?, Bool) -> Void) {
        
        guard let cameraClient = apiClient.camera else {
            completion(FunctionError.notAvailable, false)
            return
        }
        
        cameraClient.getEvent(polling: false) { (result) in
            
            switch result {
            case .success(let event):
                
                guard let eventFunction = event.function else {
                    completion(nil, false)
                    return
                }
                
                completion(nil, function == eventFunction.current)
                
            case .failure(let error):
                completion(error, false)
            }
        }
    }
    
    public func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
        guard function.function != .ping else {
            
            guard let host = baseURL?.host else {
                callback(FunctionError.notAvailable, nil)
                return
            }
            
            Pinger.ping(hostName: host, timeout: 2.0) { (interval, error) in
                callback(error, nil)
            }
            
            return
        }
        
        guard function.function != .setCurrentTime else {
            
            guard let system = apiClient.system else {
                callback(FunctionError.notAvailable, nil)
                return
            }
            
            guard let timeInformation = payload as? (date: Date, timeZone: TimeZone) else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            
            system.setCurrentTime(timeInformation.date, timeZone: timeInformation.timeZone) { (error) in
                callback(error, nil)
            }
            
            return
        }
        
        if function.function.isAVContentFunction {
            
            guard let avContent = apiClient.avContent else {
                callback(FunctionError.notAvailable, nil)
                return
            }
            
            switch function.function {
            case .listSchemes:
                
                avContent.getSchemeList() { (result) in
                    
                    switch result {
                    case .success(let schemes):
                        callback(nil, schemes as? T.ReturnType)
                    case .failure(let error):
                        callback(error, nil)
                    }
                }
                
            case .listSources:
                
                guard let scheme = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                avContent.getSourceListFor(scheme: scheme, completion: { (result) in
                    
                    switch result {
                    case .success(let sources):
                        callback(nil, sources as? T.ReturnType)
                    case .failure(let error):
                        callback(error, nil)
                    }
                })
                
            case .listContent:
                
                avContent.getContentListFor(request: (payload as? FileRequest) ?? FileRequest.sonyDefault) { (result) in
                    
                    switch result {
                    case .success(let files):
                        callback(nil, FileResponse(fullyLoaded: false, files: files) as? T.ReturnType)
                    case .failure(let error):
                        callback(error, nil)
                    }
                }
                
            case .getContentCount:
                
                avContent.getContentCountFor(request: (payload as? CountRequest) ?? CountRequest.sonyDefault) { (result) in
                    
                    switch result {
                    case .success(let count):
                        callback(nil, count as? T.ReturnType)
                    case .failure(let error):
                        callback(error, nil)
                    }
                }
                
            case .setStreamingContent:
                
                guard let content = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                avContent.setStreamingContent(content) { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let url):
                        callback(nil, url as? T.ReturnType)
                    }
                }
                
            case .startStreaming:
                
                avContent.startStreaming { (error) in
                    callback(error, nil)
                }
                
            case .pauseStreaming:
                
                avContent.pauseStreaming { (error) in
                    callback(error, nil)
                }
                
            case .stopStreaming:
                
                avContent.stopStreaming { (error) in
                    callback(error, nil)
                }
                
            case .seekStreamingPosition:
                
                avContent.seekStreamingPosition { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let position):
                        callback(nil, position as? T.ReturnType)
                    }
                }
                
            case .getStreamingStatus:
                
                guard let poll = payload as? Bool else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                avContent.getStreamingStatus(polling: poll) { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let status):
                        callback(nil, status as? T.ReturnType)
                    }
                }
                
            case .deleteContent:
                
                guard let files = payload as? [File] else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                avContent.deleteContent(uris: files.compactMap({ $0.uri })) { (error) in
                    callback(error, nil)
                }
                
            default:
                break
            }
            
        } else {
            
            guard let camera = apiClient.camera else {
                callback(FunctionError.notAvailable, nil)
                return
            }
            
            switch function.function {
            case .setShootMode:
                
                guard let shootMode = payload as? ShootingMode else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setShootMode(shootMode) { (error) in
                    callback(error, nil)
                }
                
            case .getShootMode:
                
                camera.getShootMode() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let shootMode):
                        callback(nil, shootMode as? T.ReturnType)
                    }
                }
                
            case .takePicture:
                
                let takePicture: (_ ignoreShootingFailure: Bool, _ completion: ((_ success: Bool) -> Void)?) -> Void = { ignoreShootingFailure, completion in
                    
                    camera.takePicture { (result) in
                        
                        guard case let .success(response) = result else {
                            if case let .failure(error) = result {
                                
                                Logger.log(message:"Capture failed" + (ignoreShootingFailure ? ", ignoring shooting failure" : ""), category: "SonyCamera", level: .debug)
                                
                                // If we're not ignoring the error, then call back to original caller
                                if let cameraError = error as? CameraError {
                                    switch cameraError {
                                    case .shootingFail(_):
                                        if !ignoreShootingFailure {
                                            callback(error, nil)
                                        }
                                        // Call the completion block saying shooting failed
                                        completion?(false)
                                    default:
                                        callback(error, nil)
                                    }
                                } else {
                                    callback(error, nil)
                                }
                            }
                            return
                        }
                        
                        completion?(true)

                        // If the call to takePicture tells us we need to await the response, then do so!
                        if response.needsAwait {
                            
                            camera.awaitTakePicture({ (result) in
                                switch result {
                                case .failure(let error):
                                    callback(error, nil)
                                case .success(let url):
                                    callback(nil, url as? T.ReturnType)
                                }
                            })
                            
                        } else {
                            
                            callback(nil, response.url as? T.ReturnType)
                        }
                    }
                }
                
                // Make sure our camera model requires this call! Only 3rd gen seem to
                guard let _model = modelEnum, _model.requiresHalfPressToCapture else {
                    Logger.log(message:"\(modelEnum?.friendlyName ?? "Unknown") doesn't require half press to focus, skipping step", category: "SonyCamera", level: .debug)
                    takePicture(false, nil)
                    return
                }
                
                // Make sure is in AF, otherwise we don't need to call half-press. If we don't have focusMode yet, then call halfPress
                // as it will fail anyway if the camera is in MF
                guard lastNonNilFocusState != .focusing || lastNonNilFocusState == nil else {
                    Logger.log(message:"Camera already focussing (\(lastNonNilFocusState?.debugString ?? "Unknown")), skipping half press shutter", category: "SonyCamera", level: .debug)
                    takePicture(false, nil)
                    return
                }
                
                guard focusMode == nil || focusMode!.isAutoFocus else {
                    Logger.log(message:"Camera not in AF mode, skipping half-press shutter", category: "SonyCamera", level: .debug)
                    takePicture(false, nil)
                    return
                }
                
                supportsFunction(Shutter.halfPress) { [weak self] (supports, _, _) in
                    
                    guard let this = self, let _supports = supports, _supports else {
                        Logger.log(message:"Camera doesn't support shutter half press, skipping", category: "SonyCamera", level: .debug)
                        takePicture(false, nil)
                        return
                    }
                    
                    // Perform a half-press of the shutter
                    this.performFunction(Shutter.halfPress, payload: nil, callback: { (error, _) in
                                                
                        Logger.log(message:"Half-press completed, attempting capture", category: "SonyCamera", level: .debug)
                        
                        // Take picture immediately after half press has completed, two scenarios here:
                        // 1. User is in MF, this takePicture should succeed and take the photo
                        // 2. User is in AF, this takePicture could fail (which we ignore), and then we wait for focus change
                        takePicture(false, { success in
                            
                            // If the take picture failed, then we'll await the focus change from `Shutter.halfPress`
                            guard !success else {
                                Logger.log(message:"Take picture succeeded, camera either in MF or already focussed", category: "SonyCamera", level: .debug)
                                return
                            }
                            
                            Logger.log(message:"Take picture failed, nothing we can do...", category: "SonyCamera", level: .debug)
                        })
                    })
                }
                
            case .startBulbCapture:
                
                camera.startBulbShooting { (error) in
                    callback(error, nil)
                }
                
            case .endBulbCapture:
                
                camera.stopBulbShooting { (error) in
                    callback(error, nil)
                }
                
            case .endContinuousShooting:
                
                camera.stopContinuousShooting() { (error) in
                    callback(error, nil)
                }
                
            case .startContinuousShooting:
                
                camera.startContinuousShooting { (error) in
                    callback(error, nil)
                }
                
            case .startVideoRecording:
                
                camera.startMovieRecording() { (error) in
                    callback(error, nil)
                }
                
            case .endVideoRecording:
                
                camera.stopMovieRecording() { (error) in
                    callback(error, nil)
                }
                
            case .startAudioRecording:
                
                camera.startAudioRecording() { (error) in
                    callback(error, nil)
                }
                
            case .endAudioRecording:
                
                camera.stopAudioRecording() { (error) in
                    callback(error, nil)
                }
                
            case .startIntervalStillRecording:
                
                camera.startIntervalRecording() { (error) in
                    callback(error, nil)
                }
                
            case .endIntervalStillRecording:
                
                camera.stopIntervalRecording() { (error) in
                    callback(error, nil)
                }
                
            case .startLoopRecording:
                
                camera.startLoopRecording() { (error) in
                    callback(error, nil)
                }
                
            case .endLoopRecording:
                
                camera.stopLoopRecording() { (error) in
                    callback(error, nil)
                }
                
            case .startLiveView:
                
                camera.startLiveView { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let url):
                        callback(nil, url as? T.ReturnType)
                    }
                }
                
            case .startLiveViewWithQuality:
                
                guard let size = payload as? LiveView.Quality else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.startLiveViewWithSize(size, { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let url):
                        callback(nil, url as? T.ReturnType)
                    }
                })
                
            case .getLiveViewQuality:
                
                camera.getLiveViewSize { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let quality):
                        callback(nil, quality as? T.ReturnType)
                    }
                }
                
            case .setLiveViewQuality:
                
                guard let quality = payload as? LiveView.Quality else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setLiveViewSize(size: quality) { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let url):
                        callback(
                            nil,
                            url as? T.ReturnType
                        )
                    }
                }
                
            case .endLiveView:
                
                camera.stopLiveView({ (error) in
                    callback(error, nil)
                })
                
            case .setSendLiveViewFrameInfo:
                
                guard let bool = payload as? Bool else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setLiveViewFrameInfo(bool) { (error) in
                    callback(error, nil)
                }
                
            case .getSendLiveViewFrameInfo:
                
                camera.getLiveViewFrameInfo() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let send):
                        callback(nil, send as? T.ReturnType)
                    }
                }
                
            case .startZooming, .stopZooming:
                
                guard let direction = payload as? Zoom.Direction else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.zoom(in: direction, start: function.function == .startZooming) { (error) in
                    callback(error, nil)
                }
                
            case .setZoomSetting:
                
                guard let setting = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setZoomSetting(setting) { (error) in
                    callback(error, nil)
                }
                
            case .getZoomSetting:
                
                camera.getZoomSetting() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let aperture):
                        callback(nil, aperture as? T.ReturnType)
                    }
                }
                
            case .halfPressShutter:
                
                camera.halfPressShutter { (error) in
                    callback(error, nil)
                }
                
            case .cancelHalfPressShutter:
                
                camera.cancelHalfPressShutter { (error) in
                    callback(error, nil)
                }
                
            case .setTouchAFPosition:
                
                guard let position = payload as? CGPoint else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setTouchAFPosition(position) { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let position):
                        callback(nil, position as? T.ReturnType)
                    }
                }
                
            case .getTouchAFPosition:
                
                camera.getTouchAFPosition() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let position):
                        callback(nil, position as? T.ReturnType)
                    }
                }
                
            case .cancelTouchAFPosition:
                
                camera.cancelTouchAFPosition() { (error) in
                    callback(error, nil)
                }
                
            case .startTrackingFocus:
                
                guard let position = payload as? CGPoint else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.startTrackingFocus(position) { (error) in
                    callback(error, nil)
                }
                
            case .stopTrackingFocus:
                
                camera.cancelTrackingFocus() { (error) in
                    callback(error, nil)
                }
                
            case .setTrackingFocus:
                
                guard let stringValue = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setTrackingFocus(stringValue) { (error) in
                    callback(error, nil)
                }
                
            case .getTrackingFocus:
                
                camera.getTrackingFocus() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let aperture):
                        callback(nil, aperture as? T.ReturnType)
                    }
                }
                
            case .setContinuousShootingMode:
                
                guard let mode = payload as? ContinuousCapture.Mode.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setContinuousShootingMode(mode) { (error) in
                    callback(error, nil)
                }
                
            case .getContinuousShootingMode:
                
                camera.getContinuousShootingMode() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let aperture):
                        callback(nil, aperture as? T.ReturnType)
                    }
                }
                
            case .setContinuousShootingSpeed:
                
                guard let speed = payload as? ContinuousCapture.Speed.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setContinuousShootingSpeed(speed) { (error) in
                    callback(error, nil)
                }
                
            case .getContinuousShootingSpeed:
                
                camera.getContinuousShootingSpeed() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let aperture):
                        callback(nil, aperture as? T.ReturnType)
                    }
                }
                
            case .setSelfTimerDuration:
                
                guard let duration = payload as? TimeInterval else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setSelfTimerDuration(duration) { (error) in
                    callback(error, nil)
                }
                
            case .getSelfTimerDuration:
                
                camera.getSelfTimerDuration { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let aperture):
                        callback(nil, aperture as? T.ReturnType)
                    }
                }
                
            case .setExposureMode:
                
                guard let mode = payload as? Exposure.Mode.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setExposureMode(mode) { (error) in
                    callback(error, nil)
                }
                
            case .getExposureMode:
                
                camera.getExposureMode() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let aperture):
                        callback(nil, aperture as? T.ReturnType)
                    }
                }
                
            case .setExposureCompensation:
                
                guard let compensation = payload as? Exposure.Compensation.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                // Get available compensation values.
                camera.getAvailableExposureCompensations { (result) in
                    
                    switch result {
                    case .success(let availableCompensations):
                        
                        // Find the zero-based index of the compensation we are trying to set.
                        guard let index = availableCompensations.firstIndex(where: {
                            Double.equal($0.value, compensation.value, precision: 2)
                        }) else {
                            callback(FunctionError.invalidPayload, nil)
                            return
                        }
                        guard let zeroIndex = availableCompensations.firstIndex(where: {
                            Double.equal($0.value, 0.0, precision: 4)
                        }) else {
                            callback(FunctionError.invalidPayload, nil)
                            return
                        }
                        
                        // Convert it from a zero-based index to an offset from zero.
                        //  0      1        2    3     4       5    6
                        //[-1, -0.6666, -0.3333, 0, 0.3333, 0.6666, 1]
                        //  -3    -2       -1    0     1       2    3
                        let actualIndex = index - zeroIndex
                        
                        camera.setExposureCompensation(actualIndex, { (error) in
                            callback(error, nil)
                        })
                        
                    case .failure(let error):
                        callback(error, nil)
                    }
                }
                
            case .getExposureCompensation:
                
                camera.getAvailableExposureCompensations { (result) in
                    
                    switch result {
                    case .success(let availableCompensations):
                        
                        camera.getExposureCompensation({ (result) in
                            
                            switch result {
                            case .failure(let error):
                                callback(error, nil)
                            case .success(let compensationIndex):
                                
                                guard let zeroIndex = availableCompensations.firstIndex(where: { $0.value == 0.0 }) else {
                                    callback(FunctionError.invalidResponse, nil)
                                    return
                                }
                                
                                // Convert offset from zero index back to correct zero based index
                                //  -3    -2       -1    0     1       2    3
                                //[-1, -0.6666, -0.3333, 0, 0.3333, 0.6666, 1]
                                //   0     1        2    3     4       5    6
                                let index = compensationIndex + zeroIndex
                                guard index >= 0 && index < availableCompensations.count else {
                                    callback(FunctionError.invalidResponse, nil)
                                    return
                                }
                                
                                callback(nil, availableCompensations[index] as? T.ReturnType)
                            }
                        })
                        
                    case .failure(let error):
                        callback(error, nil)
                    }
                }
                
            case .setFocusMode:
                
                guard let mode = payload as? Focus.Mode.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setFocusMode(mode) { (error) in
                    callback(error, nil)
                }
                
            case .getFocusMode:
                
                camera.getFocusMode() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let aperture):
                        callback(nil, aperture as? T.ReturnType)
                    }
                }
                
            case .setAperture:
                
                guard let aperture = payload as? Aperture.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setAperture(aperture) { (error) in
                    callback(error, nil)
                }
                
            case .getAperture:
                
                camera.getAperture() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let aperture):
                        callback(nil, aperture as? T.ReturnType)
                    }
                }
                
            case .setISO:
                
                guard let ISO = payload as? ISO.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setISO(ISO) { (error) in
                    callback(error, nil)
                }
                
            case .getISO:
                
                camera.getISO() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let ISO):
                        callback(nil, ISO as? T.ReturnType)
                    }
                }
                
            case .setWhiteBalance:
                
                guard let whiteBalance = payload as? WhiteBalance.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setWhiteBalance(whiteBalance) { (error) in
                    callback(error, nil)
                }
                
            case .getWhiteBalance:
                
                camera.getWhiteBalance() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let whiteBalance):
                        callback(nil, whiteBalance as? T.ReturnType)
                    }
                }
                
            case .setupCustomWhiteBalanceFromShot:
                
                camera.setCustomWhiteBalanceFromShot { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let whiteBalance):
                        callback(nil, whiteBalance as? T.ReturnType)
                    }
                }
                
            case .setShutterSpeed:
                
                guard let shutterSpeed = payload as? ShutterSpeed else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setShutterSpeed(shutterSpeed) { (error) in
                    callback(error, nil)
                }
                
            case .getShutterSpeed:
                
                camera.getShutterSpeed() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let shutterSpeed):
                        callback(nil, shutterSpeed as? T.ReturnType)
                    }
                }
                
            case .setProgramShift:
                
                guard let shift = payload as? Int else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setProgramShift(shift) { (error) in
                    callback(error, nil)
                }
                
            case .setFlashMode:
                
                guard let flashMode = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setFlashMode(flashMode) { (error) in
                    callback(error, nil)
                }
                
            case .getFlashMode:
                
                camera.getFlashMode() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let flashMode):
                        callback(nil, flashMode as? T.ReturnType)
                    }
                }
                
            case .setStillSize:
                
                guard let size = payload as? StillCapture.Size.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setStillSize(size) { (error) in
                    callback(error, nil)
                }
                
            case .getStillSize:
                
                camera.getStillSize() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let size):
                        callback(nil, size as? T.ReturnType)
                    }
                }
                
            case .setStillQuality:
                
                guard let quality = payload as? StillCapture.Quality.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setStillQuality(quality) { (error) in
                    callback(error, nil)
                }
                
            case .getStillQuality:
                
                camera.getStillQuality() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let quality):
                        callback(nil, quality as? T.ReturnType)
                    }
                }
                
            case .setStillFormat:
                
                guard let format = payload as? StillCapture.Format.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setStillFormat(format) { (error) in
                    callback(error, nil)
                }
                
            case .getStillFormat:
                
                camera.getStillFormat() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let quality):
                        callback(nil, quality as? T.ReturnType)
                    }
                }
                
            case .setPostviewImageSize:
                
                guard let size = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setPostviewImageSize(size) { (error) in
                    callback(error, nil)
                }
                
            case .getPostviewImageSize:
                
                camera.getPostviewImageSize() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let size):
                        callback(nil, size as? T.ReturnType)
                    }
                }
                
            case .setVideoFileFormat:
                
                guard let format = payload as? VideoCapture.FileFormat.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setMovieFileFormat(format) { (error) in
                    callback(error, nil)
                }
                
            case .getVideoFileFormat:
                
                camera.getMovieFileFormat() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let format):
                        callback(nil, format as? T.ReturnType)
                    }
                }
                
            case .setVideoQuality:
                
                guard let quality = payload as? VideoCapture.Quality.Value else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setMovieQuality(quality) { (error) in
                    callback(error, nil)
                }
                
            case .getVideoQuality:
                
                camera.getMovieQuality() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let quality):
                        callback(nil, quality as? T.ReturnType)
                    }
                }
                
            case .setSteadyMode:
                
                guard let mode = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setSteadyMode(mode) { (error) in
                    callback(error, nil)
                }
                
            case .getSteadyMode:
                
                camera.getSteadyMode() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let mode):
                        callback(nil, mode as? T.ReturnType)
                    }
                }
                
            case .setViewAngle:
                
                guard let angle = payload as? Double else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setViewAngle(angle) { (error) in
                    callback(error, nil)
                }
                
            case .getViewAngle:
                
                camera.getViewAngle() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let angle):
                        callback(nil, angle as? T.ReturnType)
                    }
                }
                
            case .setScene:
                
                guard let scene = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setSceneSelection(scene) { (error) in
                    callback(error, nil)
                }
                
            case .getScene:
                
                camera.getSceneSelection() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let scene):
                        callback(nil, scene as? T.ReturnType)
                    }
                }
                
            case .setColorSetting:
                
                guard let colorSetting = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setColorSetting(colorSetting) { (error) in
                    callback(error, nil)
                }
                
            case .getColorSetting:
                
                camera.getColorSetting() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let setting):
                        callback(nil, setting as? T.ReturnType)
                    }
                }
                
            case .setIntervalTime:
                
                guard let interval = payload as? TimeInterval else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setIntervalTime(interval) { (error) in
                    callback(error, nil)
                }
                
            case .getIntervalTime:
                
                camera.getIntervalTime() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let time):
                        callback(nil, time as? T.ReturnType)
                    }
                }
                
            case .setLoopRecordDuration:
                
                guard let duration = payload as? TimeInterval else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setLoopDuration(duration) { (error) in
                    callback(error, nil)
                }
                
            case .getLoopRecordDuration:
                
                camera.getLoopDuration() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let duration):
                        callback(nil, duration as? T.ReturnType)
                    }
                }
                
            case .setWindNoiseReduction:
                
                guard let setting = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setWindNoiseReduction(setting) { (error) in
                    callback(error, nil)
                }
                
            case .getWindNoiseReduction:
                
                camera.getWindNoiseReduction() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let duration):
                        callback(nil, duration as? T.ReturnType)
                    }
                }
                
            case .setAudioRecording:
                
                guard let setting = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setAudioRecordingSetting(setting) { (error) in
                    callback(error, nil)
                }
                
            case .getAudioRecording:
                
                camera.getAudioRecordingSetting() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let duration):
                        callback(nil, duration as? T.ReturnType)
                    }
                }
                
            case .setFlipSetting:
                
                guard let setting = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setFlipSetting(setting) { (error) in
                    callback(error, nil)
                }
                
            case .getFlipSetting:
                
                camera.getFlipSetting() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let flipSetting):
                        callback(nil, flipSetting as? T.ReturnType)
                    }
                }
                
            case .setTVColorSystem:
                
                guard let colorSystem = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setTVColorSystem(colorSystem) { (error) in
                    callback(error, nil)
                }
                
            case .getTVColorSystem:
                
                camera.getTVColorSystem() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let system):
                        callback(nil, system as? T.ReturnType)
                    }
                }
                
            case .getCameraFunction:
                
                camera.getCameraFunction() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let function):
                        callback(nil, function as? T.ReturnType)
                    }
                }
                
            case .setCameraFunction:
                
                guard let function = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setCameraFunction(function) { (error) in
                    callback(error, nil)
                }
                
            case .getInfraredRemoteControl:

                camera.getInfraredRemoteControl() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let remoteControl):
                        callback(nil, remoteControl as? T.ReturnType)
                    }
                }

            case .setInfraredRemoteControl:

                guard let remoteControl = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }

                camera.setInfraredRemoteControl(remoteControl) { (error) in
                    callback(error, nil)
                }
                
            case .getAutoPowerOff:
                
                camera.getAutoPowerOff() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let powerOff):
                        callback(nil, powerOff as? T.ReturnType)
                    }
                }
                
            case .setAutoPowerOff:
                
                guard let interval = payload as? TimeInterval else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setAutoPowerOff(interval) { (error) in
                    callback(error, nil)
                }
                
            case .getBeepMode:
                
                camera.getBeepMode() { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let beepMode):
                        callback(nil, beepMode as? T.ReturnType)
                    }
                }
                
            case .setBeepMode:
                
                guard let mode = payload as? String else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.setBeepMode(mode) { (error) in
                    callback(error, nil)
                }
                
            case .getStorageInformation:
                
                camera.getStorageInformation { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let informations):
                        callback(nil, informations as? T.ReturnType)
                    }
                }
                
            case .getEvent:
                
                guard let poll = payload as? Bool else {
                    callback(FunctionError.invalidPayload, nil)
                    return
                }
                
                camera.getEvent(polling: poll) { (result) in
                    switch result {
                    case .failure(let error):
                        callback(error, nil)
                    case .success(let informations):
                        
                        var event = informations
                        
                        // Check if shutterSpeed has changed away from Bulb! Sony doesn't have a "Bulb" shooting mode, so
                        // we need to do this automatically!
                        if let shutterSpeed = informations.shutterSpeed, let lastShootMode = self.lastShootMode, !shutterSpeed.current.isBulb && self.lastShutterSpeed?.isBulb == true {
                            event.shootMode = (current: lastShootMode, available: informations.shootMode?.available ?? [], supported: informations.shootMode?.supported ?? [])
                        }
                        
                        // Only track this if we're not bulb shooting
                        if let shootMode = event.shootMode?.current, shootMode != .bulb {
                            self.lastShootMode = shootMode
                            // If the camera was launched in bulb mode!
                        } else if let shootMode = event.shootMode?.current, shootMode == .bulb, self.lastShootMode == nil {
                            self.lastShootMode = .photo
                        }
                        
                        if let shutterSpeed = informations.shutterSpeed {
                            self.lastShutterSpeed = shutterSpeed.current
                        }
                        
                        callback(nil, event as? T.ReturnType)
                    }
                }
                
            default:
                break
            }
        }
    }
}


