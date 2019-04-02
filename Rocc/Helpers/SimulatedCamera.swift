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
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44045288_10205020816115765_8491817313958363136_o.jpg?_nc_cat=106&_nc_ht=scontent-lht6-1.xx&oh=aa827b2d112cf75fc080a114cc6e2111&oe=5CAD1495",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43951277_10205020817475799_1108877701613092864_o.jpg?_nc_cat=108&_nc_ht=scontent-lht6-1.xx&oh=f945dbf7d98ff96ec8b79420ccd96e8e&oe=5CA1418A",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43950872_10205020815595752_4593994433954840576_o.jpg?_nc_cat=111&_nc_ht=scontent-lht6-1.xx&oh=5e95e82f1dcfdeaf9703d92271a11876&oe=5CAE3F49",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44028187_10205020839276344_6822412080608444416_o.jpg?_nc_cat=102&_nc_ht=scontent-lht6-1.xx&oh=75b404651427be974f026d358b215561&oe=5C6721FD",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44091308_10205020826996037_485456601528926208_o.jpg?_nc_cat=106&_nc_ht=scontent-lht6-1.xx&oh=47b2e6265ba81862cc04114b51e99785&oe=5C9CEBD7",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44070700_10205020824675979_3158584147081953280_o.jpg?_nc_cat=103&_nc_ht=scontent-lht6-1.xx&oh=0bb093c82f9daf21b49d0b8b7f5f87b6&oe=5C69BD1C",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44062992_10205020823915960_5566386604706103296_o.jpg?_nc_cat=102&_nc_ht=scontent-lht6-1.xx&oh=ab2adaea6bb27b905cbd04bc88675211&oe=5CAF333C",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44023485_10205020821515900_1649964678064898048_o.jpg?_nc_cat=106&_nc_ht=scontent-lht6-1.xx&oh=2c424cf5874dad4235748e2dea06475f&oe=5C63C33C",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44023818_10205020820395872_1540489921649704960_o.jpg?_nc_cat=111&_nc_ht=scontent-lht6-1.xx&oh=64237f21cbdf98c0ad54ac8715b830a8&oe=5C9635A0",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43952978_10205020819395847_1951748682512596992_o.jpg?_nc_cat=101&_nc_ht=scontent-lht6-1.xx&oh=f78aae8489e1077df6cc3266d3c9ccc7&oe=5CA1232C",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43952276_10205020818115815_98364814186774528_o.jpg?_nc_cat=106&_nc_ht=scontent-lht6-1.xx&oh=c4dee9f352a34f1e7ad9b2deaf501784&oe=5CAFA3DB",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43950002_10205020816555776_4810511663855828992_o.jpg?_nc_cat=111&_nc_ht=scontent-lht6-1.xx&oh=f42a92648d41016b2faacdb99ed290ed&oe=5CA7D378",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44022896_10205020815995762_6125466268607709184_o.jpg?_nc_cat=105&_nc_ht=scontent-lht6-1.xx&oh=06690071f0491df3bed00404b4ed4804&oe=5C991E74",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/43951941_10205020815115740_33392133775818752_o.jpg?_nc_cat=105&_nc_ht=scontent-lht6-1.xx&oh=53d47ad3ef1b90f837b48b8234ba1cfb&oe=5CA14DB2",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44037802_10205020814995737_274281400411095040_o.jpg?_nc_cat=109&_nc_ht=scontent-lht6-1.xx&oh=3210f5b051c21004aa297ec02a5169bf&oe=5C65A8E8",
            "https://scontent-lht6-1.xx.fbcdn.net/v/t1.0-9/44025050_10205020814195717_8521023804535734272_o.jpg?_nc_cat=107&_nc_ht=scontent-lht6-1.xx&oh=0168dbc2717a88b9e1c68476fd858144&oe=5C691255",
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
    
    public var supportsPolledEvents: Bool = true
    
    public var hasFetchedEvent: Bool = false
    
    private var currentISO: String = "AUTO"
    
    private var currentShutterSpeed: ShutterSpeed = ShutterSpeed(numerator: 1.0, denominator: 1250)
    
    private var currentAperture: String = "1.8"
    
    private var currentSelfTimer: TimeInterval = 0.0
    
    private var currentShootMode: ShootingMode = .photo
    
    var currentFocusMode: String = "AF-S"
    
    private var currentExposureComp: Double = 0.0
    
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
            availableFunctions: [.setISO, .setShutterSpeed, .setAperture, .setExposureCompensation, .setSelfTimerDuration, .setWhiteBalance],
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
            selfTimer: (current: currentSelfTimer, available: [0.0, 2.0, 5.0]),
            shootMode: (current: currentShootMode, available: [.photo, .continuous, .timelapse, .video, .continuous]),
            exposureCompensation: (current: currentExposureComp, available: [-3.0, -2.66, -2.33, -2.0, -1.66, -1.33, -1.0, -0.66, -0.33, 0, 0.33, 0.66, 1.0, 1.33, 1.66, 2.0, 2.33, 2.66, 3.0]),
            flashMode: nil,
            aperture: (current: currentAperture, available: ["1.8", "2.0", "2.2", "2.8", "3.2", "4.0", "4.8", "5.6", "8.0", "11.0", "18.0", "22.0"]),
            focusMode: (current: currentFocusMode, available: ["AF-S", "MF"]),
            ISO: (current: currentISO, available: ["AUTO", "50", "100", "200", "400", "1600", "3200", "6400"]),
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
                ]),
            whiteBalance: CameraEvent.WhiteBalanceInformation(shouldCheck: true, whitebalanceValue: WhiteBalance.Value(mode: "Daylight", temperature: nil)),
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
            
            guard let value = payload as? String else {
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
            
            guard let value = payload as? String else {
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
            
            guard let value = payload as? String else {
                return
            }
            currentFocusMode = value
            eventCompletion?()
            
        case .setExposureCompensation:
            
            guard let value = payload as? Double else {
                return
            }
            currentExposureComp = value
            eventCompletion?()
            
        case .startLiveView:
            
            callback(nil, nil)
            
        default:
            callback(nil, nil)
        }
    }
}
