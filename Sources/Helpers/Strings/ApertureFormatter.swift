//
//  ApertureFormatter.swift
//  Rocc
//
//  Created by Simon Mitchell on 23/05/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

public class ApertureFormatter {
    
    public func string(for obj: Aperture.Value?) -> String? {
        
        guard let aperture = obj else {
            return nil
        }
        let numberFormatter = NumberFormatter()
        
        // Some apertures are represented as a decimal even when they're a whole number:
        // "9.0" vs "11". We'll use the nullability of `decimalSeperator` to unwind
        // this behaviour!
        if let decimalSeperator = aperture.decimalSeperator {
            numberFormatter.decimalSeparator = decimalSeperator
            // For the moment, we'll assume no apertures have more than one fraction digit, this seems to be the case
            // on Sony's cameras
            numberFormatter.minimumFractionDigits = 1
        } else {
            numberFormatter.minimumFractionDigits = 0
        }

        numberFormatter.maximumFractionDigits = 1
        return numberFormatter.string(from: NSNumber(value: aperture.value))
    }
    
    public func aperture(from string: String) -> Aperture.Value? {
        
        let numberFormatter = NumberFormatter()
        var decimalSeparator: String?
        
        // Parse the decimal seperator, this will always be the last non-number character in the
        // aperture
        if let decimalSeperatorCharacter = string.last(where: { (character) -> Bool in
            return !character.isNumber
        }) {
            numberFormatter.decimalSeparator = String(decimalSeperatorCharacter)
            decimalSeparator = String(decimalSeperatorCharacter)
        }
        
        guard let number = numberFormatter.number(from: string) else { return nil }
        
        return Aperture.Value(value: number.doubleValue, decimalSeperator: decimalSeparator)
    }
}
