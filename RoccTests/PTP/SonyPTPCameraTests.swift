//
//  SonyPTPCameraTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 25/09/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

extension Packetable {
    var trimmedHexData: String {
        return data.toHex.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

func ==(lhs: TestPTPPacketStream.TestFlow, rhs: Array<PacketInfo>) -> Bool {
    return lhs.packetsSentAndReceived == rhs
}

extension TestPTPPacketStream.TestFlow {
    
    var packetsSentAndReceived: [PacketInfo] {
        return flatMap { (flowStep) -> [PacketInfo] in
            var packets: [PacketInfo] = [flowStep.packetReceived]
            packets.append(contentsOf: flowStep.response ?? [])
            return packets
        }
    }
}

class SonyPTPCameraTests: XCTestCase {
    
    override func setUpWithError() throws {
        camera.ptpIPClient = nil
    }
    
    let camera = SonyPTPIPDevice(dictionary: [
        "av:X_ScalarWebAPI_DeviceInfo": [
            "av:X_ScalarWebAPI_ImagingDevice": [
                "av:X_ScalarWebAPI_LiveView_URL": "192.168.0.1"
            ]
        ],
        "UDN": TestPTPPacketStream.TestFlow.Sony.guid
    ])!

    func testConnectionFlow() {
                
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Sony.connect
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
    
    func testConnectionFlowOtherSessionOpenFirstSDIOConnect() {
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Sony.connectAlreadyOpen
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
