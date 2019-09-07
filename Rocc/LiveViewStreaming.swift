//
//  LiveViewStreaming.swift
//  Rocc
//
//  Created by Simon Mitchell on 14/05/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

#if os(iOS)
public typealias Image = UIImage
#else
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
    
    /// The delegate which will have live stream updates passed to it
    public var delegate: LiveViewStreamDelegate?
    
    /// The camera who's live view is being streamed
    public let camera: Camera
    
    /// Whether the stream is currently running
    public var isStreaming: Bool = false
    
    /// The size of the stream (M/L)
    public var streamSize: String?
    
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
    }
    
    private var eventTimer: Timer?
    
    /// Starts the stream
    public func start() {
        
        #if os(iOS)
        guard camera as? DummyCamera == nil else {
            if let image = UIImage(named: "test_image", in: .main, compatibleWith: nil) {
                delegate?.liveViewStream(self, didReceive: image)
            }
            return
        }
        #endif
        
        camera.performFunction(LiveView.start, payload: nil) { [weak self] (error, streamURL) in
            
            guard let strongSelf = self else { return }
            
            guard let streamURL = streamURL else {
                
                guard let sonyError = error as? CameraError, case .alreadyRunningPollingAPI(_) = sonyError else {
                    strongSelf.delegate?.liveViewStream(strongSelf, didError: error ?? StreamingError.unknown)
                    return
                }
                
                strongSelf.camera.performFunction(LiveView.stop, payload: nil, callback: { [weak strongSelf] (error, response) in
                    
                    guard let _strongSelf = strongSelf else { return }
                    guard error == nil else {
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
    
    private func streamFrom(url: URL) {
        
        isStreaming = true
        //TODO: CREATE AND SEND A DELEGATE QUEUE HERE
        streamingSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: url)
        
        receivedData = Data()
        dataTask = streamingSession?.dataTask(with: request)
        dataTask?.resume()
    }
    
    /// Stops the stream
    public func stop() {
        
        isStreaming = false
        streamingSession?.invalidateAndCancel()
        streamingSession = nil
        receivedData = Data()
        
        camera.performFunction(LiveView.stop, payload: nil) { (error, void) in
            
        }
    }
    
    private struct Payload {
        
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
    
    private func attemptImageParse() {
        
        // Re-case as Data in-case we've received a DataSlice, which seems to be an issue somewhere!
        receivedData = Data(receivedData)
        
        // If for some reason our data doesn't start with the "Start Byte", then delete up to that point!
        if receivedData.count > 0, receivedData[0] != 0xFF {
            
            // If we have a start byte, discard everything before it
            if receivedData.contains(0xFF) {
                receivedData = receivedData.split(separator: 0xFF, maxSplits: 1, omittingEmptySubsequences: false).last ?? Data()
            } else {
                receivedData = Data()
            }
        }
        
        guard let payloads = payloads(), !payloads.isEmpty else {
            return
        }
        
        payloads.forEach { (payload) in
            
            if let image = payload.image {
                delegate?.liveViewStream(self, didReceive: image)
            }
            
            if let frames = payload.frames {
                delegate?.liveViewStream(self, didReceive: frames)
            }
        }
    }
    
    enum PayloadType {
        case image
        case frameInfo
    }
    
    private func payloads() -> [Payload]? {
        
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
}

extension LiveViewStream: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        attemptImageParse()
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
