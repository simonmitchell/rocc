//
//  ByteBuffer.swift
//  CCKit
//
//  Created by Simon Mitchell on 30/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

typealias Byte = UInt8
typealias Word = UInt16
typealias DWord = UInt32
typealias QWord = UInt64

extension Data {
    
    /// Converts a `Data` object to it's `UInt8` byte array equivalent
    var toBytes: [Byte] {
        let byteCount = count / MemoryLayout<UInt8>.size
        // create an array of Uint8
        var byteArray = [UInt8](repeating: 0, count: byteCount)
        // copy bytes into array
        copyBytes(to: &byteArray, count: byteCount)
        return byteArray
    }
    
    init(_ byteBuffer: ByteBuffer) {
        let bytes = byteBuffer.bytes.compactMap({ $0 })
        self.init(bytes: bytes, count: bytes.count)
    }
}

/// ByteBuffer is a simple struct for manipulating and accessing bytes in a little-endian manner.
struct ByteBuffer {
    
    /// The raw array of bytes the buffer represents
    var bytes: [Byte?] = []
    
    //MARK: - Writing -
    
    private mutating func setLittleEndian(offset: UInt, value: Int, nBytes: UInt) {
        for i in 0..<nBytes {
            // >> 8 * i shifts a whole byte to the right adding 0s to replace missing bits
            // (say i = 1) 01010101 11101110 01010101 01010101 -> 00000000 01010101 11101110 01010101
            // & Byte(0xff) does a logical AND between the shifted bits and 00000000 00000000 00000000 11111111
            // so 00000000 01010101 11101110 01010101 & 0xff -> 00000000 00000000 00000000 01010101
            bytes[safe: offset + i] = Byte((value >> (8 * i)) & Int(0xff))
        }
    }
    
    private func getLittleEndian(offset: UInt, nBytes: UInt) -> Int? {
        
        var value: Int = 0
        for i in 0..<nBytes {
            guard let byte = bytes[safe: offset + i] else { return nil }
            value = value + Int(byte) << (8 * i)
        }
        return value
    }
    
    mutating func append(data: Data) {
        bytes.append(contentsOf: data.toBytes)
    }
    
    mutating func append<T: FixedWidthInteger>(_ value: T) {
        // Special case for byte
        if let byte = value as? Byte {
            bytes.append(byte)
        } else {
            setLittleEndian(offset: UInt(bytes.count), value: Int(value), nBytes: UInt(MemoryLayout<T>.size))
        }
    }
    
    mutating func append(bytes value: [Byte]) {
        bytes.append(contentsOf: value)
    }
    
    mutating func append(wChar character: Character) {
        // As described in "PIMA 15740:2000", characters are encoded in PTP as
        // ISO10646 2-byte characters.
        guard let utf16 = character.unicodeScalars.first?.utf16.first else { return }
        append(utf16)
    }
    
    mutating func append(wString string: String, includingLength: Bool = false) {
        
        if includingLength {
            let lengthWithNull = string.count + 1;
            append(Byte(lengthWithNull));
        }
        string.forEach { (character) in
            append(wChar: character)
        }
        append(0);
    }
    
    mutating func clear() {
        bytes = []
    }
    
    private mutating func set<T: FixedWidthInteger>(_ value: T, at offset: UInt) {
        setLittleEndian(offset: offset, value: Int(value), nBytes: UInt(MemoryLayout<T>.size))
    }
    
    func sliced(_ offset: Int, _ end: Int? = nil) -> ByteBuffer {
        let internalEnd = end ?? bytes.endIndex
        // Offset must be greater than startIndex
        var fixedOffset = max(offset, bytes.startIndex)
        // End must be less than end endIndex
        let fixedEnd = min(internalEnd, bytes.endIndex)
        // If our offset is past the end of our data, then we've asked for non-existent data so return that!
        guard fixedOffset < bytes.count else { return ByteBuffer() }
        // Offset must be less than fixedEnd
        fixedOffset = min(fixedEnd, fixedOffset)
        return ByteBuffer(bytes: Array(bytes[fixedOffset..<fixedEnd]))
    }
    
    mutating func slice(_ offset: Int, _ end: Int? = nil) {
        let internalEnd = end ?? bytes.endIndex
        let fixedEnd = min(internalEnd, bytes.endIndex)
        let fixedOffset = max(offset, bytes.startIndex)
        // If offset >= end then we're after the end of the data, so we just create a new data array
        guard fixedOffset < fixedEnd else {
            bytes = []
            return
        }
        bytes = Array(bytes[fixedOffset..<fixedEnd])
    }
    
