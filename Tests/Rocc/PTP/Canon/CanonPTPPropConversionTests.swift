//
//  CanonPTPPropConversionTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 04/12/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class CanonPTPPropConversionTests: XCTestCase {

    func testShutterSpeedInitialisedCorrectly() throws {

        let testCases: [(PTPDevicePropertyDataType, ShutterSpeed?)] = [
            (Word(0x04), .bulb),
            (Word(0x10), .init(numerator: 30, denominator: 1)),
            (Word(0x13), .init(numerator: 25, denominator: 1)),
            (Word(0x15), .init(numerator: 20, denominator: 1)),
            (Word(0x18), .init(numerator: 15, denominator: 1)),
            (Word(0x1b), .init(numerator: 13, denominator: 1)),
            (Word(0x1d), .init(numerator: 10, denominator: 1)),
            (Word(0x20), .init(numerator: 8, denominator: 1)),
            (Word(0x23), .init(numerator: 6, denominator: 1)),
            (Word(0x25), .init(numerator: 5, denominator: 1)),
            (Word(0x28), .init(numerator: 4, denominator: 1)),
            (Word(0x2b), .init(numerator: 3.2, denominator: 1)),
            (Word(0x2d), .init(numerator: 2.5, denominator: 1)),
            (Word(0x30), .init(numerator: 2, denominator: 1)),
            (Word(0x32), .init(numerator: 1.6, denominator: 1)),
            (Word(0x35), .init(numerator: 1.3, denominator: 1)),
            (Word(0x38), .init(numerator: 1, denominator: 1)),
            (Word(0x3b), .init(numerator: 0.8, denominator: 1)),
            (Word(0x3d), .init(numerator: 0.6, denominator: 1)),
            (Word(0x40), .init(numerator: 0.5, denominator: 1)),
            (Word(0x43), .init(numerator: 0.4, denominator: 1)),
            (Word(0x45), .init(numerator: 0.3, denominator: 1)),
            (Word(0x48), .init(numerator: 1, denominator: 4)),
            (Word(0x4b), .init(numerator: 1, denominator: 5)),
            (Word(0x4d), .init(numerator: 1, denominator: 6)),
            (Word(0x50), .init(numerator: 1, denominator: 8)),
            (Word(0x53), .init(numerator: 1, denominator: 10)),
            (Word(0x55), .init(numerator: 1, denominator: 13)),
            (Word(0x58), .init(numerator: 1, denominator: 15)),
            (Word(0x5b), .init(numerator: 1, denominator: 20)),
            (Word(0x5d), .init(numerator: 1, denominator: 25)),
            (Word(0x60), .init(numerator: 1, denominator: 30)),
            (Word(0x63), .init(numerator: 1, denominator: 40)),
            (Word(0x65), .init(numerator: 1, denominator: 50)),
            (Word(0x68), .init(numerator: 1, denominator: 60)),
            (Word(0x6b), .init(numerator: 1, denominator: 80)),
            (Word(0x6d), .init(numerator: 1, denominator: 100)),
            (Word(0x70), .init(numerator: 1, denominator: 125)),
            (Word(0x73), .init(numerator: 1, denominator: 160)),
            (Word(0x75), .init(numerator: 1, denominator: 200)),
            (Word(0x78), .init(numerator: 1, denominator: 250)),
            (Word(0x7b), .init(numerator: 1, denominator: 320)),
            (Word(0x7d), .init(numerator: 1, denominator: 400)),
            (Word(0x80), .init(numerator: 1, denominator: 500)),
            (Word(0x83), .init(numerator: 1, denominator: 640)),
            (Word(0x85), .init(numerator: 1, denominator: 800)),
            (Word(0x88), .init(numerator: 1, denominator: 1000)),
            (Word(0x8b), .init(numerator: 1, denominator: 1250)),
            (Word(0x8d), .init(numerator: 1, denominator: 1600)),
            (Word(0x90), .init(numerator: 1, denominator: 2000)),
            (Word(0x93), .init(numerator: 1, denominator: 2500)),
            (Word(0x95), .init(numerator: 1, denominator: 3200)),
            (Word(0x98), .init(numerator: 1, denominator: 4000)),
            (Word(0x9a), .init(numerator: 1, denominator: 5000)),
            (Word(0x9d), .init(numerator: 1, denominator: 6400)),
            (Word(0xa0), .init(numerator: 1, denominator: 8000)),
            ("Hello World", nil)
        ]

        XCTAssertTrue(ShutterSpeed(value: Word(0x04), manufacturer: .canon)?.isBulb ?? false)

        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.1,
                ShutterSpeed(value: testCase.0, manufacturer: .canon)
            )
        }
    }

    func testShutterSpeedConvertsToDataCorrectly() throws {

        let testCases: [(Word, ShutterSpeed)] = [
            (Word(0x04), .bulb),
            (Word(0x10), .init(numerator: 30, denominator: 1)),
            (Word(0x13), .init(numerator: 25, denominator: 1)),
            (Word(0x15), .init(numerator: 20, denominator: 1)),
            (Word(0x18), .init(numerator: 15, denominator: 1)),
            (Word(0x1b), .init(numerator: 13, denominator: 1)),
            (Word(0x1d), .init(numerator: 10, denominator: 1)),
            (Word(0x20), .init(numerator: 8, denominator: 1)),
            (Word(0x23), .init(numerator: 6, denominator: 1)),
            (Word(0x25), .init(numerator: 5, denominator: 1)),
            (Word(0x28), .init(numerator: 4, denominator: 1)),
            (Word(0x2b), .init(numerator: 3.2, denominator: 1)),
            (Word(0x2d), .init(numerator: 2.5, denominator: 1)),
            (Word(0x30), .init(numerator: 2, denominator: 1)),
            (Word(0x32), .init(numerator: 1.6, denominator: 1)),
            (Word(0x35), .init(numerator: 1.3, denominator: 1)),
            (Word(0x38), .init(numerator: 1, denominator: 1)),
            (Word(0x3b), .init(numerator: 0.8, denominator: 1)),
            (Word(0x3d), .init(numerator: 0.6, denominator: 1)),
            (Word(0x40), .init(numerator: 0.5, denominator: 1)),
            (Word(0x43), .init(numerator: 0.4, denominator: 1)),
            (Word(0x45), .init(numerator: 0.3, denominator: 1)),
            (Word(0x48), .init(numerator: 1, denominator: 4)),
            (Word(0x4b), .init(numerator: 1, denominator: 5)),
            (Word(0x4d), .init(numerator: 1, denominator: 6)),
            (Word(0x50), .init(numerator: 1, denominator: 8)),
            (Word(0x53), .init(numerator: 1, denominator: 10)),
            (Word(0x55), .init(numerator: 1, denominator: 13)),
            (Word(0x58), .init(numerator: 1, denominator: 15)),
            (Word(0x5b), .init(numerator: 1, denominator: 20)),
            (Word(0x5d), .init(numerator: 1, denominator: 25)),
            (Word(0x60), .init(numerator: 1, denominator: 30)),
            (Word(0x63), .init(numerator: 1, denominator: 40)),
            (Word(0x65), .init(numerator: 1, denominator: 50)),
            (Word(0x68), .init(numerator: 1, denominator: 60)),
            (Word(0x6b), .init(numerator: 1, denominator: 80)),
            (Word(0x6d), .init(numerator: 1, denominator: 100)),
            (Word(0x70), .init(numerator: 1, denominator: 125)),
            (Word(0x73), .init(numerator: 1, denominator: 160)),
            (Word(0x75), .init(numerator: 1, denominator: 200)),
            (Word(0x78), .init(numerator: 1, denominator: 250)),
            (Word(0x7b), .init(numerator: 1, denominator: 320)),
            (Word(0x7d), .init(numerator: 1, denominator: 400)),
            (Word(0x80), .init(numerator: 1, denominator: 500)),
            (Word(0x83), .init(numerator: 1, denominator: 640)),
            (Word(0x85), .init(numerator: 1, denominator: 800)),
            (Word(0x88), .init(numerator: 1, denominator: 1000)),
            (Word(0x8b), .init(numerator: 1, denominator: 1250)),
            (Word(0x8d), .init(numerator: 1, denominator: 1600)),
            (Word(0x90), .init(numerator: 1, denominator: 2000)),
            (Word(0x93), .init(numerator: 1, denominator: 2500)),
            (Word(0x95), .init(numerator: 1, denominator: 3200)),
            (Word(0x98), .init(numerator: 1, denominator: 4000)),
            (Word(0x9a), .init(numerator: 1, denominator: 5000)),
            (Word(0x9d), .init(numerator: 1, denominator: 6400)),
            (Word(0xa0), .init(numerator: 1, denominator: 8000)),
        ]

        XCTAssertEqual(ShutterSpeed.dataType(for: .canon), .uint16)
        XCTAssertEqual(ShutterSpeed.devicePropertyCode(for: .canon), .shutterSpeedCanonEOS)

        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.0,
                testCase.1.value(for: .canon) as? Word
            )
        }
    }
}
