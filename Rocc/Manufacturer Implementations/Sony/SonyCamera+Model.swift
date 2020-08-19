//
//  SonyCamera+Model.swift
//  Rocc
//
//  Created by Simon Mitchell on 29/10/2018.
//  Copyright © 2018 Simon Mitchell. All rights reserved.
//

import Foundation

extension SonyCamera {
    
    enum Model: String, CaseIterable {
        case a7 = "ILCE-7"
        case a7ii = "ILCE-7M2"
        case a7iii = "ILCE-7M3"
        case a7r = "ILCE-7R"
        case a7rii = "ILCE-7RM2"
        case a7riii = "ILCE-7RM3"
        case a7riv = "ILCE-7RM4"
        case a7s = "ILCE-7S"
        case a7sii = "ILCE-7SM2"
        case a7siii = "ILCE-7SM3"
        case a9 = "ILCE-9"
        case a9ii = "ILCE-9M2"
        case a5000 = "ILCE-5000"
        case a5100 = "ILCE-5100"
        case a6000 = "ILCE-6000"
        case a6100 = "ILCE-6100"
        case a6300 = "ILCE-6300"
        case a6400 = "ILCE-6400"
        case a6500 = "ILCE-6500"
        case a6600 = "ILCE-6600"
        case cyberShot_HX50 = "DSC-HX50"
        case cyberShot_HX50V = "DSC-HX50V"
        case cyberShot_HX60 = "DSC-HX60"
        case cyberShot_HX60V = "DSC-HX60V"
        case cyberShot_HX80 = "DSC-HX80"
        case cyberShot_HX90 = "DSC-HX90"
        case cyberShot_HX90V = "DSC-HX90V"
        case cyberShot_HX400 = "DSC-HX400"
        case cyberShot_HX400V = "DSC-HX400V"
        case cyberShot_WX500 = "DSC-WX500"
        case cyberShot_RX0 = "DSC-RX0"
        case cyberShot_RX0M2 = "DSC-RX0M2"
        case cyberShot_RX10M2 = "DSC-RX1RM2"
        case cyberShot_RX10M3 = "DSC-RX10M3"
        case cyberShot_RX100M2 = "DSC-RX100M2"
        case cyberShot_RX100M3 = "DSC-RX100M3"
        case cyberShot_RX100M4 = "DSC-RX100M4"
        case cyberShot_RX100M5 = "DSC-RX100M5"
        case cyberShot_RX100M6 = "DSC-RX100M6"
        case cyberShot_RX100M7 = "DSC-RX100M7"
        case FDR_X1000V = "FDR-X1000V"
        case FDR_X3000 = "FDR-X3000"
        case HDR_AS100V = "HDR-AS100V"
        case HDR_AS15 = "HDR-AS15"
        case HDR_AS20 = "HDR-AS20"
        case HDR_AS200V = "HDR-AS200V"
        case HDR_AS30V = "HDR-AS30V"
        case HDR_AS300 = "HDR-AS300"
        case HDR_AS50 = "HDR-AS50"
        case HDR_AZ1 = "HDR-AZ1"
        case HDR_MV1 = "HDR-MV1"
        case NEX_5R = "NEX-5R"
        case NEX_5T = "NEX-5T"
        case NEX_6 = "NEX-6"
        case QX1 = "ILCE-QX1"
        case QX10 = "DSC-QX10"
        case QX100 = "DSC-QX100"
        case QX30 = "DSC-QX30"
        
