//
//  PTPPacketParsingTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 25/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class PTPPacketParsingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testMalformedPacketDoesntCrashApp() {
        
        var byteBuffer = ByteBuffer(hexString: "0e 00 00 00 07 00 00 00")
        let packets = byteBuffer.parsePackets(removingParsedData: true)
        
        XCTAssertEqual(packets?.count, 1)
    }

    func testMalformedCommandResponseParsedCorrectly() {
        
        var byteBuffer = ByteBuffer(hexString: "0e 00 00 00 07 00 00 00")
        let packets = byteBuffer.parsePackets(removingParsedData: true)
        
        XCTAssertEqual(packets?.count, 1)
        
        guard let cmdResponsePacket = packets?.first as? CommandResponsePacket else {
            XCTFail("Failed to allocate malformed packet as command response")
            return
        }
        XCTAssertNil(cmdResponsePacket.code)
    }
    
    func testMalformedCommandResponsePacketDoesntBreakSubsequentPacket() {
        
        var byteBuffer = ByteBuffer(hexString: "0e 00 00 00 07 00 00 00 14 00 00 00 09 00 00 00 04 00 00 00 04 00 00 00 00 00 00 00")
        let packets = byteBuffer.parsePackets(removingParsedData: true)
        
        XCTAssertEqual(packets?.count, 2)
        
        if let cmdResponsePacket = packets?.first as? CommandResponsePacket {
            XCTAssertNil(cmdResponsePacket.code)
        } else {
            XCTFail("Failed to allocate malformed packet as command response")
        }
        
        guard let dataStartPacket = packets?.last as? StartDataPacket else {
            XCTFail("Failed to allocate malformed packet as data start")
            return
        }
        XCTAssertEqual(dataStartPacket.transactionId, 4)
        XCTAssertEqual(dataStartPacket.dataLength, 4)
    }
}
