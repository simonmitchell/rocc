//
//  FileSystem.swift
//  Rocc
//
//  Created by Simon Mitchell on 27/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

/// A structural representation of a file on a Camera
public struct File: Equatable {
    
    /// A structural representation of the content of a file
    public struct Content: Equatable {
        
        /// A structural representation of the original representation of some content. Each content can have multiple of these, for example a RAW and JPEG original when shooting in RAW+JPEG!
        public struct Original: Equatable {
            
            /// The name of the original content
            public let fileName: String?
            
            /// The file type of the original content
            public let fileType: String?
            
            /// The url which this content can be downloaded from
            public let url: URL?
            
            init(fileName: String?, fileType: String?, url: URL?) {
                
                self.fileName = fileName
                self.fileType = fileType
                self.url = url
            }
        }
        
        /// All originals available for transfer/download.
        public let originals: [Original]
        
        /// A large preview URL for the content
        public let largeURL: URL?
        
        /// A smaller preview URL for the content
        public let smallURL: URL?
        
        /// A thumbnail URL for the content
        public let thumbnailURL: URL?
        
        init(originals: [Original], largeURL: URL?, smallURL: URL?, thumbnailURL: URL?) {
            
            self.originals = originals
            self.largeURL = largeURL
            self.smallURL = smallURL
            self.thumbnailURL = thumbnailURL
        }
    }
    
    /// The content of the file
    public let content: Content?
    
    /// The date on which the file was created
    public let created: Date?
    
    /// The kind of file this is
    public let kind: String?
    
    /// The folder number the file is stored in
    public let folderNo: String?
    
    /// The file number of the file
    public let fileNo: String?
    
    /// Whether the file can be used for playback (Coming soon!)
    public let isPlayable: Bool?
    
    /// Whether the file is browsable
    public let isBrowsable: Bool?
    
    /// Whether the file is protected, i.e. can't be deleted
    public let isProtected: Bool?
    
    /// The uri of the file
    public let uri: String
    
    init(content: Content? = nil, created: Date? = nil, kind: String? = nil, folderNo: String? = nil, fileNo: String? = nil, isPlayable: Bool? = nil, isBrowsable: Bool? = nil, isProtected: Bool? = nil, uri: String) {
        
        self.content = content
        self.created = created
        self.kind = kind
        self.folderNo = folderNo
        self.fileNo = fileNo
        self.isPlayable = isPlayable
        self.isProtected = isProtected
        self.isBrowsable = isBrowsable
        self.uri = uri
    }

    public static func == (lhs: File, rhs: File) -> Bool {
        return lhs.uri == rhs.uri
            && lhs.content == rhs.content
            && lhs.created?.timeIntervalSince1970 == rhs.created?.timeIntervalSince1970
            && lhs.kind == rhs.kind
    }
}

/// Represents all the information required to request files from a camera.
public struct FileRequest: Equatable {
    
    /// How the returned files should be sorted
    ///
    /// - ascending: In ascending order (By date)
    /// - descending: In descending order (By date)
    public enum SortOrder {
        case ascending
        case descending
    }
    
    /// Represents the hierarchy of how files should be returned
    ///
    /// - date: Returned sorted into date folders. When using this you would then make a further request by appending the folder name to the original `uri` used.
    /// - flat: Returned as one flat list of files in a single folder.
    public enum View {
        case date
        case flat
    }
    
    /// The uri to search under, append the formatted date if the original request was made using the `date` view.
    public let uri: String
    
    /// The first index to return a file at
    public let startIndex: Int
    
    /// The number of files to return
    public let count: Int
    
    /// The required return hierarchy of files
    public let view: View
    
    /// How to sort the returned files
    public let sort: SortOrder?
    
    /// The type of files to return, use nil to return all file types
    public let types: [String]?
    
    public init(uri: String, startIndex: Int = 0, count: Int = 50, view: View = .flat, sort: SortOrder? = nil, types: [String]? = nil) {
        
        self.uri = uri
        self.startIndex = startIndex
        self.count = count
        self.view = view
        self.sort = sort
        self.types = types
    }
}

/// Represents all the information required to request a content count from a camera.
public struct CountRequest: Equatable {
    
    /// Represents the hierarchy of how files should be counted
    ///
    /// - date: Returns the number of dates photos were taken on.
    /// - flat: Returns the content count of a flat list of files.
    public enum View {
        case date
        case flat
    }
    
    /// The uri to return the content count within, append the folder name to the original
    /// uri when using the `date` view to get the count on a certain date
    public let uri: String
    
    /// Widen result within specified URI in the request. Following values are defined.
    public let target: String
    
    /// The view you will be using to actually fetch files. With `date` this will return
    /// the number of folders, and `flat` will return the number of files
    public let view: View
    
    /// The type of files to count, use nil to count all file types
    public let types: [String]?
    
    public init(uri: String, view: View = .flat, target: String = "all", types: [String]? = nil) {
        
        self.uri = uri
        self.view = view
        self.target = target
        self.types = types
    }
}

/// Represents a file response from the camera
public struct FileResponse: Equatable {
    
    /// Whether the request loaded in the remaining (Or all) files for a given URI
    public let fullyLoaded: Bool
    
    /// The files that are available
    public let files: [File]
}

/// Functions for interacting with the camera's file system
public struct FileSystem {
    
    /// Functions for managing the file system
    public struct Manage: CameraFunction {
        
        public typealias ReturnType = Wrapper<Void>
        
        public typealias SendType = [File]
        
        public var function: _CameraFunction
        
        /// Deletes an array of files from the camera
        public static let delete = Manage(function: .deleteContent)
    }
    
    /// Functions for listing sources available on the camera
    public struct Sources: CameraFunction {
        
        public typealias ReturnType = [String]
        
        public typealias SendType = String
        
        public var function: _CameraFunction
        
        /// Returns a list of sources under a given scheme
        public static let list = Sources(function: .listSources)
    }
    
    /// Functions for listing schemes available on the camera
    public struct Schemes: CameraFunction {
        
        public typealias ReturnType = [String]
        
        public typealias SendType = Wrapper<Void>
        
        public var function: _CameraFunction
        
        /// Returns a list of the available schemes on the camera
        public static let list = Schemes(function: .listSchemes)
    }
    
    /// Functions for interacting with the file sytem's contents!
    public struct Contents: CameraFunction {
        
        public var function: _CameraFunction
        
        public typealias SendType = FileRequest
        
        public typealias ReturnType = FileResponse
        
        /// Returns a list of content on the camera using the given file request
        public static let list = Contents(function: .listContent)
        
        /// Functions for returning the count of a particular folder
        public struct Count: CameraFunction {
            
            public var function: _CameraFunction
            
            public typealias SendType = CountRequest
            
            public typealias ReturnType = Int
            
            /// Returns a count of the content at a given uri using the given count request
            public static let get = Count(function: .getContentCount)
        }
    }
}
