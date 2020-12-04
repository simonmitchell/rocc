//
//  CanonPTPEvent.swift
//  Rocc
//
//  Created by Simon Mitchell on 26/11/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

/// A base protocol for types allowed in the array of `CanonPTPEvents`
///
/// Currently this is almost equivalent to `Any` but could change in future
protocol CanonPTPEvent {
    
    /// Initialises the change type with a byte buffer
    /// - Parameter data: The raw byte buffer for the change, excluding length and type info
    init?(_ data: ByteBuffer)
}

/// Canon cameras have special PTP Events/Changes which contain an array
/// of "Changes", with types such as `AvailableListChange` `PropValueChanged`
struct CanonPTPEvents {
    
    /// An array of changes that were sent through from the device
    let events: [CanonPTPEvent]
    
    enum EventType: DWord {
        case requestGetEvent = 0xc101
        case requestCancelTransferMA = 0xc180
        case objectAddedEx = 0xc181
        case objectRemoved = 0xc182
        case requestGetObjectInfoEx = 0xc183
        case storageStatusChanged = 0xc184
        case storageInfoChanged = 0xc185
        case requestObjectTransfer = 0xc186
        case objectInfoChangedEx = 0xc187
        case objectContentChanged = 0xc188
        case propValueChanged = 0xc189
        case availableListChanged = 0xc18a
        case cameraStatusChanged = 0xc18b
        case willSoonShutdown = 0xc18d
        case shutdownTimerUpdated = 0xc18e
        case requestCancelTransfer = 0xc18f
        case requestObjectTransferDT = 0xc190
        case requestCancelTransferDT = 0xc191
        case storeAdded = 0xc192
        case storeRemoved = 0xc193
        case bulbExposureTime = 0xc194
        case recordingTime = 0xc195
        case innerDevelopParam = 0xc196
        case requestObjectTransferDevelop = 0xc197
        case GPSLogOutputProgress = 0xc198
        case GPSLogOutputComplete = 0xc199
        case touchTrans = 0xc19a
        case requestObjectTransferExInfo = 0xc19b
        case powerZoomInfoChanged = 0xc19d
        case requestPushMode = 0xc19f
        case requestObjectTransferTS = 0xc1a2
        case autoFocusResult = 0xc1a3
        case CTGInfoCheckComplete = 0xc1a4
        case OLCInfoChanged = 0xc1a5
        case objectAddedEx64 = 0xc1a7
        case objectInfoChangedEx64 = 0xc1a8
        case requestObjectTransfer64 = 0xc1a9
        case requestObjectTransferDT64 = 0xc1aa
        case requestObjectTransferFTP64 = 0xc1ab
        case requestObjectTransferInfoEx64 = 0xc1ac
        case requestObjectTransferMA64 = 0xc1ad
        case importError = 0xc1af
        case blePairing = 0xc1b0
        case requestAutoSendImages = 0xc1b1
        case requestTranscodedBlockTransfer = 0xc1b2
        case requestCAssistImage = 0xc1b4
        case requestObjectTransferFTP = 0xc1f1
        
        var eventClass: CanonPTPEvent.Type? {
            switch self {
            case .propValueChanged:
                return CanonPTPPropValueChange.self
            case .requestGetEvent:
                return nil
            case .requestCancelTransferMA:
                return nil
            case .objectAddedEx:
                return nil
            case .objectRemoved:
                return nil
            case .requestGetObjectInfoEx:
                return nil
            case .storageStatusChanged:
                return nil
            case .storageInfoChanged:
                return nil
            case .requestObjectTransfer:
                return nil
            case .objectInfoChangedEx:
                return nil
            case .objectContentChanged:
                return nil
            case .availableListChanged:
                return CanonPTPAvailableValuesChange.self
            case .cameraStatusChanged:
                return nil
            case .willSoonShutdown:
                return nil
            case .shutdownTimerUpdated:
                return nil
            case .requestCancelTransfer:
                return nil
            case .requestObjectTransferDT:
                return nil
            case .requestCancelTransferDT:
                return nil
            case .storeAdded:
                return nil
            case .storeRemoved:
                return nil
            case .bulbExposureTime:
                return nil
            case .recordingTime:
                return nil
            case .innerDevelopParam:
                return nil
            case .requestObjectTransferDevelop:
                return nil
            case .GPSLogOutputProgress:
                return nil
            case .GPSLogOutputComplete:
                return nil
            case .touchTrans:
                return nil
            case .requestObjectTransferExInfo:
                return nil
            case .powerZoomInfoChanged:
                return nil
            case .requestPushMode:
                return nil
            case .requestObjectTransferTS:
                return nil
            case .autoFocusResult:
                return nil
            case .CTGInfoCheckComplete:
                return nil
            case .OLCInfoChanged:
                return nil
            case .objectAddedEx64:
                return nil
            case .objectInfoChangedEx64:
                return nil
            case .requestObjectTransfer64:
                return nil
            case .requestObjectTransferDT64:
                return nil
            case .requestObjectTransferFTP64:
                return nil
            case .requestObjectTransferInfoEx64:
                return nil
            case .requestObjectTransferMA64:
                return nil
            case .importError:
                return nil
            case .blePairing:
                return nil
            case .requestAutoSendImages:
                return nil
            case .requestTranscodedBlockTransfer:
                return nil
            case .requestCAssistImage:
                return nil
            case .requestObjectTransferFTP:
                return nil
            }
        }
    }
    
    /// Initialises a new Canon PTP Event from the provided data
    /// - Parameter data: The data received from the camera
    init(data: ByteBuffer) throws {
        
        var offset: UInt = 0
        
        var _events: [CanonPTPEvent] = []
        
        while offset < data.length {
            
            // If we can't get a size, we have invalid data... don't continue
            guard let size: DWord = data.read(offset: &offset) else {
                throw CanonPTPEventParsingError.invalidData
            }
                        
            // Make sure we have at least 8 bytes
            guard size > DWord(MemoryLayout<DWord>.size * 2) else { break }
            // Make sure we're not overlapping the whole data payload
            guard offset + UInt(size - DWord(MemoryLayout<DWord>.size)) < data.length else { break }
            
            let dataSize = size - DWord(MemoryLayout<DWord>.size * 2)
            
            // If we can't get a type, we have invalid data... don't continue
            guard let type: DWord = data.read(offset: &offset) else {
                throw CanonPTPEventParsingError.invalidData
            }
            
            // If we don't have an enum case, we can simply break as we want to continue anyways for other changes
            guard let typeEnum = EventType(rawValue: type) else {
                offset += UInt(dataSize)
                break
            }
            
            let eventData = data.sliced(Int(offset), Int(offset + UInt(dataSize)))
            offset += UInt(dataSize)

            guard let eventClass = typeEnum.eventClass else {
                break
            }
            guard let event = eventClass.init(eventData) else {
                break
            }
            
            _events.append(event)
        }
        
        events = _events
    }
    
    enum CanonPTPEventParsingError: LocalizedError {
        case invalidData
    }
}
