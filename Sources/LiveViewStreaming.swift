//
//  LiveViewStreaming.swift
//  Rocc
//
//  Created by Simon Mitchell on 14/05/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import os.log

#if canImport(UIKit)
import UIKit
public typealias Image = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias Image = NSImage
#endif

/// A delegation protocol which is used to provide updates on frame information
public protocol LiveViewStreamDelegate {
        
    /// Called when the stream receives a new image frame from the camera
    ///
    /// - Parameters:
    ///   - stream: The stream which received an image
    ///   - image: The image which was received
    func liveViewStream(_ stream: LiveViewStream, didReceive image: Image)
    
    /// Called if the stream errors in any way
    ///
    /// - Parameters:
    ///   - stream: The stream which errored
    ///   - error: The error that occured
    func liveViewStream(_ stream: LiveViewStream, didError error: Error)
    
    /// Called when the stream stops
    ///
    /// - Parameter stream: The stream which stopped
    func liveViewStreamDidStop(_ stream: LiveViewStream)
    
    /// Called when the stream receives frame information from the camera
    ///
    /// - Parameters:
    ///   - stream: The stream which received frame information
    ///   - frames: The frames which were received
    func liveViewStream(_ stream: LiveViewStream, didReceive frames: [FrameInfo])
}

/// A structural represention an area on screen and information about it, be it an in-focus area or a detected face
public struct FrameInfo {
    
    /// The category of the frame information
    public enum Category: UInt8 {
        /// The frame is invalid
        case invalid = 0x00
        /// The frame is for contrast AF information
        case contrastAF = 0x01
        /// The frame is for phase detection AF information
        case phaseDetectionAF = 0x02
        /// The frame is for facial tracking
        case facialTracking = 0x04
        /// The frame is for tracking
        case tracking = 0x05
    }
    
    /// The status of the frame information
    public enum Status: UInt8 {
        /// The frame is invalid
        case invalid = 0x00
        /// The frame is normal
        case normal = 0x01
        /// The frame is the main frame
        case main = 0x02
        /// The frame is a sub-frame
        case subframe = 0x03
        /// The frame is in-focus
        case focussed = 0x04
    }
    
    /// The area the frame info covers, dimensions are a fraction of the dimension of the full frame of the live stream
    public let area: CGRect
    
    /// The category of the frame information
    public let category: Category
    
    /// The status of the frame information
    public let status: Status
    
    fileprivate init?(data: Data) {
        
        switch data.count {
        case 16:
            self.init(sixteenBitData: data)
        default:
            return nil
        }
    }
    
    private init?(sixteenBitData: Data) {
        
        guard let topLeftX = UInt16(data: sixteenBitData[0..<2]) else { return nil }
        guard let topLeftY = UInt16(data: sixteenBitData[2..<4]) else { return nil }
        guard let bottomRightX = UInt16(data: sixteenBitData[4..<6]) else { return nil }
        guard let bottomRightY = UInt16(data: sixteenBitData[6..<8]) else { return nil }
        
        let topLeftXFrac = CGFloat(topLeftX)/10000
        let topLeftYFrac = CGFloat(topLeftY)/10000
        let bottomRightXFrac = CGFloat(bottomRightX)/10000
        let bottomRightYFrac = CGFloat(bottomRightY)/10000
        
        area = CGRect(x: topLeftXFrac, y: topLeftYFrac, width: bottomRightXFrac - topLeftXFrac, height: bottomRightYFrac - topLeftYFrac)
        
        if let categoryInt = UInt8(data: sixteenBitData[8..<9]) {
            category = Category(rawValue: categoryInt) ?? .invalid
        } else {
            category = .invalid
        }
        
        if let statusInt = UInt8(data: sixteenBitData[9..<10]) {
            status = Status(rawValue: statusInt) ?? .invalid
        } else {
            status = .invalid
        }
    }
}

/// A class for streaming the live view data from a particular instance of a Camera.
///
/// This class will be entirely responsible for fetching live view images from the camera and providing
/// them back to the callee through a delegate based approach
public final class LiveViewStream: NSObject {
    
    private let log = OSLog(subsystem: "com.yellow-brick-bear.rocc", category: "LiveViewStreaming")
    
    /// The delegate which will have live stream updates passed to it
    public var delegate: LiveViewStreamDelegate?
    
    /// The camera who's live view is being streamed
    public let camera: Camera
    
    /// Whether the stream is currently running
    public var isStreaming: Bool = false
    
    /// Whether the stream is currently starting
    public var isStarting: Bool = false
    
    /// The size of the stream (M/L)
    public var streamSize: String?
    
