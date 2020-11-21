//
//  ThunderRequestTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
typealias UIImage = NSImage
#endif
import XCTest
@testable import ThunderRequest

struct Response: Codable {
    var args: [String : String]
    var data: String
    var files: [String : String]
    var form: [String : String]
    var headers: [String : String]
    var json: CodableStruct
    var origin: String
    var url: URL
}

class ResponseTests: XCTestCase {
    
    let requestBaseURL = URL(string: "https://httpbin.org/")!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateControllerWithURL() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        XCTAssertNotNil(requestController, "A request Controller failed to be initialised with a URL")
    }
    
    func testRequestInvokesSuccessCompletionBlockWithResponseObject() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "GET Request")
        
        requestController.request("get", method: .GET) { (response, error) in
            
            XCTAssertNil(error, "Request controller returned error for GET request")
            XCTAssertNotNil(response, "Request Controller did not return a response object")
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35) { (error) -> Void in
            XCTAssertNil(error, "The GET request timed out")
        }
    }
    
    func testOperationInvokesFailureCompletionBlockWithErrorOn404() {
            
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "404 Request should return with response and error")
        
        requestController.request("status/404", method: .GET) { (response, error) in
            XCTAssertNotNil(error, "Request controller did not return an error object")
            XCTAssertNotNil(response, "Request controller did not return a response object")
            XCTAssertEqual(response?.status, .notFound, "Request controller did not return 404")
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The 404 request timed out")
        })
    }
    
    func testOperationInvokesFailureCompletionBlockWithErrorOn500() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "500 Response should return with response and error")
        
        requestController.request("status/500", method: .GET) { (response, error) in
            XCTAssertNotNil(error, "Request controller did not return an error object")
            XCTAssertNotNil(response, "Request controller did not return a response object")
            XCTAssertEqual(response!.status, .internalServerError, "Request controller did not return 500")
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The 404 request timed out")
        })
    }
    
    func testAppIsNotifiedAboutServerErrors() {
    
        let requestController = RequestController(baseURL: requestBaseURL)

        let finishExpectation = expectation(description: "App should be notified about server errors")

        var notificationFound = false

        let observer = NotificationCenter.default.addObserver(forName: RequestController.DidErrorNotificationName, object: nil, queue: nil) { (notification) -> Void in
            notificationFound = true
        }

        requestController.request("status/500", method: .GET) { (response, error) in
            if notificationFound == true {
                finishExpectation.fulfill()
            }
        }
    
        waitForExpectations(timeout: 35, handler: { (error) -> Void in

            XCTAssertNil(error, "The notification test timed out")
            NotificationCenter.default.removeObserver(observer)
        })
    }
    
    func testAppIsNotifiedAboutServerResponse() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "App should be notified about server responses")
        
        var notificationFound = false
        
        let observer = NotificationCenter.default.addObserver(forName: RequestController.DidReceiveResponseNotificationName, object: nil, queue: nil) { (notification) -> Void in
            
            notificationFound = true
            
        }
        
        requestController.request("status/500", method: .GET) { (response, error) in
            if notificationFound == true {
                finishExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            
            XCTAssertNil(error, "The server response notification test timed out")
            
            NotificationCenter.default.removeObserver(observer)
            
        })
    }
    
    func testPostRequest() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "App should correctly send POST data to server")
        
        requestController.request("post", method: .POST, body: JSONRequestBody(["RequestTest": "Success"])) { (response, error) in
            
            let responseJson = response?.dictionary?["json"] as! Dictionary<String, String>
            let successString = responseJson["RequestTest"]
            XCTAssertTrue(successString == "Success", "Server did not return POST body sent by request kit")
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The POST request timed out")
        })
    }
    
    func testCancelRequestWithTagReturnsCancelledError() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation1 = expectation(description: "Request should be cancelled")
        let finishExpectation2 = expectation(description: "Request should be cancelled")
        let finishExpectation3 = expectation(description: "Request should be cancelled")
        let finishExpectation4 = expectation(description: "Request should succeed")
        
        requestController.request("get", method: .GET, tag: 123) { (_, error) in
            XCTAssertNotNil(error, "Error unexpectedly nil")
            defer {
                finishExpectation1.fulfill()
            }
            guard let error = error else { return }
            XCTAssertEqual((error as NSError).code, URLError.cancelled.rawValue, "Request controller returned invalid error")
        }
        
        requestController.request("get", method: .GET, tag: 123) { (_, error) in
            XCTAssertNotNil(error, "Error unexpectedly nil")
            defer {
                finishExpectation2.fulfill()
            }
            guard let error = error else { return }
            XCTAssertEqual((error as NSError).code, URLError.cancelled.rawValue, "Request controller returned invalid error")
        }
        
        requestController.request("get", method: .GET, tag: 123) { (_, error) in
            XCTAssertNotNil(error, "Error unexpectedly nil")
            defer {
                finishExpectation3.fulfill()
            }
            guard let error = error else { return }
            XCTAssertEqual((error as NSError).code, URLError.cancelled.rawValue, "Request controller returned invalid error")
        }
        
        requestController.request("get", method: .GET, tag: 201) { (response, error) in
            XCTAssertNil(error, "Request controller returned error for GET request")
            XCTAssertNotNil(response, "Request Controller did not return a response object")
            XCTAssertEqual(response?.status, .okay)
            finishExpectation4.fulfill()
        }
        
        requestController.cancelRequestsWith(tag: 123)
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The GET request timed out")
        })
    }
    
    func testCancelAllRequestsReturnsCancelledError() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation1 = expectation(description: "Request should be cancelled")
        let finishExpectation2 = expectation(description: "Request should be cancelled")
        let finishExpectation3 = expectation(description: "Request should be cancelled")
        let finishExpectation4 = expectation(description: "Request should succeed")
        
        requestController.request("get", method: .GET, tag: 123) { (_, error) in
            XCTAssertNotNil(error, "Error unexpectedly nil")
            defer {
                finishExpectation1.fulfill()
            }
            guard let error = error else { return }
            XCTAssertEqual((error as NSError).code, URLError.cancelled.rawValue, "Request controller returned invalid error")
        }
        
        requestController.request("get", method: .GET, tag: 123) { (_, error) in
            XCTAssertNotNil(error, "Error unexpectedly nil")
            defer {
                finishExpectation2.fulfill()
            }
            guard let error = error else { return }
            XCTAssertEqual((error as NSError).code, URLError.cancelled.rawValue, "Request controller returned invalid error")
        }
        
        requestController.request("get", method: .GET, tag: 123) { (_, error) in
            XCTAssertNotNil(error, "Error unexpectedly nil")
            defer {
                finishExpectation3.fulfill()
            }
            guard let error = error else { return }
            XCTAssertEqual((error as NSError).code, URLError.cancelled.rawValue, "Request controller returned invalid error")
        }
        
        requestController.request("get", method: .GET, tag: 201) { (response, error) in
            XCTAssertNotNil(error, "Error unexpectedly nil")
            defer {
                finishExpectation4.fulfill()
            }
            guard let error = error else { return }
            XCTAssertEqual((error as NSError).code, URLError.cancelled.rawValue, "Request controller returned invalid error")
        }
        
        requestController.cancelAllRequests()
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The GET request timed out")
        })
    }
    
    func testResponseEncodesCorrectly() {
        
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
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "App should correctly send POST data to server")
        
        requestController.request("post", method: .POST, body: codableBody) { (response, error) in
            
            let codableResponse: Response? = response?.decoded()
            XCTAssertNotNil(codableResponse)
            XCTAssertNotNil(codableResponse?.json)
            XCTAssertEqual(codableResponse?.json.bool, true)
            XCTAssertEqual(codableResponse!.json.double, 23.12, accuracy: 0.0001)
            XCTAssertEqual(codableResponse?.json.string, "Hello")
            XCTAssertNil(codableResponse?.json.nullable)
            XCTAssertEqual(codableResponse?.json.stringArray, ["Hello", "World"])
            XCTAssertEqual(codableResponse?.json.url, URL(string: "https://www.google.co.uk"))
            XCTAssertEqual(codableResponse?.json.dictionary, ["Hello":"World"])
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The POST request timed out")
        })
    }
    
    func testMultipartRequestReturnsCorrectResponse() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let pngFile = MultipartFormFile(image: image, format: .png, fileName: "image.png", name: "image")!
        
        let formBody = MultipartFormRequestBody(
            parts: [
                "png": pngFile
            ],
            boundary: "------ABCDEFG"
        )
        
        let finishExpectation = expectation(description: "App should correctly send POST data to server")
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        requestController.request("post", method: .POST, body: formBody) { (response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response?.dictionary)
            XCTAssertEqual(response?.status, .okay)
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The POST request timed out")
        })
    }
}
