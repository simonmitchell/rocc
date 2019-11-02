//
//  CameraClient.swift
//  Rocc
//
//  Created by Simon Mitchell on 25/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

#if os(macOS)
import ThunderRequestMac
#else
import ThunderRequest
#endif

fileprivate extension ShootingMode {
    
    init?(sonyString: String) {
        guard let mode = ShootingMode.allCases.first(where: { $0.sonyString == sonyString }) else { return nil }
        self = mode
    }
    
    var sonyString: String {
        switch self {
        case .photo, .timelapse, .continuous:
            return "still"
        case .interval:
            return "intervalstill"
        case .audio:
            return "audio"
        case .video:
            return "movie"
        case .loop:
            return "looprec"
        case .bulb:
            return "bulb"
        }
    }
}

fileprivate extension ContinuousShootingMode {
    var sonyString: String {
        switch self {
        case .continuous, .single:
            return rawValue.capitalized
        case .spdPriorityContinuous:
            return "Spd Priority Cont."
        }
    }
}

fileprivate extension ContinuousShootingSpeed {
    
    init?(sonyString: String) {
        switch sonyString {
        case "Hi":
            self = .high
        case "Low":
            self = .low
        default:
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
        case .high:
            return "Hi"
        case .low:
            return "Low"
        }
    }
}

fileprivate extension FocusStatus {
    
    init?(sonyString: String) {
        switch sonyString {
        case "Not Focusing":
            self = .notFocussing
        case "Failed":
            self = .failed
        case "Focusing":
            self = .focusing
        case "Focused":
            self = .focused
        default:
            return nil
        }
    }
}

fileprivate func exposureCompensationsFor(lowerIndex: Int, upperIndex: Int, stepSize: Int) -> [Double] {
    
    var compensations: [Double] = []
    let step: Double
    
    switch stepSize {
    case 1:
        step = 1.0/3.0
    case 2:
        step = 1.0/2.0
    default:
        step = 1.0/2.0
        break
    }
    
    for i in lowerIndex...upperIndex {
        compensations.append(Double(i) * step)
    }
    
    return compensations
}

fileprivate extension CameraEvent.BatteryInformation {
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let id = dictionary["batteryID"] as? String else { return nil }
        guard let denominator = dictionary["levelDenom"] as? Int, let numerator = dictionary["levelNumer"] as? Int else {
            return nil
        }
        
        identifier = id
        
        if let statusString = dictionary["status"] as? String {
            switch statusString {
            case "active":
                status = .active
            case "inactive":
                status = .inactive
            default:
                status = .unknown
            }
        } else {
            status = .unknown
        }
        
        if let additionalStatus = dictionary["additionalStatus"] as? String {
            switch additionalStatus {
            case "batteryNearEnd":
                chargeStatus = .nearEnd
            case "charging":
                chargeStatus = .charging
            default:
                chargeStatus = nil
            }
        } else {
            chargeStatus = nil
        }
        
        description = dictionary["description"] as? String
        
        guard denominator > 0 || numerator >= 0 else {
            level = 0.0
            return
        }
        
        level = Double(numerator) / Double(denominator)
    }
}

fileprivate extension CameraStatus {
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "error":
            self = .error
            break
        case "notready":
            self = .notReady
            break
        case "idle":
            self = .idle
            break
        case "stillcapturing":
            self = .capturingStill
            break
        case "stillsaving":
            self = .savingStill
            break
        case "moviewaitrecstart":
            self = .startingMovieRecording
            break
        case "movierecording":
            self = .recordingMovie
            break
        case "moviewaitrecstop":
            self = .stoppingMovieRecording
            break
        case "moviesaving":
            self = .savingMovie
            break
        case "audiowaitrecstart":
            self = .startingAudioRecording
            break
        case "audiorecording":
            self = .recordingAudio
            break
        case "audiowaitrecstop":
            self = .stoppingAudioRecording
            break
        case "audiosaving":
            self = .savingAudio
            break
        case "intervalwaitrecstart":
            self = .startingIntervalStillCapture
            break
        case "intervalrecording":
            self = .capturingIntervalStills
            break
        case "intervalwaitrecstop":
            self = .stoppingIntervalStillCapture
            break
        case "loopwaitrecstart":
            self = .startingLoopRecording
            break
        case "looprecording":
            self = .recordingLoop
            break
        case "loopwaitrecstop":
            self = .stoppingLoopRecording
            break
        case "loopsaving":
            self = .savingLoop
            break
        case "whitebalanceonepushcapturing":
            self = .capturingWhiteBalanceSetupStill
            break
        case "contentstransfer":
            self = .readyForContentsTransfer
            break
        case "streaming":
            self = .streamingMovie
            break
        case "deleting":
            self = .deletingContent
            break
        default:
            return nil
        }
    }
}