        var friendlyName: String {
            switch self {
            case .a7: return "ɑ7"
            case .a7ii: return "ɑ7 II"
            case .a7iii: return "ɑ7 III"
            case .a7r: return "ɑ7R"
            case .a7rii: return "ɑ7R II"
            case .a7riii: return "ɑ7R III"
            case .a7riv: return "ɑ7R IV"
            case .a7s: return "ɑ7S"
            case .a7sii: return "ɑ7S II"
            case .a7siii: return "ɑ7S III"
            case .a9: return "ɑ9"
            case .a9ii: return "ɑ9 II"
            case .a5000: return "ɑ5000"
            case .a5100: return "ɑ5100"
            case .a6000: return "ɑ6000"
            case .a6100: return "ɑ6100"
            case .a6300: return "ɑ6300"
            case .a6400: return "ɑ6400"
            case .a6500: return "ɑ6500"
            case .a6600: return "ɑ6600"
            case .cyberShot_HX50: return "Cyber-Shot HX50"
            case .cyberShot_HX50V: return "Cyber-Shot HX50V"
            case .cyberShot_HX60: return "Cyber-Shot HX60"
            case .cyberShot_HX60V: return "Cyber-Shot HX60V"
            case .cyberShot_HX80: return "Cyber-Shot HX80"
            case .cyberShot_HX90: return "Cyber-Shot HX90"
            case .cyberShot_HX90V: return "Cyber-Shot HX90V"
            case .cyberShot_HX400: return "Cyber-Shot HX400"
            case .cyberShot_HX400V: return "Cyber-Shot HX400V"
            case .cyberShot_WX500: return "Cyber-Shot WX500"
            case .cyberShot_RX10M2: return "Cyber-Shot RX1 R II"
            case .cyberShot_RX10M3: return "Cyber-Shot RX10 III"
            case .cyberShot_RX100M2: return "Cyber-Shot RX100 II"
            case .cyberShot_RX100M3: return "Cyber-Shot RX100 III"
            case .cyberShot_RX100M4: return "Cyber-Shot RX100 IV"
            case .cyberShot_RX100M5: return "Cyber-Shot RX100 V"
            case .cyberShot_RX100M6: return "Cyber-Shot RX100 VI"
            case .cyberShot_RX100M7: return "Cyber-Shot RX100 VII"
            case .cyberShot_RX0: return "RX0"
            case .cyberShot_RX0M2: return "RX0 II"
            case .FDR_X1000V: return "FDR-X1000V"
            case .FDR_X3000: return "FDR-X3000"
            case .HDR_AS100V: return "HDR-AS100V"
            case .HDR_AS15: return "HDR-AS15"
            case .HDR_AS20: return "HDR-AS20"
            case .HDR_AS200V: return "HDR-AS200V"
            case .HDR_AS30V: return "HDR-AS30V"
            case .HDR_AS300: return "HDR-AS300"
            case .HDR_AS50: return "HDR-AS50"
            case .HDR_AZ1: return "HDR-AZ1"
            case .HDR_MV1: return "HDR-MV1"
            case .NEX_5R: return "NEX-5R"
            case .NEX_5T: return "NEX-5T"
            case .NEX_6: return "NEX-6"
            case .QX1: return "QX1"
            case .QX10: return "QX10"
            case .QX100: return "QX100"
            case .QX30: return "QX30"
            }
        }
        
        internal var usesLegacyAPI: Bool {
            return [.cyberShot_RX100M2, .cyberShot_HX50, .cyberShot_HX50V].contains(self)
        }
        
