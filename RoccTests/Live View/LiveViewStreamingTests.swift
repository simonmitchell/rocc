//
//  LiveViewStreamingTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 09/12/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class LiveViewStreamingTests: XCTestCase {

    func testRX100M7SingleImageDataIsParsedCorrectly() {
        
        guard let hexString = try? String(contentsOf: Bundle(for: LiveViewStreamingTests.self).url(forResource: "liveview-rx100m7-singleimage", withExtension: nil)!) else {
            XCTFail("Couldn't get hex string from file: liveview-rx100m7-singleimage")
            return
        }
        
        let byteBuffer = ByteBuffer(hexString: hexString)
        let data = Data(bytes: byteBuffer.bytes.compactMap({ $0 }))
        let liveViewStream = LiveViewStream(camera: DummyCamera(), delegate: nil)
        liveViewStream.receivedData = data
        let payloads = liveViewStream.attemptImageParse()
        XCTAssertNotNil(payloads)
        XCTAssertEqual(liveViewStream.receivedData.count, 151)
        XCTAssertEqual(liveViewStream.receivedData[0], 0)
        XCTAssertEqual(liveViewStream.receivedData[3], 0xcd)
        
        guard let image = payloads?.first?.image else {
            XCTFail("Didn't parse first payload as image correctly")
            return
        }
        
        XCTAssertEqual(image.size, CGSize(width: 640, height: 424))
    }
    
    func testRX100M7MultipleImageDataIsParsedCorrectly() {
        
        guard let hexString = try? String(contentsOf: Bundle(for: LiveViewStreamingTests.self).url(forResource: "liveview-rx100m7-multipleimages", withExtension: nil)!) else {
            XCTFail("Couldn't get hex string from file: liveview-rx100m7-multipleimages")
            return
        }
        
        let byteBuffer = ByteBuffer(hexString: hexString)
        let data = Data(bytes: byteBuffer.bytes.compactMap({ $0 }))
        let liveViewStream = LiveViewStream(camera: DummyCamera(), delegate: nil)
        liveViewStream.receivedData = data
        let payloads = liveViewStream.attemptImageParse()
        XCTAssertNotNil(payloads)
        XCTAssertEqual(payloads?.count, 2)
        XCTAssertEqual(liveViewStream.receivedData.count, 3115)
        XCTAssertEqual(liveViewStream.receivedData[0], 0)
        XCTAssertEqual(liveViewStream.receivedData[1], 0x3f)
        
        XCTAssertEqual(payloads?[0].image?.size, CGSize(width: 640, height: 424))
        XCTAssertEqual(payloads?[1].image?.size, CGSize(width: 640, height: 424))
    }
}
