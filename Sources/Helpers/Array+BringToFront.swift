//
//  Array+BringToFront.swift
//  Rocc
//
//  Created by Simon Mitchell on 23/02/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    mutating func move(_ element: Element, to newIndex: Index) {
        guard let oldIndex = self.firstIndex(of: element) else {
            return
        }
        move(from: oldIndex, to: newIndex)
    }
    
    func moving(_ element: Element, to newIndex: Index) -> [Element] {
        var copy = Array(self)
        copy.move(element, to: newIndex)
        return copy
    }
    
    mutating func bringToFront(_ element: Element) {
        move(element, to: startIndex)
    }
    
    func bringingToFront(_ element: Element) -> [Element] {
        var copy = Array(self)
        copy.bringToFront(element)
        return copy
    }
}

extension Array {
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other - this
        // won't rebuild array and will be super efficient.
        guard oldIndex != newIndex else { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        insert(remove(at: oldIndex), at: newIndex)
    }
}