        internal static func supporting(function: _CameraFunction) -> [Model] {
            switch function {
                // No API based cameras support any of these
            case .startContinuousBracketShooting, .stopContinuousBracketShooting,
                 .setContinuousBracketedShootingBracket, .getContinuousBracketedShootingBracket,
                 .takeSingleBracketShot,
                 .setSingleBracketedShootingBracket, .getSingleBracketedShootingBracket:
                return []
                // This isn't documented, so let's err on the side of caution!
            case .startBulbCapture, .endBulbCapture:
                return []
            case .startRecordMode:
                return allExcept([.a9, .a7iii, .a7riii, .a7siii])
            case .ping:
                return allCases
            case .takePicture:
                return allExcept([.HDR_AS15])
            case .startVideoRecording, .endVideoRecording:
                return allExcept([.a7, .a7r, .a5000, .a6000, .NEX_5R, .NEX_6, .NEX_5T])
            case .startAudioRecording, .endAudioRecording:
                return [.HDR_MV1]
            case .startIntervalStillRecording, .endIntervalStillRecording:
                return [.HDR_AS20, .HDR_AS30V, .HDR_AS100V, .HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000]
            case .startLoopRecording, .endLoopRecording:
                return [.HDR_AS50, .HDR_AS300, .FDR_X3000, .HDR_AS200V, .FDR_X1000V]
            case .startLiveView, .endLiveView, .getEvent, .setShootMode, .getShootMode:
                return allCases
            case .startLiveViewWithQuality, .getLiveViewQuality, .setLiveViewQuality:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: cyberShotSeries)
                return _supportingModels
            case .setSendLiveViewFrameInfo, .getSendLiveViewFrameInfo, .setProgramShift, .getProgramShift:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: [.QX1, .QX30])
                return _supportingModels
            case .startZooming, .stopZooming:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: [.QX1, .QX30, .HDR_AS50, .HDR_AS300, .FDR_X3000, .QX10, .QX100])
                return _supportingModels
            case .setZoomSetting, .getZoomSetting:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: [.QX1, .QX30, .HDR_AS50, .HDR_AS300, .FDR_X3000])
                return _supportingModels
            case .halfPressShutter, .cancelHalfPressShutter, .setTouchAFPosition, .getTouchAFPosition, .cancelTouchAFPosition, .getISO, .setISO, .setWhiteBalance, .getWhiteBalance/*, .cameraSetup*/:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: QXSeries)
                return _supportingModels
            case .setTrackingFocus, .getTrackingFocus, .getStillQuality, .setStillQuality, .setStillFormat, .getStillFormat:
                return [.QX1, .QX30]
            case .setContinuousShootingMode, .getContinuousShootingMode, .startContinuousShooting, .endContinuousShooting:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: QXSeries)
                // Not these cameras
                _supportingModels = _supportingModels.filter({ ![.a7, .a7r, .a7s, .a5000, .a5100, .a6000, .cyberShot_HX60, .cyberShot_HX60V, .cyberShot_HX400, .cyberShot_HX400V, .cyberShot_RX100M3, .QX10, .QX100].contains($0) })
                return _supportingModels
            case .setContinuousShootingSpeed, .getContinuousShootingSpeed:
                var _supportingModels: [Model] = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels = _supportingModels.filter({ ![.a7, .a7r, .a7s, .a7iii, .a9ii, .a9, .a5000, .a5100, .a6000, .a6400, .a6600, .cyberShot_HX60, .cyberShot_HX60V, .cyberShot_HX400, .cyberShot_HX400V, .cyberShot_RX100M3].contains($0) })
                let additionalModels: [Model] = [.HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000, .QX30]
                _supportingModels.append(contentsOf: additionalModels)
                return _supportingModels
            case .setSelfTimerDuration, .getSelfTimerDuration:
                var _supportingModels: [Model] = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: QXSeries)
                let additionalModels: [Model] = [.HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000]
                _supportingModels.append(contentsOf: additionalModels)
                return _supportingModels
            case .setExposureMode, .getExposureMode:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: QXSeries)
                return _supportingModels
            case .setFocusMode, .getFocusMode:
                var _supportingModels: [Model] = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: [.QX1, .QX100])
                return _supportingModels
            case .setExposureCompensation, .getExposureCompensation:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: QXSeries)
                _supportingModels.append(contentsOf: [.HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000])
                return _supportingModels
            case .setAperture, .getAperture, .setShutterSpeed, .getShutterSpeed:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: [.QX100, .QX1, .QX30])
                return _supportingModels
            case .setupCustomWhiteBalanceFromShot:
                return [.HDR_AS50, .HDR_AS200V, .HDR_AS300, .FDR_X1000V, .FDR_X3000]
            case .setStillSize, .getStillSize:
                var _supportingModels = QXSeries
                _supportingModels.append(contentsOf: [.HDR_AS50, .HDR_AS300, .FDR_X3000])
                return _supportingModels
            case .setPostviewImageSize, .getPostviewImageSize:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: QXSeries)
                _supportingModels.append(contentsOf: [.HDR_AZ1, .HDR_AS200V, .FDR_X1000V])
                return _supportingModels
            case .setVideoFileFormat, .getVideoFileFormat:
                var _supportingModels = fdrSeries
                _supportingModels.append(contentsOf: [.HDR_AZ1, .HDR_AS200V, .HDR_AS50, .HDR_AS300])
                return _supportingModels
            case .setVideoQuality, .getVideoQuality:
                return [.HDR_AS20, .HDR_AS30V, .HDR_AS100V, .HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000, .QX30]
            case .setSteadyMode, .getSteadyMode:
                return [.HDR_AS20, .HDR_AS30V, .HDR_AS100V, .HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000]
            case .setViewAngle, .getViewAngle:
                return [.HDR_AS30V, .HDR_AS200V, .FDR_X1000V]
            case .setScene, .getScene, .setColorSetting, .getColorSetting, .setIntervalTime, .getIntervalTime, .setFlipSetting, .getFlipSetting, .setTVColorSystem, .getTVColorSystem:
                return [.HDR_AZ1, .HDR_AS30V, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000]
            case .setLoopRecordDuration, .getLoopRecordDuration, .getWindNoiseReduction, .setWindNoiseReduction, .setAudioRecording, .getAudioRecording:
                return [.HDR_AS30V, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000]
            case .getCameraFunction, .setCameraFunction:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: [.QX30, .QX1, .HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .FDR_X3000, .HDR_AS300, .HDR_AS50])
                // Not these models!
                _supportingModels = _supportingModels.filter({ ![.a7, .a7r, .a7iii, .a7riii, .a7siii, .a9, .a5000, .a5100, .a6000, .cyberShot_HX60, .cyberShot_HX60V, .cyberShot_HX400].contains($0) })
                return _supportingModels
            case .listContent, .listSchemes, .listSources, .deleteContent, .getStorageInformation, .getContentCount:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: [.QX30, .QX1, .HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .FDR_X3000, .HDR_AS300, .HDR_AS50])
                // Not these models!
                _supportingModels = _supportingModels.filter({ ![.a7, .a7r, .a5000, .a5100, .a6000, .cyberShot_HX60, .cyberShot_HX60V, .cyberShot_HX400].contains($0) })
                return _supportingModels
            case .startStreaming, .stopStreaming, .pauseStreaming, .setStreamingContent, .getStreamingStatus:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: [.QX30, .QX1, .HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .FDR_X3000, .HDR_AS300, .HDR_AS50])
                // Not these models!
                _supportingModels = _supportingModels.filter({ ![.a7, .a7ii, .a7r, .a5000, .a5100, .a6000, .cyberShot_HX60, .cyberShot_HX60V, .cyberShot_HX400].contains($0) })
                return _supportingModels
            case .seekStreamingPosition:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: [.HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .FDR_X3000, .HDR_AS300, .HDR_AS50])
                // Not these models!
                _supportingModels = _supportingModels.filter({ ![.a7, .a7ii, .a7r, .a5000, .a5100, .a6000, .cyberShot_HX60, .cyberShot_HX60V, .cyberShot_HX400].contains($0) })
                return _supportingModels
            case .getInfraredRemoteControl, .setInfraredRemoteControl:
                return [.HDR_AZ1, .HDR_AS200V, .FDR_X1000V]
            case .getAutoPowerOff, .setAutoPowerOff:
                return [.HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000]
            case .setBeepMode, .getBeepMode:
                var _supportingModels = QXSeries
                _supportingModels.append(contentsOf: [.HDR_AZ1, .HDR_AS200V, .FDR_X1000V, .HDR_AS50, .HDR_AS300, .FDR_X3000])
                return _supportingModels
            case .setCurrentTime:
                var _supportingModels = QXSeries
                _supportingModels.append(.HDR_AZ1)
                return _supportingModels
            case .startTrackingFocus, .stopTrackingFocus:
                return [.QX1, .QX30]
            case .setFlashMode, .getFlashMode:
                var _supportingModels = alphaSeries
                _supportingModels.append(contentsOf: cyberShotSeries)
                _supportingModels.append(contentsOf: NEXSeries)
                _supportingModels.append(.QX1)
                return _supportingModels
            case .setExposureModeDialControl, .getExposureModeDialControl, .recordHighFrameRateCapture, .setExposureSettingsLock, .getExposureSettingsLock:
                // No cameras seem to support this, as it's a PTP IP thing
                return []
            }
        }
        
        private static func allExcept(_ models: [Model]) -> [Model] {
            return allCases.filter({ !models.contains($0) })
        }
        
        static var NEXSeries: [Model] {
            return [.NEX_5R, .NEX_5T, .NEX_6]
        }
        
        static var QXSeries: [Model] {
            return [.QX1, .QX10, .QX100, .QX30]
        }
        
        static var cyberShotSeries: [Model] {
            return [.cyberShot_HX50, .cyberShot_HX50V, .cyberShot_HX60, .cyberShot_HX60V, .cyberShot_HX80, .cyberShot_HX90, .cyberShot_HX90V, .cyberShot_HX400, .cyberShot_HX400V, .cyberShot_WX500, .cyberShot_RX10M2, .cyberShot_RX10M3, .cyberShot_RX100M2, .cyberShot_RX100M3, .cyberShot_RX100M4, .cyberShot_RX100M5, .cyberShot_RX100M6, .cyberShot_RX100M7, .cyberShot_RX0, .cyberShot_RX0M2]
        }
        
        static var fdrSeries: [Model] {
            return [.FDR_X1000V, .FDR_X3000]
        }
        
        static var HDRSeries: [Model] {
            return [.HDR_AS100V, .HDR_AS15, .HDR_AS20, .HDR_AS200V, .HDR_AS30V, .HDR_AS300, .HDR_AS50, .HDR_AZ1, .HDR_MV1]
        }
        
        static var alphaSeries: [Model] {
            return [.a7, .a7ii, .a7iii, .a7r, .a7rii, .a7riii, .a7s, .a7sii, .a7siii, .a5000, .a5100, .a6000, .a6100, .a6300, .a6400, .a6500, .a6600]
        }
        
        var latestFirmwareVersion: String? {
            switch self {
            case .a7ii, .a7rii:
                return "4.0"
            case .a6000:
                return "3.21"
            case .a7s, .a7r, .a7:
                return "3.20"
            case .a5100:
                return "3.10"
            case .a7sii:
                return "3.00"
            case .a7iii, .a7riii:
                return "3.10"
            case .a6600, .a6400, .a9ii:
                return "2.0"
            case .a6300:
                return "2.01"
            case .a5000:
                return "1.10"
            case .a6500:
                return "1.05"
            case .NEX_6, .NEX_5R:
                return "1.03"
            case .NEX_5T:
                return "1.01"
            case .a9:
                return "6.0"
            default:
                return nil
            }
        }
        
        var latestRemoteAppVersion: String? {
            switch self {
            case .a6500:
                return "4.31"
            default:
                return "4.30"
            }
        }
        
        var requiresHalfPressToCapture: Bool {
            let modelsWhichRequireHalfPressToCapture: [Model] = [
                .a7iii,
                .a7riii,
                .a9,
                .cyberShot_RX0,
                .cyberShot_RX0M2,
                .cyberShot_RX100M5,
                .cyberShot_RX100M6,
                .cyberShot_RX100M7
            ]
            return modelsWhichRequireHalfPressToCapture.contains(self)
        }
    }
}
