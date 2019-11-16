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
            "https://drive.google.com/uc?id=10W31pbVndvcp9aW3mG54UCAuLnsZJEdu",
            "https://drive.google.com/uc?id=18BqbSKAe21mySvKjbY9aCjneENtn5nkr",
            "https://drive.google.com/uc?id=1zDO2L4YErsMS8WhpqUuCrzsu5UehZ7q8",
            "https://drive.google.com/uc?id=11e--675T1i3KowEDZh5gaPAHKMd-9jit",
            "https://drive.google.com/uc?id=1re4FbtMPVFvHpJ1lBxBiSMvxNmxfWV9p",
            "https://drive.google.com/uc?id=14cHdyJOq1ZNN1ZyOSy4GjHO3GUOAMKaL",
            "https://drive.google.com/uc?id=1jmKPEIpb1Ob7g2e0maT3-m5CoyVnTSI8",
            "https://drive.google.com/uc?id=1LdQQLYe5Cnx94qBsnl7Kv7BC9W8DAaG2",
            "https://drive.google.com/uc?id=1Yw9w6N2k60U9vo-GRgwnp0dAnnM96-lq",
            "https://drive.google.com/uc?id=15mAmI7tDA4B4oFvlRJ0pmpHK5060-gK2",
            "https://drive.google.com/uc?id=1BF9oA6QXa03Qt1KcMwc96ksppGtUsOAv",
            "https://drive.google.com/uc?id=17hnMDnnX7smPhb0C6Owi6UwFJAsHUElf",
            "https://drive.google.com/uc?id=1fGrCC_wQHJ5R10IBdT7VgBZAAynmJ5uA",
            "https://drive.google.com/uc?id=1jwMZrmerzSMgT397CsB3K8d34V1QZtnN",
            "https://drive.google.com/uc?id=1MkH7ufW5jCyS4hip2oCfRlly_AiZZ662",
            "https://drive.google.com/uc?id=1x2r-8KxnpS2VXT_1eEJrVtRnBXw00BFt",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44166137_10205020811755656_6680655795945734144_o.jpg?_nc_cat=100&_nc_ht=scontent-lht6-1.xx&oh=49b136ec2c83b9d1d8a0e5c3b72dfaac&oe=5CA725D6",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44032459_10205020808315570_5469471131528331264_o.jpg?_nc_cat=111&_nc_ht=scontent-lht6-1.xx&oh=c3fae3b3b731fe98a36bbe09358d5e11&oe=5CA56D19",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44023944_10205020808195567_7274851361567539200_o.jpg?_nc_cat=102&_nc_ht=scontent-lht6-1.xx&oh=b6e306129912f6cf557a3c3b4beb2246&oe=5CB088B8",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44028963_10205020807875559_663651414500704256_o.jpg?_nc_cat=100&_nc_ht=scontent-lht6-1.xx&oh=491bfb2e8553f078ec3fcecb6fefd51e&oe=5CA6CF77",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44077180_10205020807475549_6486553158548979712_o.jpg?_nc_cat=101&_nc_ht=scontent-lht6-1.xx&oh=a9e9815ddd1be1ff06b17d850cf55561&oe=5C9A2DCD",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44027774_10205020806955536_5337969364752662528_o.jpg?_nc_cat=107&_nc_ht=scontent-lht6-1.xx&oh=6b63472242657e017db0ae3ccb131e39&oe=5C9FD62A",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43952377_10205020806595527_3181607508250722304_o.jpg?_nc_cat=101&_nc_ht=scontent-lht6-1.xx&oh=0dec0fb6f44a1a42349dc70fb669839d&oe=5CB03DA2",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44056825_10205020805115490_2152903248187490304_o.jpg?_nc_cat=101&_nc_ht=scontent-lht6-1.xx&oh=4cf2cdd7ee96e5931578811fe01bb4c8&oe=5C674634",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43952177_10205020804435473_1461334065226448896_o.jpg?_nc_cat=110&_nc_ht=scontent-lht6-1.xx&oh=fa88bda3a10e64da52f50b88af3d21fc&oe=5C671237",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43950742_10205020801795407_3857080102974128128_o.jpg?_nc_cat=107&_nc_ht=scontent-lht6-1.xx&oh=5d32f7adf9c3d83ff96def1c2e15a445&oe=5C65D719",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44063085_10205020800915385_7307852352671711232_o.jpg?_nc_cat=111&_nc_ht=scontent-lht6-1.xx&oh=cd443d54257a363973231d008b32c3c4&oe=5C65A3BF"
        ]
        
        let index = image % imageUrls.count
        let url = URL(string: imageUrls[index])
        
        let original = File.Content.Original(fileName: "Test", fileType: "RAW", url: url)
        
        let content = Content(originals: [original], largeURL: url, smallURL: url, thumbnailURL: url)
        
        let file = File(
            content: content,
            created: date,
            uri: imageUrls[index]
        )
        
        return file
    }
}

public final class DummyCamera: Camera {
    
    public var onEventAvailable: (() -> Void)?
    
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
    
    private var currentAperture: Aperture.Value = Aperture.Value(value: 1.8)
    
    private var currentSelfTimer: TimeInterval = 0.0
    
    private var currentShootMode: ShootingMode = .photo
    
    var currentFocusMode: Focus.Mode.Value = .auto
    
