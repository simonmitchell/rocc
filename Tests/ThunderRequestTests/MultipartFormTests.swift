//
//  MultipartFormTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 17/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import XCTest
import Foundation
@testable import ThunderRequest

#if os(iOS) || os(tvOS)
let expectedImageSize = CGSize(width: 350, height: 150)
#elseif os(macOS)
let expectedImageSize = CGSize(width: 262.5, height: 112.5)
#endif


class MultipartFormTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringElementFormatsCorrectly() {
        
        let stringElement = "Hello World"
        let multipartData = stringElement.multipartDataWith(boundary: "123456", key: "sentence")
        XCTAssertEqual(multipartData?.count, 70)
        XCTAssertNotNil(multipartData)
        guard let data = multipartData else {
            return
        }
        XCTAssertEqual(String(data: data, encoding: .utf8), "--123456\r\nContent-Disposition: form-   ;name=\"sentence\"\r\nHello World\r\n")
    }
    
    func testImageFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        #if os(iOS) || os(tvOS)
        let endStringRange = 8193...8203
        let imageRange = 145...8192
        let dataLength = 8204
        #elseif os(macOS)
        let endStringRange = 4655...4665
        let imageRange = 145...4644
        let dataLength = 4666
        #endif
        
        let imageMultiPartData = image.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, dataLength)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...144], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data; name=\"image\"; filename=\"filename.jpg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n")
        
        XCTAssertEqual(String(data: data[endStringRange], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[imageRange])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, expectedImageSize)
    }
    
    func testFileElementFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let fileData = try? Data(contentsOf: imageURL) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let imagePart = MultipartFormFile(
            fileData: fileData,
            contentType: "image/png",
            fileName: "fileface.png",
            disposition: "form-data",
            name: "hello",
            transferEncoding: "bubbles"
        )
        let imageMultiPartData = imagePart.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, 1409)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...144], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data; name=\"hello\"; filename=\"fileface.png\"\r\nContent-Type: image/png\r\nContent-Transfer-Encoding: bubbles\r\n\r\n")
        XCTAssertEqual(String(data: data[1398...1408], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[145...1408])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, expectedImageSize)
    }
    
    func testFileElementWithDefaultsFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let fileData = try? Data(contentsOf: imageURL) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let imagePart = MultipartFormFile(
            fileData: fileData,
            contentType: "image/png",
            fileName: "fileface.png"
        )
        let imageMultiPartData = imagePart.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, 1408)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...143], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data; name=\"image\"; filename=\"fileface.png\"\r\nContent-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n")
        XCTAssertEqual(String(data: data[1397...1407], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[144...1407])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, expectedImageSize)
    }
    
    func testJpegFileFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        #if os(iOS) || os(tvOS)
        let endStringRange = 8190...8200
        let imageRange = 142...8189
        let dataLength = 8201
        #elseif os(macOS)
        let endStringRange = 4652...4662
        let imageRange = 142...4641
        let dataLength = 4663
        #endif
        
        let imageFile = MultipartFormFile(image: image, format: .jpeg, fileName: "image.jpg", name: "image")
        XCTAssertNotNil(imageFile)
        
        let imageMultiPartData = imageFile?.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, dataLength)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...141], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n")
        XCTAssertEqual(String(data: data[endStringRange], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[imageRange])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, expectedImageSize)
    }
    
    func testPNGFileFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let imageFile = MultipartFormFile(image: image, format: .png, fileName: "image.png", name: "image")
        XCTAssertNotNil(imageFile)
        
        let imageMultiPartData = imageFile?.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        #if os(iOS) || os(tvOS)
        let endStringRange: ClosedRange<Int>
        let imageRange: ClosedRange<Int>
        let dataLength: Int
        if #available(iOS 13.0, *) {
            dataLength = 2022
            imageRange = 141...2012
            endStringRange = 2011...2021
        } else {
            dataLength = 1942
            imageRange = 141...1932
            endStringRange = 1931...1941
        }
        #elseif os(macOS)
        let endStringRange = 1952...1962
        let imageRange = 141...1951
        let dataLength = 1963
        #endif
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, dataLength)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...140], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\nContent-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n")
        XCTAssertEqual(String(data: data[endStringRange], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[imageRange])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, expectedImageSize)
    }
    
    func testWholeFormFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let pngFile = MultipartFormFile(image: image, format: .png, fileName: "image.png", name: "image")!
        let jpegFile = MultipartFormFile(image: image, format: .jpeg, fileName: "image.jpeg", name: "jpeg")!
        
        let formBody = MultipartFormRequestBody(
            parts: [
                "png": pngFile,
                "jpeg": jpegFile
            ],
            boundary: "ABCDEFG"
        )
        
        let payload = formBody.payload()
        
        #if os(iOS) || os(tvOS)
        let dataLength: Int
        if #available(iOS 13.0, *) {
            dataLength = 10223
        } else {
            dataLength = 10143
        }
        #elseif os(macOS)
        let dataLength = 6626
        #endif
        
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload?.count, dataLength)
        XCTAssertEqual(formBody.contentType, "multipart/form-data; boundary=ABCDEFG")
    }
}
