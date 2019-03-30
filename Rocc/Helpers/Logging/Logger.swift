//
//  Logger.swift
//  Rocc
//
//  Created by Simon Mitchell on 23/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log
#if os(macOS)
import ThunderRequestMac
#elseif os(iOS)
import ThunderRequest
#endif

/// A simple class for logging to a given file url
public final class Logger {
    
    /// Shared instance of the logger
    public static let shared = Logger()
    
    /// Whether logs are currently being saved to a file
    public var isLoggingToFile: Bool {
        return fileURL != nil
    }
    
    /// The file that logs should be saved to
    public var fileURL: URL?
    
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
    
    /// Logs a given message via the shared instance of `Logger`
    ///
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: The category of the log
    public class func log(message: String, category: String) {
        Logger.shared.log(message, category: category)
    }
    
    private init() {
        
    }
    
    private func log(_ message: String, category: String) {
        
        guard let fileURL = fileURL, let logQueue = logQueue else { return }
        
        logQueue.sync {
            
            let fm = FileManager.default
            if !fm.fileExists(atPath: fileURL.isFileURL ? fileURL.path : fileURL.absoluteString) {
                fm.createFile(atPath: fileURL.isFileURL ? fileURL.path : fileURL.absoluteString, contents: nil, attributes: nil)
            }
            
            var writeString = message
            
            if !writeString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                writeString = "\n\(formatter.string(from: Date())) [\(category)] \(writeString)"
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
}

extension Logger: LogReceiver {
    
    public func log(_ message: String, category: String, level: LogLevel) {
        log(message, category: category)
    }
}
