//
//  ShutterSpeedFormatterTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 27/11/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class ShutterSpeedFormatterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFractionParses() {
        
        let formatter = ShutterSpeedFormatter()
        
        let fractionString = "20/30"
        let shutterSpeed = formatter.shutterSpeed(from: fractionString)
        XCTAssertEqual(shutterSpeed?.numerator, 20.0)
        XCTAssertEqual(shutterSpeed?.denominator, 30.0)
        XCTAssertEqual(shutterSpeed?.value, 20.0/30.0)
    }

    func testFractionWithWhitespaceParses() {
        
        let formatter = ShutterSpeedFormatter()
        
        let fractionString = "\t20/30 \n"
        let shutterSpeed = formatter.shutterSpeed(from: fractionString)
        XCTAssertEqual(shutterSpeed?.numerator, 20.0)
        XCTAssertEqual(shutterSpeed?.denominator, 30.0)
        XCTAssertEqual(shutterSpeed?.value, 20.0/30.0)
    }
    
    func testParsesWithoutQuotes() {
        
        let formatter = ShutterSpeedFormatter()
        
        let string = "23.5"
        let shutterSpeed = formatter.shutterSpeed(from: string)
        XCTAssertEqual(shutterSpeed?.numerator, 23.5)
        XCTAssertEqual(shutterSpeed?.denominator, 1)
        XCTAssertEqual(shutterSpeed?.value, 23.5)
    }
    
    func testParsesWithQuotes() {
        
        let formatter = ShutterSpeedFormatter()
        
        let string = "10\""
        let shutterSpeed = formatter.shutterSpeed(from: string)
        XCTAssertEqual(shutterSpeed?.numerator, 10.0)
        XCTAssertEqual(shutterSpeed?.denominator, 1.0)
        XCTAssertEqual(shutterSpeed?.value, 10)
    }
    
    func testIntegerFormatsWithQuotes() {
        
        let formatter = ShutterSpeedFormatter()
        let shutterSpeed = ShutterSpeed(numerator: 10, denominator: 1)
        let formatted = formatter.string(from: shutterSpeed)
        XCTAssertEqual(formatted, "10\"")
    }
    
    func testIntegerFormatsWithoutQuotes() {
        
        let formatter = ShutterSpeedFormatter()
        formatter.formattingOptions = []
        let shutterSpeed = ShutterSpeed(numerator: 10, denominator: 1)
        let formatted = formatter.string(from: shutterSpeed)
        XCTAssertEqual(formatted, "10")
    }
    
    func testFractionalFormats() {
        
        let formatter = ShutterSpeedFormatter()
        let shutterSpeed = ShutterSpeed(numerator: 1, denominator: 3000)
        let formatted = formatter.string(from: shutterSpeed)
        XCTAssertEqual(formatted, "1/3000")
    }
    
    func testFractionalParsesThenFormatsCorrectly() {
        
        let formatter = ShutterSpeedFormatter()
        let string = "1/3000"
        let shutterSpeed = formatter.shutterSpeed(from: string)
        let formatted = formatter.string(from: shutterSpeed!)
        XCTAssertEqual(formatted, string)
    }
    
    func testForceIntFormatsToDoublesCorrectly() {
        
        let formatter = ShutterSpeedFormatter()
        formatter.formattingOptions = [.appendQuotes, .forceIntegersToDouble]
        let string = "1.0/3000.0"
        let shutterSpeed = formatter.shutterSpeed(from: string)
        let formatted = formatter.string(from: shutterSpeed!)
        XCTAssertEqual(formatted, "1.0/3000.0")
    }
    
    func testNonIntegarFractionalParsesThenFormatsCorrectly() {
        
        let formatter = ShutterSpeedFormatter()
        let string = "3.4/3000"
        let shutterSpeed = formatter.shutterSpeed(from: string)
        let formatted = formatter.string(from: shutterSpeed!)
        XCTAssertEqual(formatted, string)
    }
    
    func testLargerThan1FormatsCorrectly() {
        
        let formatter = ShutterSpeedFormatter()
        
        let speeds: [ShutterSpeed] = [
            .init(numerator: 1, denominator: 8000), .init(numerator: 1, denominator: 6400), .init(numerator: 1, denominator: 5000),
            .init(numerator: 1, denominator: 4000), .init(numerator: 1, denominator: 3200), .init(numerator: 1, denominator: 2500),
            .init(numerator: 1, denominator: 2000), .init(numerator: 1, denominator: 1600), .init(numerator: 4, denominator: 10),
            .init(numerator: 10, denominator: 10), .init(numerator: 13, denominator: 10), .init(numerator: 16, denominator: 10),
            .init(numerator: 20, denominator: 10), .init(numerator: 80, denominator: 10), .init(numerator: 100, denominator: 10),
            .init(numerator: 130, denominator: 10), .init(numerator: 250, denominator: 10), .init(numerator: 300, denominator: 10)
        ]
        let formatted = speeds.map({ formatter.string(from: $0) })
        XCTAssertEqual(formatted, [
            "1/8000", "1/6400", "1/5000", "1/4000", "1/3200", "1/2500", "1/2000", "1/1600", "0.4\"", "1\"", "1.3\"", "1.6\"", "2\"",
            "8\"", "10\"", "13\"","25\"", "30\""
        ])
    }
}
