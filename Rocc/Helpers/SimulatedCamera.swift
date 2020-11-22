//
//  SimulatedCamera.swift
//  Camrote
//
//  Created by Simon Mitchell on 26/05/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

extension BinaryInteger {
    
    static func rand(_ min: Self, _ max: Self) -> Self {
        let _min = min
        let difference = max+1 - _min
        return Self(arc4random_uniform(UInt32(difference))) + _min
    }
}

extension BinaryFloatingPoint {
    
    private func toInt() -> Int {
        // https://stackoverflow.com/q/49325962/4488252
        if let value = self as? CGFloat {
            return Int(value)
        }
        return Int(self)
    }
    
    static func rand(_ min: Self, _ max: Self, precision: Int) -> Self {
        
        if precision == 0 {
            let min = min.rounded(.down).toInt()
            let max = max.rounded(.down).toInt()
            return Self(Int.rand(min, max))
        }
        
        let delta = max - min
        let maxFloatPart = Self(pow(10.0, Double(precision)))
        let maxIntegerPart = (delta * maxFloatPart).rounded(.down).toInt()
        let randomValue = Int.rand(0, maxIntegerPart)
        let result = min + Self(randomValue)/maxFloatPart
        return Self((result*maxFloatPart).toInt())/maxFloatPart
    }
}

extension File {
    
    static func dummy(date: Date = Date(), image: Int) -> File {
        
        let imageUrls: [String] = [
            "https://user-images.githubusercontent.com/9033831/69366783-f0057400-0c8e-11ea-9ba6-110b184daf43.jpg",
            "https://user-images.githubusercontent.com/9033831/69366786-f09e0a80-0c8e-11ea-95bb-c347c7910881.jpg",
            "https://user-images.githubusercontent.com/9033831/69366787-f09e0a80-0c8e-11ea-92b1-f6e63109bde0.jpg",
            "https://user-images.githubusercontent.com/9033831/69366788-f09e0a80-0c8e-11ea-8fa0-3f086154110d.jpg",
            "https://user-images.githubusercontent.com/9033831/69366789-f136a100-0c8e-11ea-9190-6ea3262b5068.jpg",
            "https://user-images.githubusercontent.com/9033831/69366790-f136a100-0c8e-11ea-8eca-d8b25b4ef194.jpg",
            "https://user-images.githubusercontent.com/9033831/69366791-f136a100-0c8e-11ea-9592-3e234a08407e.jpg",
            "https://user-images.githubusercontent.com/9033831/69366792-f136a100-0c8e-11ea-93e7-36659e4e9120.jpg",
            "https://user-images.githubusercontent.com/9033831/69366794-f136a100-0c8e-11ea-9b8c-0d02bd466615.jpg",
            "https://user-images.githubusercontent.com/9033831/69366795-f1cf3780-0c8e-11ea-8933-8e12d0cd507d.jpg",
            "https://user-images.githubusercontent.com/9033831/69366796-f1cf3780-0c8e-11ea-866d-4157889cb9dd.jpg",
            "https://user-images.githubusercontent.com/9033831/69366797-f1cf3780-0c8e-11ea-9057-88cf68158615.jpg",
            "https://user-images.githubusercontent.com/9033831/69366800-f1cf3780-0c8e-11ea-9160-48f37c330641.jpg",
            "https://user-images.githubusercontent.com/9033831/69366801-f1cf3780-0c8e-11ea-93c9-3b69d5b92039.jpg",
            "https://user-images.githubusercontent.com/9033831/69366802-f267ce00-0c8e-11ea-86cb-7ea3facbf4f8.jpg",
            "https://user-images.githubusercontent.com/9033831/69366803-f267ce00-0c8e-11ea-92ab-1b2f1aff1834.jpg",
            "https://user-images.githubusercontent.com/9033831/69366805-f267ce00-0c8e-11ea-936a-9d50cc8dce21.jpg",
            "https://user-images.githubusercontent.com/9033831/69366806-f267ce00-0c8e-11ea-93af-ee86d680a625.jpg",
            "https://user-images.githubusercontent.com/9033831/69366807-f3006480-0c8e-11ea-8871-e89d7b890adb.jpg",
            "https://user-images.githubusercontent.com/9033831/69366809-f3006480-0c8e-11ea-8f3f-8f3b9f1769e9.jpg",
            "https://user-images.githubusercontent.com/9033831/69366811-f3006480-0c8e-11ea-9a9f-0d6018d9689a.jpg",
            "https://user-images.githubusercontent.com/9033831/69366812-f3006480-0c8e-11ea-9896-33b82df37aa0.jpg",
            "https://user-images.githubusercontent.com/9033831/69366813-f3006480-0c8e-11ea-9c9d-acf4f285c0ca.jpg",
            "https://user-images.githubusercontent.com/9033831/69366814-f398fb00-0c8e-11ea-8328-6177325958c5.jpg",
            "https://user-images.githubusercontent.com/9033831/69366815-f398fb00-0c8e-11ea-8313-1aed95f64171.jpg",
            "https://user-images.githubusercontent.com/9033831/69366817-f398fb00-0c8e-11ea-88df-e7f6f9698366.jpg"
        ]
        
        let index = image % imageUrls.count
        let url = URL(string: imageUrls[index])
        
        let original = File.Content.Original(fileName: "test.jpeg", fileType: "JPG", url: url)
        let rawOriginal = File.Content.Original(fileName: "rest.ARW", fileType: "ARW", url: URL(string: "https://www.rawsamples.ch/raws/sony/RAW_SONY_ILCE-7M2.ARW"))
        
        let content = Content(originals: [rawOriginal, original], largeURL: url, smallURL: url, thumbnailURL: url)
        
        let file = File(
            content: content,
            created: date,
            uri: imageUrls[index] + "\(image)"
        )
        
        return file
    }
}

