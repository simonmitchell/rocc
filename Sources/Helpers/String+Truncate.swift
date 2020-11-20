//
//  String+Truncate.swift
//  Rocc
//
//  Created by Simon Mitchell on 14/03/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension String {
    /// Truncates the string to the specified length number of characters and appends an optional trailing string if longer. (https://gist.github.com/budidino/8585eecd55fd4284afaaef762450f98e)
    /// - Parameters:
    ///   - length: Desired maximum lengths of a string
    ///   - trailing: A 'String' that will be appended after the truncation.
    func trunc(length: Int, trailing: String = "…") -> String {
        return count > length ? prefix(length) + trailing : self
    }
}

