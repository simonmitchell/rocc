//
//  AsyncWhileTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 19/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class AsyncWhileTests: XCTestCase {

    func testTimeoutCalledBeforeBreaking() {
        
        var continueCalls: Int = 0
        let expectation = XCTestExpectation(description: "timeout called")
        
        DispatchQueue.global().asyncWhile({ (continueClosure) in
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.2) {
                continueCalls += 1
                continueClosure(true)
            }
            
        }, timeout: 1.0) {
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(continueCalls, 0)
    }
    
    func testWhileClosureCalledAppropriateNumberOfTimes() {
        
        let expectation = XCTestExpectation(description: "timeout called")
        var calls: Int = 0
        
        DispatchQueue.global().asyncWhile({ (continueClosure) in
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                calls += 1
                continueClosure(false)
            }
            
        }, timeout: 2.1) {
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(calls, 10)
    }
    
    func testCallingContinueWithTrueBreaksWhile() {
        
        let expectation = XCTestExpectation(description: "timeout called")
        var calls: Int = 0
        
        DispatchQueue.global().asyncWhile({ (continueClosure) in
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                calls += 1
                continueClosure(true)
            }
            
        }, timeout: 2.1) {
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(calls, 1)
    }
    
    func testWhileClosureCalledOnMainThread() {
        
        let expectation = XCTestExpectation(description: "timeout called")
        
        DispatchQueue.global().asyncWhile({ (continueClosure) in
            
            XCTAssertEqual(Thread.current.isMainThread, true)
            
        }, timeout: 0.2) {
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.3)
    }
    
    func testDoneClosureCalledOnMainThread() {
        
        let expectation = XCTestExpectation(description: "timeout called")
        
        DispatchQueue.global().asyncWhile({ (continueClosure) in
            
            
        }, timeout: 0.2) {
            
            XCTAssertEqual(Thread.current.isMainThread, true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.3)
    }
    
    func testDoneClosureCalledAfterTimeoutWithoutCallingContinue() {
        
        let expectation = XCTestExpectation(description: "timeout called")
        
        DispatchQueue.global().asyncWhile({ (continueClosure) in
            
            
        }, timeout: 0.2) {
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.3)
    }
}