    /// The maximum size the data buffer should be allowed to reach
    /// before being cleared out. This means that for unparsable streams
    /// we won't cause out of memory crashes
    ///
    /// - Note: This defaults to 10Mb
    public var bufferSize: Int = 10_485_760
    
    /// Used to make sure overflown buffer only logged once
    private var hasLoggedOverflowBuffer: Bool = false
    
    /// The data that has been received from the stream
    internal var receivedData: Data = Data()
    
    /// Creates a new stream object for the given camera
    ///
    /// - Parameters:
    ///   - camera: The camera to stream live view images from
    ///   - delegate: A delegate to callback with errors or new live view images/frames
    public init(camera: Camera, delegate: LiveViewStreamDelegate?) {
        
        self.delegate = delegate
        self.camera = camera
        self.dataProcessingQueue.qualityOfService = .utility
    }
    
    private var eventTimer: Timer?
    
    /// Performs all setup of the live view stream and begins streaming images over the network
    public func start() {
        
        #if os(iOS)
        guard camera as? DummyCamera == nil else {
            if let image = UIImage(named: "test_image", in: .main, compatibleWith: nil) {
                delegate?.liveViewStream(self, didReceive: image)
            }
            return
        }
        #endif
                
        isStarting = true
        
        Logger.log(message: "Starting live view stream", category: "LiveViewStreaming", level: .debug)
        os_log("Starting live view stream", log: log, type: .debug)
        
        camera.performFunction(LiveView.start, payload: nil) { [weak self] (error, streamURL) in
            
            guard let strongSelf = self else { return }
            
            guard let streamURL = streamURL else {
                
                guard let sonyError = error as? CameraError, case .alreadyRunningPollingAPI(_) = sonyError else {
                    Logger.log(message: "Starting live view stream errored \((error ?? StreamingError.unknown).localizedDescription)", category: "LiveViewStreaming", level: .error)
                    os_log("Starting live view stream errored %@", log: strongSelf.log, type: .error, (error ?? StreamingError.unknown).localizedDescription)
                    strongSelf.isStarting = false
                    strongSelf.delegate?.liveViewStream(strongSelf, didError: error ?? StreamingError.unknown)
                    return
                }
                
                Logger.log(message: "Got already running polling API error, restarting live stream", category: "LiveViewStreaming", level: .debug)
                os_log("Got already running polling API error, restarting live stream", log: strongSelf.log, type: .debug)
                
                strongSelf.camera.performFunction(LiveView.stop, payload: nil, callback: { [weak strongSelf] (error, response) in
                    
                    guard let _strongSelf = strongSelf else { return }
                    guard error == nil else {
                        Logger.log(message: "Stopping live view stream errored \((error ?? StreamingError.unknown).localizedDescription)", category: "LiveViewStreaming", level: .error)
                        os_log("Stopping live view stream errored %@", log: _strongSelf.log, type: .error, (error ?? StreamingError.unknown).localizedDescription)
                        _strongSelf.isStarting = false
                        _strongSelf.delegate?.liveViewStream(_strongSelf, didError: error ?? StreamingError.unknown)
                        return
                    }
                    _strongSelf.start()
                })
                
                return
            }
            
            strongSelf.camera.performFunction(LiveView.SendFrameInfo.set, payload: true, callback: { (_, _) in
                
            })
            
            strongSelf.streamFrom(url: streamURL)
        }
    }
    
    private var streamingSession: URLSession?
    
    private var dataTask: URLSessionDataTask?
    
    var isPacketedStream: Bool = false
    
    let dataProcessingQueue = OperationQueue()
        
