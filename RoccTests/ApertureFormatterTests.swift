//
//  ApertureParsingTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 23/05/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

import XCTest

class ApertureFormatterTests: XCTestCase {

    func testIntegerParsesCorrectly() {
        
        let formatter = ApertureFormatter()
        let aperture = formatter.aperture(from: "12")
        
        XCTAssertNotNil(aperture)
        XCTAssertNil(aperture?.decimalSeperator)
        XCTAssertEqual(aperture?.value, 12)
    }
    
    func testDecimalParsesCorrectly() {
        
        let formatter = ApertureFormatter()
        let aperture = formatter.aperture(from: "5.6")
        
        XCTAssertNotNil(aperture)
        XCTAssertEqual(aperture?.decimalSeperator, ".")
        XCTAssertEqual(aperture?.value, 5.6)
    }
    
    func testCommaSeperatedDecimalParsesCorrectly() {
        
        let formatter = ApertureFormatter()
        let aperture = formatter.aperture(from: "5,6")
        
        XCTAssertNotNil(aperture)
        XCTAssertEqual(aperture?.decimalSeperator, ",")
        XCTAssertEqual(aperture?.value, 5.6)
    }
    
    func testValuesReformatCorrectly() {
        
        let formatter = ApertureFormatter()
        
        let values: [String] = [
            "12",
            "19",
            "5.6",
            "9.0",
            "5,6",
            "9,0"
        ]
        
        let results = values.compactMap { (string) -> Aperture.Value? in
            return formatter.aperture(from: string)
        }.compactMap { (aperture) -> String? in
            return formatter.string(for: aperture)
        }
        
        XCTAssertEqual(values, results)
    }
}
