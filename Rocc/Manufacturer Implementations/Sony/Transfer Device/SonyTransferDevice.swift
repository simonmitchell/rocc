//
//  SonyCamera.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation
#if os(iOS)
import ThunderRequest
#elseif os(macOS)
import ThunderRequestMac
#endif

internal final class SonyTransferDevice {
    
    var ipAddress: sockaddr_in?
    
    var apiVersion: String?
    
    var baseURL: URL?
    
    var manufacturer: String
    
    var name: String?
    
    var model: String?
    
    var modelEnum: SonyCameraDevice.Model?
    
    var firmwareVersion: String?
    
    public var latestFirmwareVersion: String? {
        return modelEnum?.latestFirmwareVersion
    }
    
    var remoteAppVersion: String?
    
    var latestRemoteAppVersion: String? {
        return "4.31"
    }
    
    var identifier: String
    
    var isConnected: Bool
    
    var services: [UPnPService]?
    
    let udn: String?
    
    let manufacturerURL: URL?
    
    var contentDirectoryDevice: UPnPDevice?
    
    var pushContentDevice: UPnPDevice?
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let serviceDictionaries = dictionary["serviceList"] as? [[AnyHashable : Any]] else {
            return nil
        }
        
        services = serviceDictionaries.compactMap({ UPnPService(dictionary: $0) })
                
        model = dictionary["friendlyName"] as? String
        udn = dictionary["UDN"] as? String
        
        identifier = udn ?? NSUUID().uuidString
        
        if let model = model {
            modelEnum = SonyCameraDevice.Model(rawValue: model)
        } else {
            modelEnum = nil
        }
        
        name = modelEnum?.friendlyName
        manufacturer = dictionary["manufacturer"] as? String ?? "Sony"
        
        if let manufacturerURLString = dictionary["manufacturerURL"] as? String {
            manufacturerURL = URL(string: manufacturerURLString)
        } else {
            manufacturerURL = nil
        }
        
        
        isConnected = false
    }
    
    internal var requestController: RequestController?
    
    var dateFolders: [UPnPFolder]?
}

extension UPnPFolder: Countable {
    var count: Int {
        return childrenCount
    }
}

extension SonyTransferDevice: Camera {
    
    func handleEvent(event: CameraEvent) {
        
    }
    
    var connectionMode: ConnectionMode {
        return .contentsTransfer(pushContentDevice != nil)
    }
    
    func finishTransfer(callback: @escaping ((Error?) -> Void)) {
        
        guard let requestController = requestController else {
            callback(CameraError.cameraNotReady("Unknown"))
            return
        }
        
        guard let pushService = services?.first(where: { $0.type == .pushList }) else {
            callback(nil)
            return
        }
            
        let finishTransferRequestBody = SOAPRequestBody(
            bodyXML: """
                     <u:X_TransferEnd xmlns:u="urn:schemas-sony-com:service:XPushList:1">
                        <ErrCode>0</ErrCode>
                     </u:X_TransferEnd>
                     """,
            headerXML: nil
        )
        
        requestController.request(pushService.controlURL, method: .POST, body: finishTransferRequestBody, headers: ["SOAPACTION": "\"urn:schemas-sony-com:service:XPushList:1#X_TransferEnd\""]) { (response, error) in
            callback(error)
        }
    }
    
    func loadFilesToTransfer(callback: @escaping ((Error?, [File]?) -> Void)) {
        
        guard let requestController = requestController else {
            callback(CameraError.cameraNotReady("Unknown"), nil)
            return
        }
        
        let loadFiles: (_ callback: @escaping ((Error?, [File]?) -> Void)) -> Void = { [weak self] _callback in
            
            guard let this = self else { return }
            
            // For now we'll piggy-back of the fact the app seems to setup the content manager API as well as the newly discovered
            this.performFunction(FileSystem.Contents.Count.get, payload: nil) { [weak self] (error, count) in
                guard let this = self else { return }
                guard let count = count else {
                    _callback(error, nil)
                    return
                }
                this.performFunction(FileSystem.Contents.list, payload: FileRequest(uri: "", startIndex: 0, count: count, view: .flat, sort: nil, types: nil), callback: { (filesError, fileResponse) in
                    guard let _fileResponse = fileResponse else {
                        _callback(filesError, nil)
                        return
                    }
                    _callback(nil, _fileResponse.files)
                })
            }
        }
        
        if let pushService = services?.first(where: { $0.type == .pushList }) {
            
            let startTransferRequestBody = SOAPRequestBody(
                bodyXML: """
                         <u:X_TransferStart xmlns:u="urn:schemas-sony-com:service:XPushList:1"/>
                         """,
                headerXML: nil
            )
            
            requestController.request(pushService.controlURL, method: .POST, body: startTransferRequestBody, headers: ["SOAPACTION": "\"urn:schemas-sony-com:service:XPushList:1#X_TransferStart\""]) { (response, error) in
                loadFiles(callback)
            }
        } else {
            loadFiles(callback)
        }
    }
    