    private func streamFrom(url: URL) {
        
        Logger.log(message: "Beggining live view stream from \(url.absoluteString)", category: "LiveViewStreaming", level: .debug)
        os_log("Beggining live view stream from %@", log: log, type: .debug, url.absoluteString)
        
        isPacketedStream = false
        isStarting = false
        isStreaming = true
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        
        streamingSession?.invalidateAndCancel()
        streamingSession = nil
        
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        streamingSession = URLSession(configuration: config, delegate: self, delegateQueue: dataProcessingQueue)
        
        dataProcessingQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.receivedData = Data()
            self.dataTask = self.streamingSession?.dataTask(with: request)
            self.dataTask?.resume()
        }
    }
    
    /// Stops the stream
    public func stop() {
        
        Logger.log(message: "Stopping live view stream", category: "LiveViewStreaming", level: .debug)
        os_log("Stopping live view stream", log: log, type: .debug)
        
        isStreaming = false
        streamingSession?.invalidateAndCancel()
        streamingSession = nil
        dataProcessingQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.receivedData = Data()
        }
        
        camera.performFunction(LiveView.stop, payload: nil) { (error, void) in
            
        }
    }
    
    internal struct Payload {
        
        enum Content: UInt8 {
            case image = 0x01
            case frameInfo = 0x02
        }
        
        let sequence: UInt16
        
        let timestamp: UInt32
        
        let type: Content
        
        let dataRange: Range<Int>
        
        let image: Image?
        
        let frames: [FrameInfo]?
        
        init(image: Image, dataRange: Range<Int>) {
            
            self.image = image
            self.type = .image
            self.timestamp = 0
            self.sequence = 0
            self.dataRange = dataRange
            self.frames = nil
        }
        
        init?(data: Data) {
            
            var _data = Data(data)
            
            //Common Header
            
            guard _data.count > 136 else { return nil }
            
            let typeByte = _data[1]
            guard let type = Content(rawValue: typeByte) else { return nil }
            
            let sequenceRange = 2..<4
            let timestampRange = 4..<8
            
            guard let sequence = UInt16(data: _data[sequenceRange]) else { return nil }
            guard let timestamp = UInt32(data: _data[timestampRange]) else { return nil }
            
            self.type = type
            self.sequence = sequence
            self.timestamp = timestamp
            
            let commonHeaderRange = 0..<8
            _data.removeSubrange(commonHeaderRange)
            
            // Payload Header
            
            let checkBytes = Data([0x24, 0x35, 0x68, 0x79])
            let checkRange = 0..<4
            
            let found = _data.range(of: checkBytes, options: [.anchored], in: checkRange)
            guard found != nil else {
                return nil
            }
            
            guard let _payloadBytes = UInt(data: _data[4..<7]) else { return nil }
            let paddingSize = Int(_data[7])
            let payloadBytes = Int(_payloadBytes)
            
            let numberOfFrames = UInt16(data: _data[10..<12])
            let frameDataSize = UInt16(data: _data[12..<14])
            
            _data.removeSubrange(0..<128)
            
            guard _data.count >= payloadBytes + paddingSize else { return nil }
            
            let payloadRange = 0..<payloadBytes
            let payloadData = _data[payloadRange]
            
            switch type {
            case .image:
                frames = nil
                guard let _image = Image(data: payloadData) else { return nil }
                image = _image
            case .frameInfo:
                
                guard let frameSize = frameDataSize, let frames = numberOfFrames else {
                    return nil
                }
                
                image = nil
                
                var _frames: [FrameInfo] = []
                
                for i in 0..<frames {
                    // Cast this to data otherwise we have a DataSlice which has non-zero based range!
                    let frameData = Data(payloadData[(i*frameSize)..<((i + 1)*frameSize)])
                    if let frame = FrameInfo(data: frameData) {
                        _frames.append(frame)
                    }
                }
                
                self.frames = _frames
            }
            
            dataRange = 0..<(136+payloadBytes+paddingSize)
        }
    }
    
    @discardableResult internal func attemptImageParse() -> [Payload]? {
        
        // Re-case as Data in-case we've received a DataSlice, which seems to be an issue somewhere!
        receivedData = Data(receivedData)
        
        // If for some reason our data doesn't start with the "Start Byte", then delete up to that point!
        if let firstByte = receivedData.first, firstByte != 0xFF {
            
            Logger.log(message: "Received data didn't start with 0xFF deleting up to that point", category: "LiveViewStreaming", level: .debug)
            os_log("Received data didn't start with 0xFF deleting up to that point", log: log, type: .debug)
            
            // If we have a start byte, discard everything before it
            if receivedData.contains(0xFF) {
                Logger.log(message: "Discarding data up to first 0xFF", category: "LiveViewStreaming", level: .debug)
                os_log("Discarding data up to first 0xFF", log: log, type: .debug)
                receivedData = Data(receivedData.split(separator: 0xFF, maxSplits: 1, omittingEmptySubsequences: false).last ?? Data())
                // Add back in the 0xff byte as this is required to parse a JPEG!
                receivedData.insert(0xFF, at: 0)
            }
        }
        
        var payloads = parsePayloads()
        // Only do JPEG fallback if we haven't manged to parse packeted payloads already in this streaming session
        if payloads == nil && !isPacketedStream {
            payloads = parseJPEGs()
        } else if !isPacketedStream {
            isPacketedStream = true
        }

        var lastImage: Image?
        var lastFrames: [FrameInfo]?

        payloads?.forEach({ (payload) in

            if let image = payload.image {
                lastImage = image
            }
            
            if let frames = payload.frames {
                lastFrames = frames
            }
        })

        if let image = lastImage {
            delegate?.liveViewStream(self, didReceive: image)
        }

        if let frames = lastFrames {
            delegate?.liveViewStream(self, didReceive: frames)
        }
        
        return payloads
    }
    
    enum PayloadType {
        case image
        case frameInfo
    }
    
    private func parsePayloads() -> [Payload]? {
        
        var payload = Payload(data: receivedData)
        
        if let _payload = payload {
            let range = _payload.dataRange.clamped(to: receivedData.startIndex..<receivedData.endIndex)
            receivedData.removeSubrange(range)
        }
        
        var payloads: [Payload] = []
        if let initialPayload = payload {
            payloads.append(initialPayload)
        }
        
        while payload != nil {
            
            payload = Payload(data: receivedData)
            
            if let _payload = payload {
                receivedData.removeSubrange(payload!.dataRange)
                payloads.append(_payload)
            }
        }
        
        return payloads.isEmpty ? nil : payloads
    }
    
    private func parseJPEGs() -> [Payload]? {
        
        // Keep local copy so not mutated whilst we're doing this
        let data = Data(receivedData)
        
        // No point if data length < 2, also we may crash in that case...
        guard data.count > 2 else { return nil }
        
        var offset: Int = 0
        var startImageOffset: Int?
        
        var payloads: [Payload] = []
        
        // Search for next ff xx
        while offset < data.count - 1 {
            
            // Find 0xff 0xx (ignoring multiple chained 0xff 0xff 0xff which is valid)
            guard data[offset] == 0xff, data[offset + 1] != 0xff else {
                offset += 1
                continue
            }
            
            switch data[offset + 1] {
                // If any of these bytes follow the 0xff marker we don't get a length next
                // so we just offset ++ and then continue
            case 0x00, 0x01, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xdb:
                offset += 1
                // Start of image marker!
            case 0xd8:
                startImageOffset = offset
                offset += 1
                // End of image marker!
            case 0xd9:
                guard let _startImageOffset = startImageOffset else {
                    offset += 1
                    continue
                }
                let imageRange: Range<Int> = _startImageOffset..<offset+2
                let imageData = Data(data[imageRange])
                guard let image = Image(data: imageData) else {
                    offset += 1
                    continue
                }
                offset += 1
                // Set this back to nil so don't end up corrupting our data again
                startImageOffset = nil
                let payload = Payload(image: image, dataRange: imageRange)
                payloads.append(payload)
            default:
                guard startImageOffset != nil else {
                    offset += 1
                    continue
                }
                // We're going to read two bytes, so make sure we won't get out of bounds!
                guard offset < data.count -  4 else {
                    offset += 1
                    continue
                }
                guard let length = UInt16(data: data[offset+2..<offset+4]), length > 2 else {
                    offset += 1
                    continue
                }
                offset += Int(length) - 2
                continue
            }
        }
        
        if let payloadsMinBound = payloads.first?.dataRange.startIndex, let payloadsMaxBound = payloads.last?.dataRange.endIndex {
            let fullRange: Range<Int> = payloadsMinBound..<payloadsMaxBound
            let range = fullRange.clamped(to: receivedData.startIndex..<receivedData.endIndex)
            receivedData.removeSubrange(range)
        }
        
        return payloads.isEmpty ? nil : payloads
    }
}