public final class DummyCamera: Camera {
    
    public var isInBeta: Bool {
        return false
    }
    
    public var lastEvent: CameraEvent? {
        return nil
    }
    
    public var onEventAvailable: (() -> Void)?
    
    public var onDisconnected: (() -> Void)?
    
    public func handleEvent(event: CameraEvent) {
        
    }
    
    public var connectionMode: ConnectionMode {
        return .remoteControl
    }
    
    public func finishTransfer(callback: @escaping ((Error?) -> Void)) {
        
    }
    
    public func loadFilesToTransfer(callback: @escaping ((Error?, [File]?) -> Void)) {
        
    }
    
    public var latestFirmwareVersion: String?
    
    public var remoteAppVersion: String?
    
    public var latestRemoteAppVersion: String?
    
    public var firmwareVersion: String?
    
    public var lensModelName: String?
    
    public var apiVersion: String?

    public var eventVersion: String?

    public var model: String?
    
    public var identifier: String = "dummy"
    
    public var ipAddress: sockaddr_in?
    
    public var baseURL: URL?
        
    public var manufacturer: String = "Sony"
    
    public var name: String? = "Sony a7ii"
    
    public var eventPollingMode: PollingMode {
        return .continuous
    }
    
    public var hasFetchedEvent: Bool = false
    
    private var currentISO: ISO.Value = .auto
    
    private var currentShutterSpeed: ShutterSpeed = ShutterSpeed(numerator: 1.0, denominator: 1250)
    
    private var currentAperture: Aperture.Value = Aperture.Value(value: 1.8, decimalSeperator: nil)
    
    private var currentProgrammeMode: Exposure.Mode.Value = .aperturePriority
    
    private var currentSelfTimer: TimeInterval = 0.0
    
    private var currentShootMode: ShootingMode = .photo
    
    private var currentWhiteBalance: WhiteBalance.Value = .init(mode: .auto, temperature: nil, rawInternal: "")
    
    var currentFocusMode: Focus.Mode.Value = .auto
    
    private var currentExposureComp: Exposure.Compensation.Value = Exposure.Compensation.Value(value: 0.0)
    
