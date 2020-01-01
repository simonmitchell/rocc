//
//  SonyXMLParsers.swift
//  Rocc
//
//  Created by Simon Mitchell on 12/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import os.log

final class SonyCameraParser: NSObject, XMLParserDelegate {
    
    typealias CompletionHandler = (_ device: SonyCameraDevice?, _ error: Error?) -> Void
    
    /// The parsed device, only available once parsing has finished.
    var device: SonyCameraDevice?
    
    /// Completion handler called when parsing has finished.
    var completion: CompletionHandler?
    
    private var deviceDictionary: [AnyHashable : Any] = [:]
    
    private var xmlParser: XMLParser?
    
    private var currentElement: String = ""
    
    private var foundCharacters: String = ""
    
    /// Represents the current scope of the XML parser
    private var scope: [String] = []
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "SonyCameraXMLParser")
    
    let xmlString: String
    
    init(xmlString string: String) {
        xmlString = string
        super.init()
    }
    
    func parse(completion: @escaping CompletionHandler) {
        
        self.completion = completion
        
        guard let data = xmlString.data(using: .utf8) else {
            completion(nil, SonyCameraParserError.couldntCreateData)
            Logger.log(message: "Parser failed, couldn't create Data from XML string", category: "SonyCameraXMLParser")
            os_log("Parse failed, couldn't create Data from XML string", log: log, type: .error)
            return
        }
        
        xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        Logger.log(message: "Beginning parsing", category: "SonyCameraXMLParser")
        os_log("Beginning parsing", log: log, type: .debug)
    }
    
    private var services: [[AnyHashable : Any]] = []
    
    private var currentService: [AnyHashable : Any] = [:]
    
    private var webApiDeviceInfo: [AnyHashable : Any] = [:]
    
    private var webApiServices: [[AnyHashable : Any]] = []
    
    private var currentWebApiService: [AnyHashable : Any] = [:]
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        scope.append(elementName)
        
        switch elementName {
        case "serviceList":
            services = []
            currentService = [:]
        case "av:X_ScalarWebAPI_DeviceInfo":
            webApiDeviceInfo = [:]
            webApiServices = []
            currentWebApiService = [:]
        default:
            break
        }
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
        
        switch elementName {
        case "serviceList":
            deviceDictionary[elementName] = services
        case "service":
            services.append(currentService)
            currentService = [:]
        case "av:X_ScalarWebAPI_Service":
            webApiServices.append(currentWebApiService)
            currentWebApiService = [:]
        case "av:X_ScalarWebAPI_ServiceList":
            webApiDeviceInfo[elementName] = webApiServices
        case "av:X_ScalarWebAPI_DeviceInfo":
            deviceDictionary[elementName] = webApiDeviceInfo
        default:
            
            // We are inside a service object
            guard !foundCharacters.isEmpty, scope.count >= 2 else {
                return
            }
            
            let containingScope = scope[scope.count - 2]
            
            switch containingScope {
            case "service":
                currentService[elementName] = foundCharacters
            case "av:X_ScalarWebAPI_DeviceInfo":
                webApiDeviceInfo[elementName] = foundCharacters
            case "device":
                deviceDictionary[elementName] = foundCharacters
            case "av:X_ScalarWebAPI_Service":
                currentWebApiService[elementName] = foundCharacters
            default:
                break
            }
            
            break
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        device = SonyCameraDevice(dictionary: deviceDictionary)
        completion?(device, nil)
        Logger.log(message: "Parser did end document with success: \(device != nil)", category: "SonyCameraXMLParser")
        os_log("Parser did end document", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.log(message: "Parser error occured: \(parseError.localizedDescription)", category: "SonyCameraXMLParser")
        os_log("Parse error occured: %@", log: log, type: .error, parseError.localizedDescription)
        completion?(nil, parseError)
    }
    
    enum SonyCameraParserError: Error {
        case couldntCreateData
    }
}

final class SonyTransferDeviceParser: NSObject, XMLParserDelegate {
    
    typealias CompletionHandler = (_ device: SonyTransferDevice?, _ error: Error?) -> Void
    
    /// The parsed device, only available once parsing has finished.
    var device: SonyTransferDevice?
    
    /// Completion handler called when parsing has finished.
    var completion: CompletionHandler?
    
    private var deviceDictionary: [AnyHashable : Any] = [:]
    
    private var xmlParser: XMLParser?
    
    private var currentElement: String = ""
    
    private var foundCharacters: String = ""
    
    /// Represents the current scope of the XML parser
    private var scope: [String] = []
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "TransferDeviceXMLParser")
    
    let xmlString: String
    
    init(xmlString string: String) {
        xmlString = string
        super.init()
    }
    
    func parse(completion: @escaping CompletionHandler) {
        
        self.completion = completion
        
        guard let data = xmlString.data(using: .utf8) else {
            completion(nil, SonyCameraParserError.couldntCreateData)
            Logger.log(message: "Parse failed, couldn't create Data from XML string", category: "SonyTransferDeviceXMLParser")
            os_log("Parse failed, couldn't create Data from XML string", log: log, type: .error)
            return
        }
        
        xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        Logger.log(message: "Beginning parsing", category: "SonyTransferDeviceXMLParser")
        os_log("Beginning parsing", log: log, type: .debug)
    }
    
    private var services: [[AnyHashable : Any]] = []
    
    private var currentService: [AnyHashable : Any] = [:]
    
    private var webApiDeviceInfo: [AnyHashable : Any] = [:]
    
    private var webApiServices: [[AnyHashable : Any]] = []
    
    private var currentWebApiService: [AnyHashable : Any] = [:]
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        scope.append(elementName)
        
        switch elementName {
        case "serviceList":
            services = []
            currentService = [:]
        case "av:X_ScalarWebAPI_DeviceInfo":
            webApiDeviceInfo = [:]
            webApiServices = []
            currentWebApiService = [:]
        default:
            break
        }
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
        
        switch elementName {
        case "serviceList":
            deviceDictionary[elementName] = services
        case "service":
            services.append(currentService)
            currentService = [:]
        case "av:X_ScalarWebAPI_DeviceInfo":
            deviceDictionary[elementName] = webApiDeviceInfo
        default:
            
            // We are inside a service object
            guard !foundCharacters.isEmpty, scope.count >= 2 else {
                return
            }
            
            let containingScope = scope[scope.count - 2]
            
            switch containingScope {
            case "service":
                currentService[elementName] = foundCharacters
            case "av:X_ScalarWebAPI_DeviceInfo":
                webApiDeviceInfo[elementName] = foundCharacters
            case "device":
                deviceDictionary[elementName] = foundCharacters
            case "av:X_ScalarWebAPI_Service":
                currentWebApiService[elementName] = foundCharacters
            default:
                break
            }
            
            break
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        device = SonyTransferDevice(dictionary: deviceDictionary)
        completion?(device, nil)
        Logger.log(message: "Parser did end document with success: \(device != nil)", category: "SonyTransferDeviceXMLParser")
        os_log("Parser did end document", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.log(message: "Parser error occured: \(parseError.localizedDescription)", category: "SonyTransferDeviceXMLParser")
        os_log("Parse error occured: %@", log: log, type: .error, parseError.localizedDescription)
        completion?(nil, parseError)
    }
    
    enum SonyCameraParserError: Error {
        case couldntCreateData
    }
}

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
            case "X_DeviceInfo":
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
