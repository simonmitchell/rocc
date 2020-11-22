//
//  CameraClient.swift
//  Rocc
//
//  Created by Simon Mitchell on 25/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import ThunderRequest

fileprivate extension LiveView.Quality {
    
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "m":
            self = .displaySpeed
        case "l":
            self = .imageQuality
        default:
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
        case .displaySpeed:
            return "m"
        case .imageQuality:
            return "l"
        }
    }
}

fileprivate extension StillCapture.Quality.Value {
    
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "fine":
            self = .fine
        case "standard":
            self = .standard
        default:
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
        case .fine:
            return "Fine"
        case .standard:
            return "Standard"
        case .extraFine:
            return "Extra Fine"
        }
    }
}

fileprivate extension StillCapture.Format.Value {
    
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "fine", "standard":
            self = .jpeg(sonyString)
        case "raw+jpeg":
            self = .rawAndJpeg
        default:
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
        case .jpeg(let string):
            return string
        case .rawAndJpeg:
            return "RAW+JPEG"
        default:
            return "RAW"
        }
    }
}

fileprivate extension Flash.Mode.Value {
    
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "off":
            self = .off
        case "auto":
            self = .auto
        case "on":
            self = .forcedOn
        case "slowsync":
            self = .slowSynchro
        case "rearsync":
            self = .rearSync
        case "wireless":
            self = .wireless
        default:
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
        case .fill:
            return "fill"
        case .slowSynchro:
            return "slowSync"
        case .rearSync:
            return "rearSync"
        case .auto:
            return "auto"
        case .off:
            return "off"
        case .forcedOn:
            return "on"
        case .wireless:
            return "wireless"
        }
    }
}

fileprivate extension Exposure.Mode.Value {
    
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "aperture":
            self = .aperturePriority
        case "intelligent auto":
            self = .intelligentAuto
        case "program auto":
            self = .programmedAuto
        case "shutter":
            self = .shutterPriority
        case "manual":
            self = .manual
        case "superior auto":
            self = .superiorAuto
        default:
            //TODO: Find strings for other cases
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
        case .aperturePriority:
            return "Aperture"
        case .intelligentAuto:
            return "Intelligent Auto"
        case .programmedAuto:
            return "Program Auto"
        case .shutterPriority:
            return "Shutter"
        case .manual:
            return "Manual"
        case .superiorAuto:
            return "Superior Auto"
        default:
            //TODO: Find strings for other cases
            return ""
        }
    }
}

fileprivate extension Focus.Mode.Value {
    
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "mf":
            self = .manual
        case "af-a":
            self = .auto
        case "af-s":
            self = .autoSingle
        case "af-c":
            self = .autoContinuous
        case "dmf":
            self = .directManual
        default:
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
        case .manual:
            return "MF"
        case .auto:
            return "AF-A"
        case .autoSingle:
            return "AF-S"
        case .autoContinuous:
            return "AF-C"
        case .directManual:
            return "DMF"
        }
    }
}

fileprivate extension ISO.Value {
    
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "auto":
            self = .auto
        default:
            guard let number = Int(sonyString) else { return nil }
            self = number < 100 ? .extended(number) : .native(number)
        }
    }
    
    var sonyString: String {
        switch self {
        case .auto, .multiFrameNRAuto, .multiFrameNRHiAuto:
            return "AUTO"
        case .extended(let value), .native(let value), .multiFrameNRHi(let value), .multiFrameNR(let value):
            return "\(value)"
        }
    }
}

fileprivate extension VideoCapture.Quality.Value {
    
    init?(sonyString: String) {
        // Some cases are missing here as they are not documented by Sony...
        switch sonyString.lowercased() {
        case "ps":
            self = .ps
        case "hq":
            self = .hq
        case "std":
            self = .std
        case "vga":
            self = .vga
        case "slow":
            self = .slow
        case "sslow":
            self = .sslow
        case "hs120":
            self = .hs120
        case "hs100":
            self = .hs100
        case "hs240":
            self = .hs240
        case "hs200":
            self = .hs200
        case "50m 60p":
            self = ._60p_50m
        case "50m 50p":
            self = ._50p_50m
        case "50m 30p":
            self = ._30p_50m
        case "50m 25p":
            self = ._25p_50m
        case "50m 24p":
            self = ._24p_50m
        case "100m 120p":
            self = ._120p_100m
        case "100m 100p":
            self = ._100p_100m
        case "60m 120p":
            self = ._120p_60m
        case "60m 100p":
            self = ._100p_60m
        case "100m 240p":
            self = ._240p_100m
        case "100m 200p":
            self = ._200p_100m
        case "60m 240p":
            self = ._240p_60m
        case "60m 200p":
            self = ._200p_60m
        case "100m 30p":
            self = ._30p_100m
        case "100m 25p":
            self = ._25p_100m
        case "100m 24p":
            self = ._24p_100m
        case "60m 30p":
            self = ._30p_60m
        case "60m 25p":
            self = ._25p_60m
        case "60m 24p":
            self = ._24p_60m
            // Below are guesses based on the above formatting...
        case "50m 120p":
            self = ._120p_50m
        case "50m 100p":
            self = ._100p_50m
        case "16m 30p":
            self = ._30p_16m
        case "16m 25p":
            self = ._25p_16m
        case "6m 30p":
            self = ._30p_6m
        case "6m 25p":
            self = ._25p_6m
        case "28m 60p":
            self = ._60p_28m
        case "28m 50p":
            self = ._50p_28m
        case "25m 60p":
            self = ._60p_25m
        case "25m 50p":
            self = ._50p_25m
        default:
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
            // Some cases are missing here as they are not documented by Sony...
        case .none, ._24p_24m_fx, ._25p_24m_fx, ._50i_24m_fx, ._60i_24m_fx, ._50p_28m_ps, ._60p_28m_ps, ._24p_17m_fh, ._25p_17m_fh, ._50i_17m_fh, ._60i_17m_fh:
            return ""
        case .ps:
            return "PS"
        case .hq:
            return "HQ"
        case .std:
            return "STD"
        case .vga:
            return "VGA"
        case .slow:
            return "SLOW"
        case .sslow:
            return "SSLOW"
        case .hs120:
            return "HS120"
        case .hs100:
            return "HS100"
        case .hs240:
            return "HS240"
        case .hs200:
            return "HS200"
        case ._120p_50m:
            return "50M 120p"
        case ._100p_50m:
            return "50M 100p"
        case ._60p_50m:
            return "50M 60p"
        case ._50p_50m:
            return "50M 50p"
        case ._30p_50m:
            return "50M 30p"
        case ._25p_50m:
            return "50M 25p"
        case ._24p_50m:
            return "50M 24p"
        case ._120p_100m:
            return "100M 120p"
        case ._100p_100m:
            return "100M 100p"
        case ._120p_60m:
            return "60M 120p"
        case ._100p_60m:
            return "60M 100p"
        case ._240p_100m:
            return "100M 240p"
        case ._200p_100m:
            return "100M 200p"
        case ._240p_60m:
            return "60M 240p"
        case ._200p_60m:
            return "60M 200p"
        case ._30p_100m:
            return "100M 30p"
        case ._25p_100m:
            return "100M 25p"
        case ._24p_100m:
            return "100M 24p"
        case ._30p_60m:
            return "60M 30p"
        case ._25p_60m:
            return "60M 25p"
        case ._24p_60m:
            return "60M 24p"
        case ._60p_28m:
            return "28M 60p"
        case ._50p_28m:
            return "28M 50p"
        case ._60p_25m:
            return "25M 60p"
        case ._50p_25m:
            return "25M 50p"
        case ._30p_16m, ._30p_16m_alt:
            return "16M 30p"
        case ._25p_16m, ._25p_16m_alt:
            return "16M 25p"
        case ._30p_6m:
            return "6M 30p"
        case ._25p_6m:
            return "6M 25p"
        }
    }
}

fileprivate extension VideoCapture.FileFormat.Value {
    
    init?(sonyString: String) {
        switch sonyString.lowercased() {
        case "none":
            self = .none
        case "mp4":
            self = .mp4
        case "xavc":
            self = .xavc
        case "xavc s":
            self = .xavc_s
        case "xavc s hd":
            self = .xavc_s_hd
        case "xavc s 4k":
            self = .xavc_s_4k
        case "dvd":
            self = .dvd
        case "dv":
            self = .dv
        case "mxf":
            self = .mxf
        case "avchd":
            self = .avchd
        case "m2ps":
            self = .m2ps
        default:
            return nil
        }
    }
    
    var sonyString: String {
        switch self {
        case .none:
            return "NONE"
        case .dvd:
            return "DVD"
        case .m2ps:
            return "M2PS"
        case .avchd:
            return "AVCHD"
        case .mp4:
            return "MP4"
        case .dv:
            return "DV"
        case .xavc:
            return "XAVC"
        case .mxf:
            return "MXF"
        case .xavc_s_4k:
            return "XAVC S 4K"
        case .xavc_s_hd:
            return "XAVC S HD"
        case .xavc_s:
            return "XAVC S"
        }
    }
}

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
        case .highFrameRate, .singleBracket, .continuousBracket:
            // Not actually a thing for Sony API cameras... so should never be asked for this!
            return ""
        }
    }
}

fileprivate extension ContinuousCapture.Mode.Value {
    var sonyString: String {
        switch self {
        case .continuous, .single, .burst:
            return rawValue.capitalized
        case .motionShot:
            return "Motion Shot"
        case .spdPriorityContinuous:
            return "Spd Priority Cont."
        }
    }
}

fileprivate extension ContinuousCapture.Speed.Value {

    var sonyString: String {
        switch self {
        case .high:
            return "Hi"
        default:
            return rawValue.capitalized
        }
    }
}

