//
//  Collection+AsyncForEach.swift
//  Rocc
//
//  Created by Simon Mitchell on 21/11/2023.
//  Copyright © 2023 Simon Mitchell. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Calls the given closure on each element in the sequence in the same order as a for-in loop. Allowing each call of the closure to contain async code.
    ///
    /// - Note: The closure passed to `body` **must** be called for all code paths otherwise execution will not complete
    /// - Important: Do not mutate `self` in the execution of `body` as the array is iterated by index so if elements are removed or added it may result in fatal errors
    /// - Parameter body: A closure that takes an element of the sequence, and a closure to be called to progress to the next element as a parameter.
    func asyncForEach(
        body: @escaping (Element) async throws -> Void,
        done: @escaping (Error?) -> Void
    ) {
        guard !isEmpty else {
            done(nil)
            return
        }

        Task {
            for (element, index) in zip(self, indices) {
                do {
                    try await body(element)
                    if index == self.index(endIndex, offsetBy: -1) {
                        done(nil)
                    }
                } catch let error {
                    done(error)
                    break
                }
            }
        }
    }
}
