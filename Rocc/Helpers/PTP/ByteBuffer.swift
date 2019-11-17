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
    
    mutating func append(dWord value: DWord) {
        setLittleEndian(offset: UInt(bytes.count), value: Int(value), nBytes: 4)
    }
    
    mutating func append(word value: Word) {
        setLittleEndian(offset: UInt(bytes.count), value: Int(value), nBytes: 2)
    }
    
    mutating func append(int8 value: Int8) {
        setLittleEndian(offset: UInt(bytes.count), value: Int(value), nBytes: 1)
    }
    
    mutating func append(int16 value: Int16) {
        setLittleEndian(offset: UInt(bytes.count), value: Int(value), nBytes: 2)
    }
    
    mutating func append(byte value: Byte) {
        bytes.append(value)
    }
    
    mutating func append(bytes value: [Byte]) {
        bytes.append(contentsOf: value)
    }
    
    mutating func append(wChar character: Character) {
        // As described in "PIMA 15740:2000", characters are encoded in PTP as
        // ISO10646 2-byte characters.
        guard let utf16 = character.unicodeScalars.first?.utf16.first else { return }
        append(word: utf16)
    }
    
    mutating func append(wString string: String, includingLength: Bool = false) {
        
        if includingLength {
            let lengthWithNull = string.count + 1;
            append(byte: Byte(lengthWithNull));
        }
        string.forEach { (character) in
            append(wChar: character)
        }
        append(word: 0);
    }
    
    mutating func clear() {
        bytes = []
    }
    
    private mutating func set(qWord value: QWord, at offset: UInt) {
        setLittleEndian(offset: offset, value: Int(value), nBytes: 8)
    }
    
    private mutating func set(dWord value: DWord, at offset: UInt) {
        setLittleEndian(offset: offset, value: Int(value), nBytes: 4)
    }
    
    private mutating func set(word value: Word, at offset: UInt) {
        setLittleEndian(offset: offset, value: Int(value), nBytes: 2)
    }
    
    private mutating func set(int16 value: Int16, at offset: UInt) {
        setLittleEndian(offset: offset, value: Int(value), nBytes: 2)
    }
    
    private mutating func set(int8 value: Int8, at offset: UInt) {
        setLittleEndian(offset: offset, value: Int(value), nBytes: 1)
    }
    
    func sliced(_ offset: Int, _ end: Int? = nil) -> ByteBuffer {
        let internalEnd = end ?? bytes.endIndex
        let fixedOffset = max(offset, bytes.startIndex)
        let fixedEnd = min(internalEnd, bytes.endIndex)
        guard fixedOffset < bytes.count else { return ByteBuffer() }
        return ByteBuffer(bytes: Array(bytes[fixedOffset..<fixedEnd]))
    }
    
    mutating func slice(_ offset: Int, _ end: Int? = nil) {
        let internalEnd = end ?? bytes.endIndex
        let fixedOffset = max(offset, bytes.startIndex)
        let fixedEnd = min(internalEnd, bytes.endIndex)
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
    
    subscript (int8 index: UInt) -> Int8? {
        get {
            guard let littleEndian = getLittleEndian(offset: index, nBytes: 1) else {
                return nil
            }
            return Int8(bitPattern: UInt8(littleEndian))
        }
        set {
            guard let newValue = newValue else { return }
            set(int8: newValue, at: index)
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
            guard let littleEndian = getLittleEndian(offset: index, nBytes: 2) else {
                return nil
            }
            return Word(littleEndian)
        }
        set {
            guard let newValue = newValue else { return }
            set(word: newValue, at: index)
        }
    }
    
    subscript (int16 index: UInt) -> Int16? {
        get {
            guard let littleEndian = getLittleEndian(offset: index, nBytes: 2) else {
                return nil
            }
            return Int16(bitPattern: UInt16(littleEndian))
        }
        set {
            guard let newValue = newValue else { return }
            set(int16: newValue, at: index)
        }
    }
    
    subscript (dWord index: UInt) -> DWord? {
        get {
            guard let littleEndian = getLittleEndian(offset: index, nBytes: 4) else {
                return nil
            }
            return DWord(littleEndian)
        }
        set {
            guard let newValue = newValue else { return }
            set(dWord: newValue, at: index)
        }
    }
    
    subscript (qWord index: UInt) -> QWord? {
        get {
            guard let littleEndian = getLittleEndian(offset: index, nBytes: 8) else {
                return nil
            }
            return QWord(littleEndian)
        }
        set {
            guard let newValue = newValue else { return }
            set(qWord: newValue, at: index)
        }
    }
    
    subscript (wStringWithoutCount index: UInt) -> String? {
        get {
            var string: String = ""
            var i = index
            while i < bytes.count {
                guard let character = self[wChar: i], character != "\u{0000}" else {
                    return string.count > 0 ? string : nil
                }
                string.append(character)
                i += UInt(MemoryLayout<Word>.size)
            }
            return string.count > 0 ? string : nil
        }
        set {
            print("Setting of wString by subscript is not yet supported!")
        }
    }
    
    subscript (wString index: UInt) -> String? {
        get {
            guard let length = self[index] else { return nil }
            var string: String = ""
            for i in 0..<UInt(length) {
                guard let character = self[wChar: index + UInt(MemoryLayout<Byte>.size) + UInt(MemoryLayout<Word>.size) * i], character != "\u{0000}" else {
                    return string.count > 0 ? string : nil
                }
                string.append(character)
            }
            return string.count > 0 ? string : nil
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
            guard let length = self[dWord: index] else { return nil }
            var arrayElements: [Word] = []
            for i in 0..<UInt(length) {
                guard let word = self[word: index + UInt(MemoryLayout<DWord>.size) + (UInt(MemoryLayout<Word>.size) * i)] else { continue }
                arrayElements.append(word)
            }
            return arrayElements
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