    //MARK: - Reading -
    
    var toHex: String {
                
        let hexDigits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        
        var hexString = ""
        
        bytes.forEach { (byte) in
            let int = Int(byte ?? 0)
            hexString.append(hexDigits[int >> 4])
            hexString.append(hexDigits[int & 0x0f])
            hexString.append(contentsOf: " ")
        }
        
        return hexString
    }
    
    var toString: String {
        var s = ""
        var separator = ""
        bytes.forEach { (x) in
            guard let byte = x else { return }
            let hex = String(byte, radix: 16, uppercase: false)
            s = s + separator + (hex.count == 1 ? "0" : "") + hex
            separator = " "
        }
        return s
    }
    
    var length: Int {
        return bytes.count
    }
    
    init() { }
    
    init(bytes: [Byte?]) {
        self.bytes = bytes
    }
    
    init(hexString: String) {
        
        let hexCharacters = "0123456789abcdefABCDEF"
        let fixedString = hexString.filter { (character) -> Bool in
            hexCharacters.contains(character)
        }
        
        let length = fixedString.count

        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        
        var index = fixedString.startIndex
        
        for _ in 0..<length/2 {
            let nextIndex = fixedString.index(index, offsetBy: 2)
            if let b = UInt8(fixedString[index..<nextIndex], radix: 16) {
                bytes.append(b)
            }
            index = nextIndex
        }
        
        self.bytes = bytes
    }
}

extension ByteBuffer {
    
    func read<T: UnsignedInteger>(offset: inout UInt) -> T? {
        guard let littleEndian = getLittleEndian(offset: offset, nBytes: UInt(MemoryLayout<T>.size)) else { return nil }
        offset += UInt(MemoryLayout<T>.size)
        return T(littleEndian)
    }
    
    func read<T: SignedInteger>(offset: inout UInt) -> T? {
        guard let littleEndian = getLittleEndian(offset: offset, nBytes: UInt(MemoryLayout<T>.size)) else { return nil }
        var returnValue: T?
        switch T() {
        case _ as Int8:
            if littleEndian > UInt8.max || littleEndian < UInt8.min {
                returnValue = Int8(littleEndian) as? T
            } else {
                returnValue = Int8(bitPattern: UInt8(littleEndian)) as? T
            }
        case _ as Int16:
            if littleEndian > UInt16.max || littleEndian < UInt16.min {
                returnValue = Int16(littleEndian) as? T
            } else {
                returnValue = Int16(bitPattern: UInt16(littleEndian)) as? T
            }
        case _ as Int32:
            if littleEndian > UInt32.max || littleEndian < UInt32.min {
                returnValue = Int32(littleEndian) as? T
            } else {
                returnValue = Int32(bitPattern: UInt32(littleEndian)) as? T
            }
        case _ as Int64:
            if littleEndian > UInt64.max || littleEndian < UInt64.min {
                returnValue = Int64(littleEndian) as? T
            } else {
                returnValue = Int64(bitPattern: UInt64(littleEndian)) as? T
            }
        default:
            return nil
        }
        guard let _returnValue = returnValue else { return nil }
        offset += UInt(MemoryLayout<T>.size)
        return _returnValue
    }
    
