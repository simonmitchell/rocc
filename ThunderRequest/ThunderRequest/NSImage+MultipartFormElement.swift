//
//  NSImage+MultipartFormElement.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import AppKit

extension NSImage: MultipartFormElement {
    public func multipartDataWith(boundary: String, key: String) -> Data? {
        
        guard let bitmapRepresentation = representations.first(where: { $0 is NSBitmapImageRep }) as? NSBitmapImageRep else {
            return nil
        }
        guard let jpegData = bitmapRepresentation.representation(using: .jpeg, properties: [:]) else {
            return nil
        }
        return jpegData.multipartDataWith(boundary: boundary, key: key, contentType: "image/jpeg", fileExtension: "jpg")
    }
}
