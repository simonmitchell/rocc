//
//  VideoCaptureQuality_SonyPTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 11/03/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension VideoCapture.Quality.Value: SonyPTPPropValueConvertable {
    
    var type: PTP.DeviceProperty.DataType {
        return .uint16
    }
    
    var code: PTP.DeviceProperty.Code {
        return .movieQuality
    }
    
    init?(sonyValue: PTPDevicePropertyDataType) {
        
        guard let binaryInt = sonyValue.toInt else {
            return nil
        }
        
        switch binaryInt {
        case 0x0000:
            self = .none
        case 0x0001:
            self = ._60p_50m
        case 0x0002:
            self = ._30p_50m
        case 0x0003:
            self = ._24p_50m
        case 0x0004:
            self = ._50p_50m
        case 0x0005:
            self = ._25p_50m
        case 0x0006:
            self = ._60i_24m_fx
        case 0x0007:
            self = ._50i_24m_fx
        case 0x0008:
            self = ._60i_17m_fh
        case 0x0009:
            self = ._50i_17m_fh
        case 0x000a:
            self = ._60p_28m_ps
        case 0x000b:
            self = ._50p_28m_ps
        case 0x000c:
            self = ._24p_24m_fx
        case 0x000d:
            self = ._25p_24m_fx
        case 0x000e:
            self = ._24p_17m_fh
        case 0x000f:
            self = ._25p_17m_fh
        case 0x0010:
            self = ._120p_50m
        case 0x0011:
            self = ._100p_50m
        case 0x0012:
            self = ._30p_16m
        case 0x0013:
            self = ._25p_16m
        case 0x0014:
            self = ._30p_6m
        case 0x0015:
            self = ._25p_6m
        case 0x0016:
            self = ._60p_28m
        case 0x0017:
            self = ._50p_28m
        case 0x0018:
            self = ._60p_25m
        case 0x0019:
            self = ._50p_25m
        case 0x001a:
            self = ._30p_16m
        case 0x001b:
            self = ._25p_16m
        case 0x001c:
            self = ._120p_100m
        case 0x001d:
            self = ._100p_100m
        case 0x001e:
            self = ._120p_60m
        case 0x001f:
            self = ._100p_60m
        case 0x0020:
            self = ._30p_100m
        case 0x0021:
            self = ._25p_100m
        case 0x0022:
            self = ._24p_100m
        case 0x0023:
            self = ._30p_60m
        case 0x0024:
            self = ._25p_60m
        case 0x0025:
            self = ._24p_60m
        default:
            return nil
        }
    }
    
    var sonyPTPValue: PTPDevicePropertyDataType {
        switch self {
            // None is returning the correct value, all others don't seem to be supported by PTP/IP
        case .none, .ps, .hq, .std, .vga, .slow, .sslow, .hs100, .hs120, .hs200, .hs240, ._240p_100m, ._200p_100m, ._240p_60m, ._200p_60m:
            return DWord(0x0000)
        case ._120p_50m:
            return DWord(0x0010)
        case ._100p_50m:
            return DWord(0x0011)
        case ._60p_50m:
            return DWord(0x0001)
        case ._50p_50m:
            return DWord(0x0004)
        case ._30p_50m:
            return DWord(0x0002)
        case ._25p_50m:
            return DWord(0x0005)
        case ._24p_50m:
            return DWord(0x0003)
        case ._30p_16m_alt:
            return DWord(0x001a)
        case ._25p_16m_alt:
            return DWord(0x001b)
        case ._120p_100m:
            return DWord(0x001c)
        case ._100p_100m:
            return DWord(0x001d)
        case ._120p_60m:
            return DWord(0x001e)
        case ._100p_60m:
            return DWord(0x001f)
        case ._30p_100m:
            return DWord(0x0020)
        case ._25p_100m:
            return DWord(0x0021)
        case ._24p_100m:
            return DWord(0x0022)
        case ._30p_60m:
            return DWord(0x0023)
        case ._25p_60m:
            return DWord(0x0024)
        case ._24p_60m:
            return DWord(0x0025)
        case ._60p_28m:
            return DWord(0x0016)
        case ._50p_28m:
            return DWord(0x0017)
        case ._60p_25m:
            return DWord(0x0018)
        case ._50p_25m:
            return DWord(0x0019)
        case ._30p_16m:
            return DWord(0x001a)
        case ._25p_16m:
            return DWord(0x001b)
        case ._30p_6m:
            return DWord(0x0014)
        case ._25p_6m:
            return DWord(0x0015)
        case ._60i_24m_fx:
            return DWord(0x0006)
        case ._50i_24m_fx:
            return DWord(0x0007)
        case ._60i_17m_fh:
            return DWord(0x0008)
        case ._50i_17m_fh:
            return DWord(0x0009)
        case ._60p_28m_ps:
            return DWord(0x000a)
        case ._50p_28m_ps:
            return DWord(0x000b)
        case ._24p_24m_fx:
            return DWord(0x000c)
        case ._25p_24m_fx:
            return DWord(0x000d)
        case ._24p_17m_fh:
            return DWord(0x000e)
        case ._25p_17m_fh:
            return DWord(0x000f)
        }
    }
}