    func read(offset: inout UInt, withCount: Bool = true) -> String? {
        
        if withCount {
            
            guard let length: Byte = read(offset: &offset) else { return nil }
            var string: String = ""
            for i in 0..<UInt(length) {
                // If we can't parse the character then we must be at the end of the string
                guard let character = self[wChar: offset + UInt(MemoryLayout<Word>.size) * i] else {
                    if string.count > 0 {
                        // Don't append `UInt(MemoryLayout<Word>.size)` because we don't have a terminating \u{0000}
                        offset += UInt(string.count * MemoryLayout<Word>.size)
                    }
                    return string.count > 0 ? string : nil
                }
                guard character != "\u{0000}" else {
                    offset += UInt(string.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
                    return string.count > 0 ? string : nil
                }
                string.append(character)
            }
            
            if string.count > 0 {
                offset += UInt(string.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
            }
            
            return string.count > 0 ? string : nil
            
        } else {
            
            var string: String = ""
            var i = offset
            while i < bytes.count {
                // If we can't parse the character then we must be at the end of the string
                guard let character = self[wChar: offset + UInt(MemoryLayout<Word>.size) * i] else {
                    if string.count > 0 {
                        // Don't append `UInt(MemoryLayout<Word>.size)` because we don't have a terminating \u{0000}
                        offset += UInt(string.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
                    }
                    return string.count > 0 ? string : nil
                }
                guard character != "\u{0000}" else {
                    offset += UInt(string.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
                    return string.count > 0 ? string : nil
                }
                string.append(character)
                i += UInt(MemoryLayout<Word>.size)
            }
            
            if string.count > 0 {
                offset += UInt(string.count * MemoryLayout<Word>.size) + UInt(MemoryLayout<Word>.size)
            }
            
            return string.count > 0 ? string : nil
        }
    }
    
    func read(offset: inout UInt) -> [Word]? {
        guard let length: DWord = read(offset: &offset) else { return nil }
        var arrayElements: [Word] = []
        for _ in 0..<UInt(length) {
            guard let word: Word = self.read(offset: &offset) else { continue }
            arrayElements.append(word)
        }
        return arrayElements
    }
}

extension ByteBuffer {
    
    subscript (int8 index: UInt) -> Int8? {
        get {
            var _index = index
            return read(offset: &_index)
        }
        set {
            guard let newValue = newValue else { return }
            set(newValue, at: index)
        }
    }
    
    subscript (index: UInt) -> Byte? {
        get {
            return bytes[safe: index]
        }
        set {
            bytes[safe: index] = newValue
        }
    }
    
    subscript (word index: UInt) -> Word? {
        get {
            var _index = index
            return read(offset: &_index)
        }
        set {
            guard let newValue = newValue else { return }
            set(newValue, at: index)
        }
    }
    
    subscript (int16 index: UInt) -> Int16? {
        get {
            var _index = index
            return read(offset: &_index)
        }
        set {
            guard let newValue = newValue else { return }
            set(newValue, at: index)
        }
    }
    
    subscript (dWord index: UInt) -> DWord? {
        get {
            var _index = index
            return read(offset: &_index)
        }
        set {
            guard let newValue = newValue else { return }
            set(newValue, at: index)
        }
    }
    
    subscript (int32 index: UInt) -> Int32? {
        get {
            var _index = index
            return read(offset: &_index)
        }
        set {
            guard let newValue = newValue else { return }
            set(newValue, at: index)
        }
    }
    
    subscript (qWord index: UInt) -> QWord? {
        get {
            var _index = index
            return read(offset: &_index)
        }
        set {
            guard let newValue = newValue else { return }
            set(newValue, at: index)
        }
    }
    
    subscript (int64 index: UInt) -> Int64? {
        get {
            var _index = index
            return read(offset: &_index)
        }
        set {
            guard let newValue = newValue else { return }
            set(newValue, at: index)
        }
    }
    
    subscript (wStringWithoutCount index: UInt) -> String? {
        get {
            var offset = index
            return read(offset: &offset)
        }
        set {
            print("Setting of wString by subscript is not yet supported!")
        }
    }
    
    subscript (wString index: UInt) -> String? {
        get {
            var offset = index
            return read(offset: &offset, withCount: false)
        }
        set {
            print("Setting of wString (with length byte) by subscript is not yet supported!")
        }
    }
    
    subscript (wChar index: UInt) -> String? {
        get {
            guard let word = self[word: index] else { return nil }
            let codeUnits = [word]
            return String(utf16CodeUnits: codeUnits, count: 1)
        }
        set {
            print("Setting of wChar by subscript is not yet supported!")
        }
    }
    
    subscript (wordArray index: UInt) -> [Word]? {
        get {
            var offset = index
            return read(offset: &offset)
        }
        set {
            print("Setting of word array by subscript is not yet supported!")
        }
    }
}

extension Array where Element == UInt8? {
    
    subscript (safe index: UInt) -> Element {
        get {
            return Int(index) < count ? self[Int(index)] : nil
        }
        set {
            while Int(index) >= count {
                append(nil)
            }
            self[Int(index)] = newValue
        }
    }
}

extension Array where Element: UnsignedInteger {
    
    subscript (safe index: UInt) -> Element? {
        get {
            return Int(index) < count ? self[Int(index)] : nil
        }
        set {
            guard let newValue = newValue else { return }
            while Int(index) >= count {
                append(0)
            }
            self[Int(index)] = newValue
        }
    }
}

