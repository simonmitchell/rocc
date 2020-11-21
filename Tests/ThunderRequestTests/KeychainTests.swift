//
//  ThunderRequest-KeychainTests.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/09/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderRequest

class ThunderRequest_KeychainTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialiseUsernamePasswordCredential() {
        
        let credential = RequestCredential(username: "test", password: "123")
        
        XCTAssertNotNil(credential.username, "Username is nil")
        XCTAssertNotNil(credential.password, "Password is nil")
        XCTAssertNotNil(credential.credential, "Credential is nil")
    }
    
    func testInitialiseAuthTokenCredential() {
        
        let credential = RequestCredential(authorizationToken: "SHADSJMAS")
        
        XCTAssertNotNil(credential.authorizationToken, "Authorization Token is nil")
    }
    
    func testInitialiseOAuth2Credential() {
        
        let credential = RequestCredential(authorizationToken: "saDHSAHF", refreshToken: "DSAHJDSA", expiryDate: Date(timeIntervalSinceNow: 24))
        
        XCTAssertNotNil(credential.authorizationToken, "Authorization Token is nil")
        XCTAssertNotNil(credential.refreshToken, "Refresh Token is nil")
        XCTAssertNotNil(credential.expirationDate, "Expiry Date is nil")
    }
}
