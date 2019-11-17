//
//  SonyPTPIPCamera+FunctionSupport.swift
//  Rocc
//
//  Created by Simon Mitchell on 17/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension SonyPTPIPDevice {
    
    func supportsFunction<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        
        var supported: Bool = false
                
        // If the function has a related PTP property value
        if let deviceInfo = deviceInfo, let propTypeCodes = function.function.ptpDevicePropertyCodes {
                        
            // Check that the related property value is supported
            supported = propTypeCodes.contains { (functionPropCode) -> Bool in
                return deviceInfo.supportedDeviceProperties.contains(functionPropCode)
            }
            if !supported {
                callback(false, nil, nil)
                return
            }
        }
                
        if let latestEvent = lastEvent, let _ = latestEvent.supportedFunctions {
            latestEvent.supportsFunction(function, callback: callback)
            return
        }
        
        // Fallback for functions that aren't related to a particular camera prop type, or that function differently to the PTP spec!
        switch function.function {
        case .ping:
            callback(true, nil, nil)
        //TODO: Finish implementing!
        default:
            callback(false, nil, nil)
        }
    }
    
}
