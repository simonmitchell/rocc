//
//  PTP.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct PTP {
    
    enum CommandCode: Word {
        case getDeviceInfo = 0x1001
        case openSession = 0x1002
        case closeSession = 0x1003
        case getStorageIds = 0x1004
        case getStorageInfo = 0x1005
        case getNumObjects = 0x1006
        case getObjectHandles = 0x1007
        case getObjectInfo = 0x1008
        case getObject = 0x1009
        case getThumb = 0x100a
        case deleteObject = 0x100b
        case sendObjectInfo = 0x100c
        case sendObject = 0x100d
        case initiateCapture = 0x100e
        case formatStore = 0x100f
        case resetDevice = 0x1010
        case selfTest = 0x1011
        case setObjectProtection = 0x1012
        case powerDown = 0x1013
        case getDevicePropDesc = 0x1014
        case getDevicePropValue = 0x1015
        case setDevicePropValue = 0x1016
        case resetDevicePropValue = 0x1017
        case terminateOpenCapture = 0x1018
        case moveObject = 0x1019
        case copyObject = 0x101a
        case getPartialObject = 0x101b
        case initiateOpenCapture = 0x101c
        case okay = 0x2001
        case sdioConnect = 0x9201
        case sdioGetExtDeviceInfo = 0x9202
        case sonyGetDevicePropDesc = 0x9203
        case sonyGetDevicePropValue = 0x9204
        case setControlDeviceA = 0x9205
        case getControlDeviceDesc = 0x9206
        case setControlDeviceB = 0x9207
        case getAllDevicePropData = 0x9209
        case startMovieRec = 0x920a
        case endMovieRec = 0x920b
        case terminateCapture = 0x920c
        case unknownHandshakeRequest = 0x920D
        case getObjectProperties = 0x9801
        case getObjectPropertyDescription = 0x9802
        case getObjectPropertyValue = 0x9803
        case getObjectPropertyList = 0x9805
    }
}
