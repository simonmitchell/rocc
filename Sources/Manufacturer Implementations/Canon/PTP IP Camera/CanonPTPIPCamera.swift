//
//  CanonPTPIPCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

internal final class CanonPTPIPCamera: PTPIPCamera {
    
    required init(dictionary: [AnyHashable : Any]) throws {
        
        do {
            try super.init(dictionary: dictionary)
        } catch let error {
            throw error
        }
        
        // Seems on Canon cameras this actually reflects the model of camera
        let _name = dictionary["modelName"] as? String
        let _modelEnum: Canon.Camera.Model?
        if let _name = _name {
            _modelEnum = Canon.Camera.Model(rawValue: _name)
        } else {
            _modelEnum = nil
        }
                
        name = _modelEnum?.friendlyName ?? _name
        model = _modelEnum
    }
}
