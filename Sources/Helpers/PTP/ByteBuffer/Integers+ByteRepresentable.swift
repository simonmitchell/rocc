//
//  Integers+ByteRepresentable.swift
//  Rocc
//
//  Created by Simon Mitchell on 28/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension FixedWidthInteger {
    
    func append(to byteBuffer: inout ByteBuffer) {
        
        // Special case for byte
        if let byte = self as? Byte {
            byteBuffer.bytes.append(byte)
        } else {
            byteBuffer.setLittleEndian(offset: UInt(byteBuffer.bytes.count), value: Int(self), nBytes: UInt(MemoryLayout<Self>.size))
        }
    }
}

extension UnsignedInteger {
    
    static func read(from byteBuffer: ByteBuffer, at offset: inout UInt) -> Self? {
        
        guard let littleEndian = byteBuffer.getLittleEndian(offset: offset, nBytes: UInt(MemoryLayout<Self>.size)) else { return nil }
        offset += UInt(MemoryLayout<Self>.size)
        return Self(littleEndian)
    }
}

extension UInt: ByteRepresentable { }
extension UInt8: ByteRepresentable { }
extension UInt16: ByteRepresentable { }
extension UInt32: ByteRepresentable { }
extension UInt64: ByteRepresentable { }

extension Int: ByteRepresentable { }
extension Int8: ByteRepresentable { }
extension Int16: ByteRepresentable { }
extension Int32: ByteRepresentable { }
extension Int64: ByteRepresentable { }

extension SignedInteger {
    
    static func read(from byteBuffer: ByteBuffer, at offset: inout UInt) -> Self? {
        
        guard let littleEndian = byteBuffer.getLittleEndian(offset: offset, nBytes: UInt(MemoryLayout<Self>.size)) else { return nil }
        var returnValue: Self?
        switch Self() {
        case _ as Int8:
            if littleEndian > UInt8.max || littleEndian < UInt8.min {
                returnValue = Int8(littleEndian) as? Self
            } else {
                returnValue = Int8(bitPattern: UInt8(littleEndian)) as? Self
            }
        case _ as Int16:
            if littleEndian > UInt16.max || littleEndian < UInt16.min {
                returnValue = Int16(littleEndian) as? Self
            } else {
                returnValue = Int16(bitPattern: UInt16(littleEndian)) as? Self
            }
        case _ as Int32:
            if littleEndian > UInt32.max || littleEndian < UInt32.min {
                returnValue = Int32(littleEndian) as? Self
            } else {
                returnValue = Int32(bitPattern: UInt32(littleEndian)) as? Self
            }
        case _ as Int64:
            if littleEndian > UInt64.max || littleEndian < UInt64.min {
                returnValue = Int64(littleEndian) as? Self
            } else {
                returnValue = Int64(bitPattern: UInt64(littleEndian)) as? Self
            }
        default:
            return nil
        }
        guard let _returnValue = returnValue else { return nil }
        offset += UInt(MemoryLayout<Self>.size)
        return _returnValue
    }
}
