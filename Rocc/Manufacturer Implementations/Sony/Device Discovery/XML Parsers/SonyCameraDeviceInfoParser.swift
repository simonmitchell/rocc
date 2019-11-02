//
//  SonyCameraDeviceInfoParser.swift
//  Rocc
//
//  Created by Simon Mitchell on 02/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

class SonyCameraDeviceInfoParser: NSObject, XMLParserDelegate {
    
    typealias CompletionHandler = (_ device: SonyDeviceInfo?, _ error: Error?) -> Void
    
    /// The parsed device info, only available once parsing has finished.
    var deviceInfo: SonyDeviceInfo?
    
    /// Completion handler called when parsing has finished.
    var completion: CompletionHandler?
    
    private var deviceDictionary: [AnyHashable : Any] = [:]
    
    private var xmlParser: XMLParser?
    
    private var currentElement: String = ""
    
    private var foundCharacters: String = ""
    
    private var apps: [[AnyHashable : Any]] = []
    
    private var currentApp: [AnyHashable : Any] = [:]
    
    /// Represents the current scope of the XML parser
    private var scope: [String] = []
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "DeviceInfoXMLParser")
    
    let xmlString: String
    
    init(xmlString string: String) {
        xmlString = string
        super.init()
    }
    
    func parse(completion: @escaping CompletionHandler) {
        
        self.completion = completion
        
        guard let data = xmlString.data(using: .utf8) else {
            completion(nil, SonyCameraParserError.couldntCreateData)
            Logger.log(message: "Parser failed, couldn't create Data from XML string", category: "DeviceInfoXMLParser")
            os_log("Parse failed, couldn't create Data from XML string", log: log, type: .error)
            return
        }
        
        xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        Logger.log(message: "Beginning parsing", category: "DeviceInfoXMLParser")
        os_log("Beginning parsing", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        scope.append(elementName)
        
        if elementName == "X_PlayMemoriesCameraApps_App" {
            currentApp = [:]
        }
        
        os_log("Parser did start element: %@\nCurrent scope:%@", log: log, type: .debug, elementName, scope)
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
            os_log("Parser did end element: %@\nCurrent scope:%@", log: log, type: .debug, elementName, scope)
        }
        
        switch elementName {
        case "X_PlayMemoriesCameraApps_App":
            apps.append(currentApp)
        case "X_InstalledPlayMemoriesCameraApps":
            deviceDictionary["X_InstalledPlayMemoriesCameraApps"] = apps
        default:
            
            // We are inside the device info object
            guard !foundCharacters.isEmpty, scope.count >= 2 else {
                return
            }
            
            let containingScope = scope[scope.count - 2]
            
            switch containingScope {
            case "X_PlayMemoriesCameraApps_App":
                currentApp[elementName] = foundCharacters
            case "X_DeviceInfo", "X_DigitalImagingDeviceInfo":
                deviceDictionary[elementName] = foundCharacters
            default:
                break
            }
            
            break
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        deviceInfo = SonyDeviceInfo(dictionary: deviceDictionary)
        completion?(deviceInfo, nil)
        Logger.log(message: "Parser did end document with success: \(deviceInfo != nil)", category: "DeviceInfoXMLParser")
        os_log("Parser did end document", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.log(message: "Parse error occured: \(parseError.localizedDescription)", category: "DeviceInfoXMLParser")
        os_log("Parse error occured: %@", log: log, type: .error, parseError.localizedDescription)
        completion?(nil, parseError)
    }
    
    enum SonyCameraParserError: Error {
        case couldntCreateData
    }
}