extension LiveViewStream: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        attemptImageParse()
        // Clear out the buffer if it got too big!
        if receivedData.count > bufferSize {
            
            defer {
                receivedData = Data()
            }
            
            Logger.log(message: "Live view stream buffer has overflown", category: "LiveViewStreaming", level: .info)
            os_log("Live view stream buffer has overflown", log: log, type: .info)
            
            guard !hasLoggedOverflowBuffer else {
                return
            }
            
            Logger.log(message: "\(ByteBuffer(bytes: data.toBytes).toHex)", category: "LiveViewStreaming", level: .info)
            hasLoggedOverflowBuffer = true
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if (error as NSError?)?.domain == NSURLErrorDomain && (error as NSError?)?.code == NSURLErrorCancelled {
            Logger.log(message: "Live view stream cancelled, ignoring...", category: "LiveViewStreaming", level: .info)
            os_log("Live view stream cancelled, ignoring...", log: log, type: .info)
            // Still need to reset data, otherwise we may run into parsing issues!
            receivedData = Data()
            return
        }
        
        Logger.log(message: "Live view stream did error, restarting...", category: "LiveViewStreaming", level: .error)
        os_log("Live view stream did error, restarting...", log: log, type: .error)
        receivedData = Data()
        guard error != nil else { return }
        start()
    }
}

/// An error enum for stream errors
///
/// - unknown: An unknown error occured
/// - alreadyStreaming: The device is already streaming
public enum StreamingError: Error {
    case unknown
    case alreadyStreaming
}
