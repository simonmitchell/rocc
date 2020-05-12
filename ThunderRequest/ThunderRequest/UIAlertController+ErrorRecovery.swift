//
//  UIAlertController+ErrorRecovery.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension ErrorRecoveryOption.Style {
    var alertActionStyle: UIAlertAction.Style {
        switch self {
        case .cancel:
            return .cancel
        default:
            return .default
        }
    }
}

public extension ErrorOverrides {
    
    /// Returns a summarised message body to display to the user combining
    /// failure reasons and suggested recovery options if supplied
    ///
    /// - Parameter error: The error to format for
    /// - Returns: An optional message
    static func recoveryMessageFor(error: Error) -> String? {
        
        let recoverableError = error as? CustomisableRecoverableError
        let override = ErrorOverrides.overrideFor(domain: recoverableError?.domain ?? (error as NSError).domain, code: recoverableError?.code ?? (error as NSError).code)
        
        var message: String = ""
        if let failureReason = recoverableError?.failureReason ?? (error as NSError).localizedFailureReason  {
            message.append(failureReason)
        }
        if let recoverySuggestion = override.recoverySuggestion ?? recoverableError?.recoverySuggestion ?? (error as NSError).localizedRecoverySuggestion {
            if !message.isEmpty {
                message.append("\n")
            }
            message.append(recoverySuggestion)
        }
        
        return message.isEmpty ? nil : message
    }
}

extension UIAlertController {
    
    /// Presents an error as a recoverable error from the given view controller
    ///
    /// - Parameters:
    ///   - error: The error to present
    ///   - viewController: The view controller to present it in
    public static func present(error: Error, in viewController: UIViewController) {
        
        let alertController = UIAlertController(error: error)
        OperationQueue.main.addOperation { [weak viewController] in
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Initialises a UIAlertController from a given error
    ///
    /// This will add recovery options if the error conforms to `CustomisableRecoverableError` or `RecoverableError`
    ///
    /// - Parameter error: The error to show
    public convenience init(error: Error) {
        
        let errorOverride = ErrorOverrides.overrideFor(domain: (error as NSError).domain, code: (error as NSError).code)
        
        self.init(
            title: errorOverride.description ?? (error as? CustomisableRecoverableError)?.description ?? error.localizedDescription,
            message:  ErrorOverrides.recoveryMessageFor(error: error),
            preferredStyle: .alert
        )
        
        switch error {
        case var anyRecoverableError as CustomisableRecoverableError:
            
            if anyRecoverableError.options.isEmpty {
                anyRecoverableError.add(option: ErrorRecoveryOption(title: "Dismiss", style: .cancel))
            }
            
            anyRecoverableError.options.enumerated().forEach { (index, option) in
                addAction(UIAlertAction(title: option.title, style: option.style.alertActionStyle, handler: { (action) in
                    _ = anyRecoverableError.attemptRecovery(optionIndex: index)
                }))
            }
            
        case let recoverableError as RecoverableError:
            
            guard !recoverableError.recoveryOptions.isEmpty else {
                addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                return
            }
            
            recoverableError.recoveryOptions.enumerated().forEach { (index, option) in
                addAction(UIAlertAction(title: option, style: .default, handler: { (action) in
                    _ = recoverableError.attemptRecovery(optionIndex: index)
                }))
            }
            
        default:
            addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        }
    }
}
