//
//  Data+Mutate.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        guard let newData = string.data(using: encoding) else { return }
        self.append(newData)
    }
}
