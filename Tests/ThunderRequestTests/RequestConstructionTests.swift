//
//  RequestConstructionTests.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 24/07/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderRequest

class RequestConstructionTests: XCTestCase {
    
    static let testURL = URL(string: "https://www.google.co.uk/")!

    func testNilQueryItemsDoesntAppendQuestionMark() {
        
        let request = Request(baseURL: RequestConstructionTests.testURL, path: "home", method: .GET, queryItems: nil)
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/home")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testNilQueryItemsAndSpaceInPathDoesntAppendQuestionMark() {
        let request = Request(baseURL: RequestConstructionTests.testURL, path: " ", method: .GET, queryItems: nil)
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/%20")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testEmptyQueryItemsAppendsQuestionMark() {
        
        let request = Request(baseURL: RequestConstructionTests.testURL, path: "home", method: .GET, queryItems: [])
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/home?")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testUrlParametersArePulledFromBaseURLWhenNilQueryItemsProvided() {
        
        let url = URL(string: "https://www.google.co.uk/search?term=pie")!
        let request = Request(baseURL: url, path: "", method: .GET, queryItems: nil)
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/search?term=pie")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testUrlParametersArePulledFromBaseURLWhenEmptyQueryItemsProvided() {
        
        let url = URL(string: "https://www.google.co.uk/search?term=pie")!
        let request = Request(baseURL: url, path: "", method: .GET, queryItems: [])
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/search?term=pie")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testUrlParametersArePulledFromPathWhenNilQueryItemsProvided() {
        
        let url = URL(string: "https://www.google.co.uk/")!
        let request = Request(baseURL: url, path: "search?term=pie", method: .GET, queryItems: nil)
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/search?term=pie")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testUrlParametersArePulledFromPathWhenEmptyQueryItemsProvided() {
        
        let url = URL(string: "https://www.google.co.uk/")!
        let request = Request(baseURL: url, path: "search?term=pie", method: .GET, queryItems: [])
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/search?term=pie")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testUrlParametersArePulledFromQueryItemsWhenBaseURLProvided() {
        
        let url = URL(string: "https://www.google.co.uk/search")!
        let request = Request(baseURL: url, path: "", method: .GET, queryItems: [URLQueryItem(name: "term", value: "pie")])
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/search?term=pie")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testUrlParametersArePulledFromQueryItemsWhenPathProvided() {
        
        let url = URL(string: "https://www.google.co.uk/")!
        let request = Request(baseURL: url, path: "search", method: .GET, queryItems: [URLQueryItem(name: "term", value: "pie")])
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/search?term=pie")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testUrlParametersArePulledFromMultipleQueryItemsWhenPathProvided() {
        
        let url = URL(string: "https://www.google.co.uk/")!
        let request = Request(baseURL: url, path: "search", method: .GET, queryItems: [
            URLQueryItem(name: "term", value: "pie"),
            URLQueryItem(name: "test", value: "2")
        ])
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/search?term=pie&test=2")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
    
    func testUrlParametersAreSupplementary() {
        
        let url = URL(string: "https://www.google.co.uk/")!
        let request = Request(baseURL: url, path: "search?term=pie", method: .GET, queryItems: [URLQueryItem(name: "test", value: "2")])
        do {
            let urlRequest = try request.construct()
            XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.google.co.uk/search?test=2&term=pie")
        } catch let error {
            XCTFail("Failed to construct request object \(error)")
        }
    }
}
