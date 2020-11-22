//
//  CameraParser.swift
//  Rocc
//
//  Created by Simon Mitchell on 21/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

import Foundation
import os.log

protocol SSDPCameraInfo {
    
    init(dictionary: [AnyHashable : Any]) throws
}

/// A protocol which devices discoverable over SSDP should implement
/// so they can be allocated from an XML dictionary
protocol SSDPCamera: Camera {
    
    /// Default initialiser for an `SSDPCamera`
    /// - Parameter dictionary: The XML received over SSDP as a dictionary
    init(dictionary: [AnyHashable : Any]) throws
    
    /// The UPnP services available on the device
    var services: [UPnPService]? { get }
    
    /// Updates the camera with more info from a subsequent call over SSDP
    /// - Parameter deviceInfo: The camera info from the device
    func update(with deviceInfo: SSDPCameraInfo)
}

extension Manufacturer {
    
    var deviceClasses: [SSDPCamera.Type] {
        switch self {
        case .sony:
            return [SonyAPICameraDevice.self, PTPIPCamera.self]
        case .canon:
            return [CanonPTPIPCamera.self]
        }
    }
}

final class SSDPCameraParser: NSObject, XMLParserDelegate {
    
    typealias CompletionHandler = (_ device: SSDPCamera?, _ error: Error?) -> Void
    
    /// The parsed device, only available once parsing has finished.
    var device: SSDPCamera?
    
    /// Completion handler called when parsing has finished.
    var completion: CompletionHandler?
    
    private var deviceDictionary: [AnyHashable : Any] = [:]
    
    private var xmlParser: XMLParser?
    
    private var currentElement: String = ""
    
    private var foundCharacters: String = ""
    
    /// Represents the current scope of the XML parser
    private var scope: [String] = []
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "CameraXMLParser")
    
    let xmlString: String
    
    init(xmlString string: String) {
        xmlString = string
        super.init()
    }
    
    func parse(completion: @escaping CompletionHandler) {
        
        self.completion = completion
        
        guard let data = xmlString.data(using: .utf8) else {
            completion(nil, CameraParserError.couldntCreateData)
            Logger.log(message: "Parser failed, couldn't create Data from XML string", category: "SonyCameraXMLParser", level: .error)
            os_log("Parse failed, couldn't create Data from XML string", log: log, type: .error)
            return
        }
        
        xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        Logger.log(message: "Beginning parsing", category: "SonyCameraXMLParser", level: .debug)
        os_log("Beginning parsing", log: log, type: .debug)
    }
    
    private var services: [[AnyHashable : Any]] = []
    
    private var currentService: [AnyHashable : Any] = [:]
    
    private var webApiDeviceInfo: [AnyHashable : Any] = [:]
    
    private var webApiServices: [[AnyHashable : Any]] = []
    
    private var currentWebApiService: [AnyHashable : Any] = [:]
    
    private var webApiImagingDevice: [AnyHashable : Any]? = [:]
    
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
        case "av:X_ScalarWebAPI_ImagingDevice":
            webApiImagingDevice = [:]
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
        case "av:X_ScalarWebAPI_ImagingDevice":
            webApiDeviceInfo[elementName] = webApiImagingDevice
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
            case "av:X_ScalarWebAPI_ImagingDevice":
                webApiImagingDevice?[elementName] = foundCharacters
            default:
                break
            }
            
            break
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        if let manufacturerString = deviceDictionary["manufacturer"] as? String,
           let manufacturer = Manufacturer(rawValue: manufacturerString) {
            device = manufacturer.deviceClasses.compactMap({
                return try? $0.init(dictionary: deviceDictionary)
            }).first
        }
        
        completion?(device, nil)
        Logger.log(message: "Parser did end document with success: \(device != nil)", category: "SonyCameraXMLParser", level: .debug)
        os_log("Parser did end document", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.log(message: "Parser error occured: \(parseError.localizedDescription)", category: "SonyCameraXMLParser", level: .error)
        os_log("Parse error occured: %@", log: log, type: .error, parseError.localizedDescription)
        completion?(nil, parseError)
    }
    
    enum CameraParserError: Error {
        case couldntCreateData
    }
}
