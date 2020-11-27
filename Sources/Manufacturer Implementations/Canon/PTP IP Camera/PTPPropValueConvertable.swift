//
//  SonyPTPPropValueConvertible.swift
//  Rocc
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

/// A protocol which types can conform to to allow them to
/// be converted to and from PTP Prop Values
internal protocol PTPPropValueConvertable {
    
    /// Returns the raw value for the given value of the conformer
    /// to the protocol
    /// - Parameter manufacturer: The manufacturer of the camera
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType
    
    /// Returns the PTP property code for the given manufacturer
    /// - Parameter manufacturer: The manufacturer of the camera
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code
    
    /// Initialises the value based on the raw value from the camera and given manufacturer
    /// - Parameter value: The raw value from the camera
    /// - Parameter manufacturer: The manufacturer to convert for
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer)
}

extension PTPPropValueConvertable {
    /// Returns the data type of the value of the prop
    /// - Parameter manufacturer: The manufacturer of the camera
    static func dataType(for manufacturer: Manufacturer) -> PTP.DeviceProperty.DataType {
        return Self.devicePropertyCode(for: manufacturer).dataType(for: manufacturer)
    }
}
