//
//  PTPFlow+Sony+Connect.swift
//  RoccTests
//
//  Created by Simon Mitchell on 27/09/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import UIKit
@testable import Rocc

extension TestPTPPacketStream.TestFlow {
    
    struct Canon {
        
        static let guid: String = "8810B99668841894"
        
        static let connect: TestPTPPacketStream.TestFlow = Bundle.current.ptpTestFlow(named: "PTPFlow_Canon_Connect")
        
//        static let getEvent = Bundle.current.ptpTestFlow(named: "PTPFlow_Canon_GetEvent")
//        
//        static let takePicture = Bundle.current.ptpTestFlow(named: "PTPFlow_Canon_TakePic")
//        
//        static let functionAvailability = Bundle.current.ptpTestFlow(named: "PTPFlow_Canon_FunctionAvailability")
//        
//        static let performGetFunction = Bundle.current.ptpTestFlow(named: "PTPFlow_Canon_FunctionPerformGet")
//        
//        static let performSetFunction = Bundle.current.ptpTestFlow(named: "PTPFlow_Canon_FunctionPerformSet")
//        
//        static let functionSupport = Bundle.current.ptpTestFlow(named: "PTPFlow_Canon_FunctionSupport")
    }
}
