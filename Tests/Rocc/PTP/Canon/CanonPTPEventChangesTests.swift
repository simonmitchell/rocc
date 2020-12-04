//
//  CanonPTPEventChangesTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 27/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class CanonPTPEventChangesTests: XCTestCase {

    func testPropValueAndAvailableListEventParsesCorrectly() throws {
        
        let byteBuffer = Bundle.current.byteBuffer(named: "Canon_Event_Prop_And_Available")
        
        do {
            let change = try CanonPTPEvents(data: byteBuffer)
            XCTAssertEqual(change.events.count, 146)
        } catch {
            XCTFail("Failed to create events object")
        }
    }
}