    private var currentExposureComp: Exposure.Compensation.Value = Exposure.Compensation.Value(value: 0.0)
    
    private var eventCompletion: (() -> Void)?
    
    public func connect(completion: @escaping Camera.ConnectedCompletion) {
        
        isConnected = true
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
            completion(nil, false)
        }
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
                ShutterSpeed(numerator: 30, denominator: 1)
            ] as? [T.SendType])
        case .setExposureCompensation:
            callback(true, nil, [-3.0, -2.66, -2.33, -2.0, -1.66, -1.33, -1.0, -0.66, -0.33, 0, 0.33, 0.66, 1.0, 1.33, 1.66, 2.0, 2.33, 2.66, 3.0] as? [T.SendType])
        case .setFocusMode:
            callback(true, nil, ["AF-S", "MF"] as? [T.SendType])
        default:
            callback(true, nil, nil)
        }
    }
    
    public func makeFunctionAvailable<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        callback(nil)
    }
    
    private func constructCurrentEvent() -> CameraEvent {
        
        return CameraEvent(
            status: .idle,
            liveViewInfo: nil,
            zoomPosition: nil,
            availableFunctions: [.setISO, .setShutterSpeed, .setAperture, .setExposureCompensation, .setSelfTimerDuration, .setWhiteBalance, .startZooming],
            supportedFunctions: [],
            postViewPictureURLs: nil,
            storageInformation: nil,
            beepMode: nil,
            function: nil,
            functionResult: true,
            videoQuality: nil,
            stillSizeInfo: nil,
            steadyMode: nil,
            viewAngle: nil,
            exposureMode: nil,
            postViewImageSize: nil,
            selfTimer: (current: currentSelfTimer, available: [0.0, 2.0, 5.0], supported: [0.0, 2.0, 5.0]),
            shootMode: (current: currentShootMode, available: [.photo, .continuous, .timelapse, .video, .continuous, .bulb], supported: [.photo, .continuous, .timelapse, .video, .continuous, .bulb]),
            exposureCompensation: (current: currentExposureComp, available: [-3.0, -2.66, -2.33, -2.0, -1.66, -1.33, -1.0, -0.66, -0.33, 0, 0.33, 0.66, 1.0, 1.33, 1.66, 2.0, 2.33, 2.66, 3.0].map({ Exposure.Compensation.Value(value: $0) }), supported: [-3.0, -2.66, -2.33, -2.0, -1.66, -1.33, -1.0, -0.66, -0.33, 0, 0.33, 0.66, 1.0, 1.33, 1.66, 2.0, 2.33, 2.66, 3.0].map({ Exposure.Compensation.Value(value: $0) })),
            flashMode: nil,
            aperture: (current: currentAperture, available: [Aperture.Value(value: 1.8), Aperture.Value(value: 2.0), Aperture.Value(value: 2.2), Aperture.Value(value: 2.8), Aperture.Value(value: 3.2), Aperture.Value(value: 4.0), Aperture.Value(value: 4.8), Aperture.Value(value: 5.6), Aperture.Value(value: 8.0), Aperture.Value(value: 11.0), Aperture.Value(value: 18.0), Aperture.Value(value: 22.0)], supported: [Aperture.Value(value: 1.8), Aperture.Value(value: 2.0), Aperture.Value(value: 2.2), Aperture.Value(value: 2.8), Aperture.Value(value: 3.2), Aperture.Value(value: 4.0), Aperture.Value(value: 4.8), Aperture.Value(value: 5.6), Aperture.Value(value: 8.0), Aperture.Value(value: 11.0), Aperture.Value(value: 18.0), Aperture.Value(value: 22.0)]),
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
                ShutterSpeed(numerator: 30, denominator: 1)
                ], supported: []),
            whiteBalance: CameraEvent.WhiteBalanceInformation(shouldCheck: true, whitebalanceValue: WhiteBalance.Value(mode: .daylight, temperature: nil, rawInternal: ""), available: nil, supported: nil),
            touchAF: nil,
            focusStatus: nil,
            zoomSetting: nil,
            stillQuality: nil,
            continuousShootingMode: nil,
            continuousShootingSpeed: nil,
            continuousShootingURLS: nil,
            flipSetting: nil,
            scene: nil,
            intervalTime: nil,
            colorSetting: nil,
            videoFileFormat: nil,
            videoRecordingTime: nil,
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
        
        print("Performing Function: ", function.function)
        
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
            var date = Date(timeIntervalSinceNow: -100)
            for i in 0..<request.count {
                files.append(File.dummy(date: date, image: i))
                date = Date(timeInterval: -Double.rand(60.0, 2*60*60.0, precision: 1), since: date)
            }
            callback(nil, FileResponse(fullyLoaded: false, files: files) as? T.ReturnType)
            
        case .setAperture:
            
            guard let value = payload as? Aperture.Value else {
                return
            }
            currentAperture = value
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
            
        case .startBulbCapture:
            
            callback(nil, nil)
            
        case .endBulbCapture:
            
            callback(nil, nil)
            
        case .startLiveView:
            
            callback(nil, nil)
            
        case .takePicture:
            
            callback(nil, URL(string: "https://via.placeholder.com/1370x1028") as? T.ReturnType)
            
        default:
            callback(nil, nil)
        }
    }
}
