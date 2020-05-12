//
//  UIImage+MultipartFormElement.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UIImage: MultipartFormElement {
    
    public func multipartDataWith(boundary: String, key: String) -> Data? {
        let jpegData = self.jpegData(compressionQuality: 1.0)
        return jpegData?.multipartDataWith(boundary: boundary, key: key, contentType: "image/jpeg", fileExtension: "jpg")
    }
}
