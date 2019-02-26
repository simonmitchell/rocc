//
//  UPnPContentDirectoryServiceParser.swift
//  Rocc
//
//  Created by Simon Mitchell on 14/01/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation
import os

internal final class UPnPDevice {
    
    struct StateVariable {
        
        let sendsEvents: Bool
        let name: String
        let dataType: String
        let allowedValues: [Any]
        
        init?(dictionary: [AnyHashable : Any]) {
            
            guard let _name = dictionary["name"] as? String else {
                return nil
            }
            guard let _dataType = dictionary["dataType"] as? String else {
                return nil
            }
            name = _name
            dataType = _dataType
            allowedValues = dictionary["allowedValueList"] as? [Any] ?? []
            sendsEvents = false
        }
    }
    
    struct Action {
        
        struct Argument {
            
            let name: String
            
            let isInput: Bool
            
            let relatedStateVariable: String?
            
            init?(dictionary: [AnyHashable : Any]) {
                
                guard let _name = dictionary["name"] as? String else {
                    return nil
                }
                guard let direction = dictionary["direction"] as? String else {
                    return nil
                }
                
                relatedStateVariable = dictionary["relatedStateVariable"] as? String
                isInput = direction.lowercased() == "in"
                name = _name
            }
        }
        
        let name: String
        
        let arguments: [Argument]
        
        init?(dictionary: [AnyHashable : Any]) {
            
            guard let _name = dictionary["name"] as? String else {
                return nil
            }
            name = _name
            self.arguments = (dictionary["argumentList"] as? [[AnyHashable : Any]])?.compactMap({ Argument(dictionary: $0) }) ?? []
        }
    }
    
    enum DeviceType: String {
        case contentDirectory = "urn:upnp-org:serviceId:ContentDirectory:1"
        case connectionManager = "urn:schemas-upnp-org:service:ConnectionManager:1"
    }
    
    let type: DeviceType
    
    let stateVariables: [StateVariable]
    
    let actions: [Action]
    
    init(dictionary: [AnyHashable : Any], type: DeviceType) {
        self.type = type
        if let stateVariableDictionaries = dictionary["serviceStateTable"] as? [[AnyHashable : Any]] {
            stateVariables = stateVariableDictionaries.compactMap({ StateVariable(dictionary: $0) })
        } else {
            stateVariables = []
        }
        if let actionDictionaries = dictionary["actionList"] as? [[AnyHashable : Any]] {
            actions = actionDictionaries.compactMap({ Action(dictionary: $0) })
        } else {
            actions = []
        }
    }
    
    func actionFor(name: String) -> Action? {
        return actions.first(where: { $0.name == name })
    }
}

internal final class UPnPDeviceParser: NSObject, XMLParserDelegate {
    
    typealias CompletionHandler = (_ device: UPnPDevice?, _ error: Error?) -> Void
    
    /// The parsed device, only available once parsing has finished.
    var device: UPnPDevice?
    
    /// Completion handler called when parsing has finished.
    var completion: CompletionHandler?
    
    private var deviceDictionary: [AnyHashable : Any] = [:]
    
    private var xmlParser: XMLParser?
    
    private var currentElement: String = ""
    
    private var foundCharacters: String = ""
    
    private var stateVariables: [[AnyHashable : Any]] = []
    
    private var actions: [[AnyHashable: Any]] = []
    
    private var currentVariable: [AnyHashable : Any] = [:]
    
    private var currentAction: [AnyHashable : Any] = [:]
    
    private var currentArgument: [AnyHashable : Any] = [:]
    
    private var currentArguments: [[AnyHashable : Any]] = []
    
    private var currentAllowedValues: [Any] = []
    
