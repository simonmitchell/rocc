//
//  XMLParser.swift
//  Rocc
//
//  Created by Simon Mitchell on 22/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

protocol XMLStringParser {
    
    associatedtype ReturnType
    
    init(xmlString string: String)
    
    /// The main function of the XML parser which runs parsing on the string
    /// - Parameter completion: Closure to be called when parsing is done
    func parse(completion: @escaping (_ result: Result<ReturnType, Error>) -> Void)
}