fileprivate extension Aperture.Value {
    
    init?(sonyString: String) {
        let formatter = ApertureFormatter()
        guard let aperture = formatter.aperture(from: sonyString) else { return nil }
        self = aperture
    }
    
    var sonyString: String {
        let formatter = ApertureFormatter()
        return formatter.string(for: self) ?? "\(value)"
    }
}

fileprivate extension WhiteBalance.Mode {
    
    init?(sonyString: String) {
                
        switch sonyString.lowercased() {
        case "auto wb":
            self = .auto
        case "daylight":
            self = .daylight
        case "color temperature":
            self = .colorTemp
        case "shade":
            self = .shade
        case "cloudy":
            self = .cloudy
        case "incandescent":
            self = .incandescent
        case "fluorescent: warm white (-1)", "fluorescent warm white", "fluorescent: warm white":
            self = .fluorescentWarmWhite
        case "fluorescent: cool white (0)", "fluorescent cool white", "fluorescent: cool white":
            self = .fluorescentCoolWhite
        case "fluorescent: day white (+1)", "fluorescent day white", "fluorescent: day white":
            self = .fluorescentDayWhite
        case "fluorescent: daylight (+2)", "fluorescent daylight", "fluorescent: daylight":
            self = .fluorescentDaylight
        case "flash":
            self = .flash
        case "underwater auto":
            self = .underwaterAuto
        case "custom 1":
            self = .custom1
        case "custom 2":
            self = .custom2
        case "custom 3":
            self = .custom3
        default:
            return nil
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

fileprivate func exposureCompensationsFor(lowerIndex: Int, upperIndex: Int, stepSize: Int) -> [Exposure.Compensation.Value] {
    
    var compensations: [Exposure.Compensation.Value] = []
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
        compensations.append(Exposure.Compensation.Value(value: Double(i) * step))
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
        var _beepMode: (current: String, available: [String], supported: [String])?
        var _function: (current: String, available: [String], supported: [String])?
        var _functionResult: Bool = false
        var _videoQuality: (current: VideoCapture.Quality.Value, available: [VideoCapture.Quality.Value], supported: [VideoCapture.Quality.Value])?
        var _stillSizeInfo: StillSizeInformation?
        var _steadyMode: (current: String, available: [String], supported: [String])?
        var _viewAngle: (current: Double, available: [Double], supported: [Double])?
        var _exposureMode: (current: Exposure.Mode.Value, available: [Exposure.Mode.Value], supported: [Exposure.Mode.Value])?
        var _postViewImageSize: (current: String, available: [String], supported: [String])?
        var _selfTimer: (current: TimeInterval, available: [TimeInterval], supported: [TimeInterval])?
        var _shootMode: (current: ShootingMode, available: [ShootingMode]?, supported: [ShootingMode])?
        var _exposureCompensation: (current: Exposure.Compensation.Value, available: [Exposure.Compensation.Value], supported: [Exposure.Compensation.Value])?
        var _flashMode: (current: Flash.Mode.Value, available: [Flash.Mode.Value], supported: [Flash.Mode.Value])?
        var _aperture: (current: Aperture.Value, available: [Aperture.Value], supported: [Aperture.Value])?
        var _focusMode: (current: Focus.Mode.Value, available: [Focus.Mode.Value], supported: [Focus.Mode.Value])?
        var _ISO: (current: ISO.Value, available: [ISO.Value], supported: [ISO.Value])?
        var _isProgramShifted: Bool?
        var _shutterSpeed: (current: ShutterSpeed, available: [ShutterSpeed], supported: [ShutterSpeed]?)?
        var _whiteBalance: WhiteBalanceInformation?
        var _touchAF: TouchAF.Information?
        var _focusStatus: FocusStatus?
        var _zoomSetting: (current: String, available: [String], supported: [String])?
        var _stillQuality: (current: StillCapture.Quality.Value, available: [StillCapture.Quality.Value], supported: [StillCapture.Quality.Value])?
        var _stillFormat: (current: StillCapture.Format.Value, available: [StillCapture.Format.Value], supported: [StillCapture.Format.Value])?
        var _continuousShootingMode: (current: ContinuousCapture.Mode.Value?, available: [ContinuousCapture.Mode.Value], supported: [ContinuousCapture.Mode.Value])?
        var _continuousShootingSpeed: (current: ContinuousCapture.Speed.Value, available: [ContinuousCapture.Speed.Value], supported: [ContinuousCapture.Speed.Value])?
        var _continuousShootingURLS: [(postView: URL, thumbnail: URL)]?
        var _flipSetting: (current: String, available: [String], supported: [String])?
        var _scene: (current: String, available: [String], supported: [String])?
        var _intervalTime: (current: TimeInterval, available: [TimeInterval], supported: [TimeInterval])?
        var _colorSetting: (current: String, available: [String], supported: [String])?
        var _videoFileFormat: (current: VideoCapture.FileFormat.Value, available: [VideoCapture.FileFormat.Value], supported: [VideoCapture.FileFormat.Value])?
        var _videoRecordingTime: TimeInterval?
        var _infraredRemoteControl: (current: String, available: [String], supported: [String])?
        var _tvColorSystem: (current: String, available: [String], supported: [String])?
        var _trackingFocusStatus: String?
        var _trackingFocus: (current: String, available: [String], supported: [String])?
        var _batteryInfo: [BatteryInformation]?
        var _numberOfShots: Int?
        var _autoPowerOff: (current: TimeInterval, available: [TimeInterval], supported: [TimeInterval])?
        var _loopRecordTime: (current: TimeInterval, available: [TimeInterval], supported: [TimeInterval])?
        var _audioRecording: (current: String, available: [String], supported: [String])?
        var _windNoiseReduction: (current: String, available: [String], supported: [String])?
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
                    _beepMode = (current, candidates, candidates)
                case "cameraFunction":
                    guard let current = dictionaryElement["currentCameraFunction"] as? String, let candidates = dictionaryElement["cameraFunctionCandidates"] as? [String] else { return }
                    _function = (current, candidates, candidates)
                case "movieQuality":
                    guard let current = dictionaryElement["currentMovieQuality"] as? String, let candidates = dictionaryElement["movieQualityCandidates"] as? [String], let currentEnum = VideoCapture.Quality.Value(sonyString: current) else { return }
                    let enumCandidates = candidates.compactMap({ VideoCapture.Quality.Value(sonyString: $0) })
                    _videoQuality = (currentEnum, enumCandidates, enumCandidates)
                case "stillSize":
                    guard let check = dictionaryElement["checkAvailability"] as? Bool, let currentAspect = dictionaryElement["currentAspect"] as? String, let currentSize = dictionaryElement["currentSize"] as? String else { return }
                    _stillSizeInfo = StillSizeInformation(shouldCheck: check, stillSize: StillCapture.Size.Value(aspectRatio: currentAspect, size: currentSize), available: nil, supported: nil)
                case "cameraFunctionResult":
                    guard let current = dictionaryElement["cameraFunctionResult"] as? String, current == "Success" || current == "Failure" else { return }
                    _functionResult = current == "Success"
                case "steadyMode":
                    guard let current = dictionaryElement["currentSteadyMode"] as? String, let candidates = dictionaryElement["steadyModeCandidates"] as? [String] else { return }
                    _steadyMode = (current, candidates, candidates)
                case "viewAngle":
                    guard let current = dictionaryElement["currentViewAngle"] as? Int, let candidates = dictionaryElement["viewAngleCandidates"] as? [Int] else { return }
                    _viewAngle = (Double(current), candidates.map({ Double($0) }), candidates.map({ Double($0) }))
                case "exposureMode":
                    guard let current = dictionaryElement["currentExposureMode"] as? String, let currentEnum = Exposure.Mode.Value(sonyString: current), let candidates = dictionaryElement["exposureModeCandidates"] as? [String] else { return }
                    _exposureMode = (currentEnum, candidates.compactMap({ Exposure.Mode.Value(sonyString: $0) }), candidates.compactMap({ Exposure.Mode.Value(sonyString: $0) }))
                case "postviewImageSize":
                    guard let current = dictionaryElement["currentPostviewImageSize"] as? String, let candidates = dictionaryElement["postviewImageSizeCandidates"] as? [String] else { return }
                    _postViewImageSize = (current, candidates, candidates)
                case "selfTimer":
                    guard let current = dictionaryElement["currentSelfTimer"] as? Int, let candidates = dictionaryElement["selfTimerCandidates"] as? [Int] else { return }
                    _selfTimer = (TimeInterval(current), candidates.map({ TimeInterval($0) }), candidates.map({ TimeInterval($0) }))
                case "shootMode":
                    guard let current = dictionaryElement["currentShootMode"] as? String, let candidates = dictionaryElement["shootModeCandidates"] as? [String] else { return }
                    guard let currentEnum = ShootingMode(sonyString: current) else { return }
                    var enumCandidates = candidates.compactMap({ ShootingMode(sonyString: $0) })
                    if enumCandidates.contains(.photo) {
                        enumCandidates.append(contentsOf: [.timelapse, .continuous, .bulb])
                    }
                    _shootMode = (currentEnum, enumCandidates, enumCandidates)
                case "exposureCompensation":
                    
                    guard let currentStep = dictionaryElement["currentExposureCompensation"] as? Int, let minIndex = dictionaryElement["minExposureCompensation"] as? Int, let maxIndex = dictionaryElement["maxExposureCompensation"] as? Int, let stepIndex = dictionaryElement["stepIndexOfExposureCompensation"] as? Int else { return }
                    
                    let compensations = exposureCompensationsFor(lowerIndex: minIndex, upperIndex: maxIndex, stepSize: stepIndex)
                    
                    let centeredIndex = compensations.count/2 + currentStep
                    guard centeredIndex < compensations.count, centeredIndex >= 0 else { return }
                    _exposureCompensation = (compensations[centeredIndex], compensations, compensations)
                    
                case "flashMode":
                    guard let current = dictionaryElement["currentFlashMode"] as? String, let currentEnum = Flash.Mode.Value(sonyString: current), let candidates = dictionaryElement["flashModeCandidates"] as? [String] else { return }
                    _flashMode = (currentEnum, candidates.compactMap({ Flash.Mode.Value(sonyString: $0) }), candidates.compactMap({ Flash.Mode.Value(sonyString: $0) }))
                case "fNumber":
                    guard let current = dictionaryElement["currentFNumber"] as? String, let aperture = Aperture.Value(sonyString: current), let candidates = dictionaryElement["fNumberCandidates"] as? [String] else { return }
                    _aperture = (aperture, candidates.compactMap({ Aperture.Value(sonyString: $0) }), candidates.compactMap({ Aperture.Value(sonyString: $0) }))
                case "focusMode":
                    guard let current = dictionaryElement["currentFocusMode"] as? String, let currentEnum = Focus.Mode.Value(sonyString: current), let candidates = dictionaryElement["focusModeCandidates"] as? [String] else { return }
                    _focusMode = (currentEnum, candidates.compactMap({ Focus.Mode.Value(sonyString: $0) }), candidates.compactMap({ Focus.Mode.Value(sonyString: $0) }))
                case "isoSpeedRate":
                    guard let current = dictionaryElement["currentIsoSpeedRate"] as? String, let currentEnum = ISO.Value(sonyString: current), let candidates = dictionaryElement["isoSpeedRateCandidates"] as? [String] else { return }
                    let candidateEnums = candidates.compactMap({ ISO.Value(sonyString: $0) })
                    _ISO = (currentEnum, candidateEnums, candidateEnums)
                case "programShift":
                    _isProgramShifted = dictionaryElement["isShifted"] as? Bool
                case "shutterSpeed":
                    let shutterSpeedFormatter = ShutterSpeedFormatter()
                    guard let currentString = dictionaryElement["currentShutterSpeed"] as? String, let current = shutterSpeedFormatter.shutterSpeed(from: currentString), let candidateStrings = dictionaryElement["shutterSpeedCandidates"] as? [String] else { return }
                    _shutterSpeed = (current, candidateStrings.compactMap({ shutterSpeedFormatter.shutterSpeed(from: $0) }), candidateStrings.compactMap({ shutterSpeedFormatter.shutterSpeed(from: $0) }))
                case "whiteBalance":
                    guard let check = dictionaryElement["checkAvailability"] as? Bool, let currentMode = dictionaryElement["currentWhiteBalanceMode"] as? String, let modeEnum = WhiteBalance.Mode(sonyString: currentMode) else { return }
                    let currentTemp = dictionaryElement["currentColorTemperature"] as? Int
                    _whiteBalance = WhiteBalanceInformation(shouldCheck: check, whitebalanceValue: WhiteBalance.Value(mode: modeEnum, temperature: currentTemp != -1 ? currentTemp : nil, rawInternal: currentMode), available: nil, supported: nil)
                case "touchAFPosition":
                    _touchAF = TouchAF.Information(dictionary: dictionaryElement)
                case "focusStatus":
                    guard let status = dictionaryElement["focusStatus"] as? String else { return }
                    _focusStatus = FocusStatus(sonyString: status)
                case "zoomSetting":
                    guard let current = dictionaryElement["zoom"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _zoomSetting = (current, candidates, candidates)
                case "stillQuality":
                    guard let current = dictionaryElement["stillQuality"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    if let currentQuality = StillCapture.Quality.Value(sonyString: current) {
                        let qualities = candidates.compactMap({ StillCapture.Quality.Value(sonyString: $0) }).unique
                        _stillQuality = (currentQuality, qualities, qualities)
                    }
                    if let currentFormat = StillCapture.Format.Value(sonyString: current) {
                        //TODO: This may give us duplicate still formats, work out a way around!
                        let formats = candidates.compactMap({ StillCapture.Format.Value(sonyString: $0) })
                        _stillFormat = (currentFormat, formats, formats)
                    }
                case "contShootingMode":
                    guard let current = dictionaryElement["contShootingMode"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    guard let currentEnum = ContinuousCapture.Mode.Value(rawValue: current.lowercased()) else { return }
                    _continuousShootingMode = (currentEnum, candidates.compactMap({ ContinuousCapture.Mode.Value(rawValue: $0.lowercased()) }), candidates.compactMap({ ContinuousCapture.Mode.Value(rawValue: $0.lowercased()) }))
                case "contShootingSpeed":
                    guard let current = dictionaryElement["contShootingSpeed"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    guard let currentEnum = ContinuousCapture.Speed.Value(rawValue: current.lowercased()) else {
                        return
                    }
                    _continuousShootingSpeed = (currentEnum, candidates.compactMap({ ContinuousCapture.Speed.Value(rawValue: $0.lowercased()) }), candidates.compactMap({ ContinuousCapture.Speed.Value(rawValue: $0.lowercased()) }))
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
                    _flipSetting = (current, candidates, candidates)
                case "sceneSelection":
                    guard let current = dictionaryElement["scene"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _scene = (current, candidates, candidates)
                case "intervalTime":
                    guard let current = dictionaryElement["intervalTimeSec"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    guard let currentDouble = TimeInterval(current) else { return }
                    let available = candidates.compactMap({ (candidate) -> TimeInterval? in
                        return TimeInterval(candidate)
                    })
                    _intervalTime = (currentDouble, available, available)
                case "colorSetting":
                    guard let current = dictionaryElement["colorSetting"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _colorSetting = (current, candidates, candidates)
                case "movieFileFormat":
                    guard let current = dictionaryElement["movieFileFormat"] as? String, let candidates = dictionaryElement["candidate"] as? [String], let currentEnum = VideoCapture.FileFormat.Value(sonyString: current) else { return }
                    let enumCandidates = candidates.compactMap({ VideoCapture.FileFormat.Value(sonyString: $0) })
                    _videoFileFormat = (currentEnum, enumCandidates, enumCandidates)
                case "infraredRemoteControl":
                    guard let current = dictionaryElement["infraredRemoteControl"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _infraredRemoteControl = (current, candidates, candidates)
                case "tvColorSystem":
                    guard let current = dictionaryElement["tvColorSystem"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _tvColorSystem = (current, candidates, candidates)
                case "trackingFocusStatus":
                    _trackingFocusStatus = dictionaryElement["trackingFocusStatus"] as? String
                case "trackingFocus":
                    guard let current = dictionaryElement["trackingFocus"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _trackingFocus = (current, candidates, candidates)
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
                    _autoPowerOff = (TimeInterval(current), candidates.map({ TimeInterval($0) }), candidates.map({ TimeInterval($0) }))
                case "loopRecTime":
                    
                    guard let current = dictionaryElement["loopRecTime"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    
                    guard let duration: TimeInterval = current == "unlimited" ? TimeInterval.infinity : TimeInterval(current) else { return }
                    
                    let available: [TimeInterval] = candidates.compactMap({
                        if $0 == "unlimited" {
                            return TimeInterval.infinity
                        }
                        return TimeInterval($0)
                    })
                    
                    _loopRecordTime = (duration, available, available)
                    
                case "audioRecording":
                    guard let current = dictionaryElement["audioRecording"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _audioRecording = (current, candidates, candidates)
                case "windNoiseReduction":
                    guard let current = dictionaryElement["windNoiseReduction"] as? String, let candidates = dictionaryElement["candidate"] as? [String] else { return }
                    _windNoiseReduction = (current, candidates, candidates)
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
                        
                       let info = StorageInformation(dictionary: element)
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
            liveViewInfo = LiveViewInformation(
                status: liveViewStatus,
                orientation: _liveViewOrientation
            )
        } else {
            liveViewInfo = nil
        }
        
        if _shutterSpeed?.current.isBulb == true {
            // If the shutter speed is bulb, then we're in BULB shoot mode.
            // we need to manually report this because Sony don't do it for us!
            _shootMode = (.bulb, _shootMode?.available ?? [], _shootMode?.supported ?? [])
        }
        
        var pictureURLs: [ShootingMode: [(postView: URL, thumbnail: URL?)]] = [:]
        
        if !_takenPictureURLS.isEmpty {
            pictureURLs[.photo] = _takenPictureURLS.flatMap({ $0 }).map({ (url) -> (postView: URL, thumbnail: URL?) in
                return (url, nil)
            })
        }
        
        if let continuousShootingURLs = _continuousShootingURLS {
            pictureURLs[.continuous] = continuousShootingURLs
        }
        
        status = _cameraStatus
        zoomPosition = _zoomPosition
        postViewPictureURLs = pictureURLs.isEmpty ? nil : pictureURLs
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
        exposureSettingsLockStatus = nil
        flashMode = _flashMode
        aperture = _aperture
        focusMode = _focusMode
        iso = _ISO
        isProgramShifted = _isProgramShifted
        shutterSpeed = _shutterSpeed
        whiteBalance = _whiteBalance
        touchAF = _touchAF
        focusStatus = _focusStatus
        zoomSetting = _zoomSetting
        stillQuality = _stillQuality
        stillFormat = _stillFormat
        continuousShootingMode = _continuousShootingMode
        continuousShootingSpeed = _continuousShootingSpeed
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
        supportedFunctions = []
        //PTP/IP things!
        exposureModeDialControl = nil
        highFrameRateCaptureStatus = nil
        singleBracketedShootingBrackets = nil
        continuousBracketedShootingBrackets = nil
        liveViewQuality = nil
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
        noMedia = id?.lowercased() == "no media"
        
        if let time = dictionary["recordableTime"] as? Int, time != -1 {
            recordableTime = time
        } else {
            recordableTime = nil
        }
    }
}

fileprivate extension StillCapture.Size.Value {
    
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
        
        guard let mode = dictionary["whiteBalanceMode"] as? String, let modeEnum = WhiteBalance.Mode(sonyString: mode) else {
            return nil
        }
        
        self.mode = modeEnum
        rawInternal = mode
        temperature = dictionary["colorTemperature"] as? Int
    }
    
    var sonySerialisable: [Any] {
        return [self.rawInternal, temperature != nil, self.temperature ?? 2500]
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
    
    var eventMethodName: String? {
        guard let availableApiList = availableApiList else {
            return nil
        }
        for eventName in ["getEvent", "receiveEvent"] {
            if availableApiList.contains(eventName) {
                return eventName
            }
        }
        return nil
    }
    
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
    
    typealias ShootModesCompletion = (_ result: Result<[ShootingMode], Error>) -> Void
    
    typealias ShootModeCompletion = (_ result: Result<ShootingMode, Error>) -> Void
    
    func getSupportedShootModes(_ completion: @escaping ShootModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedShootMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedShootMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedShootMode")))
                return
            }
            
            var enumValues = supported.compactMap({ ShootingMode(sonyString: $0) })
            guard !enumValues.isEmpty else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedShootMode")))
                return
            }
            
            if enumValues.contains(.photo) {
                enumValues.append(contentsOf: [.timelapse, .continuous])
            }
            
            completion(Result.success(enumValues))
        }
    }
    
    func getAvailableShootModes(_ completion: @escaping ShootModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableShootMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableShootMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableShootMode")))
                return
            }
            
            var enumValues = available.compactMap({ ShootingMode(sonyString: $0) })
            guard !enumValues.isEmpty else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableShootMode")))
                return
            }
            
            if enumValues.contains(.photo) {
                enumValues.append(contentsOf: [.timelapse, .continuous, .bulb])
            }
            
            completion(Result.success(enumValues))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let shootingMode = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getShootMode")))
                return
            }
            
            guard let enumResult = ShootingMode(sonyString: shootingMode) else {
                completion(Result.failure(CameraError.invalidResponse("getShootMode")))
                return
            }
            
            completion(Result.success(enumResult))
        }
    }
    
    //MARK: - Aperture
    
    typealias AperturesCompletion = (_ result: Result<[Aperture.Value], Error>) -> Void

    typealias ApertureCompletion = (_ result: Result<Aperture.Value, Error>) -> Void
    
    func getSupportedApertures(_ completion: @escaping AperturesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFNumber")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFNumber") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedFNumber")))
                return
            }
            
            completion(Result.success(supported.compactMap({ Aperture.Value(sonyString: $0) })))
        }
    }
    
    func getAvailableApertures(_ completion: @escaping AperturesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFNumber")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFNumber") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableFNumber")))
                return
            }
            
            completion(Result.success(available.compactMap({ Aperture.Value(sonyString: $0) })))
        }
    }
    
    func setAperture(_ aperture: Aperture.Value, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setFNumber", params: [aperture.sonyString], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setFNumber"))
        }
    }
    
    func getAperture(_ completion: @escaping ApertureCompletion) {
        
        let body = SonyRequestBody(method: "getFNumber")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getFNumber") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let apertureString = result.first, let aperture = Aperture.Value(sonyString: apertureString) else {
                completion(Result.failure(CameraError.invalidResponse("getFNumber")))
                return
            }
            
            completion(Result.success(aperture))
        }
    }
    
    //MARK: - ISO
    
    typealias ISOValuesCompletion = (_ result: Result<[ISO.Value], Error>) -> Void
    
    typealias ISOCompletion = (_ result: Result<ISO.Value, Error>) -> Void
    
    func getSupportedISOValues(_ completion: @escaping ISOValuesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedIsoSpeedRate")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedIsoSpeedRate") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedIsoSpeedRate")))
                return
            }
            
            completion(Result.success(supported.compactMap({ ISO.Value(sonyString: $0) })))
        }
    }
    
    func getAvailableISOValues(_ completion: @escaping ISOValuesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableIsoSpeedRate")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableIsoSpeedRate") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableIsoSpeedRate")))
                return
            }
            
            completion(Result.success(available.compactMap({ ISO.Value(sonyString: $0) })))
        }
    }
    
    func setISO(_ ISO: ISO.Value, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setIsoSpeedRate", params: [ISO.sonyString], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setIsoSpeedRate"))
        }
    }
    
    func getISO(_ completion: @escaping ISOCompletion) {
        
        let body = SonyRequestBody(method: "getIsoSpeedRate")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getIsoSpeedRate") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let iso = result.first, let ISOValue = ISO.Value(sonyString: iso) else {
                completion(Result.failure(CameraError.invalidResponse("getIsoSpeedRate")))
                return
            }
            
            completion(Result.success(ISOValue))
        }
    }
    
    //MARK: - Shutter Speed
    
    typealias ShutterSpeedsCompletion = (_ result: Result<[ShutterSpeed], Error>) -> Void
    
    typealias ShutterSpeedCompletion = (_ result: Result<ShutterSpeed, Error>) -> Void
    
    func getSupportedShutterSpeeds(_ completion: @escaping ShutterSpeedsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedShutterSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedShutterSpeed") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedShutterSpeed")))
                return
            }
            
            let formatter = ShutterSpeedFormatter()
            let shutterSpeeds = supported.compactMap({ formatter.shutterSpeed(from: $0) })
            completion(Result.success(shutterSpeeds))
        }
    }
    
    func getAvailableShutterSpeeds(_ completion: @escaping ShutterSpeedsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableShutterSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableShutterSpeed") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableShutterSpeed")))
                return
            }
            
            let formatter = ShutterSpeedFormatter()
            let shutterSpeeds = available.compactMap({ formatter.shutterSpeed(from: $0) })
            completion(Result.success(shutterSpeeds))
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
                completion(Result.failure(error))
                return
            }
            
            let shutterSpeedFormatter = ShutterSpeedFormatter()
            guard let result = response?.dictionary?["result"] as? [String], let shutterSpeedString = result.first, let shutterSpeed = shutterSpeedFormatter.shutterSpeed(from: shutterSpeedString) else {
                completion(Result.failure(CameraError.invalidResponse("getShutterSpeed")))
                return
            }
            
            completion(Result.success(shutterSpeed))
        }
    }
    
    //MARK: - White Balance
    
    typealias WhiteBalancesCompletion = (_ result: Result<[WhiteBalance.Value], Error>) -> Void
    
    typealias WhiteBalanceCompletion = (_ result: Result<WhiteBalance.Value, Error>) -> Void
    
    func getSupportedWhiteBalances(_ completion: @escaping WhiteBalancesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedWhiteBalance")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in

            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedWhiteBalance") {
                completion(Result.failure(error))
                return
            }

            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedWhiteBalance")))
                return
            }
            
            var supportedWhiteBalances: [WhiteBalance.Value] = []
            
            supported.forEach({ (whiteBalanceDict) in
                
                guard let mode = whiteBalanceDict["whiteBalanceMode"] as? String, let modeEnum = WhiteBalance.Mode(sonyString: mode), let colorTempRange = whiteBalanceDict["colorTemperatureRange"] as? [Int] else {
                    return
                }
                
                guard !colorTempRange.isEmpty else {
                    supportedWhiteBalances.append(WhiteBalance.Value(mode: modeEnum, temperature: nil, rawInternal: mode))
                    return
                }
                
                colorTempRange.forEach({ (temperature) in
                    supportedWhiteBalances.append(WhiteBalance.Value(mode: modeEnum, temperature: temperature, rawInternal: mode))
                })
            })
            
            completion(Result.success(supportedWhiteBalances))
        }
    }
    
    func getAvailableWhiteBalances(_ completion: @escaping WhiteBalancesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableWhiteBalance")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableWhiteBalance") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [[AnyHashable : Any]] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableWhiteBalance")))
                return
            }
            
            var availableWhiteBalances: [WhiteBalance.Value] = []
            
            available.forEach({ (whiteBalanceDict) in
                
                guard let mode = whiteBalanceDict["whiteBalanceMode"] as? String, let modeEnum = WhiteBalance.Mode(sonyString: mode), let colorTempRange = whiteBalanceDict["colorTemperatureRange"] as? [Int] else {
                    return
                }
                
                guard !colorTempRange.isEmpty else {
                    availableWhiteBalances.append(WhiteBalance.Value(mode: modeEnum, temperature: nil, rawInternal: mode))
                    return
                }
                
                colorTempRange.forEach({ (temperature) in
                    availableWhiteBalances.append(WhiteBalance.Value(mode: modeEnum, temperature: temperature, rawInternal: mode))
                })
            })
            
            completion(Result.success(availableWhiteBalances))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let whiteBalanceDict = result.first, let whiteBalance = WhiteBalance.Value(dictionary: whiteBalanceDict) else {
                completion(Result.failure(CameraError.invalidResponse("getWhiteBalance")))
                return
            }
            
            completion(Result.success(whiteBalance))
        }
    }
    
    typealias WhiteBalanceCustomFromShotCompletion = (_ result: Result<WhiteBalance.Custom.Result, Error>) -> Void
    
    func setCustomWhiteBalanceFromShot(_ completion: @escaping WhiteBalanceCustomFromShotCompletion) {
        
        let body = SonyRequestBody(method: "actWhiteBalanceOnePushCustom")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "actWhiteBalanceOnePushCustom") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let firstResult = result.first else {
                completion(Result.failure(CameraError.invalidResponse("actWhiteBalanceOnePushCustom")))
                return
            }
            
            guard let resultObject = WhiteBalance.Custom.Result(dictionary: firstResult) else {
                completion(Result.failure(CameraError.invalidResponse("actWhiteBalanceOnePushCustom")))
                return
            }
            
            completion(Result.success(resultObject))
        }
    }
    
    //MARK: - Camera Function -
    
    typealias CameraFunctionCompletion = (_ result: Result<String, Error>) -> Void

    typealias CameraFunctionsCompletion = (_ result: Result<[String], Error>) -> Void
    
    func getSupportedCameraFunctions(_ completion: @escaping CameraFunctionsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedCameraFunction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedCameraFunction") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let functions = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedCameraFunction")))
                return
            }
            
            completion(Result.success(functions))
        }
    }
    
    func getAvailableCameraFunctions(_ completion: @escaping CameraFunctionsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableCameraFunction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableCameraFunction") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let functions = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableCameraFunction")))
                return
            }
            
            completion(Result.success(functions))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let function = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getCameraFunction")))
                return
            }
            
            completion(Result.success(function))
        }
    }
    
    //MARK: - Capture -
    
    typealias TakePictureCompletion = (_ result: Result<(url: URL?, needsAwait: Bool), Error>) -> Void
    
    typealias AwaitPictureCompletion = (_ result: Result<URL, Error>) -> Void
    
    //MARK: Single
    
    func takePicture(_ completion: @escaping TakePictureCompletion) {
        
        let body = SonyRequestBody(method: "actTakePicture")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let responseError = CameraError(responseDictionary: response?.dictionary, methodName: "actTakePicture") {
                switch responseError {
                    
                case .stillCapturingNotFinished:
                    completion(Result.success((nil, true)))
                default:
                    completion(Result.failure(responseError))
                }
                
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let urlString = result.first?.first, let url = URL(string: urlString) else {
                completion(Result.failure(CameraError.invalidResponse("actTakePicture")))
                return
            }
            
            completion(Result.success((url, false)))
        }
    }
    
    func awaitTakePicture(_ completion: @escaping AwaitPictureCompletion) {
        
        let body = SonyRequestBody(method: "awaitTakePicture")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "awaitTakePicture") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let urlString = result.first?.first, let url = URL(string: urlString) else {
                completion(Result.failure(CameraError.invalidResponse("awaitTakePicture")))
                return
            }
            
            completion(Result.success(url))
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
    
    typealias ContinuousShootingModesCompletion = (_ result: Result<[ContinuousCapture.Mode.Value], Error>) -> Void
    
    typealias ContinuousShootingModeCompletion = (_ result: Result<ContinuousCapture.Mode.Value, Error>) -> Void
    
    func getSupportedContinuousShootingModes(_ completion: @escaping ContinuousShootingModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedContShootingMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedContShootingMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingModes = result.first, let supported = continuousShootingModes["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedContShootingMode")))
                return
            }
            
            let modes = supported.compactMap({ ContinuousCapture.Mode.Value(rawValue: $0.lowercased()) })
            completion(Result.success(modes))
        }
    }
    
    func getAvailableContinuousShootingModes(_ completion: @escaping ContinuousShootingModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableContShootingMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableContShootingMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingModes = result.first, let available = continuousShootingModes["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableContShootingMode")))
                return
            }
            
            let modes = available.compactMap({ ContinuousCapture.Mode.Value(rawValue: $0.lowercased()) })
            completion(Result.success(modes))
        }
    }
    
    func setContinuousShootingMode(_ mode: ContinuousCapture.Mode.Value, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setContShootingMode", params: [["contShootingMode" : mode.sonyString]], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setContShootingMode"))
        }
    }
    
    func getContinuousShootingMode(_ completion: @escaping ContinuousShootingModeCompletion) {
        
        let body = SonyRequestBody(method: "getContShootingMode")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getContShootingMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingModes = result.first, let value = continuousShootingModes["contShootingMode"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getContShootingMode")))
                return
            }
            
            guard let mode = ContinuousCapture.Mode.Value(rawValue: value.lowercased()) else {
                completion(Result.failure(CameraError.invalidResponse("getContShootingMode")))
                return
            }
            
            completion(Result.success(mode))
        }
    }
    
    //MARK: Speeds
    
    typealias ContinuousShootingSpeedsCompletion = (_ result: Result<[ContinuousCapture.Speed.Value], Error>) -> Void
    
    typealias ContinuousShootingSpeedCompletion = (_ result: Result<ContinuousCapture.Speed.Value, Error>) -> Void
    
    func getSupportedContinuousShootingSpeeds(_ completion: @escaping ContinuousShootingSpeedsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedContShootingSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedContShootingSpeed") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingSpeeds = result.first, let supported = continuousShootingSpeeds["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedContShootingSpeed")))
                return
            }
            
            let supportedEnums = supported.compactMap({ ContinuousCapture.Speed.Value(rawValue: $0.lowercased()) })
            
            completion(Result.success(supportedEnums))
        }
    }
    
    func getAvailableContinuousShootingSpeeds(_ completion: @escaping ContinuousShootingSpeedsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableContShootingSpeed")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableContShootingSpeed") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let continuousShootingSpeeds = result.first, let available = continuousShootingSpeeds["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableContShootingSpeed")))
                return
            }
            
            let availableEnums = available.compactMap({ ContinuousCapture.Speed.Value(rawValue: $0.lowercased()) })
            completion(Result.success(availableEnums))
        }
    }
    
    func setContinuousShootingSpeed(_ speed: ContinuousCapture.Speed.Value, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setContShootingSpeed", params: [["contShootingSpeed" : speed.sonyString]], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setContShootingSpeed"))
        }
    }
    
    func getContinuousShootingSpeed(_ completion: @escaping ContinuousShootingSpeedCompletion) {
        
        let body = SonyRequestBody(method: "getContShootingSpeed")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getContShootingSpeed") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let speedSettings = result.first, let value = speedSettings["contShootingSpeed"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getContShootingSpeed")))
                return
            }
            
            guard let enumValue = ContinuousCapture.Speed.Value(rawValue: value.lowercased()) else {
                completion(Result.failure(CameraError.invalidResponse("getContShootingSpeed")))
                return
            }
            
            completion(Result.success(enumValue))
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
    
    typealias AudioRecordingSettingsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias AudioRecordingSettingCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedAudioRecordingSettings(_ completion: @escaping AudioRecordingSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedAudioRecording")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedAudioRecording") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedAudioRecording")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableAudioRecordingSettings(_ completion: @escaping AudioRecordingSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableAudioRecording")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableAudioRecording") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableAudioRecording")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["windNoiseReduction"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getAudioRecording")))
                return
            }
            
            completion(Result.success(scene))
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
    
    typealias LoopDurationsCompletion = (_ result: Result<[TimeInterval], Error>) -> Void
    
    typealias LoopDurationCompletion = (_ result: Result<TimeInterval, Error>) -> Void
    
    func getSupportedLoopDurations(_ completion: @escaping LoopDurationsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedLoopDuration")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedLoopDuration") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedLoopDuration")))
                return
            }
            
            let _supported: [TimeInterval] = supported.compactMap({
                if $0 == "unlimited" {
                    return TimeInterval.infinity
                }
                return TimeInterval($0)
            })
            
            completion(Result.success(_supported))
        }
    }
    
    func getAvailableLoopDurations(_ completion: @escaping LoopDurationsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableLoopDuration")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableLoopDuration") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableLoopDuration")))
                return
            }
            
            let _available: [TimeInterval] = available.compactMap({
                if $0 == "unlimited" {
                    return TimeInterval.infinity
                }
                return TimeInterval($0)
            })
            
            completion(Result.success(_available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let durationMinString = result.first?["loopRecTimeMin"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getLoopDuration")))
                return
            }
            
            if let durationMin = TimeInterval(durationMinString) {
                completion(Result.success(durationMin * 60))
            } else if durationMinString == "unlimited" {
                completion(Result.success(TimeInterval.infinity))
            } else {
                completion(Result.failure(CameraError.invalidResponse("getLoopDuration")))
            }
        }
    }
    
    //MARK: - Live View -
    
    typealias LiveViewCompletion = (_ result: Result<URL, Error>) -> Void

    func startLiveView(_ completion: @escaping LiveViewCompletion) {
        
        let body = SonyRequestBody(method: "startLiveview")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startLiveview") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let streamURLString = result.first, let streamURL = URL(string: streamURLString) else {
                completion(Result.failure(CameraError.invalidResponse("startLiveview")))
                return
            }
            
            completion(Result.success(streamURL))
        }
    }
    
    func stopLiveView(_ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "stopLiveview")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "stopLiveview"))
        }
    }
    
    //MARK: - With Size
    
    typealias LiveViewSizesCompletion = (_ result: Result<[LiveView.Quality], Error>) -> Void
    
    typealias LiveViewSizeCompletion = (_ result: Result<LiveView.Quality, Error>) -> Void
    
    typealias SetLiveViewSizeCompletion = (_ result: Result<URL, Error>) -> Void
    
    func getAvailableLiveViewSizes(_ completion: @escaping LiveViewSizesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableLiveviewSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableLiveviewSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableLiveviewSize")))
                return
            }
            
            completion(Result.success(available.compactMap({ LiveView.Quality(sonyString: $0) })))
        }
    }
    
    func getSupportedLiveViewSizes(_ completion: @escaping LiveViewSizesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedLiveviewSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedLiveviewSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let supported = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedLiveviewSize")))
                return
            }
            
            completion(Result.success(supported.compactMap({ LiveView.Quality(sonyString: $0) })))
        }
    }
    
    func startLiveViewWithSize(_ size: LiveView.Quality, _ completion: @escaping LiveViewCompletion) {
        
        let body = SonyRequestBody(method: "startLiveviewWithSize", params: [size.sonyString], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "startLiveviewWithSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String],
                let streamURLString = result.first,
                let streamURL = URL(string: streamURLString) else {
                completion(Result.failure(CameraError.invalidResponse("startLiveviewWithSize")))
                return
            }
            
            completion(Result.success(streamURL))
        }
    }
    
    func getLiveViewSize(_ completion: @escaping LiveViewSizeCompletion) {
        
        let body = SonyRequestBody(method: "getLiveviewSize")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getLiveviewSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String],
                let size = result.first,
                let sizeEnum = LiveView.Quality(sonyString: size) else {
                completion(Result.failure(CameraError.invalidResponse("getLiveviewSize")))
                return
            }
            
            completion(Result.success(sizeEnum))
        }
    }
    
    func setLiveViewSize(size: LiveView.Quality, _ completion: @escaping LiveViewCompletion) {
        
        // We have to start and stop the live view to set it's size using `startLiveViewWithSize`
        let performSwitch: (@escaping LiveViewCompletion) -> Void = { [weak self] completion in
            guard let self = self else { return }
            self.stopLiveView { (_) in
                self.startLiveViewWithSize(size, completion)
            }
        }
        
        // First we're going to check if the requested size is available, if it's not then we'll return an error
        getAvailableLiveViewSizes { (result) in
            switch result {
            case .success(let sizes):
                guard sizes.contains(size) else {
                    completion(.failure(CameraError.notAvailable("")))
                    return
                }
                performSwitch(completion)
            case .failure(_):
                performSwitch(completion)
            }
        }
    }
    
    //MARK: - Frame info
    
    typealias LiveViewFrameInfoCompletion = (_ result: Result<Bool, Error>) -> Void
    
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let info = result.first, let enabled = info["frameInfo"] as? Bool else {
                completion(Result.failure(CameraError.invalidResponse("getLiveviewFrameInfo")))
                return
            }
            
            completion(Result.success(enabled))
        }
    }
    
    //MARK: - Zoom -
    
    func zoom(in direction: Zoom.Direction, start: Bool, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "actZoom", params: [direction.rawValue, start ? "start" : "stop"], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "actZoom"))
        }
    }
    
    typealias ZoomSettingsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias ZoomSettingCompletion = (_ result: Result<String, Error>) -> Void
    
    //MARK: - Settings
    
    func getSupportedZoomSettings(_ completion: @escaping ZoomSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedZoomSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedZoomSetting") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let zoomSettings = result.first, let supported = zoomSettings["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedZoomSetting")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableZoomSettings(_ completion: @escaping ZoomSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableZoomSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableZoomSetting") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let zoomSettings = result.first, let supported = zoomSettings["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableZoomSetting")))
                return
            }
            
            completion(Result.success(supported))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let zoomSettingDict = result.first, let setting = zoomSettingDict["zoom"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getZoomSetting")))
                return
            }
            
            completion(Result.success(setting))
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
    
    typealias TouchAFPositionCompletion = (_ result: Result<TouchAF.Information, Error>) -> Void
    
    func setTouchAFPosition(_ position: CGPoint, _ completion: @escaping TouchAFPositionCompletion) {
        
        let body = SonyRequestBody(method: "setTouchAFPosition", params: [position.x, position.y], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            guard let result = (response?.dictionary?["result"] as? [Any])?.compactMap({ $0 as? [AnyHashable : Any] }).first, let touchAFInfo = TouchAF.Information(dictionary: result) else {
                completion(Result.failure(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setTouchAFPosition") ?? CameraError.invalidResponse("setTouchAFPosition")))
                return
            }
            
            completion(Result.success(touchAFInfo))
        }
    }
    
    func getTouchAFPosition(_ completion: @escaping TouchAFPositionCompletion) {
        
        let body = SonyRequestBody(method: "getTouchAFPosition")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getTouchAFPosition") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = (response?.dictionary?["result"] as? [[AnyHashable : Any]])?.first, let touchAFInfo = TouchAF.Information(dictionary: result) else {
                completion(Result.failure(CameraError.invalidResponse("getTouchAFPosition")))
                return
            }
            
            completion(Result.success(touchAFInfo))
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
    
    typealias TrackingFocusCompletion = (_ result: Result<String, Error>) -> Void
    
    typealias TrackingFocussesCompletion = (_ result: Result<[String], Error>) -> Void
    
    //MARK: - Settings
    
    func getSupportedTrackingFocusses(_ completion: @escaping TrackingFocussesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedTrackingFocus")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedTrackingFocus") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let trackingFocusSettings = result.first, let supported = trackingFocusSettings["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedTrackingFocus")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableTrackingFocusses(_ completion: @escaping TrackingFocussesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableTrackingFocus")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableTrackingFocus") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let trackingFocusSettings = result.first, let supported = trackingFocusSettings["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableTrackingFocus")))
                return
            }
            
            completion(Result.success(supported))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let trackingFocusSettings = result.first, let value = trackingFocusSettings["trackingFocus"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getTrackingFocus")))
                return
            }
            
            completion(Result.success(value))
        }
    }
    
    //MARK: - Self Timer -
    
    typealias SelfTimerDurationsCompletion = (_ result: Result<[TimeInterval], Error>) -> Void
    
    typealias SelfTimerDurationCompletion = (_ result: Result<TimeInterval, Error>) -> Void
    
    func getSupportedSelfTimerDurations(_ completion: @escaping SelfTimerDurationsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedSelfTimer")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedSelfTimer") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[Int]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedSelfTimer")))
                return
            }
            
            completion(Result.success(supported.map({ TimeInterval($0) })))
        }
    }
    
    func getAvailableSelfTimerDurations(_ completion: @escaping SelfTimerDurationsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableSelfTimer")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableSelfTimer") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [Int] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableSelfTimer")))
                return
            }
            
            completion(Result.success(available.map({ TimeInterval($0) })))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Int], let selfTimerDuration = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSelfTimer")))
                return
            }
            
            completion(Result.success(TimeInterval(selfTimerDuration)))
        }
    }
    
    //MARK: - Exposure -
    
    //MARK: Mode
    
    typealias ExposureModesCompletion = (_ result: Result<[Exposure.Mode.Value], Error>) -> Void
    
    typealias ExposureModeCompletion = (_ result: Result<Exposure.Mode.Value, Error>) -> Void
    
    func getSupportedExposureModes(_ completion: @escaping ExposureModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedExposureMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFocusMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedExposureMode")))
                return
            }
            
            completion(Result.success(supported.compactMap({ Exposure.Mode.Value(sonyString: $0) })))
        }
    }
    
    func getAvailableExposureModes(_ completion: @escaping ExposureModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableExposureMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableExposureMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableExposureMode")))
                return
            }
            
            completion(Result.success(available.compactMap({ Exposure.Mode.Value(sonyString: $0) })))
        }
    }
    
    func setExposureMode(_ mode: Exposure.Mode.Value, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setExposureMode", params: [mode.sonyString], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setExposureMode"))
        }
    }
    
    func getExposureMode(_ completion: @escaping ExposureModeCompletion) {
        
        let body = SonyRequestBody(method: "getExposureMode")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getExposureMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let mode = result.first, let modeEnum = Exposure.Mode.Value(sonyString: mode) else {
                completion(Result.failure(CameraError.invalidResponse("getExposureMode")))
                return
            }
            
            completion(Result.success(modeEnum))
        }
    }
    
    //MARK: Compensation
    
    typealias ExposureCompensationsCompletion = (_ result: Result<[Exposure.Compensation.Value], Error>) -> Void
    
    typealias ExposureCompensationCompletion = (_ result: Result<Int, Error>) -> Void
    
    func getSupportedExposureCompensations(_ completion: @escaping ExposureCompensationsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedExposureCompensation")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedExposureCompensation") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[Int]], result.count == 3 else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedExposureCompensation")))
                return
            }
            
            guard let upperIndex = result[0].first, let lowerIndex = result[1].first, let stepSize = result[2].first, stepSize == 1 || stepSize == 2 else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedExposureCompensation")))
                return
            }
            
            completion(Result.success(exposureCompensationsFor(lowerIndex: lowerIndex, upperIndex: upperIndex, stepSize: stepSize)))
        }
    }
    
    func getAvailableExposureCompensations(_ completion: @escaping ExposureCompensationsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableExposureCompensation")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableExposureCompensation") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Int], result.count == 4 else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableExposureCompensation")))
                return
            }
            
            let lowerIndex = result[2]
            let upperIndex = result[1]
            let stepSize = result[3]
            
            completion(Result.success(exposureCompensationsFor(lowerIndex: lowerIndex, upperIndex: upperIndex, stepSize: stepSize)))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Int], let compensation = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getExposureCompensation")))
                return
            }
            
            completion(Result.success(compensation))
        }
    }
    
    //MARK: - Focus -
    
    //MARK: Mode
    
    typealias FocusModesCompletion = (_ result: Result<[Focus.Mode.Value], Error>) -> Void
    
    typealias FocusModeCompletion = (_ result: Result<Focus.Mode.Value, Error>) -> Void
    
    func getSupportedFocusModes(_ completion: @escaping FocusModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFocusMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFocusMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedFocusMode")))
                return
            }
            
            completion(Result.success(supported.compactMap({ Focus.Mode.Value(sonyString: $0) })))
        }
    }
    
    func getAvailableFocusModes(_ completion: @escaping FocusModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFocusMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFocusMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableFocusMode")))
                return
            }
            
            completion(Result.success(available.compactMap({ Focus.Mode.Value(sonyString: $0) })))
        }
    }
    
    func setFocusMode(_ mode: Focus.Mode.Value, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setFocusMode", params: [mode.sonyString], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setFocusMode"))
        }
    }
    
    func getFocusMode(_ completion: @escaping FocusModeCompletion) {
        
        let body = SonyRequestBody(method: "getFocusMode")
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getFocusMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let mode = result.first, let modeEnum = Focus.Mode.Value(sonyString: mode) else {
                completion(Result.failure(CameraError.invalidResponse("getFocusMode")))
                return
            }
            
            completion(Result.success(modeEnum))
        }
    }
    
    //MARK: - Program Shift -
    
    typealias ProgramShiftsCompletion = (_ result: Result<[Int], Error>) -> Void
    
    func getSupportedProgramShifts(_ completion: @escaping ProgramShiftsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedProgramShift")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedProgramShift") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[Int]], let supported = result.first, supported.count == 2 else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedProgramShift")))
                return
            }
            
            let max = supported[0]
            let min = supported[1]
            
            var supportedValues: [Int] = []
            for i in min...max {
                supportedValues.append(i)
            }
            
            completion(Result.success(supportedValues))
        }
    }
    
    func setProgramShift(_ shift: Int, _ completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setProgramShift", params: [shift], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setProgramShift"))
        }
    }
    
    //MARK: - Flash Mode -
    
    typealias FlashModesCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias FlashModeCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedFlashModes(_ completion: @escaping FlashModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFlashMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFlashMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedFlashMode")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableFlashModes(_ completion: @escaping FlashModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFlashMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFlashMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableFlashMode")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let flashMode = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getFlashMode")))
                return
            }
            
            completion(Result.success(flashMode))
        }
    }
    
    //MARK: - Still Settings -
    
    //MARK: Size
    
    typealias StillSizesCompletion = (_ result: Result<[StillCapture.Size.Value], Error>) -> Void
    
    typealias StillSizeCompletion = (_ result: Result<StillCapture.Size.Value, Error>) -> Void
    
    func getSupportedStillSizes(_ completion: @escaping StillSizesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedStillSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedStillSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedStillSize")))
                return
            }
            
            let _supported = supported.compactMap({ StillCapture.Size.Value(dictionary: $0) })
            
            completion(Result.success(_supported))
        }
    }
    
    func getAvailableStillSizes(_ completion: @escaping StillSizesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableStillSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableStillSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [[AnyHashable : Any]] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableStillSize")))
                return
            }
            
            let _available = available.compactMap({ StillCapture.Size.Value(dictionary: $0) })
            
            completion(Result.success(_available))
        }
    }
    
    func setStillSize(_ stillSize: StillCapture.Size.Value, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setStillSize", params: [stillSize.aspectRatio ?? "", stillSize.size], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setStillSize"))
        }
    }
    
    func getStillSize(_ completion: @escaping StillSizeCompletion) {
        
        let body = SonyRequestBody(method: "getStillSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getStillSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let size = result.first, let stillSize = StillCapture.Size.Value(dictionary: size) else {
                completion(Result.failure(CameraError.invalidResponse("getStillSize")))
                return
            }
            
            completion(Result.success(stillSize))
        }
    }
    
    //MARK: Quality
    
    typealias StillQualitiesCompletion = (_ result: Result<[StillCapture.Quality.Value], Error>) -> Void
    
    typealias StillQualityCompletion = (_ result: Result<StillCapture.Quality.Value, Error>) -> Void
    
    func getSupportedStillQualities(_ completion: @escaping StillQualitiesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedStillQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedStillQuality")))
                return
            }
            
            completion(Result.success(supported.compactMap({ StillCapture.Quality.Value(sonyString: $0) })))
        }
    }
    
    func getAvailableStillQualities(_ completion: @escaping StillQualitiesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableStillQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableStillQuality")))
                return
            }
            
            completion(Result.success(available.compactMap({ StillCapture.Quality.Value(sonyString: $0) })))
        }
    }
    
    func setStillQuality(_ quality: StillCapture.Quality.Value, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setStillQuality", params: [["stillQuality": quality.sonyString]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setStillQuality"))
        }
    }
    
    func getStillQuality(_ completion: @escaping StillQualityCompletion) {
        
        let body = SonyRequestBody(method: "getStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getStillQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let qualityString = result.first?["stillQuality"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getStillQuality")))
                return
            }
            guard let quality = StillCapture.Quality.Value(sonyString: qualityString) else {
                completion(Result.failure(CameraError.invalidResponse("getStillQuality")))
                return
            }
            
            completion(Result.success(quality))
        }
    }
    
    //MARK: Format
    
    typealias StillFormatsCompletion = (_ result: Result<[StillCapture.Format.Value], Error>) -> Void
    
    typealias StillFormatCompletion = (_ result: Result<StillCapture.Format.Value, Error>) -> Void
    
    func getSupportedStillFormats(_ completion: @escaping StillFormatsCompletion) {
        
        // Sony rest camera doesn't support this, so we munge from still quality instead!
        let body = SonyRequestBody(method: "getSupportedStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedStillQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedStillQuality")))
                return
            }
            
            //TODO: This could give duplicate values, find a way to counteract!
            completion(Result.success(supported.compactMap({ StillCapture.Format.Value(sonyString: $0) })))
        }
    }
    
    func getAvailableStillFormats(_ completion: @escaping StillFormatsCompletion) {
        
        // Sony rest camera doesn't support this, so we munge from still quality instead!
        let body = SonyRequestBody(method: "getAvailableStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableStillQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableStillQuality")))
                return
            }
            
            //TODO: This could give duplicate values, find a way to counteract!
            completion(Result.success(available.compactMap({ StillCapture.Format.Value(sonyString: $0) })))
        }
    }
    
    func setStillFormat(_ quality: StillCapture.Format.Value, completion: @escaping GenericCompletion) {
        
        // Sony rest camera doesn't support this, so we munge to still quality instead!
        let body = SonyRequestBody(method: "setStillQuality", params: [["stillQuality": quality.sonyString]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setStillQuality"))
        }
    }
    
    func getStillFormat(_ completion: @escaping StillFormatCompletion) {
        
        // Sony rest camera doesn't support this, so we munge from still quality instead!
        let body = SonyRequestBody(method: "getStillQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getStillQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let qualityString = result.first?["stillQuality"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getStillQuality")))
                return
            }
            guard let format = StillCapture.Format.Value(sonyString: qualityString) else {
                completion(Result.failure(CameraError.invalidResponse("getStillQuality")))
                return
            }
            
            completion(Result.success(format))
        }
    }
    
    //MARK: - Post View Image Size
    
    typealias PostviewImageSizesCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias PostviewImageSizeCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedPostviewImageSizes(_ completion: @escaping PostviewImageSizesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedPostviewImageSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedPostviewImageSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedPostviewImageSize")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailablePostviewImageSizes(_ completion: @escaping PostviewImageSizesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailablePostviewImageSize")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailablePostviewImageSize") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailablePostviewImageSize")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let size = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getPostviewImageSize")))
                return
            }
            
            completion(Result.success(size))
        }
    }
    
    //MARK: - Movie -
    //MARK: File Format
    
    typealias MovieFileFormatsCompletion = (_ result: Result<[VideoCapture.FileFormat.Value], Error>) -> Void
    
    typealias MovieFileFormatCompletion = (_ result: Result<VideoCapture.FileFormat.Value, Error>) -> Void
    
    func getSupportedMovieFileFormats(_ completion: @escaping MovieFileFormatsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedMovieFileFormat")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedMovieFileFormat") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedMovieFileFormat")))
                return
            }
            
            completion(Result.success(supported.compactMap({ VideoCapture.FileFormat.Value(sonyString: $0) })))
        }
    }
    
    func getAvailableMovieFileFormats(_ completion: @escaping MovieFileFormatsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableMovieFileFormat")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableMovieFileFormat") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableMovieFileFormat")))
                return
            }
            
            completion(Result.success(available.compactMap({ VideoCapture.FileFormat.Value(sonyString: $0) })))
        }
    }
    
    func setMovieFileFormat(_ format: VideoCapture.FileFormat.Value, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setMovieFileFormat", params: [["movieFileFormat":format.sonyString]], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setMovieFileFormat"))
        }
    }
    
    func getMovieFileFormat(_ completion: @escaping MovieFileFormatCompletion) {
        
        let body = SonyRequestBody(method: "getMovieFileFormat")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getMovieFileFormat") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let format = result.first?["movieFileFormat"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getMovieFileFormat")))
                return
            }
            guard let enumFormat = VideoCapture.FileFormat.Value(sonyString: format) else {
                completion(Result.failure(CameraError.invalidResponse("getMovieFileFormat")))
                return
            }
            
            completion(Result.success(enumFormat))
        }
    }
    
    //MARK: Quality
    
    typealias MovieQualitiesCompletion = (_ result: Result<[VideoCapture.Quality.Value], Error>) -> Void
    
    typealias MovieQualityCompletion = (_ result: Result<VideoCapture.Quality.Value, Error>) -> Void
    
    func getSupportedMovieQualities(_ completion: @escaping MovieQualitiesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedMovieQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedMovieQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedMovieQuality")))
                return
            }
            
            completion(Result.success(supported.compactMap({ VideoCapture.Quality.Value(sonyString: $0) })))
        }
    }
    
    func getAvailableMovieQualities(_ completion: @escaping MovieQualitiesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableMovieQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableMovieQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableMovieQuality")))
                return
            }
            
            completion(Result.success(available.compactMap({ VideoCapture.Quality.Value(sonyString: $0) })))
        }
    }
    
    func setMovieQuality(_ quality: VideoCapture.Quality.Value, completion: @escaping GenericCompletion) {
        
        let body = SonyRequestBody(method: "setMovieQuality", params: [quality.sonyString], id: 1, version: "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setMovieQuality"))
        }
    }
    
    func getMovieQuality(_ completion: @escaping MovieQualityCompletion) {
        
        let body = SonyRequestBody(method: "getMovieQuality")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getMovieQuality") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let quality = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getMovieQuality")))
                return
            }
            guard let qualityEnum = VideoCapture.Quality.Value(sonyString: quality) else {
                completion(Result.failure(CameraError.invalidResponse("getMovieQuality")))
                return
            }
            
            completion(Result.success(qualityEnum))
        }
    }
    
    //MARK: - Steady Mode -
    
    typealias SteadyModesCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias SteadyModeCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedSteadyModes(_ completion: @escaping SteadyModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedSteadyMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedSteadyMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedSteadyMode")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableSteadyModes(_ completion: @escaping SteadyModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableSteadyMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableSteadyMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableSteadyMode")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let mode = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSteadyMode")))
                return
            }
            
            completion(Result.success(mode))
        }
    }
    
    //MARK: - View Angle -
    
    typealias ViewAnglesCompletion = (_ result: Result<[Double], Error>) -> Void
    
    typealias ViewAngleCompletion = (_ result: Result<Double, Error>) -> Void
    
    func getSupportedViewAngles(_ completion: @escaping ViewAnglesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedViewAngle")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedViewAngle") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[Int]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedViewAngle")))
                return
            }
            
            completion(Result.success(supported.map({ Double($0) })))
        }
    }
    
    func getAvailableViewAngles(_ completion: @escaping ViewAnglesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableViewAngle")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableViewAngle") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [Int] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableViewAngle")))
                return
            }
            
            completion(Result.success(available.map({ Double($0) })))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Int], let angle = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getViewAngle")))
                return
            }
            
            completion(Result.success(Double(angle)))
        }
    }
    
    //MARK: - Scene Selection -
    
    typealias SceneSelectionsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias SceneSelectionCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedSceneSelections(_ completion: @escaping SceneSelectionsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedSceneSelection")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedSceneSelection") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedSceneSelection")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableSceneSelections(_ completion: @escaping SceneSelectionsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableSceneSelection")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableSceneSelection") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableSceneSelection")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["scene"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getSceneSelection")))
                return
            }
            
            completion(Result.success(scene))
        }
    }
    
    //MARK: - Color Setting -
    
    typealias ColorSettingsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias ColorSettingCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedColorSettings(_ completion: @escaping ColorSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedColorSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedColorSetting") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedColorSetting")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableColorSettings(_ completion: @escaping ColorSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableColorSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableColorSetting") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableColorSetting")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["colorSetting"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getColorSetting")))
                return
            }
            
            completion(Result.success(scene))
        }
    }
    
    //MARK: - Interval Times -
    
    typealias IntervalTimesCompletion = (_ result: Result<[TimeInterval], Error>) -> Void
    
    typealias IntervalTimeCompletion = (_ result: Result<TimeInterval, Error>) -> Void
    
    func getSupportedIntervalTimes(_ completion: @escaping IntervalTimesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedIntervalTime")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedIntervalTime") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedIntervalTime")))
                return
            }
            
            let _supported = supported.compactMap({ TimeInterval($0) })
            
            completion(Result.success(_supported))
        }
    }
    
    func getAvailableIntervalTimes(_ completion: @escaping IntervalTimesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableIntervalTime")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableIntervalTime") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableIntervalTime")))
                return
            }
            
            let _available = available.compactMap({ TimeInterval($0) })
            
            completion(Result.success(_available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let intervalSec = result.first?["intervalTimeSec"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getIntervalTime")))
                return
            }
            guard let interval = TimeInterval(intervalSec) else {
                completion(Result.failure(CameraError.invalidResponse("getIntervalTime")))
                return
            }
            
            completion(Result.success(interval))
        }
    }
    
    //MARK: - Wind Noise Reduction -
    
    typealias WindNoiseReductionsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias WindNoiseReductionCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedWindNoiseReductions(_ completion: @escaping WindNoiseReductionsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedWindNoiseReduction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedWindNoiseReduction") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedWindNoiseReduction")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableWindNoiseReductions(_ completion: @escaping WindNoiseReductionsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableWindNoiseReduction")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableWindNoiseReduction") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableWindNoiseReduction")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["windNoiseReduction"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getWindNoiseReduction")))
                return
            }
            
            completion(Result.success(scene))
        }
    }
    
    //MARK: - Flip Setting -
    
    typealias FlipSettingsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias FlipSettingCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedFlipSettings(_ completion: @escaping FlipSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedFlipSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedFlipSetting") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedFlipSetting")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableFlipSettings(_ completion: @escaping FlipSettingsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableFlipSetting")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableFlipSetting") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableFlipSetting")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["flip"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getFlipSetting")))
                return
            }
            
            completion(Result.success(scene))
        }
    }
    
    //MARK: - TV Color Setting -
    
    typealias TVColorSystemsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias TVColorSystemCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedTVColorSystems(_ completion: @escaping TVColorSystemsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedTVColorSystem")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedTVColorSystem") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedTVColorSystem")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableTVColorSystems(_ completion: @escaping TVColorSystemsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableTVColorSystem")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableTVColorSystem") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableTVColorSystem")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["tvColorSystem"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getTVColorSystem")))
                return
            }
            
            completion(Result.success(scene))
        }
    }
    
    //MARK: - Infrared Remote Control -
    
    typealias InfraredRemoteControlsCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias InfraredRemoteControlCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedInfraredRemoteControls(_ completion: @escaping InfraredRemoteControlsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedInfraredRemoteControl")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedInfraredRemoteControl") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedInfraredRemoteControl")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableInfraredRemoteControls(_ completion: @escaping InfraredRemoteControlsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableInfraredRemoteControl")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableInfraredRemoteControl") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [String] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableInfraredRemoteControl")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let scene = result.first?["infraredRemoteControl"] as? String else {
                completion(Result.failure(CameraError.invalidResponse("getInfraredRemoteControl")))
                return
            }
            
            completion(Result.success(scene))
        }
    }
    
    //MARK: - Auto Power Off -
    
    typealias AutoPowerOffsCompletion = (_ result: Result<[TimeInterval], Error>) -> Void
    
    typealias AutoPowerOffCompletion = (_ result: Result<TimeInterval, Error>) -> Void
    
    func getSupportedAutoPowerOffs(_ completion: @escaping AutoPowerOffsCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedAutoPowerOff")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedAutoPowerOff") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let supported = result.first?["candidate"] as? [Int] else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedAutoPowerOff")))
                return
            }
            
            completion(Result.success(supported.map({ TimeInterval($0) })))
        }
    }
    
    func getAvailableAutoPowerOffs(_ completion: @escaping AutoPowerOffsCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableAutoPowerOff")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableAutoPowerOff") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let available = result.first?["candidate"] as? [Int] else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableAutoPowerOff")))
                return
            }
            
            completion(Result.success(available.map({ TimeInterval($0) })))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[AnyHashable : Any]], let powerOff = result.first?["autoPowerOff"] as? Int else {
                completion(Result.failure(CameraError.invalidResponse("getAutoPowerOff")))
                return
            }
            
            completion(Result.success(TimeInterval(powerOff)))
        }
    }
    
    //MARK: - Beep Mode -
    
    typealias BeepModesCompletion = (_ result: Result<[String], Error>) -> Void
    
    typealias BeepModeCompletion = (_ result: Result<String, Error>) -> Void
    
    func getSupportedBeepModes(_ completion: @escaping BeepModesCompletion) {
        
        let body = SonyRequestBody(method: "getSupportedBeepMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getSupportedBeepMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[String]], let supported = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getSupportedBeepMode")))
                return
            }
            
            completion(Result.success(supported))
        }
    }
    
    func getAvailableBeepModes(_ completion: @escaping BeepModesCompletion) {
        
        let body = SonyRequestBody(method: "getAvailableBeepMode")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getAvailableBeepMode") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any], let available = result.compactMap({ $0 as? [String] }).first else {
                completion(Result.failure(CameraError.invalidResponse("getAvailableBeepMode")))
                return
            }
            
            completion(Result.success(available))
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
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [String], let mode = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getBeepMode")))
                return
            }
            
            completion(Result.success(mode))
        }
    }
    
    //MARK: - Storage Information -
    
    typealias StorageInformationCompletion = (_ result: Result<[StorageInformation], Error>) -> Void
    
    func getStorageInformation(_ completion: @escaping StorageInformationCompletion) {
        
        let body = SonyRequestBody(method: "getStorageInformation")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getStorageInformation") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [[[AnyHashable : Any]]], let infos = result.first else {
                completion(Result.failure(CameraError.invalidResponse("getStorageInformation")))
                return
            }
            
            let storageInformations = infos.map({ StorageInformation(dictionary: $0) })
            completion(Result.success(storageInformations))
        }
    }
    
    //MARK: - Events -
    
    typealias EventCompletion = (_ result: Result<CameraEvent, Error>) -> Void
    
    func getEvent(polling: Bool, _ completion: @escaping EventCompletion) {
        
        guard let eventMethodName = eventMethodName else {
            
            getAvailableApiList { [weak self] (result) in
                // Fallback to getEvent as more commonly used!
                self?.getEvent(methodName: self?.eventMethodName ?? "getEvent", polling: polling, completion)
            }
            
            return
        }
        
        getEvent(methodName: eventMethodName, polling: polling, completion)
    }
    
    private func getEvent(methodName: String, polling: Bool, _ completion: @escaping EventCompletion) {
        
        let body = SonyRequestBody(method: methodName, params: [polling], id: 1, version: versions?.last ?? "1.0")
        
        requestController.request(service.type, method: .POST, body: body.requestSerialised) { (response, error) in
            
            if let error = error ?? CameraError(responseDictionary: response?.dictionary, methodName: "getEvent") {
                completion(Result.failure(error))
                return
            }
            
            guard let result = response?.dictionary?["result"] as? [Any] else {
                completion(Result.failure(CameraError.invalidResponse("getEvent")))
                return
            }
            
            let event = CameraEvent(result: result)
            completion(Result.success(event))
        }
    }
}
