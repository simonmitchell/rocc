//
//  CanonCamera+Model.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

struct Canon {
    
    struct Camera {
        
        enum Model: String, CameraModel, CaseIterable {
            
            var latestFirmwareVersion: String? {
                //TODO: Research this!
                return nil
            }
            
            case EOS_R = "Canon EOS R"
            case EOS_4000D = "Canon EOS 4000D"
            // TODO: Populate all models!
            
            var friendlyName: String {
                switch self {
                case .EOS_R: return "EOS R"
                case .EOS_4000D: return "EOS 400D"
                }
            }
        }
    }
}
