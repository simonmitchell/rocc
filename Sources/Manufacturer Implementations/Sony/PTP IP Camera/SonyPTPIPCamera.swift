//
//  SonyPTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

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
    
    override func update(with deviceInfo: SSDPCameraInfo) {
        
        guard let sonyDeviceInfo = deviceInfo as? SonyDeviceInfo else { return }
        
        name = model == nil ? name : (sonyDeviceInfo.model?.friendlyName ?? name)
        model = sonyDeviceInfo.model ?? model
        lensModelName = sonyDeviceInfo.lensModelName
        firmwareVersion = sonyDeviceInfo.firmwareVersion
    }
    
    override func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
        switch function.function {
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
        default:
            super.performFunction(function, payload: payload, callback: callback)
        }
    }
}
