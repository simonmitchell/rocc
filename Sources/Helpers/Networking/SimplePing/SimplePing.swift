/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    An object wrapper around the low-level BSD Sockets ping function.
 */

import Foundation

let ICMPv4TypeEchoRequest = 8          ///< The ICMP `type` for a ping request; in this case `code` is always 0.
let ICMPv4TypeEchoReply   = 0           ///< The ICMP `type` for a ping response; in this case `code` is always 0.

let ICMPv6TypeEchoRequest = 128        ///< The ICMP `type` for a ping request; in this case `code` is always 0.
let ICMPv6TypeEchoReply   = 129         ///< The ICMP `type` for a ping response; in this case `code` is always 0.

/// Describes the on-the-wire header format for an IPv4 packet.
///
/// This defines the header structure of IPv4 packets on the wire. We need
/// this in order to skip the header in the IPv4 case, where the kernel passes
/// it to us for no obvious reason.
struct IPv4Header {
    
    /// The size of an IPv4Header in bytes
    static let size: Int = 20
    
    static let versionAndHeaderLengthOffset: Int = 0
    
    static let protocolOffset: Int = 9
    
    // options...
    // data...
}

struct ICMPHeader {
    
    /// The size of an ICMPHeader in bytes
    static let size: Int = 8
    
    static let checksumOffset: Int = 2
    
    static let typeOffset: Int = 0
    
    static let codeOffset: Int = 1
    
    static let identifierOffset: Int = 4
    
    static let sequenceNumberOffset: Int = 6
    
    var type: UInt8 = 0
    
    var code: UInt8 = 0
    
    var checksum: UInt16 = 0
    
    var identifier: UInt16 = 0
    
    var sequenceNumber: UInt16 = 0
    
    init?(_ data: Data) {
        
        guard data.count >= MemoryLayout<ICMPHeader>.size else {
            return nil
        }
        
        data[0..<1].withUnsafeBytes { type = $0.bindMemory(to: UInt8.self).first ?? type }
        data[1..<2].withUnsafeBytes { code = $0.bindMemory(to: UInt8.self).first ?? code }
        data[2..<4].withUnsafeBytes { checksum = $0.bindMemory(to: UInt16.self).first ?? checksum }
        data[4..<6].withUnsafeBytes { identifier = $0.bindMemory(to: UInt16.self).first ?? identifier }
        data[6..<8].withUnsafeBytes { sequenceNumber = $0.bindMemory(to: UInt16.self).first ?? sequenceNumber }
    }
}

extension Data {
    
    /// Calculates the offset of the ICMP header within an IPv4 packet.
    ///
    /// In the IPv4 case the kernel returns us a buffer that includes the
    /// IPv4 header.  We're not interested in that, so we have to skip over it.
    /// This code does a rough check of the IPv4 header and, if it looks OK,
    /// returns the offset of the ICMP header.
    ///
    /// - Returns: The offset of the ICMP header, or NSNotFound.
    func icmpHeaderOffsetIPv4() -> UInt? {
        guard count >= IPv4Header.size + MemoryLayout<ICMPHeader>.size else {
            return nil
        }
        let versionAndHeaderLength = self[IPv4Header.versionAndHeaderLengthOffset]
        let packetProtocol = self[IPv4Header.protocolOffset]
        
        guard versionAndHeaderLength & 0xF0 == 0x40 && packetProtocol == IPPROTO_ICMP else {
            return nil
        }
        
        let ipHeaderLength = size_t(versionAndHeaderLength & 0x0F) * MemoryLayout<UInt32>.size
        guard count >= ipHeaderLength + MemoryLayout<ICMPHeader>.size else { return nil }
        
        return UInt(ipHeaderLength)
    }
}

/// Merges two `UInt8` into a `UInt16` identical to how a `c`
/// union of `uint16_t` and `uint8_t[2]` behaves
/// - Parameters:Ω
///   - int: The original UInt8
///   - with: The UInt8 to merge into
/// - Returns: The merge of the two UInt8
func merge(_ int: UInt8, _ with: UInt8) -> UInt16 {
    return (UInt16(with) << 8) | UInt16(int)
}

