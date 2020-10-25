//
//  SOAPRequestBody.swift
//  Rocc
//
//  Created by Simon Mitchell on 15/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import os.log

import Foundation

struct SOAPRequestBody {
    
    let bodyXML: String
    
    let headerXML: String?
}

extension SOAPRequestBody: RequestBody {
    
    var contentType: String? {
        return "text/xml; charset=\"utf-8\""
    }
    
    func payload() -> Data? {
        var stringPayload = """
                            <?xml version="1.0" encoding="utf-8"?>
                            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                            """
        if let headerXMLString = headerXML {
            stringPayload.append("\n\t<s:Header>")
            headerXMLString.enumerateLines { (line, stop) in
                stringPayload.append("\n\t\t\(line)")
            }
            stringPayload.append("\n\t</s:Header>")
        }
        
        stringPayload.append("\n\t<s:Body>")
        bodyXML.enumerateLines { (line, stop) in
            stringPayload.append("\n\t\t\(line)")
        }
        stringPayload.append("\n\t</s:Body>\n</s:Envelope>")
        
        return stringPayload.data(using: .utf8)
    }
}

internal final class SOAPResponseParser: NSObject, XMLParserDelegate {
    
    typealias CompletionHandler = (_ device: [AnyHashable : Any]?, _ error: Error?) -> Void
    
    /// The parsed device, only available once parsing has finished.
    var response: [AnyHashable : Any] = [:]
    
    /// Completion handler called when parsing has finished.
    var completion: CompletionHandler?
    
    private var xmlParser: XMLParser?
    
    private var currentElement: String = ""
    
    private var foundCharacters: String = ""
    
    /// Represents the current scope of the XML parser
    private var scope: [String] = []
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "SOAPResponseXMLParser")
    
    let xmlString: String
    
    let responseTag: String
    
    init(xmlString string: String, responseTag: String) {
        xmlString = string
        self.responseTag = responseTag
        super.init()
    }
    
    func parse(completion: @escaping CompletionHandler) {
        
        self.completion = completion
        
        guard let data = xmlString.data(using: .utf8) else {
            completion(nil, UPnPDeviceParserError.couldntCreateData)
            Logger.log(message: "Parse failed, couldn't create Data from XML string", category: "SOAPResponseXMLParser", level: .error)
            os_log("Parse failed, couldn't create Data from XML string", log: log, type: .error)
            return
        }
        
        xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        Logger.log(message: "Beginning parsing", category: "SOAPResponseXMLParser", level: .debug)
        os_log("Beginning parsing", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        scope.append(elementName)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        guard scope.last == elementName else { return }
        
        foundCharacters = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
        
        defer {
            currentElement = scope.removeLast()
            foundCharacters = ""
        }
        
        // We are inside the device info object
        guard !foundCharacters.isEmpty, scope.count >= 2 else {
            return
        }
        
        let containingScope = scope[scope.count - 2]
        
        guard containingScope == responseTag else {
            return
        }
            
        response[elementName] = foundCharacters
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completion?(response.isEmpty ? nil : response, nil)
        Logger.log(message: "Parser did end document with success: \(!response.isEmpty)", category: "SOAPResponseXMLParser", level: .debug)
        os_log("Parser did end document", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.log(message: "Parse error occured: \(parseError.localizedDescription)", category: "SOAPResponseXMLParser", level: .error)
        os_log("Parse error occured: %@", log: log, type: .error, parseError.localizedDescription)
        completion?(nil, parseError)
    }
    
    enum UPnPDeviceParserError: Error {
        case couldntCreateData
    }
}

extension RequestResponse {
    
    func parseSOAPResponse(_ completion: @escaping SOAPResponseParser.CompletionHandler, tag: String) {
        guard let string = string else {
            completion(nil, nil)
            return
        }
        let parser = SOAPResponseParser(xmlString: string, responseTag: tag)
        parser.parse(completion: completion)
    }
}
