//
//  PTPDevicePropertyTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 08/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class PTPDevicePropertyTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDevicePropertyHeaderParsesCorrectly() {
        
        let headerData = ByteBuffer(hexString: "05 50 04 00 01 01 00 00 01 00 02")
        guard let header = headerData.getDevicePropHeader() else {
            XCTFail("Failed to parse device property header")
            return
        }
        
        XCTAssertEqual(header.dataType, .uint16)
        XCTAssertFalse(header.isRange)
        XCTAssertEqual(header.code, .whiteBalance)
        XCTAssertEqual(header.length, 11)
        XCTAssertEqual(header.getSet, .getSet)
    }

    func testIncorrectDataTypeFailsParsing() {
        let headerData = ByteBuffer(hexString: "05 50 06 00 01 01 00 00 01 00 02")
        XCTAssertNil(headerData.getDevicePropHeader())
    }
    
    func testUnknownPropertyTypeFailsParsing() {
        let headerData = ByteBuffer(hexString: "01 10 04 00 01 01 00 00 01 00 02")
        XCTAssertNil(headerData.getDevicePropHeader())
    }
    
    func testUnknownDataTypeFailsParsing() {
        let headerData = ByteBuffer(hexString: "05 50 08 00 01 01 00 00 01 00 02")
        XCTAssertNil(headerData.getDevicePropHeader())
    }
    
    func testNotEnoughDataFailsParsing() {
        let headerData = ByteBuffer(hexString: "05 50 04 00 01 01 00")
        XCTAssertNil(headerData.getDevicePropHeader())
    }
    
    func testEnumDevicePropertyParses() {
        let data = ByteBuffer(hexString: """
                05 50
                04 00
                01 01
                00 00
                02 00
                02
                0f 00
                02 00 04 00 11 80 10 80 06 00 01
                80 02 80 03 80 04 80 07 00 30 80 12 80 20 80 21
                80 22 80
                0f 00
                02 00 04 00 11 80 10 80 06 00 01
                80 02 80 03 80 04 80 07 00 30 80 12 80 20 80 21
                80 22 80
            """
        )
        guard let property = data.getDeviceProperty(at: 0) else {
            XCTFail("Failed to parse device property")
            return
        }
        XCTAssertEqual(property.type, .uint16)
        XCTAssertEqual(property.code, .whiteBalance)
        if let uint16Current = property.currentValue as? UInt16 {
            XCTAssertEqual(uint16Current, 0x0002)
        } else {
            XCTFail("Current value has incorrect type")
        }
        
        if let uint16Factory = property.factoryValue as? UInt16 {
            XCTAssertEqual(uint16Factory, 0x0000)
        } else {
            XCTFail("Current value has incorrect type")
        }
        
        guard let enumProperty = property as? PTP.DeviceProperty.Enum else {
            XCTFail("Property allocated as incorrect type")
            return
        }
        
        XCTAssertEqual(enumProperty.available.count, 15)
        XCTAssertEqual(enumProperty.supported.count, 15)
        XCTAssertEqual(enumProperty.length, 75)
        
        if let uint16Available = enumProperty.available as? [UInt16] {
            XCTAssertEqual(uint16Available, [0x0002, 0x0004, 0x8011, 0x8010, 0x0006, 0x8001,
                                             0x8002, 0x8003, 0x8004, 0x0007, 0x8030, 0x8012,
                                             0x8020, 0x8021, 0x8022])
        } else {
            XCTFail("Available values has incorrect type")
        }
        
        if let uint16Supported = enumProperty.supported as? [UInt16] {
            XCTAssertEqual(uint16Supported, [0x0002, 0x0004, 0x8011, 0x8010, 0x0006, 0x8001,
                                             0x8002, 0x8003, 0x8004, 0x0007, 0x8030, 0x8012,
                                             0x8020, 0x8021, 0x8022])
        } else {
            XCTFail("Available values has incorrect type")
        }
    }
    
    func testEnumDevicePropertyParsesAtNonZeroIndex() {
        let data = ByteBuffer(hexString: """
                48 00 00 00 00 00 00 00
                05 50
                04 00
                01 01
                00 00
                02 00
                02
                0f 00
                02 00 04 00 11 80 10 80 06 00 01
                80 02 80 03 80 04 80 07 00 30 80 12 80 20 80 21
                80 22 80
                0f 00
                02 00 04 00 11 80 10 80 06 00 01
                80 02 80 03 80 04 80 07 00 30 80 12 80 20 80 21
                80 22 80
            """
        )
        guard let property = data.getDeviceProperty(at: 8) else {
            XCTFail("Failed to parse device property")
            return
        }
        XCTAssertEqual(property.type, .uint16)
        XCTAssertEqual(property.code, .whiteBalance)
        if let uint16Current = property.currentValue as? UInt16 {
            XCTAssertEqual(uint16Current, 0x0002)
        } else {
            XCTFail("Current value has incorrect type")
        }
        
        if let uint16Factory = property.factoryValue as? UInt16 {
            XCTAssertEqual(uint16Factory, 0x0000)
        } else {
            XCTFail("Current value has incorrect type")
        }
        
        guard let enumProperty = property as? PTP.DeviceProperty.Enum else {
            XCTFail("Property allocated as incorrect type")
            return
        }
        
        XCTAssertEqual(enumProperty.available.count, 15)
        XCTAssertEqual(enumProperty.supported.count, 15)
        XCTAssertEqual(enumProperty.length, 75)
        
        if let uint16Available = enumProperty.available as? [UInt16] {
            XCTAssertEqual(uint16Available, [0x0002, 0x0004, 0x8011, 0x8010, 0x0006, 0x8001,
                                             0x8002, 0x8003, 0x8004, 0x0007, 0x8030, 0x8012,
                                             0x8020, 0x8021, 0x8022])
        } else {
            XCTFail("Available values has incorrect type")
        }
        
        if let uint16Supported = enumProperty.supported as? [UInt16] {
            XCTAssertEqual(uint16Supported, [0x0002, 0x0004, 0x8011, 0x8010, 0x0006, 0x8001,
                                             0x8002, 0x8003, 0x8004, 0x0007, 0x8030, 0x8012,
                                             0x8020, 0x8021, 0x8022])
        } else {
            XCTFail("Available values has incorrect type")
        }
    }
    
    func testRangeDevicePropertyParses() {
        let data = ByteBuffer(hexString: """
                0f d2
                04 00
                01 00
                00 00
                c4 09
                01
                c4 09
                ac 26
                64 00
            """
        )
        guard let property = data.getDeviceProperty(at: 0) else {
            XCTFail("Failed to parse device property")
            return
        }
        XCTAssertEqual(property.type, .uint16)
        XCTAssertEqual(property.code, .colorTemp)
        if let uint16Current = property.currentValue as? UInt16 {
            XCTAssertEqual(uint16Current, 2500)
        } else {
            XCTFail("Current value has incorrect type")
        }
        
        if let uint16Factory = property.factoryValue as? UInt16 {
            XCTAssertEqual(uint16Factory, 0)
        } else {
            XCTFail("Current value has incorrect type")
        }
        
        guard let rangeProperty = property as? PTP.DeviceProperty.Range else {
            XCTFail("Property allocated as incorrect type")
            return
        }
        
        XCTAssertEqual(rangeProperty.length, 17)
        
        if let minValue = rangeProperty.min as? UInt16 {
            XCTAssertEqual(minValue, 2500)
        } else {
            XCTFail("Available values has incorrect type")
        }
        
        if let maxValue = rangeProperty.max as? UInt16 {
            XCTAssertEqual(maxValue, 9900)
        } else {
            XCTFail("Available values has incorrect type")
        }
        
        if let stepValue = rangeProperty.step as? UInt16 {
            XCTAssertEqual(stepValue, 100)
        } else {
            XCTFail("Available values has incorrect type")
        }
    }
}
