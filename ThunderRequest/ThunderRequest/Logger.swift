//
//  Logger.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 23/01/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// An enum representing the logging level of a log
///
/// - `default`: Use this level to capture information about things that might result a failure.
/// - info: Use this level to capture information that may be helpful, but isn’t essential, for troubleshooting errors.
/// - debug: Debug logging is intended for use in a development environment and not in shipping software.
/// - error: Error-level messages are intended for reporting process-level errors.
/// - fault: Fault-level messages are intended for capturing system-level or multi-process errors only.
public enum LogLevel {
    case `default`
    case info
    case debug
    case error
    case fault
}

/// Protocol allowing logging to be achieved
public protocol LogReceiver {
    
    func log(_ message: String, category: String, level: LogLevel)
}