/// Calculates an IP checsum
//Users/simonmitchell/Downloads/hannahsimon-photo-download-1of1/portraits//
/// This is the standard BSD checksum code, modified to use modern types.
/// - Parameters:
///   - buffer: The data to checksum
///   - bufferLen: The length of the data
/// - Returns: The checksum value, in network byte order
func in_cksum(_ buffer: UnsafePointer<UInt16>, bufferLen: size_t) -> UInt16 {
        
    var bytesLeft: size_t = bufferLen
    var sum: Int32 = 0
    var cursor: UnsafePointer<UInt16> = buffer
    var answer: UInt16 = 0
        
    // Our algorithm is simple, using a 32 bit accumulator (sum), we add
    // sequential 16 bit words to it, and at the end, fold back all the
    // carry bits from the top 16 bits into the lower 16 bits.
    while bytesLeft > 1 {
        sum += Int32(cursor.pointee)
        cursor += 1
        bytesLeft -= 2
    }
    
    // Mop up an odd byte, if necessary
    if bytesLeft == 1 {
        sum += Int32(merge(UInt8(cursor.pointee), 0))
    }
    
    // Add back carry outs from top 16 bits to low 16 bits
    sum = (sum >> 16) + (sum & 0xffff) // Add hi 16 to low 16
    sum += (sum >> 16) // Add carry
    answer = UInt16(truncatingIfNeeded: ~sum) // Truncate to 16 bits
    
    return answer
}

protocol SimplePingDelegate: class {
    
    /// A SimplePing delegate callback, called once the object has started up.
    ///
    /// This is called shortly after you start the object to tell you that the
    /// object has successfully started.  On receiving this callback, you can call
    /// `sendPing(with:)` to send pings.
    ///
    /// If the object didn't start, `simplePing(_:didFailWithError:)` is called instead.
    /// - Parameters:
    ///   - simplePing: The object issuing the callback.
    ///   - address: The address that's being pinged; at the time this delegate callback
    ///   is made, this will have the same value as the `hostAddress` property.
    func simplePing(_ simplePing: SimplePing, didStartWithAddress address: Data)
    
    func simplePing(_ simplePing: SimplePing, didReceiveUnexpectedPacket packet: Data)
    
    func simplePing(_ simplePing: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16)
    
    func simplePing(_ simplePing: SimplePing, didFailWithError error: Error)
    
    func simplePing(_ simplePing: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16)
    
    func simplePing(_ simplePing: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error)
}

extension sockaddr {
    init?(_ data: Data) {
        guard data.count >= MemoryLayout<sockaddr>.size else {
            return nil
        }
        var result: sockaddr?
        data.withUnsafeBytes { bytes in
            result = bytes.baseAddress?.assumingMemoryBound(to: sockaddr.self).pointee
        }
        guard let finalResult = result else {
            return nil
        }
        self = finalResult
    }
}

/// An object wrapper around the low-level BSD Sockets ping function.
///
/// To use the class create an instance, set the delegate and call `start()`
/// to start the instance on the current run loop.  If things go well you'll soon get the
/// `simplePing(_:didStartWithAddress:)` delegate callback.  From there you can can call
/// `sendPing(with:)` to send a ping and you'll receive the
/// `simplePing(_:didReceivePingResponsePacket:sequenceNumber:)` and
/// `simplePing(_:didReceiveUnexpectedPacket:)` delegate callbacks as ICMP packets arrive.
///
/// The class can be used from any thread but the use of any single instance must be
/// confined to a specific thread and that thread must run its run loop.
class SimplePing {
    
    /// Controls the IP address version used by `SimplePing` instances.
    enum AddressStyle {
        /// Use the first IPv4 or IPv6 address found; the default.
        case any
        /// Use the first IPv4 address found.
        case ICMPv4
        /// Use the first IPv6 address found.
        case ICMPv6
    }
    
