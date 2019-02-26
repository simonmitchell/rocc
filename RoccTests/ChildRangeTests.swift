//
//  FlatRangeTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 16/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import XCTest

class ChildRangeTests: XCTestCase {

    func testEmptyArrayReturnsEmptyArray() {
        let emptyArray: [Int] = []
        XCTAssertTrue(emptyArray.childRangesCovering(range: 0...2).isEmpty)
    }
    
    func testArrayOfEmptyArraysReturnsEmptyArray() {
        let emptyArray: [[Int]] = [[], [], []]
        XCTAssertTrue(emptyArray.childRangesCovering(range: 0...2).isEmpty)
    }
    
    func testRangeOutOfBoundsIsClampedCorrectly() {
        let emptyArray: [Int] = [1, 0, 0]
        let flatRange = emptyArray.childRangesCovering(range: 0...2)
        XCTAssertFalse(flatRange.isEmpty)
        XCTAssertEqual(flatRange.count, 1)
        XCTAssertEqual(flatRange.first?.element, 1)
        XCTAssertEqual(flatRange.first?.subRange.startIndex, 0)
        XCTAssertEqual(flatRange.first?.subRange.count, 1)
    }
    
    func testNonZeroBasedRangeReturnsCorrectly() {
        
        let stringArrays: [[String]] = [["a", "b", "c"], ["d", "e", "f", "g"], ["h"]]
        
        let flatRange = stringArrays.childRangesCovering(range: 1...4)
        
        XCTAssertFalse(flatRange.isEmpty)
        XCTAssertEqual(flatRange.count, 2)
        XCTAssertEqual(flatRange.first?.element, ["a", "b", "c"])
        XCTAssertEqual(flatRange.first?.subRange.startIndex, 1)
        XCTAssertEqual(flatRange.first?.subRange.count, 2)
        XCTAssertEqual(flatRange.last?.element, ["d", "e", "f", "g"])
        XCTAssertEqual(flatRange.last?.subRange.startIndex, 0)
        XCTAssertEqual(flatRange.last?.subRange.count, 3)
        
        let flattenedArray = stringArrays.enumerated().flatMap { (index, stringArray) -> [String] in
            guard let elementAndRange = flatRange.first(where: { $0.element == stringArray }) else {
                return []
            }
            return Array(elementAndRange.element[elementAndRange.subRange])
        }
        XCTAssertEqual(flattenedArray, ["b", "c", "d", "e", "f"])
    }
    
    func testRangeSkippingFirstElementReturnsCorrectly() {
        
        let stringArrays: [[String]] = [["a", "b", "c"], ["d", "e", "f", "g"], [], [], ["h"]]
        
        let flatRange = stringArrays.childRangesCovering(range: 4...7)
        
        XCTAssertFalse(flatRange.isEmpty)
        XCTAssertEqual(flatRange.count, 2)
        XCTAssertEqual(flatRange.first?.element, ["d", "e", "f", "g"])
        XCTAssertEqual(flatRange.first?.subRange.startIndex, 1)
        XCTAssertEqual(flatRange.first?.subRange.count, 3)
        XCTAssertEqual(flatRange.last?.element, ["h"])
        XCTAssertEqual(flatRange.last?.subRange.startIndex, 0)
        XCTAssertEqual(flatRange.last?.subRange.count, 1)
        
        let flattenedArray = stringArrays.enumerated().flatMap { (index, stringArray) -> [String] in
            guard let elementAndRange = flatRange.first(where: { $0.element == stringArray }) else {
                return []
            }
            return Array(elementAndRange.element[elementAndRange.subRange])
        }
        XCTAssertEqual(flattenedArray, ["e", "f", "g", "h"])
    }
    
    func testRangeTargetingEntiretyOfLastElementReturnsCorrectly() {
        
        let stringArrays: [[String]] = [["a", "b", "c"], ["d", "e", "f", "g"], [], ["h"]]
        
        let flatRange = stringArrays.childRangesCovering(range: 7...7)
        
        XCTAssertFalse(flatRange.isEmpty)
        XCTAssertEqual(flatRange.count, 1)
        XCTAssertEqual(flatRange.first?.element, ["h"])
        XCTAssertEqual(flatRange.first?.subRange.startIndex, 0)
        XCTAssertEqual(flatRange.first?.subRange.count, 1)
        
        let flattenedArray = stringArrays.enumerated().flatMap { (index, stringArray) -> [String] in
            guard let elementAndRange = flatRange.first(where: { $0.element == stringArray }) else {
                return []
            }
            return Array(elementAndRange.element[elementAndRange.subRange])
        }
        XCTAssertEqual(flattenedArray, ["h"])
    }
    
    func testRangeExtendingBeyondEndOfChildrenReturnsCorrectly() {
        
        let stringArrays: [[String]] = [["a", "b", "c"], ["d", "e", "f", "g"], [], ["h"]]
        
        let flatRange = stringArrays.childRangesCovering(range: 5...12)
        
        XCTAssertFalse(flatRange.isEmpty)
        XCTAssertEqual(flatRange.count, 2)
        XCTAssertEqual(flatRange.first?.element, ["d", "e", "f", "g"])
        XCTAssertEqual(flatRange.first?.subRange.startIndex, 2)
        XCTAssertEqual(flatRange.first?.subRange.count, 2)
        XCTAssertEqual(flatRange.last?.element, ["h"])
        XCTAssertEqual(flatRange.last?.subRange.startIndex, 0)
        XCTAssertEqual(flatRange.last?.subRange.count, 1)
        
        let flattenedArray = stringArrays.enumerated().flatMap { (index, stringArray) -> [String] in
            guard let elementAndRange = flatRange.first(where: { $0.element == stringArray }) else {
                return []
            }
            return Array(elementAndRange.element[elementAndRange.subRange])
        }
        XCTAssertEqual(flattenedArray, ["f", "g", "h"])
    }
    
    func testReturnsEntirelyContainedRangeCorrectly() {
        
        let intArray: [[Int]] = [
            [0],
            [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
            [15, 16],
            [17, 18, 19, 20, 21, 22],
            [23, 24, 25],
            [26, 27, 28, 29, 30, 31, 32, 33, 34],
            [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57],
            [58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79],
            [8]
        ]
        
        let flatRange = intArray.childRangesCovering(range: 49...56)
        
        XCTAssertFalse(flatRange.isEmpty)
        XCTAssertEqual(flatRange.count, 1)
        XCTAssertEqual(flatRange.first?.element, [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57])
        XCTAssertEqual(flatRange.first?.subRange.startIndex, 14)
        XCTAssertEqual(flatRange.first?.subRange.count, 8)
        
        let flattenedArray = intArray.enumerated().flatMap { (index, stringArray) -> [Int] in
            guard let elementAndRange = flatRange.first(where: { $0.element == stringArray }) else {
                return []
            }
            return Array(elementAndRange.element[elementAndRange.subRange])
        }
        XCTAssertEqual(flattenedArray, [49, 50, 51, 52, 53, 54, 55, 56])
    }
}
