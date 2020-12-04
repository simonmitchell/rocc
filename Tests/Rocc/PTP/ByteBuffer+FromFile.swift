//
//  ByteBuffer+FromFile.swift
//  RoccTests
//
//  Created by Simon Mitchell on 27/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation
@testable import Rocc

extension Bundle {
        
    func byteBuffer(named: String) -> ByteBuffer {
        let fileUrl = url(forResource: named, withExtension: "hexstring")!
        let string = try! String(contentsOf: fileUrl)
        return ByteBuffer(hexString: string)
    }
}
