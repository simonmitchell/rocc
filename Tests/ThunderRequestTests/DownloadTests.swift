//
//  DownloadTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#endif
import XCTest
@testable import ThunderRequest

class DownloadTests: XCTestCase {
    
    let requestBaseURL = URL(string: "https://via.placeholder.com/")!
    
    func testDownloadSavesToDisk() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        let finishExpectation = expectation(description: "App should correctly download body from server")
        
        requestController.download("500", progress: nil) { (response, url, error) in
            
            XCTAssertNotNil(url)
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.status, .okay)
            
            XCTAssertTrue(FileManager.default.fileExists(atPath: url!.path))
            
            let data = try? Data(contentsOf: url!)
            XCTAssertNotNil(data)
            XCTAssertNotNil(UIImage(data: data!))
            
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35) { (error) in
            XCTAssertNil(error, "The download timed out")
        }
    }
}