    /// The delegate for this object.
    ///
    /// Delegate callbacks are scheduled in the default run loop mode
    /// of the run loop of the thread that calls `start()`.
    weak var delegate: SimplePingDelegate?
            
    /// True if `nextSequenceNumber` has wrapped from 65535 to 0.
    private var nextSequenceNumberHasWrapped: Bool = false
    
    /// A host object for name-to-address resolution.
    var host: CFHost?
    
    /// A socket object for ICMP send and receive.
    var icmpSocket: CFSocket?
    
    /// A copy of the value passed to `init(hostName:)`
    var hostName: String
    
    /// Controls the IP address version used by the object.
    let addressStyle: AddressStyle
    
    /// The address being pinged.
    ///
    /// The contents of the Data is a (struct sockaddr) of some form.
    /// The value is `nil` while the object is stopped and remains nil
    /// on start until `simplePing(_:didStartWithAddress:)` is called
    var hostAddress: Data?
    
    /// The address family for the `hostAddress` or `AF_UNSPEC` if that's nil
    var hostAddressFamily: sa_family_t {
        var result: sa_family_t = sa_family_t(AF_UNSPEC)
        guard let hostAddress = hostAddress else {
            return result
        }
        result = sockaddr(hostAddress)?.sa_family ?? result
        return result
    }
    
    /// The identifier used by pings by this object.
    ///
    /// When you create an instance of this object it generates a
    /// random ientifier that it uses to identify it's own pings
    let identifier: UInt16 = UInt16.random(in: 0..<UInt16.max)
    
    /// The next sequence number to be used by this object.
    ///
    /// This value starts at zero and increments each time you send a ping (safely
    /// wrapping back to zero if necessary).  The sequence number is included in the ping,
    /// allowing you to match up requests and responses, and thus calculate ping times and
    /// so on.
    var nextSequenceNumber: UInt16 = 0
    
    /// Initialises the object to ping the specified host.
    /// - Parameter hostName: The DNS name of the host to ping;
    /// an IPv4 or IPv6 address in string form will work here.
    /// - Parameter addressStyle: The address style to use
    init(hostName: String, addressStyle: AddressStyle = .any) {
        self.addressStyle = addressStyle
        self.hostName = hostName
    }
    
    deinit {
        stop()
    }
    
    /// Starts the object
    ///
    /// You should setup the delegate and any ping parameters before calling this.
    ///
    /// If things go well you'll soon get the `simplePing(_:didStartWithAddress:)` delegate
    /// callback, at which point you can start sending pings (via `sendPing(with:)`) and
    /// will start receiving ICMP packets (either ping responses, via the
    /// `simplePing(_:didReceivePingResponsePacket:sequenceNumber:)` delegate callback, or
    /// unsolicited ICMP packets, via the `simplePing(_:didReceiveUnexpectedPacket:)` delegate
    /// callback).
    ///
    /// If the object fails to start, typically because `hostName` doesn't resolve, you'll get
    /// the `simplePing(_:didFailWithError:)` delegate callback.
    ///
    /// It is not correct to start an already started object.
    func start() {
        
        let localHost = CFHostCreateWithName(nil, hostName as CFString).takeRetainedValue()
        host = localHost
                
        var context = CFHostClientContext(
            version: 0,
            info: Unmanaged.passRetained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: unsafeBitCast(kCFAllocatorDefault, to: CFAllocatorCopyDescriptionCallBack.self)
        )
        
        CFHostSetClient(
            host!,
            { (host, typeInfo, error, info) in
                guard let info = info else {
                    return
                }
                let simplePing = Unmanaged<SimplePing>.fromOpaque(info).takeRetainedValue()
                guard host == simplePing.host else { return }
                if let error = error, error.pointee.domain != 0 {
                    simplePing.didFail(hostStreamError: error.pointee)
                } else {
                    simplePing.hostResolutionDone()
                }
            },
            &context
        )
        
        CFHostScheduleWithRunLoop(
            host!,
            CFRunLoopGetCurrent(),
            CFRunLoopMode.defaultMode.rawValue
        )
        
        var streamError: CFStreamError = CFStreamError()
        let success = CFHostStartInfoResolution(
            host!,
            .addresses,
            &streamError
        )
        
        guard !success else{
            return
        }
        didFail(hostStreamError: streamError)
    }
    