    /// Represents the current scope of the XML parser
    private var scope: [String] = []
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "UPnPDeviceXMLParser")
    
    let xmlString: String
    
    let deviceType: UPnPDevice.DeviceType
    
    init(xmlString string: String, type: UPnPDevice.DeviceType) {
        xmlString = string
        deviceType = type
        super.init()
    }
    
    func parse(completion: @escaping CompletionHandler) {
        
        self.completion = completion
        
        guard let data = xmlString.data(using: .utf8) else {
            completion(nil, UPnPDeviceParserError.couldntCreateData)
            Logger.log(message: "Parse failed, couldn't create Data from XML string", category: "UPnPDeviceXMLParser")
            os_log("Parse failed, couldn't create Data from XML string", log: log, type: .error)
            return
        }
        
        xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        Logger.log(message: "Beginning parsing", category: "UPnPDeviceXMLParser")
        os_log("Beginning parsing", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        scope.append(elementName)
        
        switch elementName {
        case "stateVariable":
            currentVariable = [:]
        case "action":
            currentAction = [:]
        case "argumentList":
            currentArguments = []
        case "argument":
            currentArgument = [:]
        case "allowedValueList":
            currentAllowedValues = []
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
        
        os_log("Parser did start element: %@\nCurrent scope:%@", log: log, type: .debug, elementName, scope)
        
        defer {
            currentElement = scope.removeLast()
            foundCharacters = ""
        }
        
        switch elementName {
            
        case "argument":
            currentArguments.append(currentArgument)
        case "argumentList":
            currentAction["argumentList"] = currentArguments
        case "action":
            actions.append(currentAction)
        case "actionList":
            deviceDictionary["actionList"] = actions
        case "stateVariable":
            stateVariables.append(currentVariable)
        case "allowedValueList":
            currentVariable["allowedValueList"] = currentAllowedValues
        case "allowedValue":
            currentAllowedValues.append(foundCharacters)
        case "serviceStateTable":
            deviceDictionary["serviceStateTable"] = stateVariables
        default:
            
            // We are inside the device info object
            guard !foundCharacters.isEmpty, scope.count >= 2 else {
                return
            }
            
            let containingScope = scope[scope.count - 2]
            
            switch containingScope {
            case "stateVariable":
                currentVariable[elementName] = foundCharacters
            case "action":
                currentAction[elementName] = foundCharacters
            case "argument":
                currentArgument[elementName] = foundCharacters
            default:
                break
            }
            
            break
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        device = UPnPDevice(dictionary: deviceDictionary, type: deviceType)
        completion?(device, nil)
        Logger.log(message: "Parser did end document with success: \(device != nil)", category: "UPnPDeviceXMLParser")
        os_log("Parser did end document", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.log(message: "Parse error occured: \(parseError.localizedDescription)", category: "UPnPDeviceXMLParser")
        os_log("Parse error occured: %@", log: log, type: .error, parseError.localizedDescription)
        completion?(nil, parseError)
    }
    
    enum UPnPDeviceParserError: Error {
        case couldntCreateData
    }
}

internal struct UPnPFolder {
    
    let id: String
    
    let childrenCount: Int
    
    let title: String?
    
    init?(dictionary: [AnyHashable : Any]) {
        guard let _id = dictionary["id"] as? String else {
            return nil
        }
        guard let childCount = dictionary["childCount"] as? String else {
            return nil
        }
        title = dictionary["dc:title"] as? String
        id = _id
        childrenCount = Int(childCount) ?? 0
    }
}

internal final class UPnPFolderParser: NSObject, XMLParserDelegate {
    
    typealias CompletionHandler = (_ folders: [UPnPFolder]?, _ error: Error?) -> Void
    
    /// The parsed folders, only available once parsing has finished.
    var folders: [UPnPFolder]?
    
    /// Completion handler called when parsing has finished.
    var completion: CompletionHandler?
    
    private var xmlParser: XMLParser?
    
    private var currentElement: String = ""
    
    private var foundCharacters: String = ""
    
    private var currentFolder: [AnyHashable : Any] = [:]
    
    private var currentFolders: [[AnyHashable : Any]] = []
    
    /// Represents the current scope of the XML parser
    private var scope: [String] = []
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "UPnPFoldersXMLParser")
    
    let xmlString: String
    
    init(xmlString string: String) {
        xmlString = string
        super.init()
    }
    
    func parse(completion: @escaping CompletionHandler) {
        
        self.completion = completion
        
        guard let data = xmlString.data(using: .utf8) else {
            completion(nil, UPnPDeviceParserError.couldntCreateData)
            Logger.log(message: "Parse failed, couldn't create Data from XML string", category: "UPnPFoldersXMLParser")
            os_log("Parse failed, couldn't create Data from XML string", log: log, type: .error)
            return
        }
        
        xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        Logger.log(message: "Beginning parsing", category: "UPnPFoldersXMLParser")
        os_log("Beginning parsing", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        scope.append(elementName)
        
        os_log("Parser did start element: %@\nCurrent scope:%@", log: log, type: .debug, elementName, scope)
        
        switch elementName {
        case "container":
            currentFolder = attributeDict
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
            os_log("Parser did end element: %@\nCurrent scope:%@", log: log, type: .debug, elementName, scope)
        }
        
        switch elementName {
            
        case "container":
            currentFolders.append(currentFolder)
        default:
            
            // We are inside the device info object
            guard !foundCharacters.isEmpty, scope.count >= 2 else {
                return
            }
            
            let containingScope = scope[scope.count - 2]
            
            guard containingScope == "container" else { return }
            currentFolder[elementName] = foundCharacters
            break
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        let folderObjects = currentFolders.compactMap({ UPnPFolder(dictionary: $0) })
        folders = folderObjects.isEmpty ? nil : folderObjects
        completion?(folders, nil)
        Logger.log(message: "Parser did end document with success: \(!folderObjects.isEmpty)", category: "UPnPFoldersXMLParser")
        os_log("Parser did end document", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.log(message: "Parse error occured", category: "UPnPFoldersXMLParser")
        os_log("Parse error occured: %@", log: log, type: .error, parseError.localizedDescription)
        completion?(nil, parseError)
    }
    
    enum UPnPDeviceParserError: Error {
        case couldntCreateData
    }
}

fileprivate struct Res {
    
    enum ProtocolSize: String, CaseIterable {
        case jpegLarge = "JPEG_LRG"
        case jpegSmall = "JPEG_SM"
        case jpegThumbnail = "JPEG_TN"
        case unknown = "UNKNOWN"
        
        init?(protocolInfo: String) {
            guard let firstMatching = ProtocolSize.allCases.first(where: { (size) -> Bool in
                protocolInfo.contains(size.rawValue)
            }) else {
                return nil
            }
            self = firstMatching
        }
    }
    
    let protocolSize: ProtocolSize?
    
    let resolution: CGSize?
    
    let size: Int?
    
    let url: URL
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let urlString = dictionary["url"] as? String else { return nil }
        guard let url = URL(string: urlString) else { return nil }
        
        self.url = url
        if let protocolString = dictionary["protocolInfo"] as? String {
            protocolSize = ProtocolSize(protocolInfo: protocolString)
        } else {
            protocolSize = nil
        }
        
        switch dictionary["size"] {
        case let stringSize as String:
            size = Int(stringSize)
        case let intSize as Int:
            size = intSize
        default:
            size = nil
        }
        
        guard let resolutionString = dictionary["resolution"] as? String else {
            resolution = nil
            return
        }
        let components = resolutionString.components(separatedBy: "x")
        guard components.count > 1 else {
            resolution = nil
            return
        }
        guard let width = Double(components[0]), let height = Double(components[1]) else {
            resolution = nil
            return
        }
        resolution = CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}

extension File {
    
    init?(upnpDictionary: [AnyHashable : Any], dateFormatter: DateFormatter) {
        
        guard let resolutions = upnpDictionary["resolutions"] as? [[AnyHashable : Any]] else {
            return nil
        }
        
        let resolutionObjects = resolutions.compactMap { (res) -> Res? in
            return Res(dictionary: res)
        }
        
        guard !resolutionObjects.isEmpty else {
            return nil
        }
        
        // This is a bit complex, it seems the original file is available on some cameras
        // but because JPEG_LRG is already taken from the DLNA spec Sony seem to allow
        // the original to be accessed with an "UNKNOWN" protocol info and the resolution
        // and size parameters present. We can take a guess that if the resolution is above
        // a certain size (What RAW files are compressed down to) then it is the original
        // jpeg at least!
        let originalURL = resolutionObjects.first(where: {
            guard let resolution = $0.resolution else { return false }
            return resolution.width > 1616 || resolution.height > 1080
        })
        let largeURL = resolutionObjects.first(where: { $0.protocolSize == .jpegLarge })
        let smallURL = resolutionObjects.first(where: { $0.protocolSize == .jpegSmall })
        let thumbnailURL = resolutionObjects.first(where: { $0.protocolSize == .jpegThumbnail })
        
        let files = [originalURL, largeURL, smallURL, thumbnailURL].compactMap({ $0 })
        guard let firstFile = files.first else {
            return nil
        }
        
        self.content = Content(
            originals: [
                Content.Original(fileName: nil, fileType: "jpeg", url: firstFile.url)
            ],
            largeURL: largeURL?.url,
            smallURL: smallURL?.url,
            thumbnailURL: thumbnailURL?.url
        )
        self.kind = "jpeg"
        self.isPlayable = true
        self.isProtected = upnpDictionary["restricted"] as? Bool ?? false
        self.isBrowsable = true
        self.folderNo = nil
        self.fileNo = nil
        self.uri = ""
        
        if let createdString = upnpDictionary["dc:date"] as? String {
            created = dateFormatter.date(from: createdString)
        } else {
            created = nil
        }
    }
}

internal final class UPnPFileParser: NSObject, XMLParserDelegate {
    
    typealias CompletionHandler = (_ folders: [File]?, _ error: Error?) -> Void
    
    /// The parsed files, only available once parsing has finished.
    var files: [File]?
    
    /// Completion handler called when parsing has finished.
    var completion: CompletionHandler?
    
    private var xmlParser: XMLParser?
    
    private var currentElement: String = ""
    
    private var foundCharacters: String = ""
    
    private var currentFile: [AnyHashable : Any] = [:]
    
    private var currentFiles: [[AnyHashable : Any]] = []
    
    private var currentResolutions: [[AnyHashable : Any]] = []
    
    private var currentResolution: [AnyHashable : Any] = [:]
    
    /// Represents the current scope of the XML parser
    private var scope: [String] = []
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "UPnPFilesXMLParser")
    
    let xmlString: String
    
    init(xmlString string: String) {
        xmlString = string
        super.init()
    }
    
    func parse(completion: @escaping CompletionHandler) {
        
        self.completion = completion
        
        guard let data = xmlString.data(using: .utf8) else {
            completion(nil, UPnPDeviceParserError.couldntCreateData)
            Logger.log(message: "Parse failed, couldn't create Data from XML string", category: "UPnPFilesXMLParser")
            os_log("Parse failed, couldn't create Data from XML string", log: log, type: .error)
            return
        }
        
        xmlParser = XMLParser(data: data)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        Logger.log(message: "Beginning parsing", category: "UPnPFilesXMLParser")
        os_log("Beginning parsing", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        scope.append(elementName)
        
        os_log("Parser did start element: %@\nCurrent scope:%@", log: log, type: .debug, elementName, scope)
        
        switch elementName {
        case "item":
            currentFile = attributeDict
            currentResolutions = []
        case "res":
            currentResolution = attributeDict
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
            os_log("Parser did end element: %@\nCurrent scope:%@", log: log, type: .debug, elementName, scope)
        }
        
        switch elementName {
        case "res":
            currentResolution["url"] = foundCharacters
            currentResolutions.append(currentResolution)
        case "item":
            currentFile["resolutions"] = currentResolutions
            currentFiles.append(currentFile)
        default:
            
            // We are inside the device info object
            guard !foundCharacters.isEmpty, scope.count >= 2 else {
                return
            }
            
            let containingScope = scope[scope.count - 2]
            
            switch containingScope {
            case "item":
                currentFile[elementName] = foundCharacters
            case "res":
                currentResolution[elementName] = foundCharacters
            default:
                break
            }
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let fileObjects = currentFiles.compactMap({ File(upnpDictionary: $0, dateFormatter: dateFormatter) })
        files = fileObjects.isEmpty ? nil : fileObjects
        completion?(files, nil)
        Logger.log(message: "Beginning did end document with success: \(!fileObjects.isEmpty)", category: "UPnPFilesXMLParser")
        os_log("Parser did end document", log: log, type: .debug)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.log(message: "Parse error occured: \(parseError.localizedDescription)", category: "UPnPFilesXMLParser")
        os_log("Parse error occured: %@", log: log, type: .error, parseError.localizedDescription)
        completion?(nil, parseError)
    }
    
    enum UPnPDeviceParserError: Error {
        case couldntCreateData
    }
}
