//
//  NetworkInterface.swift
//  Rocc
//
//  Created by Simon Mitchell on 20/04/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

#if swift(>=3.2)
import Darwin
#else
import ifaddrs
#endif

fileprivate func extractAddress_ipv4(_ address:UnsafeMutablePointer<sockaddr_storage>) -> String? {
    return address.withMemoryRebound(to: sockaddr.self, capacity: 1) { addr in
        var address : String? = nil
        var hostname = [CChar](repeating: 0, count: Int(2049))
        if (getnameinfo(&addr.pointee, socklen_t(addr.pointee.sa_len), &hostname,
                        socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0) {
            address = String(cString: hostname)
        }
        else {
            //            var error = String.fromCString(gai_strerror(errno))!
            //            println("ERROR: \(error)")
        }
        return address
        
    }
}

fileprivate func extractAddress_ipv6(_ address:UnsafeMutablePointer<sockaddr_storage>) -> String? {
    var addr = address.pointee
    var ip : [Int8] = [Int8](repeating: Int8(0), count: Int(INET6_ADDRSTRLEN))
    return inetNtoP(&addr, ip: &ip)
}

fileprivate func inetNtoP(_ addr:UnsafeMutablePointer<sockaddr_storage>, ip:UnsafeMutablePointer<Int8>) -> String? {
    return addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { addr6 in
        let conversion:UnsafePointer<CChar> = inet_ntop(AF_INET6, &addr6.pointee.sin6_addr, ip, socklen_t(INET6_ADDRSTRLEN))
        return String(cString: conversion)
    }
}

fileprivate func extractAddress(_ address: UnsafeMutablePointer<sockaddr>?) -> String? {
    guard let address = address else { return nil }
    return address.withMemoryRebound(to: sockaddr_storage.self, capacity: 1) {
        if (address.pointee.sa_family == sa_family_t(AF_INET)) {
            return extractAddress_ipv4($0)
        }
        else if (address.pointee.sa_family == sa_family_t(AF_INET6)) {
            return extractAddress_ipv6($0)
        }
        else {
            return nil
        }
    }
}

struct NetworkInterface {
    
    enum Family: Int {
        
        case ipv4
        
        case ipv6
        
        var stringValue: String {
            switch self {
            case .ipv4:
                return "IPv4"
            case .ipv6:
                return "IPv6"
            }
        }
    }
    
    let address: String?
    
    let netmask: String?
    
    let name: String
    
    let family: Family?
    
    let isRunning: Bool
    
    let isUp: Bool
    
    let loopBack: Bool
    
    let supportsMulticast: Bool
    
    let broadcastAddress: String?
    
    init(data: ifaddrs) {
        
        let flags = Int32(data.ifa_flags)
        let broadcastValid : Bool = ((flags & IFF_BROADCAST) == IFF_BROADCAST)
        
        if let sa_family = data.ifa_addr?.pointee.sa_family {
            switch sa_family {
            case UInt8(AF_INET):
                family = .ipv4
            case UInt8(AF_INET6):
                family = .ipv6
            default:
                family = nil
            }
        } else {
            family = nil
        }
        
        name = String(cString: data.ifa_name)
        address = extractAddress(data.ifa_addr)
        netmask = extractAddress(data.ifa_netmask)
        isRunning = ((flags & IFF_RUNNING) == IFF_RUNNING)
        isUp = ((flags & IFF_UP) == IFF_UP)
        loopBack = ((flags & IFF_LOOPBACK) == IFF_LOOPBACK)
        supportsMulticast = ((flags & IFF_MULTICAST) == IFF_MULTICAST)
        
        guard broadcastValid, let dstAddr = data.ifa_dstaddr else {
            broadcastAddress = nil
            return
        }
        broadcastAddress = extractAddress(dstAddr)
    }
    
    static var all: [NetworkInterface] {
    
        var ifaddrs : UnsafeMutablePointer<ifaddrs>?
        
        // Gets the current interfaces, returning 0 if successful
        let success = getifaddrs(&ifaddrs)
        
        guard success == 0, let firstAddress = ifaddrs else {
            return []
        }
        
        // Create a squence of `ifaddrs` from the interfaces
        let addressSequence = sequence(first: firstAddress) { $0.pointee.ifa_next }
        
        let interfaces = addressSequence.compactMap { (address) -> NetworkInterface? in
            return NetworkInterface(data: address.pointee)
        }
        
        freeifaddrs(ifaddrs)
        return interfaces
    }
}