    private func startWithHostAddress() {
        
        guard let hostAddress = hostAddress else { return }
        
        // Open the socket
        var fd: CFSocketNativeHandle = -1
        var err: Int32 = 0
        
        switch Int32(hostAddressFamily) {
        case AF_INET:
            fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP)
            if fd < 0 {
                err = errno
            }
        case AF_INET6:
            fd = socket(AF_INET6, SOCK_DGRAM, IPPROTO_ICMPV6)
            if fd < 0 {
                err = errno
            }
        default:
            err = EPROTONOSUPPORT
        }
        
        guard err == 0 else {
            let error = NSError(
                domain: NSPOSIXErrorDomain,
                code: Int(err),
                userInfo: nil
            )
            didFail(error: error)
            return
        }
        
        var context = CFSocketContext(
            version: 0,
            info: Unmanaged.passRetained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
                
        icmpSocket = CFSocketCreateWithNative(
            nil,
            fd,
            CFOptionFlags(CFSocketCallBackType.readCallBack.rawValue),
            { (_, _, _, _, info) in
                guard let info = info else {
                    return
                }
                let simplePing = Unmanaged<SimplePing>.fromOpaque(info).takeRetainedValue()
                print("Read data")
                simplePing.readData()
            },
            &context
        )
        
        fd = -1
        let rls = CFSocketCreateRunLoopSource(nil, icmpSocket, 0)
        
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            rls,
            .defaultMode
        )
        
