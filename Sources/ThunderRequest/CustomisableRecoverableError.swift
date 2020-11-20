//
//  ErrorRecoveryAttempter.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A protocol that inherits from `RecoverableError`
/// This can be used to allow the user to attempt to recover from an error.
public protocol CustomisableRecoverableError: RecoverableError {
    
    /// The localized description for the error
    var description: String? { get }
    
    /// The reason the failure occured.
    var failureReason: String? { get }
    
    /// The suggested method of recovery.
    var recoverySuggestion: String? { get }
    
    /// An array of recovery options for the user.
    var options: [ErrorRecoveryOption] { get set }
    
    /// The code for the error.
    var code: Int { get }
    
    /// The domain of the error.
    var domain: String? { get }
}

extension CustomisableRecoverableError {
    
    public var recoveryOptions: [String] {
        return options.map({ $0.title })
    }
    
    public func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (Bool) -> Void) {
        guard recoveryOptionIndex < options.count else {
            handler(false)
            return
        }
        let option = options[recoveryOptionIndex]
        option.handler?(option, handler)
    }
    
    public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        guard recoveryOptionIndex < options.count else {
            return false
        }
        let option = options[recoveryOptionIndex]
        option.handler?(option, nil)
        return true
    }
    
    public mutating func add(option: ErrorRecoveryOption) {
        options.append(option)
    }
}

public struct ErrorOverrides {
    
    //MARK: - Overrides -
    
    /// Registers an override for a system error message. For example
    /// CLGeocoder has very poor error messaging. Registering a description through
    /// this method will ensure that this is used instead of the system one when
    /// using `UIAlertController(error:)` or `UIAlertController.present(error:in:)`
    ///
    /// - Parameters:
    ///   - overrideDescription: The description you want to display instead of the system one.
    ///   - recoverySuggestion: Advice to the user on how to recover from the error.
    ///   - forDomain: The error domain for the error. Use constants where possible.
    ///   - code: The error code to override. Use constants where possible.
    public static func register(overrideDescription description: String?, recoverySuggestion: String?, forDomain domain: String, code: Int) {
        
        let errorDescriptionKey = "\(domain)\(code)Description"
        let errorRecoveryKey = "\(domain)\(code)Recovery"
        
        var errorDictionary = UserDefaults.standard.dictionary(forKey: "TSCErrorRecoveryOverrides") ?? [:]
        errorDictionary[errorDescriptionKey] = description
        errorDictionary[errorRecoveryKey] = recoverySuggestion
        
        UserDefaults.standard.set(errorDictionary, forKey: "TSCErrorRecoveryOverrides")
    }
    
    /// Returns the overrides for a given error if there is one.
    ///
    /// - Parameters:
    ///   - domain: The error domain for the error. Use constants where possible.
    ///   - code: The error code to override. Use constants where possible.
    /// - Returns: The override information if it has been provided
    public static func overrideFor(domain: String, code: Int) -> (description: String?, recoverySuggestion: String?) {
        
        let errorDescriptionKey = "\(domain)\(code)Description"
        let errorRecoveryKey = "\(domain)\(code)Recovery"
        
        guard let dictionary = UserDefaults.standard.dictionary(forKey: "TSCErrorRecoveryOverrides") else {
            return (nil, nil)
        }
        
        return (dictionary[errorDescriptionKey] as? String, dictionary[errorRecoveryKey] as? String)
    }
}

/// A struct which attempts to convert any `Error` into a customisable representation
public struct AnyCustomisableRecoverableError: CustomisableRecoverableError, CustomNSError, LocalizedError {
    
    public var errorDescription: String? {
        return originalError.localizedDescription
    }
    
    public var localizedDescription: String {
        return originalError.localizedDescription
    }
    
    public var description: String?
    
    public var failureReason: String?
    
    public var recoverySuggestion: String?
    
    public var options: [ErrorRecoveryOption] = []
    
    public var code: Int
    
    public var domain: String?
    
    public var errorCode: Int {
        return code
    }
    
    public var errorDomain: String {
        return domain ?? "Unknown"
    }
    
    private var originalError: Error
    
    init(_ error: Error) {
        
        originalError = error
        description = error.localizedDescription
        failureReason = (error as NSError).localizedFailureReason
        recoverySuggestion = (error as NSError).localizedRecoverySuggestion
        code = (error as NSError).code
        domain = (error as NSError).domain
    }
}
