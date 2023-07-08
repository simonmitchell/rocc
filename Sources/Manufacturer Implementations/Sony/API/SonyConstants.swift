//
//  Constants.swift
//  Rocc
//
//  Created by Simon Mitchell on 20/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
import Network

internal struct SonyConstants {
    internal struct SSDP {
        static let port: NWEndpoint.Port = 1900
        static let mx = 1
        static let address: NWEndpoint.Host = "239.255.255.250"
        static let st = "urn:schemas-sony-com:service:ScalarWebAPI:1"
    }
}