        delegate?.simplePing(self, didStartWithAddress: hostAddress)
    }
    
    /// Reads data from the ICMP socket
    ///
    /// Called by the socket handling code to process an ICMP message
    /// waiting on the socket.
    private func readData() {
        
        let kBufferSize: Int = 65535
        var addr = sockaddr()
        
        // 65535 is the maximum IP packet size, which seems like a reasonable bound
        // here (plus it's what <x-man-page://8/ping> uses).
        var buffer = [UInt8](repeating: 0, count: kBufferSize)
        
        // Actually read the data.  We use recvfrom(), and thus get back the source address,
        // but we don't actually do anything with it.  It would be trivial to pass it to
        // the delegate but we don't need it in this example.
        
        var addrLen: socklen_t = socklen_t(MemoryLayout<sockaddr_in>.size)
        let bytesRead: ssize_t = recvfrom(
            CFSocketGetNative(icmpSocket),
            &buffer,
            kBufferSize,
            0,
            &addr,
            &addrLen
        )
        
        var err: Int32 = 0
        if bytesRead < 0 {
            err = errno
        }
        
        // Process the data we read.
        
        guard bytesRead > 0 else {
            // We failed to read the data, so shut everything down.
            if err == 0 {
                err = EPIPE
            }
            didFail(
                error: NSError(
                    domain: NSPOSIXErrorDomain,
                    code: Int(err),
                    userInfo: nil
                )
            )
            return
        }
        
        var sequenceNumber: UInt16 = 0
                
        buffer.withUnsafeBytes { (bufferPointer)  in
            
            guard let bufferUnsafeRawPointer = bufferPointer.baseAddress else {
                return
            }
                
            var packet = Data(bytes: bufferUnsafeRawPointer, count: bytesRead)
            
            if validatePingResponsePacket(data: &packet, sequenceNumber: &sequenceNumber) {
                delegate?.simplePing(self, didReceivePingResponsePacket: packet, sequenceNumber: sequenceNumber)
            } else {
                delegate?.simplePing(self, didReceiveUnexpectedPacket: packet)
            }
        }
        
        // Note that we don't loop back trying to read more data.  Rather, we just
        // let CFSocket call us again.
    }
    
    private func validatePingResponsePacket(data: inout Data, sequenceNumber: inout UInt16) -> Bool {
        
        switch Int32(hostAddressFamily) {
        case AF_INET:
            return validatePing4ResponsePacket(data: &data, sequenceNumber: &sequenceNumber)
        case AF_INET6:
            return validatePing6ResponsePacket(data: &data, sequenceNumber: &sequenceNumber)
        default:
            return false
        }
    }
    
    /// Checks whether an incoming IPv4 packet looks like a ping response.
    ///
    /// details This routine modifies this `packet` data!  It does this for two reasons:
    ///  - It needs to zero out the `checksum` field of the ICMPHeader in order to do
    ///  its checksum calculation.
    ///  - It removes the IPv4 header from the front of the packet.
    /// - Parameters:
    ///   - data: The IPv4 packet, as returned to us by the kernel.
    ///   - sequenceNumber: A pointer to a place to start the ICMP sequence number.
    /// - Returns: `true` if the packet looks like a reasonable IPv4 ping response.
    private func validatePing4ResponsePacket(data: inout Data, sequenceNumber: inout UInt16) -> Bool {
        
        guard let icmpHeaderOffset = data.icmpHeaderOffsetIPv4() else {
            return false
        }
        
        var icmpHeaderData = Data(data.suffix(from: Data.Index(icmpHeaderOffset)))
        
        guard let icmpHeader = ICMPHeader(icmpHeaderData) else {
            return false
        }
        
        let receivedChecksum = icmpHeader.checksum
        
        // Set checksum to zero for in_cksum calculation
        withUnsafeBytes(of: 0 as UInt16) {
            icmpHeaderData.replaceSubrange(2..<4, with: $0)
        }
        
        var dataBuffer: UnsafePointer<UInt16>?
        icmpHeaderData.withUnsafeBytes { (body) in
            dataBuffer = body.bindMemory(to: UInt16.self).baseAddress
        }
        
        guard let buffer = dataBuffer else {
            return false
        }
        
        let calculatedChecksum = in_cksum(buffer, bufferLen: data.count - Int(icmpHeaderOffset))
        
        guard receivedChecksum == calculatedChecksum else {
            return false
        }
        
        guard validateICMPHeader(icmpHeader, matchesType: ICMPv4TypeEchoReply, sequenceNumber: &sequenceNumber) else {
            return false
        }
        
        // Remove the IPv4 header off the front of the data we received, leaving us with
        // just the ICMP header and the ping payload.
        data.removeSubrange(0..<Int(icmpHeaderOffset))
        
        return true
    }
    
    /// Checks whether an incoming IPv6 packet looks like a ping response.
    /// - Parameters:
    ///   - data: The IPv6 packet, as returned to us by the kernel; note that this routine
    ///   could modify this data but does not need to in the IPv6 case.
    ///   - sequenceNumber: A pointer to a place to start the ICMP sequence number.
    /// - Returns: `true` if the packet looks like a reasonable IPv6 ping response.
    private func validatePing6ResponsePacket(data: inout Data, sequenceNumber: inout UInt16) -> Bool {
        
        guard let icmpHeader = ICMPHeader(data) else {
            return false
        }
        return validateICMPHeader(icmpHeader, matchesType: ICMPv6TypeEchoReply, sequenceNumber: &sequenceNumber)
    }
    
    private func validateICMPHeader(_ header: ICMPHeader, matchesType type: Int, sequenceNumber: inout UInt16) -> Bool {
        
        guard header.type == type, header.code == 0 else {
            return false
        }
        
        guard CFSwapInt16BigToHost(header.identifier) == identifier else {
            return false
        }
        
        let packetSequenceNumber = CFSwapInt16BigToHost(header.sequenceNumber)
        guard validateSequenceNumber(packetSequenceNumber) else {
            return false
        }
        
        sequenceNumber = packetSequenceNumber
        return true
    }
    
    /// Checks whether the specified sequence number is one we sent.
    /// - Parameter sequenceNumber: The incoming sequence number.
    /// - Returns: `true` if the sequence number looks like one we sent.
    private func validateSequenceNumber(_ sequenceNumber: UInt16) -> Bool {
        if nextSequenceNumberHasWrapped {
            // If the sequence numbers have wrapped that we can't reliably check
            // whether this is a sequence number we sent.  Rather, we check to see
            // whether the sequence number is within the last 120 sequence numbers
            // we sent.  Note that the uint16_t subtraction here does the right
            // thing regardless of the wrapping.
            //
            // Why 120?  Well, if we send one ping per second, 120 is 2 minutes, which
            // is the standard "max time a packet can bounce around the Internet" value.
            return nextSequenceNumber - sequenceNumber < 120
        } else {
            return sequenceNumber < nextSequenceNumber
        }
    }
        
    /// Stops the object.
    ///
    /// You should call this when you're done pinging.
    ///
    /// It's safe to call this on an object that's stopped.
    func stop() {
        stopHostResolution()
        stopSocket()
        
        // Junk the host address on stop. If the client calls `start()` again,
        // we'll re-resolve the host name.
        hostAddress = nil
    }
    
    /// Stops the name-to-address resolution infrastructure.
    private func stopHostResolution() {
        guard let host = host else { return }
        CFHostSetClient(host, nil, nil)
        CFHostUnscheduleFromRunLoop(
            host,
            CFRunLoopGetCurrent(),
            CFRunLoopMode.defaultMode.rawValue
        )
        self.host = nil
    }
    
    /// Stops the send and receive infrastructure.
    private func stopSocket() {
        guard let socket = icmpSocket else { return }
        CFSocketInvalidate(socket)
        self.icmpSocket = nil
    }
    
    /// Shuts down the pinger object and tell the delegate about the error.
    ///
    /// This converts the CFStreamError to an NSError and then call through to
    /// didFail(error:) to do the real work.
    /// - Parameter hostStreamError: Describes the failure.
    private func didFail(hostStreamError: CFStreamError) {
        didFail(
            error: NSError(
                domain: kCFErrorDomainCFNetwork as String,
                code: Int(CFNetworkErrors.cfHostErrorUnknown.rawValue),
                userInfo: hostStreamError.domain == kCFStreamErrorDomainNetDB ?
                    [kCFGetAddrInfoFailureKey as String : hostStreamError.error] : nil
            )
        )
    }
    
    /// Shuts down the pinger object and tell the delegate about the error.
    /// - Parameter error: Describes the failure.
    private func didFail(error: Error) {
        stop()
        delegate?.simplePing(self, didFailWithError: error)
    }
    
    /// Processes the results of our name-to-address resolution.
    ///
    /// Called by our CFHost resolution callback when host resolution
    /// is complete. We just latch the first appropriate address and kick
    /// off the send and receive infrastructure
    private func hostResolutionDone() {
        
        guard let host = host else { return }
        
        var resolved: DarwinBoolean = false
        
        let addresses = CFHostGetAddressing(host, &resolved)
        
        if let addresses = addresses?.takeUnretainedValue() as? [Data], resolved.boolValue {
            
            resolved = false
            
            for data in addresses {
                
                guard let address = sockaddr(data) else {
                    continue
                }
                    
                switch Int32(address.sa_family) {
                case AF_INET:
                    if addressStyle != .ICMPv6 {
                        hostAddress = data
                        resolved = true
                    }
                case AF_INET6:
                    if addressStyle != .ICMPv4 {
                        hostAddress = data
                        resolved = true
                    }
                default:
                    break
                }
                
                if resolved.boolValue {
                    break
                }
            }
        }
        
        // We're done resolving, so shut that down.
        stopHostResolution()
        
        // If all is okay, start the send and receive infrastructure, otherwise stop.
        
        if resolved.boolValue {
            startWithHostAddress()
        } else {
            let error = NSError(
                domain: kCFErrorDomainCFNetwork as String,
                code: Int(CFNetworkErrors.cfHostErrorHostNotFound.rawValue),
                userInfo: nil
            )
            didFail(error: error)
        }
    }
    
    /// Sends a ping packet containing the specified data.
    ///
    /// The object must be started when you call this method and, on starting the object, you must
    /// wait for the `simplePing(_:didStartWithAddress:)` delegate callback before calling it.
    /// - Parameter data: Some data to include in the ping packet, after the ICMP header, or nil if you
    /// want the packet to include a standard 56 byte payload (resulting in a standard 64 byte
    /// ping).
    func send(ping data: Data) {
        
        guard let hostAddress = hostAddress else { return }
        
        let packet: Data
        
        switch hostAddressFamily {
        case sa_family_t(AF_INET):
            packet = createPingPacket(type: UInt8(ICMPv4TypeEchoRequest), payload: data, requiresChecksum: true)
        case sa_family_t(AF_INET6):
            packet = createPingPacket(type: UInt8(ICMPv6TypeEchoRequest), payload: data, requiresChecksum: false)
        default:
            return
        }
        
        // Send the packet
        var bytesSent: ssize_t = -1
        var err: Int32 = EBADF
        
        var rawPtr: UnsafeRawPointer?
        packet.withUnsafeBytes { rawBufferPointer in
            rawPtr = rawBufferPointer.baseAddress
        }
        
        if let socket = icmpSocket, let packetRawPtr = rawPtr, var sockAddr = sockaddr(hostAddress) {
            
            bytesSent = sendto(
                CFSocketGetNative(socket),
                packetRawPtr,
                packet.count,
                0,
                &sockAddr,
                socklen_t(hostAddress.count)
            )
            err = bytesSent < 0 ? errno : 0
        }
        
        if bytesSent > 0 && bytesSent == packet.count {
            delegate?.simplePing(self, didSendPacket: packet, sequenceNumber: nextSequenceNumber)
        } else {
            
            // Some sort of failure, tell the client.
            if err == 0 {
                err = ENOBUFS // This is not a hugely descriptive error, alas
            }
            
            let error = NSError(
                domain: NSPOSIXErrorDomain,
                code: Int(err),
                userInfo: nil
            )
            
            delegate?.simplePing(
                self,
                didFailToSendPacket: packet,
                sequenceNumber: nextSequenceNumber,
                error: error
            )
        }
        
        nextSequenceNumber += 1
        if nextSequenceNumber == 0 {
            nextSequenceNumberHasWrapped = true
        }
    }
    
    /// Builds a ping packet from the supplied parameters.
    /// - Parameters:
    ///   - type: The packet type, which is different for IPv4 and IPv6.
    ///   - payload: Data to place after the ICMP header.
    ///   - requiresChecksum: Determines whether a checksum is calculated (IPv4) or not (IPv6).
    /// - Returns: A ping packet suitable to be passed to the kernel.
    private func createPingPacket(type: UInt8, payload: Data, requiresChecksum: Bool) -> Data {
        
        var packetData = Data(capacity: MemoryLayout<ICMPHeader>.size + payload.count)
        
        withUnsafeBytes(of: type) { packetData.append(contentsOf: $0) }
        withUnsafeBytes(of: 0 as UInt8) { packetData.append(contentsOf: $0) }
        withUnsafeBytes(of: 0 as UInt16) { packetData.append(contentsOf: $0) }
        withUnsafeBytes(of: CFSwapInt16HostToBig(identifier)) { packetData.append(contentsOf: $0) }
        withUnsafeBytes(of: CFSwapInt16HostToBig(nextSequenceNumber)) { packetData.append(contentsOf: $0) }
               
        packetData.append(payload)
        
        if requiresChecksum {
            
            var dataBuffer: UnsafePointer<UInt16>?
            packetData.withUnsafeBytes { (body) in
                dataBuffer = body.bindMemory(to: UInt16.self).baseAddress
            }
            
            guard let buffer = dataBuffer else {
                return packetData
            }
            
            let checksum = in_cksum(buffer, bufferLen: MemoryLayout<ICMPHeader>.size + payload.count)
            withUnsafeBytes(
                of: checksum
            ) {
                packetData.replaceSubrange(2..<4, with: $0)
            }
        }
        
        return packetData
    }
}