fileprivate extension CameraEvent {
    
    init(result: [Any]) {
        
        var _apiList: [String]?
        var _cameraStatus: CameraStatus?
        var _zoomPosition: Double?
        var _liveViewStatus: Bool?
        var _liveViewOrientation: String?
        var _takenPictureURLS: [[URL]] = []
        var _storageInfo: [StorageInformation] = []
        var _beepMode: (current: String, available: [String])?
        var _function: (current: String, available: [String])?
        var _functionResult: Bool = false
        var _videoQuality: (current: String, available: [String])?
        var _stillSizeInfo: StillSizeInformation?
        var _steadyMode: (current: String, available: [String])?
        var _viewAngle: (current: Double, available: [Double])?
        var _exposureMode: (current: String, available: [String])?
        var _postViewImageSize: (current: String, available: [String])?
        var _selfTimer: (current: TimeInterval, available: [TimeInterval])?
        var _shootMode: (current: ShootingMode, available: [ShootingMode]?)?
        var _exposureCompensation: (current: Double, available: [Double])?
        var _flashMode: (current: String, available: [String])?
        var _aperture: (current: String, available: [String])?
        var _focusMode: (current: String, available: [String])?
        var _ISO: (current: String, available: [String])?
        var _isProgramShifted: Bool?
        var _shutterSpeed: (current: ShutterSpeed, available: [ShutterSpeed])?
        var _whiteBalance: WhiteBalanceInformation?
        var _touchAF: TouchAF.Information?
        var _focusStatus: FocusStatus?
        var _zoomSetting: (current: String, available: [String])?
        var _stillQuality: (current: String, available: [String])?
        var _continuousShootingMode: (current: ContinuousShootingMode, available: [ContinuousShootingMode])?
        var _continuousShootingSpeed: (current: ContinuousShootingSpeed, available: [ContinuousShootingSpeed])?
        var _continuousShootingURLS: [(postView: URL, thumbnail: URL)]?
        var _flipSetting: (current: String, available: [String])?
        var _scene: (current: String, available: [String])?
        var _intervalTime: (current: TimeInterval, available: [TimeInterval])?
        var _colorSetting: (current: String, available: [String])?
        var _videoFileFormat: (current: String, available: [String])?
        var _videoRecordingTime: TimeInterval?
        var _infraredRemoteControl: (current: String, available: [String])?
        var _tvColorSystem: (current: String, available: [String])?
        var _trackingFocusStatus: String?
        var _trackingFocus: (current: String, available: [String])?
        var _batteryInfo: [BatteryInformation]?
        var _numberOfShots: Int?
        var _autoPowerOff: (current: TimeInterval, available: [TimeInterval])?
        var _loopRecordTime: (current: TimeInterval, available: [TimeInterval])?
        var _audioRecording: (current: String, available: [String])?
        var _windNoiseReduction: (current: String, available: [String])?
        var _bulbCapturingTime: TimeInterval?
        var _bulbShootingURL: URL?
        
        result.forEach { (eventElement) in
            
            if let dictionaryElement = eventElement as? [AnyHashable : Any], let type = dictionaryElement["type"] as? String {
                
                switch type {
                case "bulbShooting":
                    guard let urlArrays = dictionaryElement["bulbShootingUrl"] as? [[AnyHashable : Any]] else {
                        return
                    }
                    guard let urlString = urlArrays.compactMap({ (dict) -> String? in
                        dict["postviewUrl"] as? String
                    }).first else {
                        return
                    }
                    _bulbShootingURL = URL(string: urlString)
                    break
                case "availableApiList":
                    _apiList = dictionaryElement["names"] as? [String]
                case "cameraStatus":
                    guard let statusString = dictionaryElement["cameraStatus"] as? String else {
                        return
                    }
                    _cameraStatus = CameraStatus(sonyString: statusString)
                case "zoomInformation":
                    
                    guard let numberOfBoxes = dictionaryElement["zoomNumberBox"] as? Int, let currentBox = dictionaryElement["zoomIndexCurrentBox"] as? Int, let currentBoxPosition = dictionaryElement["zoomPositionCurrentBox"] as? Int, numberOfBoxes > 0 else {
                        if let zoomPosition = dictionaryElement["zoomPosition"] as? Int {
                            _zoomPosition = Double(zoomPosition)/100.0
                        }
                        return
                    }
                    
                    let boxFraction = 1.0/Double(numberOfBoxes)
                    _zoomPosition = (boxFraction * Double(currentBox)) + (Double(currentBoxPosition)/100) * boxFraction
                    
                case "liveviewStatus":
                    _liveViewStatus = dictionaryElement["liveviewStatus"] as? Bool
                case "liveviewOrientation":
                    _liveViewOrientation = dictionaryElement["liveviewOrientation"] as? String
                case "beepMode":
                    guard let current = dictionaryElement["currentBeepMode"] as? String, let candidates = dictionaryElement["beepModeCandidates"] as? [String] else { return }
                    _beepMode = (current, candidates)
                case "cameraFunction":
                    guard let current = dictionaryElement["currentCameraFunction"] as? String, let candidates = dictionaryElement["cameraFunctionCandidates"] as? [String] else { return }
                    _function = (current, candidates)
                case "movieQuality":
                    guard let current = dictionaryElement["currentMovieQuality"] as? String, let candidates = dictionaryElement["movieQualityCandidates"] as? [String] else { return }
                    _videoQuality = (current, candidates)
                case "stillSize":
                    guard let check = dictionaryElement["checkAvailability"] as? Bool, let currentAspect = dictionaryElement["currentAspect"] as? String, let currentSize = dictionaryElement["currentSize"] as? String else { return }
                    _stillSizeInfo = StillSizeInformation(shouldCheck: check, stillSize: StillSize(aspectRatio: currentAspect, size: currentSize))
                case "cameraFunctionResult":
                    guard let current = dictionaryElement["cameraFunctionResult"] as? String, current == "Success" || current == "Failure" else { return }
                    _functionResult = current == "Success"
                case "steadyMode":
                    guard let current = dictionaryElement["currentSteadyMode"] as? String, let candidates = dictionaryElement["steadyModeCandidates"] as? [String] else { return }
                    _steadyMode = (current, candidates)
                case "viewAngle":
                    guard let current = dictionaryElement["currentViewAngle"] as? Int, let candidates = dictionaryElement["viewAngleCandidates"] as? [Int] else { return }
                    _viewAngle = (Double(current), candidates.map({ Double($0) }))
                case "exposureMode":
                    guard let current = dictionaryElement["currentExposureMode"] as? String, let candidates = dictionaryElement["exposureModeCandidates"] as? [String] else { return }
                    _exposureMode = (current, candidates)
                case "postviewImageSize":
                    guard let current = dictionaryElement["currentPostviewImageSize"] as? String, let candidates = dictionaryElement["postviewImageSizeCandidates"] as? [String] else { return }
                    _postViewImageSize = (current, candidates)
                case "selfTimer":
                    guard let current = dictionaryElement["currentSelfTimer"] as? Int, let candidates = dictionaryElement["selfTimerCandidates"] as? [Int] else { return }
                    _selfTimer = (TimeInterval(current), candidates.map({ TimeInterval($0) }))
                case "shootMode":
                    guard let current = dictionaryElement["currentShootMode"] as? String, let candidates = dictionaryElement["shootModeCandidates"] as? [String] else { return }
                    guard let currentEnum = ShootingMode(sonyString: current) else { return }
                    var enumCandidates = candidates.compactMap({ ShootingMode(sonyString: $0) })
                    if enumCandidates.contains(.photo) {
                        enumCandidates.append(contentsOf: [.timelapse, .continuous, .bulb])
                    }
                    _shootMode = (currentEnum, enumCandidates)
                case "exposureCompensation":
                    
                    guard let currentStep = dictionaryElement["currentExposureCompensation"] as? Int, let minIndex = dictionaryElement["minExposureCompensation"] as? Int, let maxIndex = dictionaryElement["maxExposureCompensation"] as? Int, let stepIndex = dictionaryElement["stepIndexOfExposureCompensation"] as? Int else { return }
                    
                    let compensations = exposureCompensationsFor(lowerIndex: minIndex, upperIndex: maxIndex, stepSize: stepIndex)
                    
                    let centeredIndex = compensations.count/2 + currentStep
                    guard centeredIndex < compensations.count, centeredIndex >= 0 else { return }
                    _exposureCompensation = (compensations[centeredIndex], compensations)
                    
                case "flashMode":
                    guard let current = dictionaryElement["currentFlashMode"] as? String, let candidates = dictionaryElement["flashModeCandidates"] as? [String] else { return }
                    _flashMode = (current, candidates)
                case "fNumber":
                    guard let current = dictionaryElement["currentFNumber"] as? String, let candidates = dictionaryElement["fNumberCandidates"] as? [String] else { return }
                    _aperture = (current, candidates)
                case "focusMode":
                    guard let current = dictionaryElement["currentFocusMode"] as? String, let candidates = dictionaryElement["focusModeCandidates"] as? [String] else { return }
                    _focusMode = (current, candidates)
                case "isoSpeedRate":
                    guard let current = dictionaryElement["currentIsoSpeedRate"] as? String, let candidates = dictionaryElement["isoSpeedRateCandidates"] as? [String] else { return }
                    _ISO = (current, candidates)
                case "programShift":
                    _isProgramShifted = dictionaryElement["isShifted"] as? Bool
                case "shutterSpeed":
                    let shutterSpeedFormatter = ShutterSpeedFormatter()
                    guard let currentString = dictionaryElement["currentShutterSpeed"] as? String, let current = shutterSpeedFormatter.shutterSpeed(from: currentString), let candidateStrings = dictionaryElement["shutterSpeedCandidates"] as? [String] else { return }
                    _shutterSpeed = (current, candidateStrings.compactMap({ shutterSpeedFormatter.shutterSpeed(from: $0) }))
                case "whiteBalance":
                    guard let check = dictionaryElement["checkAvailability"] as? Bool, let currentMode = dictionaryElement["currentWhiteBalanceMode"] as? String else { return }
                    let currentTemp = dictionaryElement["currentColorTemperature"] as? Int
                    _whiteBalance = WhiteBalanceInformation(shouldCheck: check, whitebalanceValue: WhiteBalance.Value(mode: currentMode, temperature: currentTemp != -1 ? currentTemp : nil))
                case "touchAFPosition":
                    _touchAF = TouchAF.Information(dictionary: dictionaryElement)
                case "focusStatus":
                    guard let status = dictionaryElement["focusStatus"] as? String else { return }
                    _focusStatus = FocusStatus(sonyString: status)
                case "zoomSetting":
                    guard let current = dictionaryElement["zoom"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _zoomSetting = (current, candidates)
                case "stillQuality":
                    guard let current = dictionaryElement["stillQuality"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _stillQuality = (current, candidates)
                case "contShootingMode":
                    guard let current = dictionaryElement["contShootingMode"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    guard let currentEnum = ContinuousShootingMode(rawValue: current.lowercased()) else { return }
                    _continuousShootingMode = (currentEnum, candidates.compactMap({ ContinuousShootingMode(rawValue: $0.lowercased()) }))
                case "contShootingSpeed":
                    guard let current = dictionaryElement["contShootingSpeed"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    guard let currentEnum = ContinuousShootingSpeed(sonyString: current) else {
                        return
                    }
                    _continuousShootingSpeed = (currentEnum, candidates.compactMap({ ContinuousShootingSpeed(sonyString: $0) }))
                case "contShooting":
                    guard let urlDicts = dictionaryElement["contShootingUrl"] as? [[AnyHashable : Any]] else { return }
                    let urls: [(postView: URL, thumbnail: URL)] = urlDicts.compactMap({
                        guard let postviewUrlString = $0["postviewUrl"] as? String, let postviewUrl = URL(string: postviewUrlString) else {
                            return nil
                        }
                        guard let thumbnailUrlString = $0["thumbnailUrl"] as? String, let thumbnailUrl = URL(string: thumbnailUrlString) else {
                            return nil
                        }
                        return (postviewUrl, thumbnailUrl)
                    })
                    _continuousShootingURLS = urls.isEmpty ? nil : urls
                case "flipSetting":
                    guard let current = dictionaryElement["flip"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _flipSetting = (current, candidates)
                case "sceneSelection":
                    guard let current = dictionaryElement["scene"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _scene = (current, candidates)
                case "intervalTime":
                    guard let current = dictionaryElement["intervalTimeSec"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    guard let currentDouble = TimeInterval(current) else { return }
                    let available = candidates.compactMap({ (candidate) -> TimeInterval? in
                        return TimeInterval(candidate)
                    })
                    _intervalTime = (currentDouble, available)
                case "colorSetting":
                    guard let current = dictionaryElement["colorSetting"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _colorSetting = (current, candidates)
                case "movieFileFormat":
                    guard let current = dictionaryElement["movieFileFormat"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _videoFileFormat = (current, candidates)
                case "infraredRemoteControl":
                    guard let current = dictionaryElement["infraredRemoteControl"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _infraredRemoteControl = (current, candidates)
                case "tvColorSystem":
                    guard let current = dictionaryElement["tvColorSystem"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _tvColorSystem = (current, candidates)
                case "trackingFocusStatus":
                    _trackingFocusStatus = dictionaryElement["trackingFocusStatus"] as? String
                case "trackingFocus":
                    guard let current = dictionaryElement["trackingFocus"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _trackingFocus = (current, candidates)
                case "batteryInfo":
                    guard let batteryInfo = dictionaryElement["batteryInfo"] as? [[AnyHashable : Any]] else { return }
                    let batteries = batteryInfo.compactMap({ BatteryInformation(dictionary: $0) })
                    _batteryInfo = batteries.isEmpty ? nil : batteries
                case "recordingTime":
                    guard let recordingTime = dictionaryElement["recordingTime"] as? Int else { return }
                    _videoRecordingTime = TimeInterval(recordingTime)
                case "numberOfShots":
                    _numberOfShots = dictionaryElement["numberOfShots"] as? Int
                case "autoPowerOff":
                    guard let current = dictionaryElement["autoPowerOff"] as? Int, let candidates = dictionaryElement["candidate"] as? [Int] else { return }
                    _autoPowerOff = (TimeInterval(current), candidates.map({ TimeInterval($0) }))
                case "loopRecTime":
                    
                    guard let current = dictionaryElement["loopRecTime"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    
                    guard let duration: TimeInterval = current == "unlimited" ? TimeInterval.infinity : TimeInterval(current) else { return }
                    
                    let available: [TimeInterval] = candidates.compactMap({
                        if $0 == "unlimited" {
                            return TimeInterval.infinity
                        }
                        return TimeInterval($0)
                    })
                    
                    _loopRecordTime = (duration, available)
                    
                case "audioRecording":
                    guard let current = dictionaryElement["audioRecording"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _audioRecording = (current, candidates)
                case "windNoiseReduction":
                    guard let current = dictionaryElement["windNoiseReduction"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _windNoiseReduction = (current, candidates)
                case "bulbCapturingTime":
                    switch dictionaryElement["bulbCapturingTime"] {
                    case let int as Int:
                        _bulbCapturingTime = TimeInterval(int)
                    case let timeInterval as TimeInterval:
                        _bulbCapturingTime = timeInterval
                    default:
                        break
                    }
                default:
                    return
                }
                
            } else if let elements = eventElement as? [[AnyHashable : Any]] {
                
                elements.forEach({ (element) in
                    
                    guard let type = element["type"] as? String else { return }
                    
                    switch type {
                    case "takePicture":
                        
                        guard let urls = (element["takePictureUrl"] as? [String])?.compactMap({ URL(string: $0) }), !urls.isEmpty else {
                            return
                        }
                        
                        _takenPictureURLS.append(urls)
                        
                    case "storageInformation":
                        
                       let info = StorageInformation(
                            description: element["storageDescription"] as? String,
                            spaceForImages: element["numberOfRecordableImages"] as? Int,
                            recordTarget: element["recordTarget"] as? Bool ?? false,
                            recordableTime: element["recordableTime"] as? Int,
                            id: element["storageID"] as? String
                        )
                        
                        _storageInfo.append(info)
                        
                    default:
                        return
                    }
                })
            }
        }
    
        if let apiList = _apiList {
            availableFunctions = _CameraFunction.allCases.filter({
                guard let sonyName = $0.sonyCameraMethodName else { return false }
                return apiList.contains(sonyName)
            })
        } else {
            availableFunctions = nil
        }
        
        if let liveViewStatus = _liveViewStatus {
            liveViewInfo = LiveViewInformation(status: liveViewStatus, orientation: _liveViewOrientation)
        } else {
            liveViewInfo = nil
        }
        
        if _shutterSpeed?.current.isBulb == true {
            // If the shutter speed is bulb, then we're in BULB shoot mode.
            // we need to manually report this because Sony don't do it for us!
            _shootMode = (.bulb, _shootMode?.available)
        }
        
        status = _cameraStatus
        zoomPosition = _zoomPosition
        postViewPictureURLs = _takenPictureURLS.isEmpty ? nil : _takenPictureURLS
        storageInformation = _storageInfo.isEmpty ? nil : _storageInfo
        beepMode = _beepMode
        function = _function
        functionResult = _functionResult
        videoQuality = _videoQuality
        stillSizeInfo = _stillSizeInfo
        steadyMode = _steadyMode
        viewAngle = _viewAngle
        exposureMode = _exposureMode
        postViewImageSize = _postViewImageSize
        selfTimer = _selfTimer
        shootMode = _shootMode
        exposureCompensation = _exposureCompensation
        flashMode = _flashMode
        aperture = _aperture
        focusMode = _focusMode
        ISO = _ISO
        isProgramShifted = _isProgramShifted
        shutterSpeed = _shutterSpeed
        whiteBalance = _whiteBalance
        touchAF = _touchAF
        focusStatus = _focusStatus
        zoomSetting = _zoomSetting
        stillQuality = _stillQuality
        continuousShootingMode = _continuousShootingMode
        continuousShootingSpeed = _continuousShootingSpeed
        continuousShootingURLS = _continuousShootingURLS
        flipSetting = _flipSetting
        scene = _scene
        intervalTime = _intervalTime
        colorSetting = _colorSetting
        videoFileFormat = _videoFileFormat
        videoRecordingTime = _videoRecordingTime
        infraredRemoteControl = _infraredRemoteControl
        tvColorSystem = _tvColorSystem
        trackingFocusStatus = _trackingFocusStatus
        trackingFocus = _trackingFocus
        batteryInfo = _batteryInfo
        numberOfShots = _numberOfShots
        autoPowerOff = _autoPowerOff
        loopRecordTime = _loopRecordTime
        audioRecording = _audioRecording
        windNoiseReduction = _windNoiseReduction
        bulbCapturingTime = _bulbCapturingTime
        bulbShootingUrl = _bulbShootingURL
    }
}

fileprivate extension StorageInformation {
    
    init(dictionary: [AnyHashable : Any]) {
        
        description = dictionary["storageDescription"] as? String
        
        if let images = dictionary["numberOfRecordableImages"] as? Int, images != -1 {
            spaceForImages = images
        } else {
            spaceForImages = nil
        }
        
        recordTarget = dictionary["recordTarget"] as? Bool ?? false
        id = dictionary["storageID"] as? String
        
        if let time = dictionary["recordableTime"] as? Int, time != -1 {
            recordableTime = time
        } else {
            recordableTime = nil
        }
    }
}

fileprivate extension StillSize {
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let aspect = dictionary["aspect"] as? String, let size = dictionary["size"] as? String else {
            return nil
        }
        
        aspectRatio = aspect
        self.size = size
    }
}

fileprivate extension WhiteBalance.Value {
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let mode = dictionary["whiteBalanceMode"] as? String else {
            return nil
        }
        
        self.mode = mode
        temperature = dictionary["colorTemperature"] as? Int
    }
    
    var sonySerialisable: [Any] {
        return [self.mode, temperature != nil, self.temperature ?? 2500]
    }
}

fileprivate extension WhiteBalance.Custom.Result {
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let comp = dictionary["colorCompensation"] as? Int,
            let balance = dictionary["lightBalance"] as? Int,
            let range = dictionary["inRange"] as? Bool,
            let temp = dictionary["colorTemperature"] as? Int else { return nil }
        
        colorCompensation = comp
        lightBalance = balance
        inRange = range
        temperature = temp
    }
}

fileprivate extension TouchAF.Information {
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let set = dictionary["set"] as? Bool ?? dictionary["currentSet"] as? Bool ?? dictionary["AFResult"] as? Bool else { return nil }
        isSet = set
        
        guard let positions = dictionary["touchCoordinates"] as? [[Double]] ?? dictionary["currentTouchCoordinates"] as? [[Double]] else {
            self.points = []
            return
        }
        
        self.points = positions.compactMap({
            guard $0.count == 2 else { return nil }
            return CGPoint(x: $0[0], y: $0[1])
        })
    }
}

internal class CameraClient: ServiceClient {
    
    typealias GenericCompletion = (_ error: Error?) -> Void
    
    internal convenience init?(apiInfo: SonyAPICameraDevice.ApiDeviceInfo) {
        guard let cameraService = apiInfo.services.first(where: { $0.type == "camera" }) else { return nil }
        self.init(service: cameraService)
    }
    
    func startRecordMode(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "startRecMode")

        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startRecMode"))
        }
    }
    
    func stopRecordMode(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopRecMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopRecMode"))
        }
    }
    
    //MARK: - Shooting Settings
    
    //MARK: - Shoot Mode
    
    typealias ShootModesCompletion = (_ result: Result<[ShootingMode]>) -> Void
    
    typealias ShootModeCompletion = (_ result: Result<ShootingMode>) -> Void
    
    func getSupportedShootModes(_ completion: @escaping ShootModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedShootMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedShootMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedShootMode")))
                return
            }
            
            var enumValues = supported.compactMap({ ShootingMode(sonyString: $0) })
            guard !enumValues.isEmpty else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedShootMode")))
                return
            }
            
            if enumValues.contains(.photo) {
                enumValues.append(contentsOf: [.timelapse, .continuous])
            }
            
            completion(Result(value: enumValues, error: nil))
        }
    }
    
    func getAvailableShootModes(_ completion: @escaping ShootModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableShootMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableShootMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableShootMode")))
                return
            }
            
            var enumValues = available.compactMap({ ShootingMode(sonyString: $0) })
            guard !enumValues.isEmpty else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableShootMode")))
                return
            }
            
            if enumValues.contains(.photo) {
                enumValues.append(contentsOf: [.timelapse, .continuous, .bulb])
            }
            
            completion(Result(value: enumValues, error: nil))
        }
    }
    
    func setShootMode(_ shootMode: ShootingMode, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setShootMode", params: [shootMode.sonyString], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setShootMode"))
        }
    }
    
    func getShootMode(_ completion: @escaping ShootModeCompletion) {
        
        let body = SonyRequestBody(method: "getShootMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getShootMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let shootingMode = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getShootMode")))
                return
            }
            
            guard let enumResult = ShootingMode(sonyString: shootingMode) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getShootMode")))
                return
            }
            
            completion(Result(value: enumResult, error: nil))
        }
    }
    
    //MARK: - Aperture
    
    typealias AperturesCompletion = (_ result: Result<[String]>) -> Void

    typealias ApertureCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedApertures(_ completion: @escaping AperturesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFNumber")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFNumber") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedFNumber")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableApertures(_ completion: @escaping AperturesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFNumber")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFNumber") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableFNumber")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setAperture(_ aperture: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setFNumber", params: [aperture], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setFNumber"))
        }
    }
    
    func getAperture(_ completion: @escaping ApertureCompletion) {
        
        let body = SonyRequestBody(method: "getFNumber")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getFNumber") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let aperture = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getFNumber")))
                return
            }
            
            completion(Result(value: aperture, error: nil))
        }
    }
    
    //MARK: - ISO
    
    typealias ISOValuesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias ISOCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedISOValues(_ completion: @escaping ISOValuesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedIsoSpeedRate")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedIsoSpeedRate") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedIsoSpeedRate")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableISOValues(_ completion: @escaping ISOValuesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableIsoSpeedRate")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableIsoSpeedRate") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableIsoSpeedRate")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setISO(_ ISO: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setIsoSpeedRate", params: [ISO], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setIsoSpeedRate"))
        }
    }
    
    func getISO(_ completion: @escaping ISOCompletion) {
        
        let body = SonyRequestBody(method: "getIsoSpeedRate")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getIsoSpeedRate") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let ISO = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getIsoSpeedRate")))
                return
            }
            
            completion(Result(value: ISO, error: nil))
        }
    }
    
    //MARK: - Shutter Speed
    
    typealias ShutterSpeedsCompletion = (_ result: Result<[ShutterSpeed]>) -> Void
    
    typealias ShutterSpeedCompletion = (_ result: Result<ShutterSpeed>) -> Void
    
    func getSupportedShutterSpeeds(_ completion: @escaping ShutterSpeedsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedShutterSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedShutterSpeed") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedShutterSpeed")))
                return
            }
            
            let formatter = ShutterSpeedFormatter()
            let shutterSpeeds = supported.compactMap({ formatter.shutterSpeed(from: $0) })
            completion(Result(value: shutterSpeeds, error: nil))
        }
    }
    
    func getAvailableShutterSpeeds(_ completion: @escaping ShutterSpeedsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableShutterSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableShutterSpeed") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableShutterSpeed")))
                return
            }
            
            let formatter = ShutterSpeedFormatter()
            let shutterSpeeds = available.compactMap({ formatter.shutterSpeed(from: $0) })
            completion(Result(value: shutterSpeeds, error: nil))
        }
    }
    
    func setShutterSpeed(_ shutterSpeed: ShutterSpeed, completion: @escaping GenericCompletion) {
        
        let shutterSpeedFormatter = ShutterSpeedFormatter()
        
        let body = SonyRequestBody(method: "setShutterSpeed", params: [shutterSpeedFormatter.string(from: shutterSpeed)], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setShutterSpeed"))
        }
    }
    
    func getShutterSpeed(_ completion: @escaping ShutterSpeedCompletion) {
        
        let body = SonyRequestBody(method: "getShutterSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getShutterSpeed") {
                completion(Result(value: nil, error: error))
                return
            }
            
            let shutterSpeedFormatter = ShutterSpeedFormatter()
            guard let result = response?.dictionary?["result"] as? [String], let shutterSpeedString = result.first, let shutterSpeed = shutterSpeedFormatter.shutterSpeed(from: shutterSpeedString) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getShutterSpeed")))
                return
            }
            
            completion(Result(value: shutterSpeed, error: nil))
        }
    }
    
    //MARK: - White Balance
    
    typealias WhiteBalancesCompletion = (_ result: Result<[WhiteBalance.Value]>) -> Void
    
    typealias WhiteBalanceCompletion = (_ result: Result<WhiteBalance.Value>) -> Void
    
    func getSupportedWhiteBalances(_ completion: @escaping WhiteBalancesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedWhiteBalance")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in

            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedWhiteBalance") {
                completion(Result(value: nil, error: error))
                return
            }

            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedWhiteBalance")))
                return
            }
            
            var supportedWhiteBalances: [WhiteBalance.Value] = []
            
            supported.forEach({ (whiteBalanceDict) in
                
                guard let mode = whiteBalanceDict["whiteBalanceMode"] as? String, let colorTempRange = whiteBalanceDict["colorTemperatureRange"] as? [Int] else {
                    return
                }
                
                guard !colorTempRange.isEmpty else {
                    supportedWhiteBalances.append(WhiteBalance.Value(mode: mode, temperature: nil))
                    return
                }
                
                colorTempRange.forEach({ (temperature) in
                    supportedWhiteBalances.append(WhiteBalance.Value(mode: mode, temperature: temperature))
                })
            })
            
            completion(Result(value: supportedWhiteBalances, error: nil))
        }
    }
    
    func getAvailableWhiteBalances(_ completion: @escaping WhiteBalancesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableWhiteBalance")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableWhiteBalance") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [[AnyHashable : Any]] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableWhiteBalance")))
                return
            }
            
            var availableWhiteBalances: [WhiteBalance.Value] = []
            
            available.forEach({ (whiteBalanceDict) in
                
                guard let mode = whiteBalanceDict["whiteBalanceMode"] as? String, let colorTempRange = whiteBalanceDict["colorTemperatureRange"] as? [Int] else {
                    return
                }
                
                guard !colorTempRange.isEmpty else {
                    availableWhiteBalances.append(WhiteBalance.Value(mode: mode, temperature: nil))
                    return
                }
                
                colorTempRange.forEach({ (temperature) in
                    availableWhiteBalances.append(WhiteBalance.Value(mode: mode, temperature: temperature))
                })
            })
            
            completion(Result(value: availableWhiteBalances, error: nil))
        }
    }
    
    func setWhiteBalance(_ whiteBalance: WhiteBalance.Value, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setWhiteBalance", params: whiteBalance.sonySerialisable, id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setWhiteBalance"))
        }
    }
    
    func getWhiteBalance(_ completion: @escaping WhiteBalanceCompletion) {
        
        let body = SonyRequestBody(method: "getWhiteBalance")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getWhiteBalance") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let whiteBalanceDict = result.first, let whiteBalance = WhiteBalance.Value(dictionary: whiteBalanceDict) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getWhiteBalance")))
                return
            }
            
            completion(Result(value: whiteBalance, error: nil))
        }
    }
    
    typealias WhiteBalanceCustomFromShotCompletion = (_ result: Result<WhiteBalance.Custom.Result>) -> Void
    
    func setCustomWhiteBalanceFromShot(_ completion: @escaping WhiteBalanceCustomFromShotCompletion) {
        
        let body = SonyRequestBody(method: "actWhiteBalanceOnePushCustom")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "actWhiteBalanceOnePushCustom") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let firstResult = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("actWhiteBalanceOnePushCustom")))
                return
            }
            
            guard let resultObject = WhiteBalance.Custom.Result(dictionary: firstResult) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("actWhiteBalanceOnePushCustom")))
                return
            }
            
            completion(Result(value: resultObject, error: nil))
        }
    }
    
    //MARK: - Camera Function -
    
    typealias CameraFunctionCompletion = (_ result: Result<String>) -> Void

    typealias CameraFunctionsCompletion = (_ result: Result<[String]>) -> Void
    
    func getSupportedCameraFunctions(_ completion: @escaping CameraFunctionsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedCameraFunction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedCameraFunction") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let functions = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedCameraFunction")))
                return
            }
            
            completion(Result(value: functions, error: nil))
        }
    }
    
    func getAvailableCameraFunctions(_ completion: @escaping CameraFunctionsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableCameraFunction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableCameraFunction") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let functions = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableCameraFunction")))
                return
            }
            
            completion(Result(value: functions, error: nil))
        }
    }
    
    func setCameraFunction(_ function: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setCameraFunction", params: [function], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setCameraFunction"))
        }
    }
    
    func getCameraFunction(_ completion: @escaping CameraFunctionCompletion) {
        
        let body = SonyRequestBody(method: "getCameraFunction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getCameraFunction") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let function = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getCameraFunction")))
                return
            }
            
            completion(Result(value: function, error: nil))
        }
    }
    
    //MARK: - Capture -
    
    typealias TakePictureCompletion = (_ result: Result<(url: URL?, needsAwait: Bool)>) -> Void
    
    typealias AwaitPictureCompletion = (_ result: Result<URL>) -> Void
    
    //MARK: Single
    
    func takePicture(_ completion: @escaping TakePictureCompletion) {
        
        let body = SonyRequestBody(method: "actTakePicture")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error {
                completion(Result(value: nil, error: error))
                return
            }
            
            if let responseError = CameraError(responseDictionary: response?.dictionary, methodName: "actTakePicture") {
                switch responseError {
                    
                case .stillCapturingNotFinished:
                    completion(Result(value: (nil, true), error: nil))
                default:
                    completion(Result(value: nil, error: responseError))
                }
                
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let urlString = result.first?.first, let url = URL(string: urlString) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("actTakePicture")))
                return
            }
            
            completion(Result(value: (url, false), error: nil))
        }
    }
    
    func awaitTakePicture(_ completion: @escaping AwaitPictureCompletion) {
        
        let body = SonyRequestBody(method: "awaitTakePicture")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "awaitTakePicture") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let urlString = result.first?.first, let url = URL(string: urlString) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("awaitTakePicture")))
                return
            }
            
            completion(Result(value: url, error: nil))
        }
    }
    
    //MARK: - Continuous
    
    func startContinuousShooting(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "startContShooting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startContShooting"))
        }
    }
    
    func stopContinuousShooting(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopContShooting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopContShooting"))
        }
    }
    
    //MARK: - Bulb
    
    func startBulbShooting(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "startBulbShooting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startBulbShooting"))
        }
    }
    
    func stopBulbShooting(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopBulbShooting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopBulbShooting"))
        }
    }
    
    //MARK: Modes
    
    typealias ContinuousShootingModesCompletion = (_ result: Result<[ContinuousShootingMode]>) -> Void
    
    typealias ContinuousShootingModeCompletion = (_ result: Result<ContinuousShootingMode>) -> Void
    
    func getSupportedContinuousShootingModes(_ completion: @escaping ContinuousShootingModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedContShootingMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedContShootingMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingModes = result.first, let supported = continuousShootingModes["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedContShootingMode")))
                return
            }
            
            let modes = supported.compactMap({ ContinuousShootingMode(rawValue: $0.lowercased()) })
            completion(Result(value: modes, error: nil))
        }
    }
    
    func getAvailableContinuousShootingModes(_ completion: @escaping ContinuousShootingModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableContShootingMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableContShootingMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingModes = result.first, let available = continuousShootingModes["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableContShootingMode")))
                return
            }
            
            let modes = available.compactMap({ ContinuousShootingMode(rawValue: $0.lowercased()) })
            completion(Result(value: modes, error: nil))
        }
    }
    
    func setContinuousShootingMode(_ mode: ContinuousShootingMode, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setContShootingMode", params: [["contShootingMode" : mode.sonyString]], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setContShootingMode"))
        }
    }
    
    func getContinuousShootingMode(_ completion: @escaping ContinuousShootingModeCompletion) {
        
        let body = SonyRequestBody(method: "getContShootingMode")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getContShootingMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingModes = result.first, let value = continuousShootingModes["contShootingMode"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getContShootingMode")))
                return
            }
            
            guard let mode = ContinuousShootingMode(rawValue: value.lowercased()) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getContShootingMode")))
                return
            }
            
            completion(Result(value: mode, error: nil))
        }
    }
    
    //MARK: Speeds
    
    typealias ContinuousShootingSpeedsCompletion = (_ result: Result<[ContinuousShootingSpeed]>) -> Void
    
    typealias ContinuousShootingSpeedCompletion = (_ result: Result<ContinuousShootingSpeed>) -> Void
    
    func getSupportedContinuousShootingSpeeds(_ completion: @escaping ContinuousShootingSpeedsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedContShootingSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedContShootingSpeed") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingSpeeds = result.first, let supported = continuousShootingSpeeds["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedContShootingSpeed")))
                return
            }
            
            let supportedEnums = supported.compactMap({ ContinuousShootingSpeed(sonyString: $0) })
            
            completion(Result(value: supportedEnums, error: nil))
        }
    }
    
    func getAvailableContinuousShootingSpeeds(_ completion: @escaping ContinuousShootingSpeedsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableContShootingSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableContShootingSpeed") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingSpeeds = result.first, let available = continuousShootingSpeeds["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableContShootingSpeed")))
                return
            }
            
            let availableEnums = available.compactMap({ ContinuousShootingSpeed(sonyString: $0) })
            completion(Result(value: availableEnums, error: nil))
        }
    }
    
    func setContinuousShootingSpeed(_ speed: ContinuousShootingSpeed, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setContShootingSpeed", params: [["contShootingSpeed" : speed.sonyString]], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setContShootingSpeed"))
        }
    }
    
    func getContinuousShootingSpeed(_ completion: @escaping ContinuousShootingSpeedCompletion) {
        
        let body = SonyRequestBody(method: "getContShootingSpeed")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getContShootingSpeed") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let speedSettings = result.first, let value = speedSettings["contShootingSpeed"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getContShootingSpeed")))
                return
            }
            
            guard let enumValue = ContinuousShootingSpeed(sonyString: value) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getContShootingSpeed")))
                return
            }
            
            completion(Result(value: enumValue, error: nil))
        }
    }
    
    //MARK: - Movie
    
    func startMovieRecording(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "startMovieRec")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startMovieRec"))
        }
    }
    
    func stopMovieRecording(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopMovieRec")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopMovieRec"))
        }
    }
    
    //MARK: Audio
    
    typealias AudioRecordingSettingsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias AudioRecordingSettingCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedAudioRecordingSettings(_ completion: @escaping AudioRecordingSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedAudioRecording")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedAudioRecording") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedAudioRecording")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableAudioRecordingSettings(_ completion: @escaping AudioRecordingSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableAudioRecording")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableAudioRecording") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableAudioRecording")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setAudioRecordingSetting(_ setting: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setAudioRecording", params: [["audioRecording" : setting]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setAudioRecording"))
        }
    }
    
    func getAudioRecordingSetting(_ completion: @escaping SceneSelectionCompletion) {
        
        let body = SonyRequestBody(method: "getAudioRecording")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAudioRecording") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["windNoiseReduction"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAudioRecording")))
                return
            }
            
            completion(Result(value: scene, error: nil))
        }
    }
    
    //MARK: - Audio
    
    func startAudioRecording(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "startAudioRec")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startAudioRec"))
        }
    }
    
    func stopAudioRecording(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopAudioRec")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopAudioRec"))
        }
    }
    
    //MARK: - Interval
    
    func startIntervalRecording(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "startIntervalStillRec")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startIntervalStillRec"))
        }
    }
    
    func stopIntervalRecording(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopIntervalStillRec")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopIntervalStillRec"))
        }
    }
    
    //MARK: - Loop
    
    func startLoopRecording(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "startLoopRec")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startLoopRec"))
        }
    }
    
    func stopLoopRecording(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopLoopRec")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopLoopRec"))
        }
    }
    
    //MARK: Duration
    
    typealias LoopDurationsCompletion = (_ result: Result<[TimeInterval]>) -> Void
    
    typealias LoopDurationCompletion = (_ result: Result<TimeInterval>) -> Void
    
    func getSupportedLoopDurations(_ completion: @escaping LoopDurationsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedLoopDuration")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedLoopDuration") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedLoopDuration")))
                return
            }
            
            let _supported: [TimeInterval] = supported.compactMap({
                if $0 == "unlimited" {
                    return TimeInterval.infinity
                }
                return TimeInterval($0)
            })
            
            completion(Result(value: _supported, error: nil))
        }
    }
    
    func getAvailableLoopDurations(_ completion: @escaping LoopDurationsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableLoopDuration")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableLoopDuration") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableLoopDuration")))
                return
            }
            
            let _available: [TimeInterval] = available.compactMap({
                if $0 == "unlimited" {
                    return TimeInterval.infinity
                }
                return TimeInterval($0)
            })
            
            completion(Result(value: _available, error: nil))
        }
    }
    
    func setLoopDuration(_ duration: TimeInterval, completion: @escaping GenericCompletion) {
        
        var _duration = "\(Int(duration * 60))"
        if duration == .infinity {
            _duration = "unlimited"
        }
        
        let body = SonyRequestBody(method: "setLoopDuration", params: [["loopRecTimeMin" : _duration]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setLoopDuration"))
        }
    }
    
    func getLoopDuration(_ completion: @escaping LoopDurationCompletion) {
        
        let body = SonyRequestBody(method: "getLoopDuration")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getLoopDuration") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let durationMinString = result.first?["loopRecTimeMin"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getLoopDuration")))
                return
            }
            
            if let durationMin = TimeInterval(durationMinString) {
                completion(Result(value: durationMin * 60, error: nil))
            } else if durationMinString == "unlimited" {
                completion(Result(value: TimeInterval.infinity, error: nil))
            } else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getLoopDuration")))
            }
        }
    }
    
    //MARK: - Live View -
    
    typealias LiveViewCompletion = (_ result: Result<URL>) -> Void

    func startLiveView(_ completion: @escaping LiveViewCompletion) {
        
        let body = SonyRequestBody(method: "startLiveview")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startLiveview") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let streamURLString = result.first, let streamURL = URL(string: streamURLString) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("startLiveview")))
                return
            }
            
            completion(Result(value: streamURL, error: nil))
        }
    }
    
    func stopLiveView(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopLiveview")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopLiveview"))
        }
    }
    
    //MARK: - With Size
    
    typealias LiveViewSizesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias LiveViewSizeCompletion = (_ result: Result<String>) -> Void
    
    func getAvailableLiveViewSizes(_ completion: @escaping LiveViewSizesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableLiveviewSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableLiveviewSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableLiveviewSize")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func getSupportedLiveViewSizes(_ completion: @escaping LiveViewSizesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedLiveviewSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedLiveviewSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let supported = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedLiveviewSize")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func startLiveViewWithSize(_ size: String, _ completion: @escaping LiveViewCompletion) {
        
        let body = SonyRequestBody(method: "startLiveviewWithSize", params: [size], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startLiveviewWithSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let streamURLString = result.first, let streamURL = URL(string: streamURLString) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("startLiveviewWithSize")))
                return
            }
            
            completion(Result(value: streamURL, error: nil))
        }
    }
    
    func getLiveViewSize(_ completion: @escaping LiveViewSizeCompletion) {
        
        let body = SonyRequestBody(method: "getLiveviewSize")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getLiveviewSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let size = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getLiveviewSize")))
                return
            }
            
            completion(Result(value: size, error: nil))
        }
    }
    
    //MARK: - Frame info
    
    typealias LiveViewFrameInfoCompletion = (_ result: Result<Bool>) -> Void
    
    func setLiveViewFrameInfo(_ enabled: Bool, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setLiveviewFrameInfo", params: [["frameInfo": enabled]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setLiveviewFrameInfo"))
        }
    }
    
    func getLiveViewFrameInfo(_ completion: @escaping LiveViewFrameInfoCompletion) {
        
        let body = SonyRequestBody(method: "getLiveviewFrameInfo")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getLiveviewFrameInfo") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let info = result.first, let enabled = info["frameInfo"] as? Bool else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getLiveviewFrameInfo")))
                return
            }
            
            completion(Result(value: enabled, error: nil))
        }
    }
    
    //MARK: - Zoom -
    
    func zoom(in direction: Zoom.Direction, start: Bool, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "actZoom", params: [direction.rawValue, start ? "start" : "stop"], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "actZoom"))
        }
    }
    
    typealias ZoomSettingsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias ZoomSettingCompletion = (_ result: Result<String>) -> Void
    
    //MARK: - Settings
    
    func getSupportedZoomSettings(_ completion: @escaping ZoomSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedZoomSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedZoomSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let zoomSettings = result.first, let supported = zoomSettings["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedZoomSetting")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableZoomSettings(_ completion: @escaping ZoomSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableZoomSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableZoomSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let zoomSettings = result.first, let supported = zoomSettings["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableZoomSetting")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func setZoomSetting(_ setting: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setZoomSetting", params: [["zoom": setting]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setZoomSetting"))
        }
    }
    
    func getZoomSetting(_ completion: @escaping ZoomSettingCompletion) {
        
        let body = SonyRequestBody(method: "getZoomSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getZoomSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let zoomSettingDict = result.first, let setting = zoomSettingDict["zoom"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getZoomSetting")))
                return
            }
            
            completion(Result(value: setting, error: nil))
        }
    }
    
    //MARK: - Half Press Shutter -
    func halfPressShutter(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "actHalfPressShutter")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "actHalfPressShutter"))
        }
    }
    
    func cancelHalfPressShutter(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "cancelHalfPressShutter")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "cancelHalfPressShutter"))
        }
    }
    
    //MARK: - Touch AF Position -
    
    typealias TouchAFPositionCompletion = (_ result: Result<TouchAF.Information>) -> Void
    
    func setTouchAFPosition(_ position: CGPoint, _ completion: @escaping TouchAFPositionCompletion) {
        
        let body = SonyRequestBody(method: "setTouchAFPosition", params: [position.x, position.y], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            guard let result = (response?.dictionary?["result"] as? [Any])?.compactMap({ $0 as? [AnyHashable : Any] }).first, let touchAFInfo = TouchAF.Information(dictionary: result) else {
                completion(Result(value: nil, error: error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setTouchAFPosition") ?? CameraError.invalidResponse("setTouchAFPosition")))
                return
            }
            
            completion(Result(value: touchAFInfo, error: nil))
        }
    }
    
    func getTouchAFPosition(_ completion: @escaping TouchAFPositionCompletion) {
        
        let body = SonyRequestBody(method: "getTouchAFPosition")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getTouchAFPosition") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = (response?.dictionary?["result"] as? [[AnyHashable : Any]])?.first, let touchAFInfo = TouchAF.Information(dictionary: result) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getTouchAFPosition")))
                return
            }
            
            completion(Result(value: touchAFInfo, error: nil))
        }
    }
    
    func cancelTouchAFPosition(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "cancelTouchAFPosition")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "cancelTouchAFPosition"))
        }
    }
    
    //MARK: - Tracking Focus -
    
    func startTrackingFocus(_ position: CGPoint, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "actTrackingFocus", params: [["xPosition": position.x, "yPosition": position.y]], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "actTrackingFocus"))
        }
    }
    
    func cancelTrackingFocus(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "cancelTrackingFocus")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "cancelTrackingFocus"))
        }
    }
    
    typealias TrackingFocusCompletion = (_ result: Result<String>) -> Void
    
    typealias TrackingFocussesCompletion = (_ result: Result<[String]>) -> Void
    
    //MARK: - Settings
    
    func getSupportedTrackingFocusses(_ completion: @escaping TrackingFocussesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedTrackingFocus")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedTrackingFocus") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let trackingFocusSettings = result.first, let supported = trackingFocusSettings["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedTrackingFocus")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableTrackingFocusses(_ completion: @escaping TrackingFocussesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableTrackingFocus")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableTrackingFocus") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let trackingFocusSettings = result.first, let supported = trackingFocusSettings["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableTrackingFocus")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func setTrackingFocus(_ focus: String, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setTrackingFocus", params: [["trackingFocus" : focus]], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setTrackingFocus"))
        }
    }
    
    func getTrackingFocus(_ completion: @escaping TrackingFocusCompletion) {
        
        let body = SonyRequestBody(method: "getTrackingFocus")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getTrackingFocus") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let trackingFocusSettings = result.first, let value = trackingFocusSettings["trackingFocus"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getTrackingFocus")))
                return
            }
            
            completion(Result(value: value, error: nil))
        }
    }
    
    //MARK: - Self Timer -
    
    typealias SelfTimerDurationsCompletion = (_ result: Result<[TimeInterval]>) -> Void
    
    typealias SelfTimerDurationCompletion = (_ result: Result<TimeInterval>) -> Void
    
    func getSupportedSelfTimerDurations(_ completion: @escaping SelfTimerDurationsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedSelfTimer")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedSelfTimer") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[Int]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedSelfTimer")))
                return
            }
            
            completion(Result(value: supported.map({ TimeInterval($0) }), error: nil))
        }
    }
    
    func getAvailableSelfTimerDurations(_ completion: @escaping SelfTimerDurationsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableSelfTimer")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableSelfTimer") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [Int] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableSelfTimer")))
                return
            }
            
            completion(Result(value: available.map({ TimeInterval($0) }), error: nil))
        }
    }
    
    func setSelfTimerDuration(_ duration: TimeInterval, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setSelfTimer", params: [duration], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setSelfTimer"))
        }
    }
    
    func getSelfTimerDuration(_ completion: @escaping SelfTimerDurationCompletion) {
        
        let body = SonyRequestBody(method: "getSelfTimer")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSelfTimer") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Int], let selfTimerDuration = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSelfTimer")))
                return
            }
            
            completion(Result(value: TimeInterval(selfTimerDuration), error: nil))
        }
    }
    
    //MARK: - Exposure -
    
    //MARK: Mode
    
    typealias ExposureModesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias ExposureModeCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedExposureModes(_ completion: @escaping ExposureModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFocusMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFocusMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedFocusMode")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableExposureModes(_ completion: @escaping ExposureModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFocusMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFocusMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableFocusMode")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setExposureMode(_ mode: String, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setExposureMode", params: [mode], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setExposureMode"))
        }
    }
    
    func getExposureMode(_ completion: @escaping ExposureModeCompletion) {
        
        let body = SonyRequestBody(method: "getExposureMode")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getExposureMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let mode = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getExposureMode")))
                return
            }
            
            completion(Result(value: mode, error: nil))
        }
    }
    
    //MARK: Compensation
    
    typealias ExposureCompensationsCompletion = (_ result: Result<[Double]>) -> Void
    
    typealias ExposureCompensationCompletion = (_ result: Result<Int>) -> Void
    
    func getSupportedExposureCompensations(_ completion: @escaping ExposureCompensationsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedExposureCompensation")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedExposureCompensation") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[Int]], result.count == 3 else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedExposureCompensation")))
                return
            }
            
            guard let upperIndex = result[0].first, let lowerIndex = result[1].first, let stepSize = result[2].first, stepSize == 1 || stepSize == 2 else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedExposureCompensation")))
                return
            }
            
            completion(Result(value: exposureCompensationsFor(lowerIndex: lowerIndex, upperIndex: upperIndex, stepSize: stepSize), error: nil))
        }
    }
    
    func getAvailableExposureCompensations(_ completion: @escaping ExposureCompensationsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableExposureCompensation")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableExposureCompensation") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Int], result.count == 4 else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableExposureCompensation")))
                return
            }
            
            let lowerIndex = result[2]
            let upperIndex = result[1]
            let stepSize = result[3]
            
            completion(Result(value: exposureCompensationsFor(lowerIndex: lowerIndex, upperIndex: upperIndex, stepSize: stepSize), error: nil))
        }
    }
    
    func setExposureCompensation(_ compensationIndex: Int, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setExposureCompensation", params: [compensationIndex], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setExposureCompensation"))
        }
    }
    
    func getExposureCompensation(_ completion: @escaping ExposureCompensationCompletion) {
        
        let body = SonyRequestBody(method: "getExposureCompensation")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getExposureCompensation") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Int], let compensation = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getExposureCompensation")))
                return
            }
            
            completion(Result(value: compensation, error: nil))
        }
    }
    
    //MARK: - Focus -
    
    //MARK: Mode
    
    typealias FocusModesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias FocusModeCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedFocusModes(_ completion: @escaping FocusModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFocusMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFocusMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedFocusMode")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableFocusModes(_ completion: @escaping FocusModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFocusMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFocusMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableFocusMode")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setFocusMode(_ mode: String, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setFocusMode", params: [mode], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setFocusMode"))
        }
    }
    
    func getFocusMode(_ completion: @escaping FocusModeCompletion) {
        
        let body = SonyRequestBody(method: "getFocusMode")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getFocusMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let mode = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getFocusMode")))
                return
            }
            
            completion(Result(value: mode, error: nil))
        }
    }
    
    //MARK: - Program Shift -
    
    typealias ProgramShiftsCompletion = (_ result: Result<[Int]>) -> Void
    
    func getSupportedProgramShifts(_ completion: @escaping ProgramShiftsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedProgramShift")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedProgramShift") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[Int]], let supported = result.first, supported.count == 2 else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedProgramShift")))
                return
            }
            
            let max = supported[0]
            let min = supported[1]
            
            var supportedValues: [Int] = []
            for i in min...max {
                supportedValues.append(i)
            }
            
            completion(Result(value: supportedValues, error: nil))
        }
    }
    
    func setProgramShift(_ shift: Int, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setProgramShift", params: [shift], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setProgramShift"))
        }
    }
    
    //MARK: - Flash Mode -
    
    typealias FlashModesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias FlashModeCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedFlashModes(_ completion: @escaping FlashModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFlashMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFlashMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedFlashMode")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableFlashModes(_ completion: @escaping FlashModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFlashMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFlashMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableFlashMode")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setFlashMode(_ flashMode: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setFlashMode", params: [flashMode], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setFlashMode"))
        }
    }
    
    func getFlashMode(_ completion: @escaping FlashModeCompletion) {
        
        let body = SonyRequestBody(method: "getFlashMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getFlashMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let flashMode = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getFlashMode")))
                return
            }
            
            completion(Result(value: flashMode, error: nil))
        }
    }
    
    //MARK: - Still Settings -
    
    //MARK: Size
    
    typealias StillSizesCompletion = (_ result: Result<[StillSize]>) -> Void
    
    typealias StillSizeCompletion = (_ result: Result<StillSize>) -> Void
    
    func getSupportedStillSizes(_ completion: @escaping StillSizesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedStillSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedStillSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedStillSize")))
                return
            }
            
            let _supported = supported.compactMap({ StillSize(dictionary: $0) })
            
            completion(Result(value: _supported, error: nil))
        }
    }
    
    func getAvailableStillSizes(_ completion: @escaping StillSizesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableStillSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableStillSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [[AnyHashable : Any]] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableStillSize")))
                return
            }
            
            let _available = available.compactMap({ StillSize(dictionary: $0) })
            
            completion(Result(value: _available, error: nil))
        }
    }
    
    func setStillSize(_ stillSize: StillSize, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setStillSize", params: [stillSize.aspectRatio, stillSize.size], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setStillSize"))
        }
    }
    
    func getStillSize(_ completion: @escaping StillSizeCompletion) {
        
        let body = SonyRequestBody(method: "getStillSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getStillSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let size = result.first, let stillSize = StillSize(dictionary: size) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getStillSize")))
                return
            }
            
            completion(Result(value: stillSize, error: nil))
        }
    }
    
    //MARK: Quality
    
    typealias StillQualitiesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias StillQualityCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedStillQualities(_ completion: @escaping StillQualitiesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedStillQuality") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedStillQuality")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableStillQualities(_ completion: @escaping StillQualitiesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableStillQuality") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableStillQuality")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setStillQuality(_ quality: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setStillQuality", params: [["stillQuality": quality]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setStillQuality"))
        }
    }
    
    func getStillQuality(_ completion: @escaping StillQualityCompletion) {
        
        let body = SonyRequestBody(method: "getStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getStillQuality") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let quality = result.first?["stillQuality"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getStillQuality")))
                return
            }
            
            completion(Result(value: quality, error: nil))
        }
    }
    
    //MARK: - Post View Image Size
    
    typealias PostviewImageSizesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias PostviewImageSizeCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedPostviewImageSizes(_ completion: @escaping PostviewImageSizesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedPostviewImageSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedPostviewImageSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedPostviewImageSize")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailablePostviewImageSizes(_ completion: @escaping PostviewImageSizesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailablePostviewImageSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailablePostviewImageSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailablePostviewImageSize")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setPostviewImageSize(_ size: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setPostviewImageSize", params: [size], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setPostviewImageSize"))
        }
    }
    
    func getPostviewImageSize(_ completion: @escaping PostviewImageSizeCompletion) {
        
        let body = SonyRequestBody(method: "getPostviewImageSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getPostviewImageSize") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let size = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getPostviewImageSize")))
                return
            }
            
            completion(Result(value: size, error: nil))
        }
    }
    
    //MARK: - Movie -
    //MARK: File Format
    
    typealias MovieFileFormatsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias MovieFileFormatCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedMovieFileFormats(_ completion: @escaping MovieFileFormatsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedMovieFileFormat")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedMovieFileFormat") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedMovieFileFormat")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableMovieFileFormats(_ completion: @escaping MovieFileFormatsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableMovieFileFormat")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableMovieFileFormat") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableMovieFileFormat")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setMovieFileFormat(_ format: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setMovieFileFormat", params: [["movieFileFormat":format]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setMovieFileFormat"))
        }
    }
    
    func getMovieFileFormat(_ completion: @escaping MovieFileFormatCompletion) {
        
        let body = SonyRequestBody(method: "getMovieFileFormat")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getMovieFileFormat") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let format = result.first?["movieFileFormat"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getMovieFileFormat")))
                return
            }
            
            completion(Result(value: format, error: nil))
        }
    }
    
    //MARK: Quality
    
    typealias MovieQualitiesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias MovieQualityCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedMovieQualities(_ completion: @escaping MovieQualitiesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedMovieQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedMovieQuality") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedMovieQuality")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableMovieQualities(_ completion: @escaping MovieQualitiesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableMovieQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableMovieQuality") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableMovieQuality")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setMovieQuality(_ quality: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setMovieQuality", params: [quality], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setMovieQuality"))
        }
    }
    
    func getMovieQuality(_ completion: @escaping MovieQualityCompletion) {
        
        let body = SonyRequestBody(method: "getMovieQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getMovieQuality") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let quality = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getMovieQuality")))
                return
            }
            
            completion(Result(value: quality, error: nil))
        }
    }
    
    //MARK: - Steady Mode -
    
    typealias SteadyModesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias SteadyModeCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedSteadyModes(_ completion: @escaping SteadyModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedSteadyMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedSteadyMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedSteadyMode")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableSteadyModes(_ completion: @escaping SteadyModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableSteadyMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableSteadyMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableSteadyMode")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setSteadyMode(_ mode: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setSteadyMode", params: [mode], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setSteadyMode"))
        }
    }
    
    func getSteadyMode(_ completion: @escaping SteadyModeCompletion) {
        
        let body = SonyRequestBody(method: "getSteadyMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSteadyMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let mode = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSteadyMode")))
                return
            }
            
            completion(Result(value: mode, error: nil))
        }
    }
    
    //MARK: - View Angle -
    
    typealias ViewAnglesCompletion = (_ result: Result<[Double]>) -> Void
    
    typealias ViewAngleCompletion = (_ result: Result<Double>) -> Void
    
    func getSupportedViewAngles(_ completion: @escaping ViewAnglesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedViewAngle")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedViewAngle") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[Int]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedViewAngle")))
                return
            }
            
            completion(Result(value: supported.map({ Double($0) }), error: nil))
        }
    }
    
    func getAvailableViewAngles(_ completion: @escaping ViewAnglesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableViewAngle")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableViewAngle") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [Int] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableViewAngle")))
                return
            }
            
            completion(Result(value: available.map({ Double($0) }), error: nil))
        }
    }
    
    func setViewAngle(_ angle: Double, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setViewAngle", params: [Int(angle)], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setViewAngle"))
        }
    }
    
    func getViewAngle(_ completion: @escaping ViewAngleCompletion) {
        
        let body = SonyRequestBody(method: "getViewAngle")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getViewAngle") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Int], let angle = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getViewAngle")))
                return
            }
            
            completion(Result(value: Double(angle), error: nil))
        }
    }
    
    //MARK: - Scene Selection -
    
    typealias SceneSelectionsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias SceneSelectionCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedSceneSelections(_ completion: @escaping SceneSelectionsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedSceneSelection")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedSceneSelection") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedSceneSelection")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableSceneSelections(_ completion: @escaping SceneSelectionsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableSceneSelection")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableSceneSelection") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableSceneSelection")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setSceneSelection(_ scene: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setSceneSelection", params: [["scene" : scene]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setSceneSelection"))
        }
    }
    
    func getSceneSelection(_ completion: @escaping SceneSelectionCompletion) {
        
        let body = SonyRequestBody(method: "getSceneSelection")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSceneSelection") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["scene"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSceneSelection")))
                return
            }
            
            completion(Result(value: scene, error: nil))
        }
    }
    
    //MARK: - Color Setting -
    
    typealias ColorSettingsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias ColorSettingCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedColorSettings(_ completion: @escaping ColorSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedColorSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedColorSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedColorSetting")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableColorSettings(_ completion: @escaping ColorSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableColorSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableColorSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableColorSetting")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setColorSetting(_ setting: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setColorSetting", params: [["colorSetting" : setting]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setColorSetting"))
        }
    }
    
    func getColorSetting(_ completion: @escaping ColorSettingCompletion) {
        
        let body = SonyRequestBody(method: "getColorSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getColorSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["colorSetting"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getColorSetting")))
                return
            }
            
            completion(Result(value: scene, error: nil))
        }
    }
    
    //MARK: - Interval Times -
    
    typealias IntervalTimesCompletion = (_ result: Result<[TimeInterval]>) -> Void
    
    typealias IntervalTimeCompletion = (_ result: Result<TimeInterval>) -> Void
    
    func getSupportedIntervalTimes(_ completion: @escaping IntervalTimesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedIntervalTime")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedIntervalTime") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedIntervalTime")))
                return
            }
            
            let _supported = supported.compactMap({ TimeInterval($0) })
            
            completion(Result(value: _supported, error: nil))
        }
    }
    
    func getAvailableIntervalTimes(_ completion: @escaping IntervalTimesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableIntervalTime")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableIntervalTime") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableIntervalTime")))
                return
            }
            
            let _available = available.compactMap({ TimeInterval($0) })
            
            completion(Result(value: _available, error: nil))
        }
    }
    
    func setIntervalTime(_ interval: TimeInterval, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setIntervalTime", params: [["intervalTimeSec" : "\(Int(interval))"]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setIntervalTime"))
        }
    }
    
    func getIntervalTime(_ completion: @escaping IntervalTimeCompletion) {
        
        let body = SonyRequestBody(method: "getIntervalTime")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getIntervalTime") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let intervalSec = result.first?["intervalTimeSec"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getIntervalTime")))
                return
            }
            guard let interval = TimeInterval(intervalSec) else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getIntervalTime")))
                return
            }
            
            completion(Result(value: interval, error: nil))
        }
    }
    
    //MARK: - Wind Noise Reduction -
    
    typealias WindNoiseReductionsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias WindNoiseReductionCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedWindNoiseReductions(_ completion: @escaping WindNoiseReductionsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedWindNoiseReduction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedWindNoiseReduction") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedWindNoiseReduction")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableWindNoiseReductions(_ completion: @escaping WindNoiseReductionsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableWindNoiseReduction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableWindNoiseReduction") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableWindNoiseReduction")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setWindNoiseReduction(_ setting: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setWindNoiseReduction", params: [["windNoiseReduction" : setting]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setWindNoiseReduction"))
        }
    }
    
    func getWindNoiseReduction(_ completion: @escaping WindNoiseReductionCompletion) {
        
        let body = SonyRequestBody(method: "getWindNoiseReduction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getWindNoiseReduction") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["windNoiseReduction"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getWindNoiseReduction")))
                return
            }
            
            completion(Result(value: scene, error: nil))
        }
    }
    
    //MARK: - Flip Setting -
    
    typealias FlipSettingsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias FlipSettingCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedFlipSettings(_ completion: @escaping FlipSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFlipSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFlipSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedFlipSetting")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableFlipSettings(_ completion: @escaping FlipSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFlipSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFlipSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableFlipSetting")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setFlipSetting(_ setting: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setFlipSetting", params: [["flip" : setting]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setFlipSetting"))
        }
    }
    
    func getFlipSetting(_ completion: @escaping FlipSettingCompletion) {
        
        let body = SonyRequestBody(method: "getFlipSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getFlipSetting") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["flip"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getFlipSetting")))
                return
            }
            
            completion(Result(value: scene, error: nil))
        }
    }
    
    //MARK: - TV Color Setting -
    
    typealias TVColorSystemsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias TVColorSystemCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedTVColorSystems(_ completion: @escaping TVColorSystemsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedTVColorSystem")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedTVColorSystem") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedTVColorSystem")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableTVColorSystems(_ completion: @escaping TVColorSystemsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableTVColorSystem")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableTVColorSystem") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableTVColorSystem")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setTVColorSystem(_ setting: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setTVColorSystem", params: [["tvColorSystem" : setting]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setTVColorSystem"))
        }
    }
    
    func getTVColorSystem(_ completion: @escaping TVColorSystemCompletion) {
        
        let body = SonyRequestBody(method: "getTVColorSystem")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getTVColorSystem") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["tvColorSystem"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getTVColorSystem")))
                return
            }
            
            completion(Result(value: scene, error: nil))
        }
    }
    
    //MARK: - Infrared Remote Control -
    
    typealias InfraredRemoteControlsCompletion = (_ result: Result<[String]>) -> Void
    
    typealias InfraredRemoteControlCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedInfraredRemoteControls(_ completion: @escaping InfraredRemoteControlsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedInfraredRemoteControl")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedInfraredRemoteControl") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedInfraredRemoteControl")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableInfraredRemoteControls(_ completion: @escaping InfraredRemoteControlsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableInfraredRemoteControl")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableInfraredRemoteControl") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableInfraredRemoteControl")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setInfraredRemoteControl(_ remoteControl: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setInfraredRemoteControl", params: [["infraredRemoteControl" : remoteControl]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setInfraredRemoteControl"))
        }
    }
    
    func getInfraredRemoteControl(_ completion: @escaping InfraredRemoteControlCompletion) {
        
        let body = SonyRequestBody(method: "getInfraredRemoteControl")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getInfraredRemoteControl") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["infraredRemoteControl"] as? String else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getInfraredRemoteControl")))
                return
            }
            
            completion(Result(value: scene, error: nil))
        }
    }
    
    //MARK: - Auto Power Off -
    
    typealias AutoPowerOffsCompletion = (_ result: Result<[TimeInterval]>) -> Void
    
    typealias AutoPowerOffCompletion = (_ result: Result<TimeInterval>) -> Void
    
    func getSupportedAutoPowerOffs(_ completion: @escaping AutoPowerOffsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedAutoPowerOff")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedAutoPowerOff") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [Int] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedAutoPowerOff")))
                return
            }
            
            completion(Result(value: supported.map({ TimeInterval($0) }), error: nil))
        }
    }
    
    func getAvailableAutoPowerOffs(_ completion: @escaping AutoPowerOffsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableAutoPowerOff")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableAutoPowerOff") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [Int] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableAutoPowerOff")))
                return
            }
            
            completion(Result(value: available.map({ TimeInterval($0) }), error: nil))
        }
    }
    
    func setAutoPowerOff(_ interval: TimeInterval, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setAutoPowerOff", params: [["autoPowerOff" : Int(interval)]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setAutoPowerOff"))
        }
    }
    
    func getAutoPowerOff(_ completion: @escaping AutoPowerOffCompletion) {
        
        let body = SonyRequestBody(method: "getAutoPowerOff")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAutoPowerOff") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let powerOff = result.first?["autoPowerOff"] as? Int else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAutoPowerOff")))
                return
            }
            
            completion(Result(value: TimeInterval(powerOff), error: nil))
        }
    }
    
    //MARK: - Beep Mode -
    
    typealias BeepModesCompletion = (_ result: Result<[String]>) -> Void
    
    typealias BeepModeCompletion = (_ result: Result<String>) -> Void
    
    func getSupportedBeepModes(_ completion: @escaping BeepModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedBeepMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedBeepMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getSupportedBeepMode")))
                return
            }
            
            completion(Result(value: supported, error: nil))
        }
    }
    
    func getAvailableBeepModes(_ completion: @escaping BeepModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableBeepMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableBeepMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getAvailableBeepMode")))
                return
            }
            
            completion(Result(value: available, error: nil))
        }
    }
    
    func setBeepMode(_ beepMode: String, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setBeepMode", params: [beepMode], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setBeepMode"))
        }
    }
    
    func getBeepMode(_ completion: @escaping BeepModeCompletion) {
        
        let body = SonyRequestBody(method: "getBeepMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getBeepMode") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let mode = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getBeepMode")))
                return
            }
            
            completion(Result(value: mode, error: nil))
        }
    }
    
    //MARK: - Storage Information -
    
    typealias StorageInformationCompletion = (_ result: Result<[StorageInformation]>) -> Void
    
    func getStorageInformation(_ completion: @escaping StorageInformationCompletion) {
        
        let body = SonyRequestBody(method: "getStorageInformation")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getStorageInformation") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let infos = result.first else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getStorageInformation")))
                return
            }
            
            let storageInformations = infos.map({ StorageInformation(dictionary: $0) })
            completion(Result(value: storageInformations, error: nil))
        }
    }
    
    //MARK: - Events -
    
    typealias EventCompletion = (_ result: Result<CameraEvent>) -> Void
    
    func getEvent(polling: Bool, _ completion: @escaping EventCompletion) {
        
        let body = SonyRequestBody(method: "getEvent", params: [polling], id: 1, version: versions?.last ?? "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getEvent") {
                completion(Result(value: nil, error: error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any] else {
                completion(Result(value: nil, error: CameraError.invalidResponse("getEvent")))
                return
            }
            
            let event = CameraEvent(result: result)
            completion(Result(value: event, error: nil))
        }
    }
}
