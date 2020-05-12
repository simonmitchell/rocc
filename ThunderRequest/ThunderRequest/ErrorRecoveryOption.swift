//
//  ErrorRecoveryOption.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation


/// An option to be added to an `ErrorRecoveryAttempter`.
/// when the attempter presents the alert on screen to the user,
/// each one of the options will be displayed as a selectable button
public struct ErrorRecoveryOption {
    
    /// The styles available for the action
    ///
    /// - custom: A custom option for recovering from the error
    /// - retry: Displays a retry button and repeats the request where possible
    /// - cancel: Cancels the recovery
    public enum Style {
        case custom
        case retry
        case cancel
    }
    
    /// A typealias for a callback when an error recovery option is chosen
    public typealias Handler = (_ option: ErrorRecoveryOption, _ callback: ((Bool) -> Void)?) -> Void
    
    /// The title to be used on the recovery option's button
    public let title: String

    /// A closure to be called when the user selects the recovery option.
    /// If none is supplied then the alert dialog will simply dismiss
    /// when this option is selected.
    public let handler: Handler?
    
    /// The type/style that is applied to the recovery option
    public let style: Style
    
    /// Creates a new option
    ///
    /// - Parameters:
    ///   - title: The title to display in the alert
    ///   - style: The style to display the button as in the alert
    ///   - handler: A closure called when the option is selected
    public init(title: String, style: Style, handler: Handler? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
