//
//  SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

protocol SonyPTPPropValueConvertable {
    
    var sonyPTPValue: PTPDevicePropertyDataType { get }
    
    var type: PTP.DeviceProperty.DataType { get }
    
    var code: PTP.DeviceProperty.Code { get }
    
    init?(sonyValue: PTPDevicePropertyDataType)
}
