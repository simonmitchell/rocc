//
//  Logger.swift
//  Rocc
//
//  Created by Simon Mitchell on 23/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

/// A protocol that can be implemented to act as a logger for ROCC.
/// this allows you to collate logs in any way you wish, rather than relying
/// on rocc's logging to file!
public protocol Log {
    
    /// A function which will be called to write a log message to the log
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The category of the message
    ///   - subsystem: The subsystem of the log
    ///   - level: The level of the log (Allows you to filter!)
    func log(message: String, subsystem: String, category: String, level: Logger.Level)
}

/// A class which stores the shared logger, mostly for type aliasing
public final class Logger {
    
    public enum Level: String {
        case `default`
        case info
        case error
        case debug
        case fault
    }
    
    public static var sharedLog: Log = FileLog.shared
    
    internal init() {
        
    }
    
    /// Logs a given message via the shared instance of `Logger`
    ///
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The category of the log
    ///   - subsystem: The subsystem of the log
    ///   - level: The log level
    public class func log(message: String, category: String, subsystem: String = Bundle(for: Logger.self).bundleIdentifier ?? "com.yellowbrickbear.rocc", level: Level = .debug) {
        Logger.sharedLog.log(message: message, subsystem: subsystem, category: category, level: level)
    }
}

/// A simple class for logging to a given file url
public final class FileLog: Log {
    
    /// Shared instance of the logger
    public static let shared = FileLog()
    
    /// Whether logs are currently being saved to a file
    public var isLoggingToFile: Bool {
        return fileURL != nil
    }
    
    /// The file that logs should be saved to
    public var fileURL: URL?
    
    /// The maximum size that the log file will be allowed to reach in kilobytes.
    /// Default is 2Mb
    public var maxFileSize: UInt64 = 1024*2
    
    private let formatter = ISO8601DateFormatter()
    
    private var logQueue: DispatchQueue?
    
    /// Starts writing any logs to a file at a given url
    ///
    /// - Note: It is not important to create the file at the url provided, it will be created for you if it isn't already present
    ///
    /// - Parameter url: The file to write logs to
    public func startSavingToFile(at url: URL) {
        fileURL = url
        logQueue = DispatchQueue(label: "Logger", qos: .userInitiated)
    }
    
    /// Finishes writing logs to a given file and returns the url that was being written to
    ///
    /// - Returns: The url that logs were being written to
    @discardableResult public func finishSavingToFile() -> URL? {
        logQueue = nil
        let url = fileURL
        fileURL = nil
        return url
    }
    
    private init() {
        
    }
    
    public func log(message: String, subsystem: String, category: String, level: Logger.Level) {
        
        guard let fileURL = fileURL, let logQueue = logQueue else { return }
        
        logQueue.sync { [weak self] in
            
            // Trim will simply delete the file (For now) if it's already too big, which will then be re-created below
            self?.trimLog()
            
            let fm = FileManager.default
            if !fm.fileExists(atPath: fileURL.isFileURL ? fileURL.path : fileURL.absoluteString) {
                fm.createFile(atPath: fileURL.isFileURL ? fileURL.path : fileURL.absoluteString, contents: nil, attributes: nil)
            }
            
            var writeString = message
            
            if !writeString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                writeString = "\n\(formatter.string(from: Date())) [\(level.rawValue)] | \(subsystem) \(category) | \(writeString)"
            }
            
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                handle.write(writeString.data(using: .utf8)!)
                handle.closeFile()
            } else {
                
                guard let data = writeString.data(using: .utf8) else { return }
                do {
                    try data.write(to: fileURL)
                } catch {
                    print("Failed to write to log url")
                }
            }
        }
    }
    
    private func trimLog() {
        
        guard let fileURL = fileURL else { return }
        
        let fileManager = FileManager.default
        guard let attrs: NSDictionary = try? fileManager.attributesOfItem(atPath: fileURL.path) as NSDictionary else {
            return
        }
        
        let fileSize = attrs.fileSize()
        guard fileSize > maxFileSize * 1024 else {
            return
        }
        
        do {
            try fileManager.removeItem(at: fileURL)
        } catch _ {
            print("Failed to delete over-sized log file")
        }
    }
}

extension LogLevel {
    var roccLevel: Logger.Level {
        switch self {
        case .default:
            return .default
        case .debug:
            return .debug
        case .error:
            return .error
        case .fault:
            return .fault
        case .info:
            return .info
        }
    }
}

extension Logger: LogReceiver {
    
    public func log(_ message: String, category: String, level: LogLevel) {
        Logger.sharedLog.log(message: message, subsystem: "com.threesidedcube.thunderrequest", category: category, level: level.roccLevel)
    }
}
