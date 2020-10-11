//
//  PTPFlow+Sony+Connect.swift
//  RoccTests
//
//  Created by Simon Mitchell on 27/09/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import UIKit
@testable import Rocc

extension Bundle {
    
    static let current: Bundle = Bundle(for: TestPTPPacketStream.self)
    
    func ptpTestFlow(named: String) -> TestPTPPacketStream.TestFlow {
        let fileUrl = url(forResource: named, withExtension: "json")!
        let data = try! Data(contentsOf: fileUrl)
        return try! JSONDecoder().decode(TestPTPPacketStream.TestFlow.self, from: data)
    }
}

extension TestPTPPacketStream.TestFlow {
    
    struct Sony {
        
        static let guid: String = "8810B99668841894"
        
        static let connect: TestPTPPacketStream.TestFlow = Bundle.current.ptpTestFlow(named: "PTPFlow_Sony_Connect")
        
        static let connectAlreadyOpen: TestPTPPacketStream.TestFlow = Bundle.current.ptpTestFlow(named: "PTPFlow_Sony_Connect_Already_Open")
        
        static let getEvent = Bundle.current.ptpTestFlow(named: "PTPFlow_Sony_GetEvent")
        
        static let takePicture = Bundle.current.ptpTestFlow(named: "PTPFlow_Sony_TakePic")
        
        static let functionAvailability = Bundle.current.ptpTestFlow(named: "PTPFlow_Sony_FunctionAvailability")
        
        static let performGetFunction = Bundle.current.ptpTestFlow(named: "PTPFlow_Sony_FunctionPerformGet")
        
        static let performSetFunction = Bundle.current.ptpTestFlow(named: "PTPFlow_Sony_FunctionPerformSet")
        
        static let functionSupport = Bundle.current.ptpTestFlow(named: "PTPFlow_Sony_FunctionSupport")
    }
}
