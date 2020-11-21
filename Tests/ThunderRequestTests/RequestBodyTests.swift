//
//  BodyTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 15/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import XCTest
import Foundation
@testable import ThunderRequest

struct TestStruct {
    let body: String
}

struct CodableStruct: Codable {
    var integer: Int
    var double: Double
    var bool: Bool
    var date: Date
    var string: String
    var nullable: String?
    var stringArray: [String]
    var url: URL
    var dictionary: [String: String]
}

class RequestBodyTests: XCTestCase {
    
    func testCodableBodyCreatesDataCorrectly() {
        
        let codable = CodableStruct(
            integer: 123,
            double: 23.12,
            bool: true,
            date: Date(timeIntervalSince1970: 0),
            string: "Hello",
            nullable: nil,
            stringArray: ["Hello", "World"],
            url: URL(string: "https://www.google.co.uk")!,
            dictionary: [
                "Hello": "World"
            ]
        )
        
        let codableBody = EncodableRequestBody(codable, encoding: .json)
        let codableData = codableBody.payload()
        
        XCTAssertNotNil(codableData)
        XCTAssertEqual(codableData?.count, 188)
        XCTAssertEqual(codableBody.contentType, "application/json")
        XCTAssertEqual(String(data: codableData!, encoding: .utf8), "{\"double\":23.120000000000001,\"string\":\"Hello\",\"integer\":123,\"stringArray\":[\"Hello\",\"World\"],\"dictionary\":{\"Hello\":\"World\"},\"date\":-978307200,\"bool\":true,\"url\":\"https:\\/\\/www.google.co.uk\"}")
    }

    func testJSONBodyCreatesDataCorrectly() {
        
        let json = ["Hello": "World"]
        
        let jsonBody = JSONRequestBody(json)
        let jsonData = jsonBody.payload()
        
        XCTAssertNotNil(jsonData)
        XCTAssertEqual(jsonData?.count, 17)
        XCTAssertEqual(jsonBody.contentType, "application/json")
        XCTAssertEqual(String(data: jsonData!, encoding: .utf8), "{\"Hello\":\"World\"}")
    }
    
    func testJSONBodyFailsWithNonJSONParameters() {
        
        let json = ["Hello": TestStruct(body: "World")]
        
        let jsonBody = JSONRequestBody(json)
        let jsonData = jsonBody.payload()
        
        XCTAssertNil(jsonData)
        XCTAssertEqual(jsonBody.contentType, "application/json")
    }
    
    func testPlistBodyCreatesDataCorrectly() {
        
        let payload = ["Hello": "World"]
        
        let plistBody = PropertyListRequestBody(payload)
        let plistData = plistBody.payload()
        
        XCTAssertNotNil(plistData)
        XCTAssertEqual(plistData?.count, 230)
        XCTAssertEqual(plistBody.contentType, "text/x-xml-plist")
        XCTAssertEqual(String(data: plistData!, encoding: .utf8), "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>Hello</key>\n\t<string>World</string>\n</dict>\n</plist>\n")
    }
    
    func testBinaryPlistBodyCreatesDataCorrectly() {
        
        let payload = ["Hello": "World"]
        
        let plistBody = PropertyListRequestBody(payload, format: .binary)
        let plistData = plistBody.payload()
        
        XCTAssertNotNil(plistData)
        XCTAssertEqual(plistData?.count, 58)
        XCTAssertEqual(plistBody.contentType, "application/x-plist")
        XCTAssertEqual(Data(plistData![0...4]), Data([
            98,
            112,
            108,
            105,
            115
        ]))
    }
    
    func testPlistBodyFailsWithNonPlistParameters() {
        
        let payload = ["Hello": TestStruct(body: "World")]
        
        let plistBody = PropertyListRequestBody(payload)
        let plistData = plistBody.payload()
        
        XCTAssertNil(plistData)
        XCTAssertEqual(plistBody.contentType, "text/x-xml-plist")
    }
    
    func testFormURLEncodedRequestBodyCreatesDataCorrectly() {
        
        let formURLEncodedBody = FormURLEncodedRequestBody(["hello":"world", "bool": true])
        XCTAssertEqual(formURLEncodedBody.contentType, "application/x-www-form-urlencoded")
        
        let urlEncodedData = formURLEncodedBody.payload()
        XCTAssertEqual(urlEncodedData?.count, 21)
        XCTAssertNotNil(urlEncodedData)
        XCTAssertTrue(["bool=true&hello=world", "hello=world&bool=true"].contains(String(data: urlEncodedData!, encoding: .utf8)!))
    }
    
    func testDataBodyCreatesDataCorrectly() {
        
        guard let fileURL = Bundle(for: RequestBodyTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Failed to get url for test png")
        }
        guard let data = try? Data(contentsOf: fileURL) else {
            fatalError("Failed to get data from test png file")
        }
        
        let payload = data.payload()
        XCTAssertNotNil(payload)
        XCTAssertEqual(data.contentType, "image/png")
        XCTAssertEqual(data, payload)
    }
}
