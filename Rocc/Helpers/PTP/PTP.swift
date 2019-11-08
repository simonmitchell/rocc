//
//  PTP.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct PTP {
    
    /// Represents a file format as defined by PTP IP camera implementations
    /// Values were taken from [libgphoto2](https://github.com/gphoto/libgphoto2/blob/bcd86bab811a0ca0ae907f8ed3b592e050a53c46/camlibs/ptp2/ptp.h#L1180)
    enum FileFormat: Word {
        case undefined = 0x3000
        case defined = 0x3800
        case association = 0x3001
        case script = 0x3002
        case executable = 0x3003
        case text = 0x3004
        case HTML = 0x3005
        case dpof = 0x3006
        case aiff = 0x3007
        case wav = 0x3008
        case mp3 = 0x3009
        case avi = 0x300A
        case mpeg = 0x300B
        case asf = 0x300C
        case qt = 0x300D
        /* image formats */
        case jpeg = 0x3801
        case tiff_ep = 0x3802
        case flashPix = 0x3803
        case bmp = 0x3804
        case ciff = 0x3805
        case undefined_0x3806 = 0x3806
        case gif = 0x3807
        case jfif = 0x3808
        case pcd = 0x3809
        case pict = 0x380A
        case png = 0x380B
        case undefined_0x380C = 0x380C
        case tiff = 0x380D
        case tiff_it = 0x380E
        case jp2 = 0x380F
        case jpx = 0x3810
        /* ptp v1.1 has only DNG new */
        case dng = 0x3811
        /* Eastman Kodak extension ancillary format */
        case ek_m3u = 0xb002
        /* Canon extension */
        case canon_crw3 = 0xb103
        case canon_mov = 0xb104
        case canon_mov2 = 0xb105
        case canon_cr3 = 0xb108
        /* CHDK specific raw mode */
        case canon_chdk_crw = 0xb1ff
        /* Sony */
        case raw = 0xb101
        case undefined_0xb301 = 0xb301
    }
    
    enum EventCode: Word {
        case objectAdded = 0xc201
        case objectRemoved = 0xC202
        case propertyChanged = 0xC203
        case unknown1 = 0xc204
        case unknown2 = 0xc205
        case unknown3 = 0xc206
        case unknown4 = 0xc207
    }
    
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
