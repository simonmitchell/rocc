//
//  SonyPTPPropConversionTests.swift
//  RoccTests
//
//  Created by Simon Mitchell on 11/10/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import XCTest
@testable import Rocc

class SonyPTPPropConversionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testApertureInitialisedCorrectly() throws {
        
        let testCases: [(PTPDevicePropertyDataType, Aperture.Value?)] = [
            (Word(280), Aperture.Value(value: 2.8, decimalSeperator: nil)),
            (Word(300), Aperture.Value(value: 3.0, decimalSeperator: nil)),
            (Word(2000), Aperture.Value(value: 20.0, decimalSeperator: nil)),
            ("Hello World", nil)
        ]
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.1,
                Aperture.Value(sonyValue: testCase.0)
            )
        }
    }
    
    func testApertureConvertsToDataCorrectly() throws {
        
        let testCases: [(Word, Aperture.Value)] = [
            (280, Aperture.Value(value: 2.8, decimalSeperator: nil)),
            (300, Aperture.Value(value: 3.0, decimalSeperator: nil)),
            (2000, Aperture.Value(value: 20.0, decimalSeperator: nil)),
        ]
        
        XCTAssertEqual(testCases.first?.1.type, .uint16)
        XCTAssertEqual(testCases.first?.1.code, .fNumber)
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.0,
                testCase.1.sonyPTPValue as? Word
            )
        }
    }
    
    func testExposureCompensationInitialisedCorrectly() throws {
        
        let testCases: [(PTPDevicePropertyDataType, Exposure.Compensation.Value?)] = [
            (Int16(1300), Exposure.Compensation.Value(value: 1.3)),
            (Int16(300), Exposure.Compensation.Value(value: 0.3)),
            (Int16(2000), Exposure.Compensation.Value(value: 2.0)),
            ("Hello World", nil)
        ]
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.1,
                Exposure.Compensation.Value(sonyValue: testCase.0)
            )
        }
    }
    
    func testExposureCompensationConvertsToDataCorrectly() throws {
        
        let testCases: [(Int16, Exposure.Compensation.Value)] = [
            (Int16(1300), Exposure.Compensation.Value(value: 1.3)),
            (Int16(300), Exposure.Compensation.Value(value: 0.3)),
            (Int16(2000), Exposure.Compensation.Value(value: 2.0)),
        ]
        
        XCTAssertEqual(testCases.first?.1.type, .int16)
        XCTAssertEqual(testCases.first?.1.code, .exposureBiasCompensation)
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.0,
                testCase.1.sonyPTPValue as? Int16
            )
        }
    }
    
    func testExposureSettingsLockInitialisedCorrectly() throws {
        
        let testCases: [(PTPDevicePropertyDataType, Exposure.SettingsLock.Status?)] = [
            (Byte(0x01), .normal),
            (Byte(0x02), .standby),
            (Byte(0x03), .locked),
            (Byte(0x04), .buffering),
            (Byte(0x05), .recording),
            ("Hello World", nil)
        ]
        
        // Make sure all enum cases are tested for
        XCTAssertEqual(
            Exposure.SettingsLock.Status.allCases,
            testCases.compactMap({ $0.1 }),
            "Missing Exposure.SettingsLock.Status in test cases"
        )
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.1,
                Exposure.SettingsLock.Status(sonyValue: testCase.0)
            )
        }
    }
    
    func testExposureSettingsLockConvertsToDataCorrectly() throws {
        
        let testCases: [(Byte, Exposure.SettingsLock.Status)] = [
            (Byte(0x01), .normal),
            (Byte(0x02), .standby),
            (Byte(0x03), .locked),
            (Byte(0x04), .buffering),
            (Byte(0x05), .recording)
        ]
        
        // Make sure all enum cases are tested for
        XCTAssertEqual(
            Exposure.SettingsLock.Status.allCases,
            testCases.compactMap({ $0.1 }),
            "Missing Exposure.SettingsLock.Status in test cases"
        )
        
        XCTAssertEqual(testCases.first?.1.type, .uint8)
        XCTAssertEqual(testCases.first?.1.code, .exposureSettingsLock)
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.0,
                testCase.1.sonyPTPValue as? Byte
            )
        }
    }
    
    func testExposureProgrammeModeInitialisedCorrectly() throws {
        
        let testCases: [(PTPDevicePropertyDataType, Exposure.Mode.Value?)] = [
            (DWord(0x00010002), .programmedAuto),
            (DWord(0x00020003), .aperturePriority),
            (DWord(0x00030004), .shutterPriority),
            (DWord(0x000000001), .manual),
            (DWord(0x00068041), .panorama),
            (DWord(0x00078050), .videoProgrammedAuto),
            (DWord(0x00078051), .videoAperturePriority),
            (DWord(0x00078052), .videoShutterPriority),
            (DWord(0x00078053), .videoManual),
            (DWord(0x00098059), .slowAndQuickProgrammedAuto),
            (DWord(0x0009805a), .slowAndQuickAperturePriority),
            (DWord(0x0009805b), .slowAndQuickShutterPriority),
            (DWord(0x0009805c), .slowAndQuickManual),
            (DWord(0x00048000), .intelligentAuto),
            (DWord(0x00048001), .superiorAuto),
            (DWord(0x00088080), .highFrameRateProgrammedAuto),
            (DWord(0x00088081), .highFrameRateAperturePriority),
            (DWord(0x00088082), .highFrameRateShutterPriority),
            (DWord(0x00088083), .highFrameRateManual),
            (DWord(0x00000007), .scene(.portrait)),
            (DWord(0x00058011), .scene(.sport)),
            (DWord(0x00058012), .scene(.sunset)),
            (DWord(0x00058013), .scene(.night)),
            (DWord(0x00058014), .scene(.landscape)),
            (DWord(0x00058015), .scene(.macro)),
            (DWord(0x00058016), .scene(.handheldTwilight)),
            (DWord(0x00058017), .scene(.nightPortrait)),
            (DWord(0x00058018), .scene(.antiMotionBlur)),
            (DWord(0x00058019), .scene(.pet)),
            (DWord(0x0005801a), .scene(.food)),
            (DWord(0x0005801b), .scene(.fireworks)),
            (DWord(0x0005801c), .scene(.highSensitivity)),
            ("Hello World", nil)
        ]
        
        // TODO: Make sure all enum cases are tested for
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.1,
                Exposure.Mode.Value(sonyValue: testCase.0)
            )
        }
    }
    
    func testExposureProgrammeModeConvertsToDataCorrectly() throws {
        
        let testCases: [(DWord, Exposure.Mode.Value)] = [
            (DWord(0x00010002), .programmedAuto),
            (DWord(0x00020003), .aperturePriority),
            (DWord(0x00030004), .shutterPriority),
            (DWord(0x000000001), .manual),
            (DWord(0x00068041), .panorama),
            (DWord(0x00078050), .videoProgrammedAuto),
            (DWord(0x00078051), .videoAperturePriority),
            (DWord(0x00078052), .videoShutterPriority),
            (DWord(0x00078053), .videoManual),
            (DWord(0x00098059), .slowAndQuickProgrammedAuto),
            (DWord(0x0009805a), .slowAndQuickAperturePriority),
            (DWord(0x0009805b), .slowAndQuickShutterPriority),
            (DWord(0x0009805c), .slowAndQuickManual),
            (DWord(0x00048000), .intelligentAuto),
            (DWord(0x00048001), .superiorAuto),
            (DWord(0x00088080), .highFrameRateProgrammedAuto),
            (DWord(0x00088081), .highFrameRateAperturePriority),
            (DWord(0x00088082), .highFrameRateShutterPriority),
            (DWord(0x00088083), .highFrameRateManual),
            (DWord(0x00000007), .scene(.portrait)),
            (DWord(0x00058011), .scene(.sport)),
            (DWord(0x00058012), .scene(.sunset)),
            (DWord(0x00058013), .scene(.night)),
            (DWord(0x00058014), .scene(.landscape)),
            (DWord(0x00058015), .scene(.macro)),
            (DWord(0x00058016), .scene(.handheldTwilight)),
            (DWord(0x00058017), .scene(.nightPortrait)),
            (DWord(0x00058018), .scene(.antiMotionBlur)),
            (DWord(0x00058019), .scene(.pet)),
            (DWord(0x0005801a), .scene(.food)),
            (DWord(0x0005801b), .scene(.fireworks)),
            (DWord(0x0005801c), .scene(.highSensitivity)),
        ]
        
        XCTAssertEqual(testCases.first?.1.type, .uint32)
        XCTAssertEqual(testCases.first?.1.code, .exposureProgramMode)
        
        // TODO: Make sure all enum cases are tested for
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.0,
                testCase.1.sonyPTPValue as? DWord
            )
        }
    }
    
    func testVideoCaptureFormatInitialisedCorrectly() throws {
        
        let testCases: [(PTPDevicePropertyDataType, VideoCapture.FileFormat.Value?)] = [
            (Byte(0x00), VideoCapture.FileFormat.Value.none),
            (Byte(0x01), .dvd),
            (Byte(0x02), .m2ps),
            (Byte(0x03), .avchd),
            (Byte(0x04), .mp4),
            (Byte(0x05), .dv),
            (Byte(0x06), .xavc),
            (Byte(0x07), .mxf),
            (Byte(0x08), .xavc_s_4k),
            (Byte(0x09), .xavc_s_hd),
            (Byte(0x0a), .xavc_hs_8k),
            (Byte(0x0b), .xavc_hs_4k),
            (Byte(0x0c), .xavc_s_4k_alt),
            (Byte(0x0d), .xavc_s_hd_alt),
            (Byte(0x0e), .xavc_si_4k),
            (Byte(0x0f), .xavc_si_hd),
            ("Hello World", nil)
        ]
        
        // Make sure all enum cases are tested for
        XCTAssertEqual(
            VideoCapture.FileFormat.Value.allCases.filter({ $0 != .xavc_s }),
            testCases.compactMap({ $0.1 }),
            "Missing VideoCapture.FileFormat.Value in test cases"
        )
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.1,
                VideoCapture.FileFormat.Value(sonyValue: testCase.0)
            )
        }
    }
    
    func testVideoCaptureFormatConvertsToDataCorrectly() throws {
        
        let testCases: [(Byte, VideoCapture.FileFormat.Value)] = [
            (Byte(0x00), VideoCapture.FileFormat.Value.none),
            (Byte(0x01), .dvd),
            (Byte(0x02), .m2ps),
            (Byte(0x03), .avchd),
            (Byte(0x04), .mp4),
            (Byte(0x05), .dv),
            (Byte(0x06), .xavc),
            (Byte(0x07), .mxf),
            (Byte(0x08), .xavc_s_4k),
            (Byte(0x09), .xavc_s_hd),
            (Byte(0x06), .xavc_s),
            (Byte(0x0a), .xavc_hs_8k),
            (Byte(0x0b), .xavc_hs_4k),
            (Byte(0x0c), .xavc_s_4k_alt),
            (Byte(0x0d), .xavc_s_hd_alt),
            (Byte(0x0e), .xavc_si_4k),
            (Byte(0x0f), .xavc_si_hd)
        ]
        
        XCTAssertEqual(testCases.first?.1.type, .uint8)
        XCTAssertEqual(testCases.first?.1.code, .movieFormat)
        
        // Make sure all enum cases are tested for
        XCTAssertEqual(
            VideoCapture.FileFormat.Value.allCases,
            testCases.compactMap({ $0.1 }),
            "Missing VideoCapture.FileFormat.Value in test cases"
        )
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.0,
                testCase.1.sonyPTPValue as? Byte
            )
        }
    }
    
    func testVideoCaptureQualityInitialisedCorrectly() throws {
        
        let testCases: [(PTPDevicePropertyDataType, VideoCapture.Quality.Value?)] = [
            (Word(0x0000), VideoCapture.Quality.Value.none),
            (Word(0x0010), ._120p_50m),
            (Word(0x0011), ._100p_50m),
            (Word(0x0001), ._60p_50m),
            (Word(0x0004), ._50p_50m),
            (Word(0x0002), ._30p_50m),
            (Word(0x0005), ._25p_50m),
            (Word(0x0003), ._24p_50m),
            (Word(0x001c), ._120p_100m),
            (Word(0x001d), ._100p_100m),
            (Word(0x001e), ._120p_60m),
            (Word(0x001f), ._100p_60m),
            (Word(0x0020), ._30p_100m),
            (Word(0x0021), ._25p_100m),
            (Word(0x0022), ._24p_100m),
            (Word(0x0023), ._30p_60m),
            (Word(0x0024), ._25p_60m),
            (Word(0x0025), ._24p_60m),
            (Word(0x0016), ._60p_28m),
            (Word(0x0017), ._50p_28m),
            (Word(0x0018), ._60p_25m),
            (Word(0x0019), ._50p_25m),
            (Word(0x0012), ._30p_16m),
            (Word(0x0013), ._25p_16m),
            (Word(0x001a), ._30p_16m_alt),
            (Word(0x001b), ._25p_16m_alt),
            (Word(0x0014), ._30p_6m),
            (Word(0x0015), ._25p_6m),
            (Word(0x0006), ._60i_24m_fx),
            (Word(0x0007), ._50i_24m_fx),
            (Word(0x0008), ._60i_17m_fh),
            (Word(0x0009), ._50i_17m_fh),
            (Word(0x000a), ._60p_28m_ps),
            (Word(0x000b), ._50p_28m_ps),
            (Word(0x000c), ._24p_24m_fx),
            (Word(0x000d), ._25p_24m_fx),
            (Word(0x000e), ._24p_17m_fh),
            (Word(0x000f), ._25p_17m_fh),
            (Word(0x0026), ._600m_4_2_2_10bit),
            (Word(0x0027), ._500m_4_2_2_10bit),
            (Word(0x0028), ._400m_4_2_0_10bit),
            (Word(0x0029), ._300m_4_2_2_10bit),
            (Word(0x002a), ._280m_4_2_2_10bit),
            (Word(0x002b), ._250m_4_2_2_10bit),
            (Word(0x002c), ._240m_4_2_2_10bit),
            (Word(0x002d), ._222m_4_2_2_10bit),
            (Word(0x002e), ._200m_4_2_2_10bit),
            (Word(0x002f), ._200m_4_2_0_10bit),
            (Word(0x0030), ._200m_4_2_0_8bit),
            (Word(0x0031), ._185m_4_2_2_10bit),
            (Word(0x0032), ._150m_4_2_0_10bit),
            (Word(0x0033), ._150m_4_2_0_8bit),
            (Word(0x0034), ._140m_4_2_2_10bit),
            (Word(0x0035), ._111m_4_2_2_10bit),
            (Word(0x0036), ._100m_4_2_2_10bit),
            (Word(0x0037), ._100m_4_2_0_10bit),
            (Word(0x0038), ._100m_4_2_0_8bit),
            (Word(0x0039), ._93m_4_2_2_10bit),
            (Word(0x003a), ._89m_4_2_2_10bit),
            (Word(0x003b), ._75m_4_2_0_10bit),
            (Word(0x003c), ._60m_4_2_0_8bit),
            (Word(0x003d), ._50m_4_2_2_10bit),
            (Word(0x003e), ._50m_4_2_0_10bit),
            (Word(0x003f), ._50m_4_2_0_8bit),
            (Word(0x0040), ._45m_4_2_0_10bit),
            (Word(0x0041), ._30m_4_2_0_10bit),
            (Word(0x0042), ._25m_4_2_0_8bit),
            (Word(0x0043), ._16m_4_2_0_8bit),
            ("Hello World", nil)
        ]
        
        let nonPTPQualities: [VideoCapture.Quality.Value] = [
            .ps, .hq, .std, .vga, .slow, .sslow, .hs100, .hs120, .hs200,
            .hs240, ._240p_100m, ._200p_100m, ._240p_60m, ._200p_60m
        ]
        // Make sure all enum cases are tested for
        XCTAssertEqual(
            VideoCapture.Quality.Value.allCases.filter({
                !nonPTPQualities.contains($0)
            }),
            testCases.compactMap({ $0.1 }),
            "Missing VideoCapture.Quality.Value in test cases"
        )
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.1,
                VideoCapture.Quality.Value(sonyValue: testCase.0)
            )
        }
    }
    
    func testVideoCaptureQualityConvertsToDataCorrectly() throws {
        
        let testCases: [(Word, VideoCapture.Quality.Value)] = [
            (Word(0x0000), VideoCapture.Quality.Value.none),
            (Word(0x0000), .ps),
            (Word(0x0000), .hq),
            (Word(0x0000), .std),
            (Word(0x0000), .vga),
            (Word(0x0000), .slow),
            (Word(0x0000), .sslow),
            (Word(0x0000), .hs120),
            (Word(0x0000), .hs100),
            (Word(0x0000), .hs240),
            (Word(0x0000), .hs200),
            (Word(0x0010), ._120p_50m),
            (Word(0x0011), ._100p_50m),
            (Word(0x0001), ._60p_50m),
            (Word(0x0004), ._50p_50m),
            (Word(0x0002), ._30p_50m),
            (Word(0x0005), ._25p_50m),
            (Word(0x0003), ._24p_50m),
            (Word(0x001c), ._120p_100m),
            (Word(0x001d), ._100p_100m),
            (Word(0x001e), ._120p_60m),
            (Word(0x001f), ._100p_60m),
            (Word(0x0000), ._240p_100m),
            (Word(0x0000), ._200p_100m),
            (Word(0x0000), ._240p_60m),
            (Word(0x0000), ._200p_60m),
            (Word(0x0020), ._30p_100m),
            (Word(0x0021), ._25p_100m),
            (Word(0x0022), ._24p_100m),
            (Word(0x0023), ._30p_60m),
            (Word(0x0024), ._25p_60m),
            (Word(0x0025), ._24p_60m),
            (Word(0x0016), ._60p_28m),
            (Word(0x0017), ._50p_28m),
            (Word(0x0018), ._60p_25m),
            (Word(0x0019), ._50p_25m),
            (Word(0x0012), ._30p_16m),
            (Word(0x0013), ._25p_16m),
            (Word(0x001a), ._30p_16m_alt),
            (Word(0x001b), ._25p_16m_alt),
            (Word(0x0014), ._30p_6m),
            (Word(0x0015), ._25p_6m),
            (Word(0x0006), ._60i_24m_fx),
            (Word(0x0007), ._50i_24m_fx),
            (Word(0x0008), ._60i_17m_fh),
            (Word(0x0009), ._50i_17m_fh),
            (Word(0x000a), ._60p_28m_ps),
            (Word(0x000b), ._50p_28m_ps),
            (Word(0x000c), ._24p_24m_fx),
            (Word(0x000d), ._25p_24m_fx),
            (Word(0x000e), ._24p_17m_fh),
            (Word(0x000f), ._25p_17m_fh),
            (Word(0x0026), ._600m_4_2_2_10bit),
            (Word(0x0027), ._500m_4_2_2_10bit),
            (Word(0x0028), ._400m_4_2_0_10bit),
            (Word(0x0029), ._300m_4_2_2_10bit),
            (Word(0x002a), ._280m_4_2_2_10bit),
            (Word(0x002b), ._250m_4_2_2_10bit),
            (Word(0x002c), ._240m_4_2_2_10bit),
            (Word(0x002d), ._222m_4_2_2_10bit),
            (Word(0x002e), ._200m_4_2_2_10bit),
            (Word(0x002f), ._200m_4_2_0_10bit),
            (Word(0x0030), ._200m_4_2_0_8bit),
            (Word(0x0031), ._185m_4_2_2_10bit),
            (Word(0x0032), ._150m_4_2_0_10bit),
            (Word(0x0033), ._150m_4_2_0_8bit),
            (Word(0x0034), ._140m_4_2_2_10bit),
            (Word(0x0035), ._111m_4_2_2_10bit),
            (Word(0x0036), ._100m_4_2_2_10bit),
            (Word(0x0037), ._100m_4_2_0_10bit),
            (Word(0x0038), ._100m_4_2_0_8bit),
            (Word(0x0039), ._93m_4_2_2_10bit),
            (Word(0x003a), ._89m_4_2_2_10bit),
            (Word(0x003b), ._75m_4_2_0_10bit),
            (Word(0x003c), ._60m_4_2_0_8bit),
            (Word(0x003d), ._50m_4_2_2_10bit),
            (Word(0x003e), ._50m_4_2_0_10bit),
            (Word(0x003f), ._50m_4_2_0_8bit),
            (Word(0x0040), ._45m_4_2_0_10bit),
            (Word(0x0041), ._30m_4_2_0_10bit),
            (Word(0x0042), ._25m_4_2_0_8bit),
            (Word(0x0043), ._16m_4_2_0_8bit),
        ]
        
        XCTAssertEqual(testCases.first?.1.type, .uint16)
        XCTAssertEqual(testCases.first?.1.code, .movieQuality)
        
        // Make sure all enum cases are tested for
        XCTAssertEqual(
            VideoCapture.Quality.Value.allCases,
            testCases.compactMap({ $0.1 }),
            "Missing VideoCapture.Quality.Value in test cases"
        )
        
        testCases.forEach { (testCase) in
            XCTAssertEqual(
                testCase.0,
                testCase.1.sonyPTPValue as? Word
            )
        }
    }
}
