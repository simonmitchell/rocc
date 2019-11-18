//
//  OperationResponsePacket.swift
//  Rocc
//
//  Created by Simon Mitchell on 03/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

struct CommandResponsePacket: Packetable {
    
    enum Code: Word, Error {
        
        case okay = 0x2001
        case generalError = 0x2002
        case sessionNotOpen = 0x2003
        case invalidTransactionID = 0x2004
        case operationNotSupported = 0x2005
        case parameterNotSupported = 0x2006
        case incompleteTransfer = 0x2007
        case invalidStorageId = 0x2008
        case invalidObjectHandle = 0x2009
        case devicePropNotSupported = 0x200A
        case invalidObjectFormatCode = 0x200B
        case storeFull = 0x200C
        case objectWriteProtected = 0x200D
        case storeReadOnly = 0x200E
        case accessDenied = 0x200F
        case noThumbnailPresent = 0x2010
        case selfTestFailed = 0x2011
        case partialDeletion = 0x2012
        case storeNotAvailable = 0x2013
        case specificationByFormatUnsupported = 0x2014
        case noValidObjectInfo = 0x2015
        case invalidCodeFormat = 0x2016
        case unknownVendorCode = 0x2017
        case captureAlreadyTerminated = 0x2018
        case deviceBusy = 0x2019
        case invalidParentObject = 0x201A
        case invalidDevicePropFormat = 0x201B
        case invalidDevicePropValue = 0x201C
        case invalidParameter = 0x201D
        case sessionAlreadyOpened = 0x201E
        case transactionCanceled = 0x201F
        case specificationOfDestinationUnsupported = 0x2020
        /* PTP v1.1 response codes */
        case invalidEnumHandle = 0x2021
        case noStreamEnabled = 0x2022
        case invalidDataSet = 0x2023

        /* Eastman Kodak extension Response Codes */
        case EK_filenameRequired = 0xA001
        case EK_filenameConflicts = 0xA002
        case EK_filenameInvalid = 0xA003

        /* nikon specific response codes */
//        case nikon_HardwareError = 0xA001
//        case nikon_OutOfFocus = 0xA002
//        case nikon_changeCameraModeFailed = 0xA003
        case nikon_invalidStatus = 0xA004
        case nikon_setPropertyNotSupported = 0xA005
        case nikon_wbResetError = 0xA006
        case nikon_dustReferenceError = 0xA007
        case nikon_shutterSpeedBulb = 0xA008
        case nikon_mirrorUpSequence = 0xA009
        case nikon_cameraModeNotAdjustFNumber = 0xA00A
        case nikon_notLiveView = 0xA00B
        case nikon_mfDriveStepEnd = 0xA00C
        case nikon_mfDriveStepInsufficiency = 0xA00E
        case nikon_advancedTransferCancel = 0xA022

        /* nikon specific response codes */
//        case nikon_UNKNOWN_COMMAND = 0xA001
//        case nikon_OPERATION_REFUSED = 0xA005
//        case nikon_lensCover = 0xA006
        case nikon_batteryLow = 0xA101
        case nikon_notReady = 0xA102

//        case nikon_A009 = 0xA009

//        case nikon_unknownCommand = 0xA001
//        case nikon_operationRefused = 0xA005
//        case nikon_lensCoverClosed = 0xA006
//        case nikon_lowBattery = 0xA101
//        case nikon_objectNotReady = 0xA102
        case nikon_cannotMakeObject = 0xA104
        case nikon_memoryStatusNotReady = 0xA106


        /* Microsoft/MTP specific codes */
        case MTP_indefined = 0xA800
        case MTP_invalidObjectPropCode = 0xA801
        case MTP_invalidObjectPropFormat = 0xA802
        case MTP_invalidObjectPropValue = 0xA803
        case MTP_invalidObjectReference = 0xA804
        case MTP_invalidDataset = 0xA806
        case MTP_specificationByGroupUnsupported = 0xA807
        case MTP_specificationByDepthUnsupported = 0xA808
        case MTP_objectTooLarge = 0xA809
        case MTP_objectPropNotSupported = 0xA80A

        /* Microsoft Advanced Audio/Video Transfer response codes
        (microsoft.com/AAVT 1.0) */
        case MTP_invalidMediaSessionID = 0xA170
        case MTP_mediaSessionLimitReached = 0xA171
        case MTP_noMoreData = 0xA172

        /* WiFi Provisioning MTP Extension Error Codes (microsoft.com/WPDWCN: 1.0) */
        case MTP_invalidWFCSyntax = 0xA121
        case MTP_wFCVersionNotSupported = 0xA122
    }
    
    var name: Packet.Name
    
    var length: DWord
                
    var data: ByteBuffer = ByteBuffer()
    
    let code: Code?
    
    let transactionId: DWord?
    
    init?(length: DWord, name: Packet.Name, data: ByteBuffer) {
        
        self.name = name
        self.length = length
        
        guard let responseWord = data[word: 0] else {
            code = nil
            transactionId = nil
            return
        }
        guard let code = Code(rawValue: responseWord) else {
            self.code = nil
            transactionId = data[dWord: 2]
            return
        }
        
        self.code = code
        
        transactionId = data[dWord: 2]
    }
}

extension CommandResponsePacket.Code {
    
    var isError: Bool {
        return self != .okay
    }
}
