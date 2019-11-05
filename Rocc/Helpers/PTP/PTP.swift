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
    
    enum DeviceProperty: Word {
        case undefined = 0x5000
        case batteryLevel = 0x5001
        case functionalMode = 0x5002
        case imageSize = 0x5003
        case compressionSetting = 0x5004
        case whiteBalance = 0x5005
        case rgbGain = 0x5006
        case fNumber = 0x5007
        case focalLength = 0x5008
        case focusDistance = 0x5009
        case focusMode = 0x500a
        case exposureMeteringMode = 0x500b
        case flashMode = 0x500c
        case exposureTime = 0x500d
        case exposureProgramMode = 0x500e
        case exposureIndex = 0x500f
        case exposureBiasCompensation = 0x5010
        case dateTime = 0x5011
        case captureDelay = 0x5012
        case stillCaptureMode = 0x5013
        case contrast = 0x5014
        case sharpness = 0x5015
        case digitalZoom = 0x5016
        case effectMode = 0x5017
        case burstNumber = 0x5018
        case burstInterval = 0x5019
        case timelapseNumber = 0x501a
        case timelapseInterval = 0x501b
        case focusMeteringMode = 0x501c
        case uploadURL = 0x501d
        case artist = 0x501e
        case copyrightInfo = 0x501f
        /* Sony Extensions */
        case DPCCompensation = 0xD200
        case DRangeOptimize = 0xD201
        case ImageSize = 0xD203
        case ShutterSpeed = 0xD20D
        case Unknown = 0xD20E
        case ColorTemp = 0xD20F
        case CCFilter = 0xD210
        case AspectRatio = 0xD211
        case FocusFound = 0xD213
        case ObjectInMemory = 0xD215
        case ExposeIndex = 0xD216
        case BatteryLevel = 0xD218
        case PictureEffect = 0xD21B
        case ABFilter = 0xD21C
        case ISO = 0xD21E
        case Movie = 0xD2C8
        case StillImage = 0xD2C7
    }
}
