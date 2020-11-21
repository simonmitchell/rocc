//
//  RequestCredential.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

public struct Authentication {
    
    /// Representation of the token type for use in `Authorization` header!
    public struct TokenType {
        
        static let bearer = "Bearer"
    }
}

public let kTSCAuthServiceName = "TSCAuthCredential"

/// A class used to store authentication information and return the `URLCredential` object when required
@objc(TSCRequestCredential)
public final class RequestCredential: NSObject, NSCoding {
    
    /// Returns the url credential which can be used to authenticate a request
    public var credential: URLCredential?
    
    /// The username to auth the user with
    public var username: String?
    
    /// The password to auth the user with
    public var password: String?
    
    /// The auth token to auth the user with
    public var authorizationToken: String?
    
    /// The type of the token
    public var tokenType: String = Authentication.TokenType.bearer
    
    /// The date on which the authorization token expires
    public var expirationDate: Date?
    
    /// The refresh token to be sent back to the authenticating endpoint for certain auth methods
    public var refreshToken: String?
    
    /// Init method for re-constructing from data stored in the user's keychain
    ///
    /// - Parameter keychainData: The data which was retrieved from the keychain
    init?(keychainData: Data) {
        
        guard let credential = NSKeyedUnarchiver.unarchiveObject(with: keychainData) as? RequestCredential else {
            return nil
        }
        
        self.authorizationToken = credential.authorizationToken
        self.credential = credential.credential
        self.username = credential.username
        self.password = credential.password
        self.tokenType = credential.tokenType
    }
    
    /// Whether the credential has expired. Where expiryDate is missing this will return as false, as it is
    /// assumed the credential doesn't have an expiry date in this case
    public var hasExpired: Bool {
        guard let expiry = expirationDate else {
            return false
        }
        return Date() > expiry
    }
    
    /// The data to store in the keychain
    public var keychainData: Data {
        return NSKeyedArchiver.archivedData(withRootObject:self)
    }
    
    /// Creates a new username/password based credential
    ///
    /// - Parameters:
    ///   - username: The username of the authorization object
    ///   - password: The password of the authorization object
    public init(username: String, password: String) {
        super.init()
        credential = URLCredential(user: username, password: password, persistence: .none)
        self.username = username
        self.password = password
    }
    
    /// Initialises a new OAuth2 credential with given parameters
    ///
    /// - Parameters:
    ///   - authorizationToken: The authorizationToken to be sent by `RequestController` for authentication requests.
    ///   - refreshToken: The refresh token to be sent back to the authenticating endpoint for certain authentification methods.
    ///   - expiryDate: The date upon which the credential will expire for the user.
    ///   - tokenType: The token type of the credential (Defaults to Bearer)
    public init(authorizationToken: String, refreshToken: String?, expiryDate: Date, tokenType: String = "Bearer") {
        
        self.refreshToken = refreshToken
        self.expirationDate = expiryDate
        self.authorizationToken = authorizationToken
        self.tokenType = tokenType
        super.init()
    }
    
    /// Creates a new auth token based credential
    ///
    /// - Parameter authorizationToken: The authorization token to use
    init(authorizationToken: String) {
        super.init()
        self.authorizationToken = authorizationToken
    }
    
    private enum CodingKeys: String {
        case username
        case password
        case authToken = "authtoken"
        case credential
        case tokenType = "tokentype"
        case expiration
        case refreshToken = "refreshtoken"
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: CodingKeys.username.rawValue)
        aCoder.encode(password, forKey: CodingKeys.password.rawValue)
        aCoder.encode(authorizationToken, forKey: CodingKeys.authToken.rawValue)
        aCoder.encode(credential, forKey: CodingKeys.credential.rawValue)
        aCoder.encode(tokenType, forKey: CodingKeys.tokenType.rawValue)
        aCoder.encode(expirationDate, forKey: CodingKeys.expiration.rawValue)
        aCoder.encode(refreshToken, forKey: CodingKeys.refreshToken.rawValue)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        username = aDecoder.decodeObject(forKey: CodingKeys.username.rawValue) as? String
        password = aDecoder.decodeObject(forKey: CodingKeys.password.rawValue) as? String
        authorizationToken = aDecoder.decodeObject(forKey: CodingKeys.authToken.rawValue) as? String
        credential = aDecoder.decodeObject(forKey: CodingKeys.credential.rawValue) as? URLCredential
        tokenType = aDecoder.decodeObject(forKey: CodingKeys.tokenType.rawValue) as? String ?? Authentication.TokenType.bearer
        refreshToken = aDecoder.decodeObject(forKey: CodingKeys.refreshToken.rawValue) as? String
        expirationDate = aDecoder.decodeObject(forKey: CodingKeys.expiration.rawValue) as? Date
    }
}
