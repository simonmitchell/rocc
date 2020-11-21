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

extension String {
    
    static let deviceInfoHex: Self = "64 00 11 00 00 00 64 00 14 53 00 6f 00 6e 00 79 00 20 00 50 00 54 00 50 00 20 00 45 00 78 00 74 00 65 00 6e 00 73 00 69 00 6f 00 6e 00 73 00 00 00 00 00 1b 00 00 00 01 10 02 10 03 10 04 10 05 10 06 10 07 10 08 10 09 10 0a 10 0d 10 1b 10 01 92 02 92 05 92 07 92 09 92 0a 92 0b 92 0c 92 0d 92 0e 92 0f 92 01 98 02 98 03 98 05 98 0c 00 00 00 01 c2 02 c2 03 c2 04 c2 05 c2 06 c2 07 c2 08 c2 09 c2 0a c2 0b c2 0c c2 00 00 00 00 00 00 00 00 03 00 00 00 01 38 01 b3 01 b1 11 53 00 6f 00 6e 00 79 00 20 00 43 00 6f 00 72 00 70 00 6f 00 72 00 61 00 74 00 69 00 6f 00 6e 00 00 00 0c 44 00 53 00 43 00 2d 00 52 00 58 00 31 00 30 00 30 00 4d 00 37 00 00 00 05 31 00 2e 00 30 00 30 00 00 00 21 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 30 00 38 00 30 00 38 00 31 00 38 00 38 00 36 00 30 00 30 00 32 00 38 00 39 00 35 00 32 00 35 00 31 00 00 00"
    
    static let sdioDeviceInfoHex: Self = "2c 01 4e 00 00 00 05 50 07 50 0a 50 0b 50 0c 50 0e 50 10 50 13 50 00 d2 01 d2 03 d2 0d d2 0e d2 0f d2 10 d2 11 d2 13 d2 14 d2 15 d2 17 d2 18 d2 1b d2 1c d2 1d d2 1e d2 21 d2 22 d2 23 d2 2a d2 2c d2 31 d2 35 d2 36 d2 39 d2 3a d2 3b d2 3c d2 3d d2 3e d2 3f d2 40 d2 41 d2 42 d2 43 d2 44 d2 45 d2 46 d2 47 d2 48 d2 49 d2 4a d2 4c d2 4e d2 4f d2 50 d2 51 d2 52 d2 53 d2 54 d2 55 d2 59 d2 5a d2 5b d2 5c d2 5d d2 5f d2 60 d2 61 d2 62 d2 63 d2 64 d2 67 d2 69 d2 6a d2 71 d2 72 d2 73 d2 78 d2 17 00 00 00 c1 d2 c2 d2 c3 d2 c7 d2 c8 d2 c9 d2 ca d2 cd d2 ce d2 cf d2 d0 d2 d1 d2 d2 d2 d4 d2 d5 d2 d6 d2 d7 d2 d8 d2 d9 d2 da d2 db d2 dc d2 dd d2"
}

extension SonyPTPIPDevice {
    
    func setupDummyDeviceInfo() {
        
        deviceInfo = PTP.DeviceInfo(data: ByteBuffer(hexString: .deviceInfoHex))
        if let sdioInfo = PTP.SDIOExtDeviceInfo(data: ByteBuffer(hexString: .sdioDeviceInfoHex)) {
            deviceInfo?.update(with: sdioInfo)
        }
    }
}

extension TestPTPPacketStream.TestFlow {
    
