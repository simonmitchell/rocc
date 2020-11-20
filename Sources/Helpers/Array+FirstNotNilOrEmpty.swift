//
//  Array+FirstNotNilOrEmpty.swift
//  Rocc
//
//  Created by Simon Mitchell on 14/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

/// A protocol to describe something that can either be in an empty or non-empty state for use
/// with Array.firstNotNilOrEmpty()
protocol Container {
    
    /// Whether the container is empty or not
    var isEmpty: Bool { get }
}

extension Array: Container { }
extension String: Container { }

extension Array {
    
    /// Returns the first element of the array that is neither nil or empty
    /// - Returns: The first element that is neither nil or empty
    var firstNotNilOrEmpty: Element? {
        return first(
            where: {
                switch $0 {
                case let optional as Optional<Any>:
                    switch optional {
                    case .some(let value):
                        return !(($0 as? Container)?.isEmpty ?? false)
                    default:
                        return false
                    }
                case let container as Container:
                    return !container.isEmpty
                default:
                    return true
                }
                
            }
        )
    }
}
