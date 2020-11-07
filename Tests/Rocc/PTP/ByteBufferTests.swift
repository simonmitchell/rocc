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
    
    func testAppendInt8() {

        var byteBuffer = ByteBuffer(bytes: [])
        byteBuffer.append(Int64(1203))
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