    var packetsSentAndReceived: [PacketInfo] {
        
        var packets: [PacketInfo] = []
        if let initialStepPacket = initialPacket {
            packets.append(initialStepPacket)
        }
        
        steps.forEach { (flowStep) in
            packets.append(flowStep.packetReceived)
            packets.append(contentsOf: flowStep.response ?? [])
        }
        return packets
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
    
    func testEventFetchedCorrectlyWhenReceieveEventPacket() {
        
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Sony.getEvent
        camera.ptpIPClient = PTPIPClient(
            camera: camera,
            packetStream: packetStream
        )
        camera.ptpIPClient?.deviceName = "iPhone Xs Max"
        
        let expectation = XCTestExpectation(description: "Get event")
        
        self.camera.onEventAvailable = {
            self.camera.performFunction(Event.get, payload: nil) { (_, event) in
                XCTAssertNotNil(event)
                expectation.fulfill()
            }
        }
        
        camera.connect { (_, _) in
            
            
        }
                
        packetStream.sendInitialPacketIfPresent()
        
        wait(for: [expectation], timeout: 10)
                        
        XCTAssertEqual(
            packetStream.packetsSentAndReceived,
            packetStream.testFlow.packetsSentAndReceived
        )
    }
    
    func testTakePicture() {
        
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Sony.takePicture
        camera.ptpIPClient = PTPIPClient(
            camera: camera,
            packetStream: packetStream
        )
        camera.ptpIPClient?.deviceName = "iPhone Xs Max"
        
        let expectation = XCTestExpectation(description: "Take picture")
        
        self.camera.onEventAvailable = {
            
        }
        
        camera.connect { (_, _) in
            
            self.camera.performFunction(StillCapture.take, payload: nil) { (_, url) in
                expectation.fulfill()
            }
        }
                
        packetStream.sendInitialPacketIfPresent()
        
        wait(for: [expectation], timeout: 10)
                        
        XCTAssertEqual(
            packetStream.packetsSentAndReceived,
            packetStream.testFlow.packetsSentAndReceived
        )
    }
    
    func testSupportsFunctions() {
        
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Sony.functionSupport
        camera.setupDummyDeviceInfo()
        camera.ptpIPClient = PTPIPClient(
            camera: camera,
            packetStream: packetStream
        )
        camera.ptpIPClient?.deviceName = "iPhone Xs Max"
        
        let expectation = XCTestExpectation(description: "Get supports")
        
        camera.supportsFunction(Aperture.set) { (supported, error, supportedValues) in
            
            XCTAssertEqual(supported, true)
            XCTAssertNil(error)
            XCTAssertNotNil(supportedValues)
            XCTAssertEqual(
                supportedValues,
                [
                    .init(value: 2.8, decimalSeperator: nil),
                    .init(value: 3.2, decimalSeperator: nil),
                    .init(value: 3.5, decimalSeperator: nil),
                    .init(value: 4.0, decimalSeperator: nil),
                    .init(value: 4.5, decimalSeperator: nil),
                    .init(value: 5.0, decimalSeperator: nil),
                    .init(value: 5.6, decimalSeperator: nil),
                    .init(value: 6.3, decimalSeperator: nil),
                    .init(value: 7.1, decimalSeperator: nil),
                    .init(value: 8.0, decimalSeperator: nil),
                    .init(value: 9.0, decimalSeperator: nil),
                    .init(value: 10.0, decimalSeperator: nil),
                    .init(value: 11.0, decimalSeperator: nil)
                ]
            )
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
                        
        XCTAssertEqual(
            packetStream.packetsSentAndReceived,
            packetStream.testFlow.packetsSentAndReceived
        )
    }
    
    func testAvailableFunctions() {
        
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Sony.functionAvailability
        camera.setupDummyDeviceInfo()
        camera.ptpIPClient = PTPIPClient(
            camera: camera,
            packetStream: packetStream
        )
        camera.ptpIPClient?.deviceName = "iPhone Xs Max"
        
        let expectation = XCTestExpectation(description: "Get supports")
        
        camera.isFunctionAvailable(Aperture.set) { (available, error, supportedValues) in
            
            XCTAssertEqual(available, true)
            XCTAssertNil(error)
            XCTAssertNotNil(supportedValues)
            XCTAssertEqual(
                supportedValues,
                [
                    .init(value: 2.8, decimalSeperator: nil),
                    .init(value: 3.2, decimalSeperator: nil),
                    .init(value: 3.5, decimalSeperator: nil),
                    .init(value: 4.0, decimalSeperator: nil),
                    .init(value: 4.5, decimalSeperator: nil),
                    .init(value: 5.0, decimalSeperator: nil),
                    .init(value: 5.6, decimalSeperator: nil),
                    .init(value: 6.3, decimalSeperator: nil),
                    .init(value: 7.1, decimalSeperator: nil),
                    .init(value: 8.0, decimalSeperator: nil),
                    .init(value: 9.0, decimalSeperator: nil),
                    .init(value: 10.0, decimalSeperator: nil),
                    .init(value: 11.0, decimalSeperator: nil)
                ]
            )
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
                        
        XCTAssertEqual(
            packetStream.packetsSentAndReceived,
            packetStream.testFlow.packetsSentAndReceived
        )
    }
    
    func testGetFunction() {
        
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Sony.performGetFunction
        camera.setupDummyDeviceInfo()
        camera.ptpIPClient = PTPIPClient(
            camera: camera,
            packetStream: packetStream
        )
        camera.ptpIPClient?.deviceName = "iPhone Xs Max"
        
        let expectation = XCTestExpectation(description: "Get supports")
        
        camera.performFunction(Aperture.get, payload: nil) { (error, value) in
            
            XCTAssertNil(error)
            XCTAssertNotNil(value)
            XCTAssertEqual(
                value,
                .init(value: 2.8, decimalSeperator: nil)
            )
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
                        
        XCTAssertEqual(
            packetStream.packetsSentAndReceived,
            packetStream.testFlow.packetsSentAndReceived
        )
    }
    
    func testSetFunction() {
        
        let packetStream = TestPTPPacketStream(camera: camera, port: 0)!
        packetStream.testFlow = TestPTPPacketStream.TestFlow.Sony.performSetFunction
        camera.setupDummyDeviceInfo()
        camera.ptpIPClient = PTPIPClient(
            camera: camera,
            packetStream: packetStream
        )
        camera.ptpIPClient?.deviceName = "iPhone Xs Max"
        
        let expectation = XCTestExpectation(description: "Get supports")
        
        let aperture = Aperture.Value(value: 2.8, decimalSeperator: nil)
        camera.performFunction(Aperture.set, payload: aperture) { (error, _) in
            
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
                        
        XCTAssertEqual(
            packetStream.packetsSentAndReceived,
            packetStream.testFlow.packetsSentAndReceived
        )
    }
}
