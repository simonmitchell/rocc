//
//  Wrapper.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/05/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

public struct Wrapper<T> { }

extension Wrapper: Equatable where T == Void {
    public static func ==(lhs: Wrapper<T>, rhs: Wrapper<T>) -> Bool {
        return true
    }
}
