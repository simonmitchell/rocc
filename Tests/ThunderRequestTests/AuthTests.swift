//
//  AuthTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 18/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderRequest

class DummyAuthenticator: Authenticator {
    
    func authenticate(completion: (RequestCredential?, Error?, Bool) -> Void) {
        
    }
    
    var keychainAccessibility: CredentialStore.Accessibility {
        return .always
    }
    
    func reAuthenticate(credential: RequestCredential?, completion: (RequestCredential?, Error?, Bool) -> Void) {
        
    }
    
    var authIdentifier: String = "dummyauthenticator"
    
    init() {
        
    }
}

class KeychainMockStore: DataStore {
    
    var internalStore: [String : Data] = [:]
    
    init() {
        
    }
    
    func add(data: Data, identifier: String, accessibility: CredentialStore.Accessibility) -> Bool {
        internalStore[identifier] = data
        return true
    }
    
    func update(data: Data, identifier: String, accessibility: CredentialStore.Accessibility) -> Bool {
        internalStore[identifier] = data
        return true
    }
    
    func retrieveDataFor(identifier: String) -> Data? {
        return internalStore[identifier]
    }
    
    func removeDataFor(identifier: String) -> Bool {
        guard internalStore[identifier] != nil else {
            return false
        }
        internalStore[identifier] = nil
        return true
    }
}

class AuthTests: XCTestCase {
    
    let requestBaseURL = URL(string: "https://httpbin.org/")!

    func testFetchesAuthWhenAuthenticatorSet() {
        
        let store = KeychainMockStore()
        
        let requestController = RequestController(baseURL: requestBaseURL, dataStore: store)
        
        let credential = RequestCredential(authorizationToken: "token", refreshToken: "refresh", expiryDate: Date(timeIntervalSinceNow: 1600))
        
        
        CredentialStore.store(credential: credential, identifier: "dummyauthenticator", accessibility: .always, in: store)
        
        let authenticator = DummyAuthenticator()
        requestController.authenticator = authenticator
        
        XCTAssertNotNil(requestController.sharedRequestCredentials)
        XCTAssertEqual(requestController.sharedRequestCredentials?.authorizationToken, "token")
        XCTAssertEqual(requestController.sharedRequestCredentials?.hasExpired, false)
    }

    func testFetchesAuthOnInit() {
        
        let credential = RequestCredential(authorizationToken: "ABCDE")
        
        let store = KeychainMockStore()
        
        CredentialStore.store(credential: credential, identifier: "thundertable.com.threesidedcube-https://httpbin.org/", accessibility: .always, in: store)
        
        let requestController = RequestController(baseURL: requestBaseURL, dataStore: store)
        
        XCTAssertNotNil(requestController.sharedRequestCredentials)
        XCTAssertEqual(requestController.sharedRequestCredentials?.authorizationToken, "ABCDE")
        XCTAssertEqual(requestController.sharedRequestCredentials?.hasExpired, false)
    }
}
