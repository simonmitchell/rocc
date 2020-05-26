//
//  ShutterSpeedFormatter.swift
//  Rocc
//
//  Created by Simon Mitchell on 27/11/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

extension Double {
    var isInteger: Bool {
        return truncatingRemainder(dividingBy: 1) == 0
    }
}

/// A representation of shutter speed.
/// This must be stored as numerator and denominator so it can be re-constructed
/// into it's string format where needed without breaking fractional shutter speeds.
public struct ShutterSpeed: Equatable {
    
    /// The numerator of the shutter speed
    public let numerator: Double
    
    /// The denominator of the shutter speed
    public let denominator: Double
    
    /// Creates a new shutter speed with numerator and denominator
    ///
    /// - Parameters:
    ///   - numerator: The numerator for the shutter speed
    ///   - denominator: The denominator for the shutter speed
    public init(numerator: Double, denominator: Double) {
        self.numerator = numerator
        self.denominator = denominator
    }
    
    /// A statically available constant for BULB shutter speed
    public static let bulb: ShutterSpeed = ShutterSpeed(numerator: -1.0, denominator: -1.0)
    
    /// Returns whether the given shutter speed is a BULB shutter speed
    public var isBulb: Bool {
        return (denominator == -1.0 || numerator == -1.0) || (denominator == 0 && numerator == 0)
    }
}

extension ShutterSpeed: Codable {
    
}

public extension ShutterSpeed {
    /// The actual time interval the given shutter speed will take
    var value: TimeInterval {
        return numerator / denominator
    }
}

extension Double {
    var toString: String {
        return isInteger ? "\(Int(self))" : "\(self)"
    }
}

/// A formatter that converts between shutter speeds and their text format
public class ShutterSpeedFormatter {
    
    /// Formatting options for use with `ShutterSpeedFormatter`
    public struct FormattingOptions: OptionSet {
        
        public let rawValue: Int
        
        /// Whether to append quotes for shutter speeds over 1 second
        static let appendQuotes = FormattingOptions(rawValue: 1 << 0)
        
        /// Whether integers should be formatted with decimal places included
        static let forceIntegersToDouble = FormattingOptions(rawValue: 2 << 0)
    
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// The options to use when formatting shutter speeds
    public var formattingOptions: FormattingOptions = [.appendQuotes]
    
    public init() {
        
    }
    
    /// Returns a formatted string for the given shutter speed using `formattingOptions`
    ///
    /// - Parameter shutterSpeed: The shutter speed to format to a string
    /// - Returns: The shutter speed formatted to a string
    public func string(from shutterSpeed: ShutterSpeed) -> String {
        
        guard !shutterSpeed.isBulb else {
            return "BULB"
        }
        
        var fixedShutterSpeed = shutterSpeed
        
        // For some reason some cameras returns shutter speeds as 300/10 = 30 seconds.
        if fixedShutterSpeed.value >= 1 {
            while fixedShutterSpeed.denominator >= 10, fixedShutterSpeed.denominator.remainder(dividingBy: 10) == 0 {
                fixedShutterSpeed = ShutterSpeed(numerator: fixedShutterSpeed.numerator/10, denominator: fixedShutterSpeed.denominator/10)
            }
        }
        
        guard fixedShutterSpeed.denominator != 1 else {
            
            var string: String = ""
            if formattingOptions.contains(.forceIntegersToDouble) {
                string = "\(fixedShutterSpeed.value)"
            } else {
                string = "\(fixedShutterSpeed.value.toString)"
            }
            
            if formattingOptions.contains(.appendQuotes) {
                return "\(string)\""
            } else {
                return "\(string)"
            }
        }
        
        if formattingOptions.contains(.forceIntegersToDouble) {
            return "\(fixedShutterSpeed.numerator)/\(fixedShutterSpeed.denominator)"
        } else {
            return "\(fixedShutterSpeed.numerator.toString)/\(fixedShutterSpeed.denominator.toString)"
        }
    }
    
    /// Attempts to parse a shutter speed from a given string
    ///
    /// - Parameter string: The string representation of a shutter speed
    /// - Returns: A parsed shutter speed if one could be calculated
    public func shutterSpeed(from string: String) -> ShutterSpeed? {
        
        guard string.lowercased() != "bulb" else {
            return ShutterSpeed.bulb
        }
        
        let trimmedString = string.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
        
        if let timeInterval = TimeInterval(trimmedString) {
            return ShutterSpeed(numerator: timeInterval, denominator: 1)
        }
        
        return ShutterSpeed(fractionString: trimmedString)
    }
}

fileprivate extension ShutterSpeed {
    
    init?(fractionString: String) {
        
        guard let fractionRegex = try? NSRegularExpression(pattern: "^(\\d*|\\d*\\.\\d*)\\/(\\d*|\\d*\\.\\d*)$", options: [.anchorsMatchLines]), let match = fractionRegex.firstMatch(in: fractionString, options: []
            , range: NSRange(fractionString.startIndex..., in: fractionString)) else {
            return nil
        }
        
        guard let numeratorRange = Range(match.range(at: 1), in: fractionString) else {
            return nil
        }
        guard let denominatorRange = Range(match.range(at: 2), in: fractionString) else {
            return nil
        }
        
        let numeratorString = fractionString[numeratorRange]
        let denominatorString = fractionString[denominatorRange]
        
        guard let numerator = Double(numeratorString) else { return nil }
        guard let denominator = Double(denominatorString) else { return nil }
        
        self.init(numerator: numerator, denominator: denominator)
    }
}
