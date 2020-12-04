//
//  ByteBufferTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 23/01/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class ByteBufferTests: XCTestCase {
    
    func testReadUInt16StringWithLength() {
        
        var offset: UInt = 0
        let byteBuffer = ByteBuffer(hexString: "0a 43 00 61 00 6e 00 6f 00 6e 00 2e 00 49 00 6e 00 63 00 00 00 00 00 00")
        XCTAssertEqual(byteBuffer.read(offset: &offset, withCount: true, encoding: .uint16), "Canon.Inc")
        XCTAssertEqual(offset, 21)
        
        offset = 0
        let byteBuffer2 = ByteBuffer(hexString: "0c 43 00 61 00 6e 00 6f 00 6e 00 20 00 45 00 4f 00 53 00 20 00 52 00 00 00")
        XCTAssertEqual(byteBuffer2.read(offset: &offset, withCount: true, encoding: .uint16), "Canon EOS R")
        XCTAssertEqual(offset, 25)
        
        offset = 0
        let byteBuffer3 = ByteBuffer(hexString: "08 33 00 2d 00 31 00 2e 00 36 00 2e 00 30 00 00 00 00 00")
        XCTAssertEqual(byteBuffer3.read(offset: &offset, withCount: true, encoding: .uint16), "3-1.6.0")
        XCTAssertEqual(offset, 17)
    }
    
    func testReadUInt16StringWithoutLength() {
        
        var offset: UInt = 0
        let byteBuffer = ByteBuffer(hexString: "43 00 61 00 6e 00 6f 00 6e 00 2e 00 49 00 6e 00 63 00 00 00 00 00 00 00")
        XCTAssertEqual(byteBuffer.read(offset: &offset, withCount: false, encoding: .uint16), "Canon.Inc")
        XCTAssertEqual(offset, 20)
        
        offset = 0
        let byteBuffer2 = ByteBuffer(hexString: "43 00 61 00 6e 00 6f 00 6e 00 20 00 45 00 4f 00 53 00 20 00 52 00 00 00 00 00")
        XCTAssertEqual(byteBuffer2.read(offset: &offset, withCount: false, encoding: .uint16), "Canon EOS R")
        XCTAssertEqual(offset, 24)
        
        offset = 0
        let byteBuffer3 = ByteBuffer(hexString: "33 00 2d 00 31 00 2e 00 36 00 2e 00 30 00 00 00")
        XCTAssertEqual(byteBuffer3.read(offset: &offset, withCount: false, encoding: .uint16), "3-1.6.0")
        XCTAssertEqual(offset, 16)
    }
    
    func testAppendUInt16StringWithLength() {
        
        var byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "3-1.6.0", includingLength: true)
        XCTAssertEqual(byteBuffer.toHex, "08 33 00 2d 00 31 00 2e 00 36 00 2e 00 30 00 00 00 ")
        
        byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "Canon EOS R", includingLength: true)
        XCTAssertEqual(byteBuffer.toHex, "0c 43 00 61 00 6e 00 6f 00 6e 00 20 00 45 00 4f 00 53 00 20 00 52 00 00 00 ")
        
        byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "Canon.Inc", includingLength: true)
        XCTAssertEqual(byteBuffer.toHex, "0a 43 00 61 00 6e 00 6f 00 6e 00 2e 00 49 00 6e 00 63 00 00 00 ")
    }
    
    func testAppendUInt16StringWithoutLength() {
        
        var byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "3-1.6.0")
        XCTAssertEqual(byteBuffer.toHex, "33 00 2d 00 31 00 2e 00 36 00 2e 00 30 00 00 00 ")
        
        byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "Canon EOS R", includingLength: false)
        XCTAssertEqual(byteBuffer.toHex, "43 00 61 00 6e 00 6f 00 6e 00 20 00 45 00 4f 00 53 00 20 00 52 00 00 00 ")
        
        byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "Canon.Inc", includingLength: false)
        XCTAssertEqual(byteBuffer.toHex, "43 00 61 00 6e 00 6f 00 6e 00 2e 00 49 00 6e 00 63 00 00 00 ")
    }
    
    func testReadUInt8StringWithLength() {
                
        var offset: UInt = 0
        let byteBuffer = ByteBuffer(hexString: "10 45 46 35 30 6d 6d 20 66 2f 31 2e 38 20 53 54 4d 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00")
        XCTAssertEqual(byteBuffer.read(offset: &offset, withCount: true, encoding: .uint8), "EF50mm f/1.8 STM")
        XCTAssertEqual(offset, 18)

        offset = 0
        let byteBuffer2 = ByteBuffer(hexString: "0d 48 65 6c 6c 6f 20 57 6f 72 6c 64 21 00")
        XCTAssertEqual(byteBuffer2.read(offset: &offset, withCount: true, encoding: .uint8), "Hello World!")
        XCTAssertEqual(offset, 14)

        offset = 0
        let byteBuffer3 = ByteBuffer(hexString: "0a 43 61 6e 6f 6e 2e 49 6e 63 00")
        XCTAssertEqual(byteBuffer3.read(offset: &offset, withCount: true, encoding: .uint8), "Canon.Inc")
        XCTAssertEqual(offset, 11)
    }
    
    func testReadUInt8StringWithoutLength() {
        
        var offset: UInt = 0
        let byteBuffer = ByteBuffer(hexString: "45 46 35 30 6d 6d 20 66 2f 31 2e 38 20 53 54 4d 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00")
        XCTAssertEqual(byteBuffer.read(offset: &offset, withCount: false, encoding: .uint8), "EF50mm f/1.8 STM")
        XCTAssertEqual(offset, 17)

        offset = 0
        let byteBuffer2 = ByteBuffer(hexString: "48 65 6c 6c 6f 20 57 6f 72 6c 64 21 00")
        XCTAssertEqual(byteBuffer2.read(offset: &offset, withCount: false, encoding: .uint8), "Hello World!")
        XCTAssertEqual(offset, 13)

        offset = 0
        let byteBuffer3 = ByteBuffer(hexString: "43 61 6e 6f 6e 2e 49 6e 63 00")
        XCTAssertEqual(byteBuffer3.read(offset: &offset, withCount: false, encoding: .uint8), "Canon.Inc")
        XCTAssertEqual(offset, 10)
    }
    
    func testAppendUInt8StringWithLength() {
                
        var byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "EF50mm f/1.8 STM", includingLength: true, encoding: .uint8)
        XCTAssertEqual(byteBuffer.toHex, "11 45 46 35 30 6d 6d 20 66 2f 31 2e 38 20 53 54 4d 00 ")
        
        byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "Hello World!", includingLength: true, encoding: .uint8)
        XCTAssertEqual(byteBuffer.toHex, "0d 48 65 6c 6c 6f 20 57 6f 72 6c 64 21 00 ")

        byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "Canon.Inc", includingLength: true, encoding: .uint8)
        XCTAssertEqual(byteBuffer.toHex, "0a 43 61 6e 6f 6e 2e 49 6e 63 00 ")
    }
    
    func testAppendUInt8StringWithoutLength() {
        
        var byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "EF50mm f/1.8 STM", includingLength: false, encoding: .uint8)
        XCTAssertEqual(byteBuffer.toHex, "45 46 35 30 6d 6d 20 66 2f 31 2e 38 20 53 54 4d 00 ")
        
        byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "Hello World!", includingLength: false, encoding: .uint8)
        XCTAssertEqual(byteBuffer.toHex, "48 65 6c 6c 6f 20 57 6f 72 6c 64 21 00 ")

        byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(string: "Canon.Inc", includingLength: false, encoding: .uint8)
        XCTAssertEqual(byteBuffer.toHex, "43 61 6e 6f 6e 2e 49 6e 63 00 ")
    }
    
    func testAppendInt8() {

        var byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(Int8(124))
        
        XCTAssertEqual(byteBuffer.toHex, "7c ")
    }
    
    func testReadUInt8() {
        
        var offset: UInt = 0
        let byteBuffer = ByteBuffer(bytes: [20])
        var int8: UInt8? = byteBuffer.read(offset: &offset)
        
        XCTAssertEqual(int8, 20)
        XCTAssertEqual(offset, 1)
        
        offset = 0
        int8 = ByteBuffer(bytes: [0xec]).read(offset: &offset)
        XCTAssertEqual(int8, 236)
        XCTAssertEqual(offset, 1)
        
        offset = 0
        int8 = ByteBuffer(bytes: [0xfe]).read(offset: &offset)
        XCTAssertEqual(int8, 254)
        XCTAssertEqual(offset, 1)
    }

    func testReadInt8() {
        
        var offset: UInt = 0
        let byteBuffer = ByteBuffer(bytes: [20])
        var int8: Int8? = byteBuffer.read(offset: &offset)
        
        XCTAssertEqual(int8, 20)
        XCTAssertEqual(offset, 1)
        
        offset = 0
        int8 = ByteBuffer(bytes: [0x80]).read(offset: &offset)
        XCTAssertEqual(int8, Int8.min)
        XCTAssertEqual(offset, 1)
        
        offset = 0
        int8 = ByteBuffer(bytes: [0xec]).read(offset: &offset)
        XCTAssertEqual(int8, -20)
        XCTAssertEqual(offset, 1)
        
        offset = 0
        int8 = ByteBuffer(bytes: [0xfe]).read(offset: &offset)
        XCTAssertEqual(int8, -2)
        XCTAssertEqual(offset, 1)
    }
    
    func testReadInt16() {
        
        var offset: UInt = 0
        var int16: Int16? = ByteBuffer(bytes: [0xff]).read(offset: &offset)
        XCTAssertNil(int16)
        XCTAssertEqual(offset, 0)
        
        int16 = ByteBuffer(bytes: [0xfe, 0x7f]).read(offset: &offset)
        XCTAssertEqual(int16, Int16.max - 1)
        XCTAssertEqual(offset, 2)
        
        offset = 0
        int16 = ByteBuffer(bytes: [0x7f, 0xfe]).read(offset: &offset)
        XCTAssertEqual(int16, -385)
        XCTAssertEqual(offset, 2)
        
        offset = 0
        int16 = ByteBuffer(bytes: [0x00, 0x80]).read(offset: &offset)
        XCTAssertEqual(int16, Int16.min)
        XCTAssertEqual(offset, 2)
    }
    
    func testReadInt32() {
        
        var offset: UInt = 0
        var int32: Int32? = ByteBuffer(bytes: [0xff]).read(offset: &offset)
        XCTAssertNil(int32)
        XCTAssertEqual(offset, 0)

        int32 = ByteBuffer(bytes: [0xfe, 0xff, 0xff, 0x7f]).read(offset: &offset)
        XCTAssertEqual(int32, Int32.max - 1)
        XCTAssertEqual(offset, 4)
        
        offset = 0
        int32 = ByteBuffer(bytes: [0x00, 0x00, 0x00, 0x80]).read(offset: &offset)
        XCTAssertEqual(int32, Int32.min)
        XCTAssertEqual(offset, 4)
        
        offset = 0
        int32 = ByteBuffer(bytes: [0x63, 0x04, 0x00, 0x80]).read(offset: &offset)
        XCTAssertEqual(int32, -2147482525)
        XCTAssertEqual(offset, 4)
    }
    
    func testReadInt64() {
        
        var offset: UInt = 0
        var int64: Int64? = ByteBuffer(bytes: [0xfe, 0xff, 0xff, 0x7f]).read(offset: &offset)
        XCTAssertNil(int64)
        XCTAssertEqual(offset, 0)
        
        int64 = ByteBuffer(bytes: [0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f]).read(offset: &offset)
        XCTAssertEqual(int64, Int64.max - 1)
        XCTAssertEqual(offset, 8)
        
        offset = 0
        int64 = ByteBuffer(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80]).read(offset: &offset)
        XCTAssertEqual(int64, Int64.min)
        XCTAssertEqual(offset, 8)
        
        offset = 0
        int64 = ByteBuffer(bytes: [0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0]).read(offset: &offset)
        XCTAssertEqual(int64, -4611686018427387882)
        XCTAssertEqual(offset, 8)
        
        offset = 0
        int64 = ByteBuffer(bytes: [0x5f, 0xf4, 0x60, 0x01, 0x00, 0x00, 0x00, 0x80]).read(offset: &offset)
        XCTAssertEqual(int64, -9223372036831644577)
        XCTAssertEqual(offset, 8)
        
        offset = 0
        int64 = ByteBuffer(bytes: [0xb3, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]).read(offset: &offset)
        XCTAssertEqual(int64, 1203)
        XCTAssertEqual(offset, 8)
    }
    
    func testReadMaxUInt64DoesntCrash() {
        
        var offset: UInt = 0
        let int64: UInt64? = ByteBuffer(bytes: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]).read(offset: &offset)
        XCTAssertEqual(int64, UInt64.max)
    }
}
