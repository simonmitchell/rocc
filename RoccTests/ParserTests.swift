//
//  ParserTests.swift
//  CamroteTests
//
//  Created by Simon Mitchell on 14/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import XCTest

class ParserTests: XCTestCase {

    func testCDSDescriptionParsesAsUPnPDeviceCorrectly() {
        
        guard let xmlURL = Bundle(for: ParserTests.self).url(forResource: "CdsDesc", withExtension: "xml") else {
            XCTFail("Failed find CdsDesc.xml in the test bundle")
            return
        }
        guard let xmlString = try? String(contentsOf: xmlURL) else {
            XCTFail("Failed to allocate xml string from test file CdSDesc.xml")
            return
        }
        
        let finishExpectation = expectation(description: "Device Parser")
        
        let deviceParser = UPnPDeviceParser(xmlString: xmlString, type: UPnPDevice.DeviceType.contentDirectory)
        deviceParser.parse { (device, error) in
            
            XCTAssertNotNil(device)
            XCTAssertEqual(device?.stateVariables.count, 11)
            
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "A_ARG_TYPE_ObjectID" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "A_ARG_TYPE_Result" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "A_ARG_TYPE_BrowseFlag" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "A_ARG_TYPE_Filter" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "A_ARG_TYPE_SortCriteria" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "A_ARG_TYPE_Index" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "A_ARG_TYPE_Count" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "A_ARG_TYPE_UpdateID" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "SearchCapabilities" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "SortCapabilities" }), true)
            XCTAssertEqual(device?.stateVariables.contains(where: { $0.name == "SystemUpdateID" }), true)
            
            XCTAssertEqual(device?.actions.count, 4)
            XCTAssertEqual(device?.actions.contains(where: { $0.name == "GetSearchCapabilities" }), true)
            XCTAssertEqual(device?.actions.contains(where: { $0.name == "GetSortCapabilities" }), true)
            XCTAssertEqual(device?.actions.contains(where: { $0.name == "GetSystemUpdateID" }), true)
            XCTAssertEqual(device?.actions.contains(where: { $0.name == "Browse" }), true)
            
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35) { (error) -> Void in
            XCTAssertNil(error, "The parser timed out")
        }
    }
}
