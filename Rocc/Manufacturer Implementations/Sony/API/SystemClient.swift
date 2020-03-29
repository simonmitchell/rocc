//
//  CameraClient.swift
//  Rocc
//
//  Created by Simon Mitchell on 25/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import ThunderRequest

internal final class SystemClient: ServiceClient {
    
    typealias GenericCompletion = (_ error: Error?) -> Void
    
    internal convenience init?(apiInfo: SonyAPICameraDevice.ApiDeviceInfo) {
        guard let systemService = apiInfo.services.first(where: { $0.type == "system" }) else { return nil }
        self.init(service: systemService)
    }

    func setCurrentTime(_ time: Date, timeZone: TimeZone = .current, _ completion: @escaping GenericCompletion) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: time)
        
        let params: [AnyHashable : Any] = [
            "dateTime" : dateString,
            "timeZoneOffsetMinute" : Int(timeZone.secondsFromGMT() / 60),
            "dstOffsetMinute": Int(timeZone.daylightSavingTimeOffset() / 60)
        ]
        
        let requestBody = SonyRequestBody(method: "setCurrentTime", params: [params], id: 1, version: "1.0")
        requestController.request(service.type, method: .POST, body: requestBody.requestSerialised) { (response, error) in
            completion(error ?? CameraError(responseDictionary: response?.dictionary, methodName: "setCurrentTime"))
        }
    }
}
