//
//  MD5Tests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 30/03/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderRequest

class MD5Tests: XCTestCase {

    func testHelloWorldHashesCorrectly() {
        
        let helloWorld = "Hello World"
        let md5Hash = helloWorld.md5Hex
        
        XCTAssertEqual(md5Hash, "b10a8db164e0754105b7a99be72e3fe5")
        print("md5 hash", md5Hash!)
    }

    func testGoogleHashesCorrectly() {
        
        let google = "https://www.google.com"
        let md5Hash = google.md5Hex
        
        XCTAssertEqual(md5Hash, "8ffdefbdec956b595d257f0aaeefd623")
    }
}
