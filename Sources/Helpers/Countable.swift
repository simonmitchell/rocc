//
//  Countable.swift
//  Rocc
//
//  Created by Simon Mitchell on 16/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

/// A simple protocol for anything which has a count or length
protocol Countable {
    var count: Int { get }
}

extension Array: Countable {
    
}

extension String: Countable {
    
}

extension Int: Countable {
    var count: Int {
        return self
    }
}

extension Array where Element : Countable {
    
    /// Returns the elements and sub-ranges of each element that we would need to access in order to construct the equivalent
    /// of flatMapping the elements and then accessing the given range.
    ///
    /// - Important: The `subRange` for each returned element reflects the range within the element itself, rather than
    /// the flatMapped array as a whole!
    ///
    /// - Parameter range: The range of elements to return elements and sub-ranges for.
    /// - Returns: An array of each element and the sub-range that should be used to construct a flatMap of the desired total range.
    func childRangesCovering(range: Range<Int>) -> [(element: Element, subRange: Range<Int>)] {
        
        // If the range's count isn't greater than zero don't bother with any further logic
        guard range.count > 0 else { return [] }
        // Make sure the ranges lowerBound is less than it's upperBound!
        guard range.lowerBound < range.upperBound else { return [] }
        
        // Clamp the total range to the range of self
        let totalCount = self.reduce(0, { $0 + $1.count })
        
        // If the sum of our countable elements is zero, then we cannot return a valid set of sub-ranges
        guard totalCount > 0 else {
            return []
        }
        
        let clampedRange = ClosedRange(uncheckedBounds: (range.lowerBound, range.upperBound - 1)).clamped(to: 0...totalCount-1)
        
        guard !clampedRange.isEmpty else {
            return []
        }
        
        var constructedCount: Int = 0
        var idx: Int = 0
        var elementUpperBound: Int = 0
        var elementLowerBound: Int = 0
        
        var flatRange: [(element: Element, subRange: Range<Int>)] = []
        
        while constructedCount < clampedRange.count && idx < self.count {
            
            let countableElement = self[idx]
            let elementCount = countableElement.count
            
            // If the element has a zero count, then let's skip it!
            guard elementCount > 0 else {
                idx += 1
                continue
            }
            
            elementUpperBound += elementCount
            
            // If our target range's lower bound is less than this elements tracked upper bound (The upper bound of this element
            // assuming we had flatMapped self)
            guard clampedRange.lowerBound < elementUpperBound else {
                idx += 1
                elementLowerBound += elementCount
                continue
            }
                        
            let remainingRangeLength = clampedRange.count - constructedCount
            // Create a range starting at zero (sub-range within this countable element) but clamped to the size of the current element too!
            let unClampedLowerBound = Swift.max(0, clampedRange.lowerBound - elementLowerBound)
            let unClampedSubRange = ClosedRange(uncheckedBounds: (unClampedLowerBound, unClampedLowerBound + remainingRangeLength - 1))
            let subRange = unClampedSubRange.clamped(to: 0...(elementCount-1))
            
            flatRange.append((countableElement, Range(subRange)))
            
            // Increment the total count of returned items by the subRange's length from this particular element
            constructedCount += subRange.count
            elementLowerBound += elementCount
            idx += 1
        }
        
        return flatRange
    }
    
    /// Returns the elements and sub-ranges of each element that we would need to access in order to construct the equivalent
    /// of flatMapping the elements and then accessing the given range.
    ///
    /// - Important: The `subRange` for each returned element reflects the range within the element itself, rather than
    /// the flatMapped array as a whole!
    ///
    /// - Parameter range: The range of elements to return elements and sub-ranges for.
    /// - Returns: An array of each element and the sub-range that should be used to construct a flatMap of the desired total range.
    func childRangesCovering(range: ClosedRange<Int>) -> [(element: Element, subRange: Range<Int>)] {
        return childRangesCovering(range: Range(range))
    }
}
