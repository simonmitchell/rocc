//
//  CanonPTPCameraTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class CanonPTPCameraTests: XCTestCase {

    let camera = try! CanonPTPIPCamera(dictionary: [
        "UDN": TestPTPPacketStream.TestFlow.Canon.guid
    ])
    
    func testConnectionFlow() {
                
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Canon.connect
        camera.ptpIPClient = PTPIPClient(
            camera: camera,
            packetStream: packetStream
        )
        camera.ptpIPClient?.deviceName = "iPhone Xs Max"
        
        let expectation = XCTestExpectation(description: "Connect to camera")
        
        camera.connect { (error, inTransferMode) in
            XCTAssertNil(error)
            XCTAssertFalse(inTransferMode)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(
            packetStream.packetsSentAndReceived,
            packetStream.testFlow.packetsSentAndReceived
        )
    }
}