    var lensModelName: String? {
        return nil
    }
    
    var supportsPolledEvents: Bool {
        return false
    }
    
    func supportsFunction<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        switch function.function {
        case .listSchemes, .listSources, .listContent:
            callback(true, nil, nil)
        default:
            callback(false, nil, nil)
        }
    }
    
    func isFunctionAvailable<T>(_ function: T, callback: @escaping ((Bool?, Error?, [T.SendType]?) -> Void)) where T : CameraFunction {
        switch function.function {
        case .listSchemes, .listSources, .listContent, .getContentCount:
            callback(true, nil, nil)
        default:
            callback(false, nil, nil)
        }
    }
    
    func makeFunctionAvailable<T>(_ function: T, callback: @escaping ((Error?) -> Void)) where T : CameraFunction {
        callback(nil)
    }
    
    func performFunction<T>(_ function: T, payload: T.SendType?, callback: @escaping ((Error?, T.ReturnType?) -> Void)) where T : CameraFunction {
        
        switch function.function {
            
        case .getContentCount:
            
            guard requestController != nil else {
                callback(CameraError.cameraNotReady(function.function.sonyCameraMethodName ?? "Unknown"), nil)
                return
            }
            
            guard let contentsService = services?.first(where: { $0.type == .contentDirectory }) else {
                callback(CameraError.cameraNotReady(function.function.sonyCameraMethodName ?? "Unknown"), nil)
                return
            }
            
            guard let dateFolders = dateFolders else {
                
                recurseFolderContents(objectId: "0", contentServiceURLPath: contentsService.controlURL) { (error, dateFolders) in

                    guard let folders = dateFolders else {
                        callback(error ?? CameraError.invalidResponse("Browse ContentDirectory"), nil)
                        return
                    }
                    
                    callback(nil, folders.reduce(0, { $0 + $1.childrenCount }) as? T.ReturnType)
                }
                return
            }
            
            callback(nil, dateFolders.reduce(0, { $0 + $1.childrenCount }) as? T.ReturnType)
            
        case .listSchemes:
            callback(nil, [""] as? T.ReturnType)
        case .listSources:
            callback(nil, [""] as? T.ReturnType)
        case .listContent:
            
            let fileRequest = (payload as? FileRequest) ?? FileRequest.sonyDefault
            
            guard requestController != nil else {
                callback(CameraError.cameraNotReady(function.function.sonyCameraMethodName ?? "Unknown"), nil)
                return
            }
            
            guard let contentsService = services?.first(where: { $0.type == .contentDirectory }) else {
                callback(CameraError.cameraNotReady(function.function.sonyCameraMethodName ?? "Unknown"), nil)
                return
            }
            
            guard let dateFolders = dateFolders else {
                
                recurseFolderContents(objectId: "0", contentServiceURLPath: contentsService.controlURL) { [weak self] (error, dateFolders) in
                    guard let strongSelf = self else {
                        return
                    }
                    guard let folders = dateFolders else {
                        callback(error ?? CameraError.invalidResponse("Browse ContentDirectory"), nil)
                        return
                    }
                    strongSelf.loadFilesUsing(request: fileRequest, contentServiceURLPath: contentsService.controlURL, from: folders, { (fileError, files) in
                        guard let _files = files else {
                            callback(fileError, nil)
                            return
                        }
                        callback(nil, FileResponse(fullyLoaded: false, files: _files) as? T.ReturnType)
                    })
                }
                return
            }
            
            loadFilesUsing(request: fileRequest, contentServiceURLPath: contentsService.controlURL, from: dateFolders) { (error, files) in
                guard let _files = files else {
                    callback(error, nil)
                    return
                }
                callback(nil, FileResponse(fullyLoaded: false, files: _files) as? T.ReturnType)
            }
            
        case .ping:
            
            guard let host = baseURL?.host else {
                callback(FunctionError.notAvailable, nil)
                return
            }
            
            Pinger.ping(hostName: host, timeout: 2.0) { (interval, error) in
                callback(error, nil)
            }
                
        default:
            callback(CameraError.noSuchMethod(function.function.sonyCameraMethodName ?? "Unknown"), nil)
        }
    }
    
    /// Loads the files from a set of UPnP folders based on a given file request
    ///
    /// - Parameters:
    ///   - request: The request to use to determine which files should be loaded
    ///   - folders: The folders to use to load files from
    ///   - path: The path to fetch from!
    ///   - callback: A closure to be called with the result of the operation
    private func loadFilesUsing(request: FileRequest, contentServiceURLPath: String, from folders: [UPnPFolder], _ callback: @escaping (_ error: Error?, _ files: [File]?) -> Void) {
        
        let requestRange = request.startIndex...(request.startIndex + request.count - 1)
        let foldersAndRanges = folders.childRangesCovering(range: requestRange)
        recursivelyLoadFilesFrom(folders: foldersAndRanges, contentServiceURLPath: contentServiceURLPath, callback)
    }
    
    private func recursivelyLoadFilesFrom(folders: [(element: UPnPFolder, subRange: Range<Int>)], contentServiceURLPath: String, cumulativeFiles: [File] = [], _ callback: @escaping (_ error: Error?, _ files: [File]?) -> Void) {
        
        guard let nextFolderAndRange = folders.first else {
            callback(nil, cumulativeFiles)
            return
        }
        var foldersAndRanges = folders
        
        let fileRequestBody = SOAPRequestBody(browseObjectId: nextFolderAndRange.element.id, startIndex: nextFolderAndRange.subRange.startIndex, count: nextFolderAndRange.subRange.count)
        
        requestController?.request(contentServiceURLPath, method: .POST, body: fileRequestBody, headers: ["SOAPACTION": "\"urn:schemas-upnp-org:service:ContentDirectory:1#Browse\""]) { [weak self] (response, error) in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let _response = response else {
                callback(error, nil)
                return
            }
            
            strongSelf.parseFiles(response: _response, completion: { [weak strongSelf] (files, parseError) in
                
                guard let _files = files else {
                    callback(parseError, nil)
                    return
                }
                
                var nextFiles = cumulativeFiles
                nextFiles.append(contentsOf: _files)
                
                // Remove the first folder and range from array
                foldersAndRanges.removeFirst()
                // If there are no remaining folders to load, then call our callback!
                guard !foldersAndRanges.isEmpty else {
                    callback(nil, nextFiles)
                    return
                }
                
                guard let _strongSelf = strongSelf else {
                    return
                }
                // Load contents from next folder
                _strongSelf.recursivelyLoadFilesFrom(folders: foldersAndRanges, contentServiceURLPath: contentServiceURLPath, cumulativeFiles: nextFiles, callback)
            })
        }
    }
    
    /// Recursively requests UPnP directories until a directory with multiple folders is reached, or the parent directory is "Date".
    /// This seems to be how the UPnP directory structure is configured on Sony Cameras. This logic is flakey, and could break on
    /// some models, HOWEVER PlayMemories evidently does something similar as it shows the user neither the "Root" folder or "PhotoRoot"
    /// folder!
    ///
    /// - Parameters:
    ///   - objectId: The ID of the folder to load subfolders from
    ///   - path: The path to make the request to, this should be the control URL of the `ContentDirectory` service
    ///   - parentFolder: The parent folder for the request
    ///   - callback: A closure to be called once the date based folders have been found!
    private func recurseFolderContents(objectId: String, contentServiceURLPath: String, parentFolder: UPnPFolder? = nil, _ callback: @escaping (_ error: Error?, _ dateFolders: [UPnPFolder]?) -> Void) {
        
        // Using PhotoRoot here is a quick win, it may not work on all Sony models!
        let rootObjectBody = SOAPRequestBody(browseObjectId: objectId)
        
        requestController?.request(contentServiceURLPath, method: .POST, body: rootObjectBody, headers: ["SOAPACTION": "\"urn:schemas-upnp-org:service:ContentDirectory:1#Browse\""]) { [weak self] (response, requestError) in
            
            guard let strongSelf = self else {
                callback(nil, nil)
                return
            }
            
            guard let browseResponse = response else {
                callback(requestError ?? CameraError.invalidResponse("Browse ContentDirectory"), nil)
                return
            }
            
            strongSelf.parseUPnPFolders(response: browseResponse, completion: { [weak strongSelf] (folders, foldersError) in
                
                guard let _strongSelf = strongSelf else {
                    callback(nil, nil)
                    return
                }
                
                guard let _folders = folders, let firstFolder = _folders.first else {
                    callback(foldersError, nil)
                    return
                }
                
                guard _folders.count > 1 || parentFolder?.title == "Date" else {
                    _strongSelf.recurseFolderContents(objectId: firstFolder.id, contentServiceURLPath: contentServiceURLPath, parentFolder: firstFolder, callback)
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let sortedFolders = _folders.sorted(by: { (folder1, folder2) -> Bool in
                    guard let title1 = folder1.title, let date1 = dateFormatter.date(from: title1) else {
                        return false
                    }
                    guard let title2 = folder2.title, let date2 = dateFormatter.date(from: title2) else {
                        return true
                    }
                    return date1 > date2
                })
                _strongSelf.dateFolders = sortedFolders
                callback(nil, sortedFolders)
            })
        }
    }
    
    /// Parses files from a ThunderRequest RequestResponse object
    ///
    /// - Parameters:
    ///   - response: The response from the `request` method of ThunderRequest
    ///   - completion: A closure to be called once parsing has finished
    private func parseFiles(response: RequestResponse, completion: @escaping ((_ files: [File]?, _ error: Error?) -> Void)) {
        
        response.parseSOAPResponse({ [weak self] (soapResponse, soapParseError) in
            
            guard let strongSelf = self else {
                completion(nil, nil)
                return
            }
            
            guard let result = soapResponse?["Result"] as? String else {
                completion(nil, soapParseError)
                return
            }
            
            strongSelf.parseUPnPFiles(xmlString: result, completion: completion)
            
        }, tag: "u:BrowseResponse")
    }
    
    /// Parses File from an xml string
    ///
    /// - Parameters:
    ///   - xmlString: The string of xml to parse files from
    ///   - completion: A closure to be called once parsing has finished
    private func parseUPnPFiles(xmlString: String, completion: @escaping UPnPFileParser.CompletionHandler) {
        
        // Need to jump to main thread otherwise XMLParser throws a hissy-fit about re-entry or something!
        OperationQueue.main.addOperation {
            let filesParser = UPnPFileParser(xmlString: xmlString)
            filesParser.parse(completion: completion)
        }
    }
    
    /// Parses UPnP folders from a ThunderRequest RequestResponse object
    ///
    /// - Parameters:
    ///   - response: The response from the `request` method of ThunderRequest
    ///   - completion: A closure to be called once parsing has finished
    private func parseUPnPFolders(response: RequestResponse, completion: @escaping ((_ folders: [UPnPFolder]?, _ error: Error?) -> Void)) {
        
        response.parseSOAPResponse({ [weak self] (soapResponse, soapParseError) in
            
            guard let strongSelf = self else {
                completion(nil, nil)
                return
            }
            
            guard let result = soapResponse?["Result"] as? String else {
                completion(nil, soapParseError)
                return
            }
            
            strongSelf.parseUPnPFolders(xmlString: result, completion: completion)
            
        }, tag: "u:BrowseResponse")
    }
    
    /// Parses UPnP folders from an xml string
    ///
    /// - Parameters:
    ///   - xmlString: The string of xml to parse folders from
    ///   - completion: A closure to be called once parsing has finished
    private func parseUPnPFolders(xmlString: String, completion: @escaping UPnPFolderParser.CompletionHandler) {
        
        // Need to jump to main thread otherwise XMLParser throws a hissy-fit about re-entry or something!
        OperationQueue.main.addOperation {
            let foldersParser = UPnPFolderParser(xmlString: xmlString)
            foldersParser.parse(completion: completion)
        }
    }
    
    func connect(completion: @escaping ConnectedCompletion) {
        completion(nil, true)
    }
}

extension SOAPRequestBody {
    init(browseObjectId: String, startIndex: Int = 0, count: Int = 0) {
        self.init(bodyXML: """
                        <u:Browse xmlns:u="urn:schemas-upnp-org:service:ContentDirectory:1">
                            <ObjectID>\(browseObjectId)</ObjectID>
                            <StartingIndex>\(startIndex)</StartingIndex>
                            <BrowseFlag>BrowseDirectChildren</BrowseFlag>
                            <Filter>*</Filter>
                            <RequestedCount>\(count)</RequestedCount>
                            <SortCriteria></SortCriteria>
                        </u:Browse>
                        """,
                  headerXML: nil
        )
    }
}
