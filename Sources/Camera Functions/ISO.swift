//
//  Apeture.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// Functions for controlling the ISO of the camera
public struct ISO: CameraFunction {
    
    public enum Value: Equatable {
        
        case auto
        case extended(Int)
        case native(Int)
        case multiFrameNRAuto
        case multiFrameNR(Int)
        case multiFrameNRHiAuto
        case multiFrameNRHi(Int)
        
        public static func == (lhs: ISO.Value, rhs: ISO.Value) -> Bool {
            switch (lhs, rhs) {
            case (.auto, .auto):
                return true
            case (.extended(let lhsExtended), .extended(let rhsExtended)):
                return lhsExtended == rhsExtended
            case (.native(let lhsNative), .native(let rhsNative)):
                return lhsNative == rhsNative
            case (.multiFrameNR(let lhsMFNR), .multiFrameNR(let rhsMFNR)):
                return lhsMFNR == rhsMFNR
            case (.multiFrameNRHi(let lhsMFNRHi), .multiFrameNRHi(let rhsMFNRHi)):
                return lhsMFNRHi == rhsMFNRHi
            case (.multiFrameNRAuto, .multiFrameNRAuto):
                return true
            case (.multiFrameNRHiAuto, .multiFrameNRHiAuto):
                return true
            default:
                return false
            }
        }
    }
    
    public var function: _CameraFunction
    
    public typealias SendType = ISO.Value
    
    public typealias ReturnType = ISO.Value
    
    /// Sets the ISO of the camera
    public static let set = ISO(function: .setISO)
    
    /// Returns the current ISO of the camera
    public static let get = ISO(function: .getISO)
}

extension ISO.Value: Codable {
    enum CodingKeys: CodingKey {
        case type
        case value
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "auto":
            self = .auto
        case "extended":
            let value = try values.decode(Int.self, forKey: .value)
            self = .extended(value)
        case "native":
            let value = try values.decode(Int.self, forKey: .value)
            self = .native(value)
        case "multiFrameNRAuto":
            self = .multiFrameNRAuto
        case "multiFrameNR":
            let value = try values.decode(Int.self, forKey: .value)
            self = .multiFrameNR(value)
        case "multiFrameNRHiAuto":
            self = .multiFrameNRHiAuto
        case "multiFrameNRHi":
            let value = try values.decode(Int.self, forKey: .value)
            self = .multiFrameNRHi(value)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "invalid type"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .auto:
            try container.encode("auto", forKey: .type)
        case .extended(let val):
            try container.encode("extended", forKey: .type)
            try container.encode(val, forKey: .value)
        case .native(let val):
            try container.encode("native", forKey: .type)
            try container.encode(val, forKey: .value)
        case .multiFrameNRAuto:
            try container.encode("multiFrameNRAuto", forKey: .type)
        case .multiFrameNR(let val):
            try container.encode("multiFrameNR", forKey: .type)
            try container.encode(val, forKey: .value)
        case .multiFrameNRHiAuto:
            try container.encode("multiFrameNRHiAuto", forKey: .type)
        case .multiFrameNRHi(let val):
            try container.encode("multiFrameNRHi", forKey: .type)
            try container.encode(val, forKey: .value)
        }
    }
}
