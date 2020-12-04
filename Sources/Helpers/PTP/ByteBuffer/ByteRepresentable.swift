//
//  ByteRepresentable.swift
//  Rocc
//
//  Created by Simon Mitchell on 28/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

protocol ByteRepresentable {
    
    /// Called in order to write the object to the given byte buffer
    /// - Parameter byteBuffer: The byte buffer to append to
    func append(to byteBuffer: inout ByteBuffer)
    
    /// Reads 
    /// - Parameters:
    ///   - byteBuffer: The byte buffer to read from
    ///   - offset: The offset to read from, you MUST increment this by the size of the number of bytes read
    static func read(from byteBuffer: ByteBuffer, at offset: inout UInt) -> Self?
}

extension RawRepresentable where RawValue: ByteRepresentable {

    func append(to byteBuffer: inout ByteBuffer) {
        rawValue.append(to: &byteBuffer)
    }

    static func read(from byteBuffer: ByteBuffer, at offset: inout UInt) -> Self? {
        guard let rawValue = RawValue.read(from: byteBuffer, at: &offset) else {
            return nil
        }
        return Self(rawValue: rawValue)
    }
}