    private var eventCompletion: (() -> Void)?
    
    private var singleBracket: SingleBracketCapture.Bracket.Value = .init(mode: .exposure, interval: .custom(images: 5, interval: 0.3))
    
    private var continuousBracket: ContinuousBracketCapture.Bracket.Value = .init(mode: .exposure, interval: .custom(images: 5, interval: 0.3))
    
    private var continuousShootingMode: ContinuousCapture.Mode.Value = .single
    
    private var continuousShootingSpeed: ContinuousCapture.Speed.Value = .high
    
    public func connect(completion: @escaping Camera.ConnectedCompletion) {
        
        isConnected = true
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
            completion(nil, false)
        }
    }
    
    public func disconnect(completion: @escaping DisconnectedCompletion) {
        isConnected = false
        completion(nil)
    }
    
    public init() {
        
    }
    
    public var isConnected: Bool = false
    
    public func supportsFunction<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        switch function.function {
        case .setStillQuality:
            callback(false, nil, nil)
        case .setFocusMode:
            callback(true, nil, ["AF-S", "MF"] as? [T.SendType])
        default:
            callback(true, nil, nil)
        }
    }
    
    public func isFunctionAvailable<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
        switch function.function {
        case .setISO:
            callback(true, nil, ["AUTO", "50", "100", "200", "400", "1600", "3200", "6400"] as? [T.SendType])
        case .setAperture:
            callback(true, nil, ["1.8", "2.0", "2.2", "2.8", "3.2", "4.0", "4.8", "5.6", "8.0", "11.0", "18.0", "22.0"] as? [T.SendType])
        case .setStillQuality:
            callback(false, nil, nil)
        case .setShutterSpeed:
            callback(true, nil, [
                ShutterSpeed(numerator: 1, denominator: 8000),
                ShutterSpeed(numerator: 1, denominator: 6000),
                ShutterSpeed(numerator: 1, denominator: 3000),
                ShutterSpeed(numerator: 1, denominator: 2000),
                ShutterSpeed(numerator: 1, denominator: 1250),
                ShutterSpeed(numerator: 1, denominator: 1000),
                ShutterSpeed(numerator: 1, denominator: 600),
                ShutterSpeed(numerator: 1, denominator: 400),
                ShutterSpeed(numerator: 1, denominator: 200),
                ShutterSpeed(numerator: 1, denominator: 100),
                ShutterSpeed(numerator: 1, denominator: 50),
                ShutterSpeed(numerator: 1, denominator: 20),
                ShutterSpeed(numerator: 1, denominator: 10),
                ShutterSpeed(numerator: 1, denominator: 5),
                ShutterSpeed(numerator: 1, denominator: 4),
                ShutterSpeed(numerator: 1, denominator: 3),
                ShutterSpeed(numerator: 1, denominator: 2),
                ShutterSpeed(numerator: 1, denominator: 1),
                ShutterSpeed(numerator: 2, denominator: 1),
                ShutterSpeed(numerator: 3, denominator: 1),
                ShutterSpeed(numerator: 4, denominator: 1),
                ShutterSpeed(numerator: 5, denominator: 1),
                ShutterSpeed(numerator: 10, denominator: 1),
                ShutterSpeed(numerator: 12, denominator: 1),
                ShutterSpeed(numerator: 16, denominator: 1),
                ShutterSpeed(numerator: 18, denominator: 1),
                ShutterSpeed(numerator: 20, denominator: 1),
                ShutterSpeed(numerator: 25, denominator: 1),
                ShutterSpeed(numerator: 30, denominator: 1),
                .bulb
            ] as? [T.SendType])
        case .setExposureCompensation:
            callback(true, nil, [-3.0, -2.66, -2.33, -2.0, -1.66, -1.33, -1.0, -0.66, -0.33, 0, 0.33, 0.66, 1.0, 1.33, 1.66, 2.0, 2.33, 2.66, 3.0] as? [T.SendType])
        case .setFocusMode:
            callback(true, nil, ["AF-S", "MF"] as? [T.SendType])
        case .setWhiteBalance:
            callback(true, nil, [WhiteBalance.Value(mode: .auto, temperature: nil, rawInternal: "AUTO"), WhiteBalance.Value(mode: .shade, temperature: nil, rawInternal: "AUTO"), WhiteBalance.Value(mode: .flash, temperature: nil, rawInternal: "AUTO"), WhiteBalance.Value(mode: .cloudy, temperature: nil, rawInternal: "AUTO"), WhiteBalance.Value(mode: .underwaterAuto, temperature: nil, rawInternal: "AUTO"), WhiteBalance.Value(mode: .fluorescentCoolWhite, temperature: nil, rawInternal: "AUTO"), WhiteBalance.Value(mode: .fluorescentDaylight, temperature: nil, rawInternal: "AUTO")] as? [T.SendType])
        case .setExposureMode:
            callback(true, nil, [Exposure.Mode.Value.aperturePriority, Exposure.Mode.Value.manual, Exposure.Mode.Value.videoManual, Exposure.Mode.Value.shutterPriority, Exposure.Mode.Value.videoProgrammedAuto, Exposure.Mode.Value.videoAperturePriority] as? [T.SendType])
        default:
            callback(true, nil, nil)
        }
    }
    
    public func makeFunctionAvailable<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        switch function.function {
        case .startContinuousShooting:
            currentShootMode = .continuous
        case .startContinuousBracketShooting:
            currentShootMode = .continuousBracket
        case .takePicture:
            currentShootMode = .photo
        case .takeSingleBracketShot:
            currentShootMode = .singleBracket
        case .startBulbCapture:
            currentShootMode = .bulb
        case .startVideoRecording:
            currentShootMode = .video
        default:
            break
        }
        callback(nil)
    }
    
    private func constructCurrentEvent() -> CameraEvent {
        
        return CameraEvent(
            status: .idle,
            liveViewInfo: nil,
            liveViewQuality: nil,
            zoomPosition: nil,
            availableFunctions: [.setISO, .setShutterSpeed, .setAperture, .setExposureCompensation, .setSelfTimerDuration, .setWhiteBalance, .startZooming, .setExposureMode, .setTouchAFPosition, .startContinuousBracketShooting, .stopContinuousBracketShooting, .setSingleBracketedShootingBracket, .setContinuousBracketedShootingBracket, .setContinuousShootingSpeed, .setContinuousShootingMode],
            supportedFunctions: [.setISO, .setShutterSpeed, .setAperture, .setExposureCompensation, .setSelfTimerDuration, .setWhiteBalance, .startZooming, .setExposureMode, .setTouchAFPosition, .setContinuousShootingSpeed, .setContinuousShootingMode],
            postViewPictureURLs: nil,
            storageInformation: nil,
            beepMode: nil,
            function: nil,
            functionResult: true,
            videoQuality: nil,
            stillSizeInfo: nil,
            steadyMode: nil,
            viewAngle: nil,
            exposureMode: (
                current: currentProgrammeMode,
                available: [.aperturePriority, .shutterPriority, .manual, .videoAperturePriority, .videoShutterPriority, .videoManual],
                supported: [.aperturePriority, .shutterPriority, .manual, .videoAperturePriority, .videoShutterPriority, .videoManual]
            ),
            exposureModeDialControl: nil,
            exposureSettingsLockStatus: nil,
            postViewImageSize: nil,
            selfTimer: (current: currentSelfTimer, available: [0.0, 2.0, 5.0], supported: [0.0, 2.0, 5.0]),
            shootMode: (
                current: currentShootMode,
                available: [.photo, .continuous, .timelapse, .video, .continuous, .bulb, .singleBracket, .continuousBracket],
                supported: [.photo, .continuous, .timelapse, .video, .continuous, .bulb, .singleBracket, .continuousBracket]
            ),
            exposureCompensation: (
                current: currentExposureComp,
                available: [-3.0, -2.66, -2.33, -2.0, -1.66, -1.33, -1.0, -0.66, -0.33, 0, 0.33, 0.66, 1.0, 1.33, 1.66, 2.0, 2.33, 2.66, 3.0].map({ Exposure.Compensation.Value(value: $0) }),
                supported: [-3.0, -2.66, -2.33, -2.0, -1.66, -1.33, -1.0, -0.66, -0.33, 0, 0.33, 0.66, 1.0, 1.33, 1.66, 2.0, 2.33, 2.66, 3.0].map({ Exposure.Compensation.Value(value: $0) })
            ),
            flashMode: nil,
            aperture: (
                current: currentAperture,
                available: [
                        Aperture.Value(value: 1.8, decimalSeperator: "."),
                        Aperture.Value(value: 2.0, decimalSeperator: "."),
                        Aperture.Value(value: 2.2, decimalSeperator: "."),
                        Aperture.Value(value: 2.8, decimalSeperator: "."),
                        Aperture.Value(value: 3.2, decimalSeperator: "."),
                        Aperture.Value(value: 4.0, decimalSeperator: "."),
                        Aperture.Value(value: 4.8, decimalSeperator: "."),
                        Aperture.Value(value: 5.6, decimalSeperator: "."),
                        Aperture.Value(value: 8.0, decimalSeperator: "."),
                        Aperture.Value(value: 11.0, decimalSeperator: "."),
                        Aperture.Value(value: 18.0, decimalSeperator: "."),
                        Aperture.Value(value: 22.0, decimalSeperator: ".")
                ],
                supported: [
                    Aperture.Value(value: 1.8, decimalSeperator: "."),
                    Aperture.Value(value: 2.0, decimalSeperator: "."),
                    Aperture.Value(value: 2.2, decimalSeperator: "."),
                    Aperture.Value(value: 2.8, decimalSeperator: "."),
                    Aperture.Value(value: 3.2, decimalSeperator: "."),
                    Aperture.Value(value: 4.0, decimalSeperator: "."),
                    Aperture.Value(value: 4.8, decimalSeperator: "."),
                    Aperture.Value(value: 5.6, decimalSeperator: "."),
                    Aperture.Value(value: 8.0, decimalSeperator: "."),
                    Aperture.Value(value: 11.0, decimalSeperator: "."),
                    Aperture.Value(value: 18.0, decimalSeperator: "."),
                    Aperture.Value(value: 22.0, decimalSeperator: ".")
                ]
            ),
            focusMode: (current: currentFocusMode, available: [.auto, .manual], supported: [.auto, .manual]),
            iso: (current: currentISO, available: [.auto, .native(100), .native(200), .native(400), .native(1600), .native(3200), .native(6400)], supported: [.auto, .native(100), .native(200), .native(400), .native(1600), .native(3200), .native(6400)]),
            isProgramShifted: false,
            shutterSpeed: (current: currentShutterSpeed, available: [
                ShutterSpeed(numerator: 1, denominator: 8000),
                ShutterSpeed(numerator: 1, denominator: 6000),
                ShutterSpeed(numerator: 1, denominator: 3000),
                ShutterSpeed(numerator: 1, denominator: 2000),
                ShutterSpeed(numerator: 1, denominator: 1250),
                ShutterSpeed(numerator: 1, denominator: 1000),
                ShutterSpeed(numerator: 1, denominator: 600),
                ShutterSpeed(numerator: 1, denominator: 400),
                ShutterSpeed(numerator: 1, denominator: 200),
                ShutterSpeed(numerator: 1, denominator: 100),
                ShutterSpeed(numerator: 1, denominator: 50),
                ShutterSpeed(numerator: 1, denominator: 20),
                ShutterSpeed(numerator: 1, denominator: 10),
                ShutterSpeed(numerator: 1, denominator: 5),
                ShutterSpeed(numerator: 1, denominator: 4),
                ShutterSpeed(numerator: 1, denominator: 3),
                ShutterSpeed(numerator: 1, denominator: 2),
                ShutterSpeed(numerator: 1, denominator: 1),
                ShutterSpeed(numerator: 2, denominator: 1),
                ShutterSpeed(numerator: 3, denominator: 1),
                ShutterSpeed(numerator: 4, denominator: 1),
                ShutterSpeed(numerator: 5, denominator: 1),
                ShutterSpeed(numerator: 10, denominator: 1),
                ShutterSpeed(numerator: 12, denominator: 1),
                ShutterSpeed(numerator: 16, denominator: 1),
                ShutterSpeed(numerator: 18, denominator: 1),
                ShutterSpeed(numerator: 20, denominator: 1),
                ShutterSpeed(numerator: 25, denominator: 1),
                ShutterSpeed(numerator: 30, denominator: 1),
                .bulb
                ], supported: []),
            whiteBalance: CameraEvent.WhiteBalanceInformation(shouldCheck: true, whitebalanceValue: currentWhiteBalance, available: nil, supported: nil),
            touchAF: nil,
            focusStatus: nil,
            zoomSetting: nil,
            stillQuality: nil,
            stillFormat: nil,
            continuousShootingMode: (current: continuousShootingMode, available: [.continuous, .single], supported: [.continuous, .single]),
            continuousShootingSpeed: (current: continuousShootingSpeed, available: [.regular, .high, .highPlus, .low, .tenFps1Sec], supported: [.regular, .high, .highPlus, .low, .tenFps1Sec]),
            continuousBracketedShootingBrackets: (
                current: continuousBracket,
                available: [
                    .init(mode: .exposure, interval: .custom(images: 3, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 5, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 7, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 3, interval: 0.5)),
                    .init(mode: .exposure, interval: .custom(images: 5, interval: 0.5)),
                    .init(mode: .exposure, interval: .custom(images: 7, interval: 0.5))
                ],
                supported: [
                    .init(mode: .exposure, interval: .custom(images: 3, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 5, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 7, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 3, interval: 0.5)),
                    .init(mode: .exposure, interval: .custom(images: 5, interval: 0.5)),
                    .init(mode: .exposure, interval: .custom(images: 7, interval: 0.5))
                ]
            ),
            singleBracketedShootingBrackets: (
                current: singleBracket,
                available: [
                    .init(mode: .whiteBalance, interval: .low),
                    .init(mode: .whiteBalance, interval: .high),
                    .init(mode: .dro, interval: .low),
                    .init(mode: .dro, interval: .high),
                    .init(mode: .exposure, interval: .custom(images: 3, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 5, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 7, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 3, interval: 0.5)),
                    .init(mode: .exposure, interval: .custom(images: 5, interval: 0.5)),
                    .init(mode: .exposure, interval: .custom(images: 7, interval: 0.5))
                ],
                supported: [
                    .init(mode: .whiteBalance, interval: .low),
                    .init(mode: .whiteBalance, interval: .high),
                    .init(mode: .dro, interval: .low),
                    .init(mode: .dro, interval: .high),
                    .init(mode: .exposure, interval: .custom(images: 3, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 5, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 7, interval: 0.3)),
                    .init(mode: .exposure, interval: .custom(images: 3, interval: 0.5)),
                    .init(mode: .exposure, interval: .custom(images: 5, interval: 0.5)),
                    .init(mode: .exposure, interval: .custom(images: 7, interval: 0.5))
                ]
            ),
            flipSetting: nil,
            scene: nil,
            intervalTime: nil,
            colorSetting: nil,
            videoFileFormat: nil,
            videoRecordingTime: nil,
            highFrameRateCaptureStatus: nil,
            infraredRemoteControl: nil,
            tvColorSystem: nil,
            trackingFocusStatus: nil,
            trackingFocus: nil,
            batteryInfo: nil,
            numberOfShots: nil,
            autoPowerOff: nil,
            loopRecordTime: nil,
            audioRecording: nil,
            windNoiseReduction: nil,
            bulbShootingUrl: nil,
            bulbCapturingTime: nil
        )
    }
    
    public func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
                
        switch function.function {
        case .listSchemes:
            callback(nil, ["scheme"] as? T.ReturnType)
        case .listSources:
            callback(nil, ["memoryCard:1"] as? T.ReturnType)
        case .getContentCount:
            callback(nil, 120 as? T.ReturnType)
        case .getEvent:
            guard hasFetchedEvent else {
                let event = self.constructCurrentEvent()
                hasFetchedEvent = true
                callback(nil, event as? T.ReturnType)
                return
            }
            eventCompletion = { [weak self] in
                guard let self = self else { return }
                let event = self.constructCurrentEvent()
                callback(nil, event as? T.ReturnType)
            }
        case .listContent:
            
            guard let request = payload as? FileRequest else {
                callback(FunctionError.invalidPayload, nil)
                return
            }
            
            var files: [File] = []
            let twoDays: TimeInterval = 2*60.0*60.0
            var date = Date(timeIntervalSinceNow: -(twoDays * TimeInterval(request.startIndex)))
            for i in request.startIndex..<request.count + request.startIndex {
                files.append(File.dummy(date: date, image: i))
                date = Date(timeInterval: -Double.rand(60.0, twoDays, precision: 1), since: date)
            }
            callback(nil, FileResponse(fullyLoaded: false, files: files) as? T.ReturnType)
            
        case .setAperture:
            
            guard let value = payload as? Aperture.Value else {
                return
            }
            currentAperture = value
            eventCompletion?()
            
        case .setExposureMode:
            
            guard let value = payload as? Exposure.Mode.Value else {
                return
            }
            currentProgrammeMode = value
            eventCompletion?()
            
        case .setShutterSpeed:
            
            guard let value = payload as? ShutterSpeed else {
                return
            }
            currentShutterSpeed = value
            eventCompletion?()
            
        case .setISO:
            
            guard let value = payload as? ISO.Value else {
                return
            }
            currentISO = value
            eventCompletion?()
            
        case .setSelfTimerDuration:
            
            guard let value = payload as? Double else {
                return
            }
            currentSelfTimer = value
            eventCompletion?()
            
        case .setShootMode:
            
            guard let value = payload as? ShootingMode else {
                return
            }
            currentShootMode = value
            eventCompletion?()
            
        case .setFocusMode:
            
            guard let value = payload as? Focus.Mode.Value else {
                return
            }
            currentFocusMode = value
            eventCompletion?()
            
        case .setExposureCompensation:
            
            guard let value = payload as? Exposure.Compensation.Value else {
                return
            }
            currentExposureComp = value
            eventCompletion?()
            
        case .setWhiteBalance:
            
            guard let value = payload as? WhiteBalance.Value else { return }
            currentWhiteBalance = value
            eventCompletion?()
            
        case .startBulbCapture:
            
            callback(nil, nil)
            
        case .endBulbCapture:
            
            callback(nil, nil)
            
        case .startLiveView:
            
            callback(nil, nil)
            
        case .takePicture:
            
            callback(nil, URL(string: "https://via.placeholder.com/1370x1028?text=\(NSUUID().uuidString)") as? T.ReturnType)
            
        case .setSingleBracketedShootingBracket:
            
            guard let value = payload as? SingleBracketCapture.Bracket.Value else {
                return
            }
            singleBracket = value
            eventCompletion?()
            
        case .setContinuousBracketedShootingBracket:
        
            guard let value = payload as? ContinuousBracketCapture.Bracket.Value else {
                return
            }
            continuousBracket = value
            eventCompletion?()
            
        case .setContinuousShootingSpeed:
            
            guard let value = payload as? ContinuousCapture.Speed.Value else {
                return
            }
            continuousShootingSpeed = value
            eventCompletion?()
            
        case .setContinuousShootingMode:
            
            guard let value = payload as? ContinuousCapture.Mode.Value else {
                return
            }
            continuousShootingMode = value
            eventCompletion?()
            
        default:
            callback(nil, nil)
        }
    }
}
