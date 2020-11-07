//
//  Data+Conversion.swift
//  Rocc
//
//  Created by Simon Mitchell on 15/05/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

extension DataConvertible {
    
    init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else { return nil }
        self = data.withUnsafeBytes { $0.load(as: Self.self) }
    }
    
    var data: Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension UnsignedInteger {
    
    init?(data: Data) {
        
        let bytes = [UInt8](data)
        guard bytes.count <= MemoryLayout<Self>.size else { return nil }
        
        var value : UInt64 = 0
        
        for byte in bytes {
            value <<= 8
            value |= UInt64(byte)
        }
        
        self.init(value)
    }
}

extension Float : DataConvertible { }
extension Double : DataConvertible { }
extension Int: DataConvertible { }


