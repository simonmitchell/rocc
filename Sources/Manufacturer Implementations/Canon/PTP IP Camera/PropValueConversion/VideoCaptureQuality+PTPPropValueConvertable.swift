//
//  VideoCaptureQuality_SonyPTPPropValueConvertable.swift
//  Rocc
//
//  Created by Simon Mitchell on 11/03/2020.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation

extension VideoCapture.Quality.Value: PTPPropValueConvertable {
    
    static func devicePropertyCode(for manufacturer: Manufacturer) -> PTP.DeviceProperty.Code {
        switch manufacturer {
        case .sony:
            return .movieQuality
        case .canon:
            //TODO: [Canon] Implement
            return .movieQuality
        }
    }
    
    init?(value: PTPDevicePropertyDataType, manufacturer: Manufacturer) {
        switch manufacturer {
        case .sony:
            guard let binaryInt = value.toInt else {
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
                self = ._30p_16m_alt
            case 0x001b:
                self = ._25p_16m_alt
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
            case 0x0026:
                self = ._600m_4_2_2_10bit
            case 0x0027:
                self = ._500m_4_2_2_10bit
            case 0x0028:
                self = ._400m_4_2_0_10bit
            case 0x0029:
                self = ._300m_4_2_2_10bit
            case 0x002a:
                self = ._280m_4_2_2_10bit
            case 0x002b:
                self = ._250m_4_2_2_10bit
            case 0x002c:
                self = ._240m_4_2_2_10bit
            case 0x002d:
                self = ._222m_4_2_2_10bit
            case 0x002e:
                self = ._200m_4_2_2_10bit
            case 0x002f:
                self = ._200m_4_2_0_10bit
            case 0x0030:
                self = ._200m_4_2_0_8bit
            case 0x0031:
                self = ._185m_4_2_2_10bit
            case 0x0032:
                self = ._150m_4_2_0_10bit
            case 0x0033:
                self = ._150m_4_2_0_8bit
            case 0x0034:
                self = ._140m_4_2_2_10bit
            case 0x0035:
                self = ._111m_4_2_2_10bit
            case 0x0036:
                self = ._100m_4_2_2_10bit
            case 0x0037:
                self = ._100m_4_2_0_10bit
            case 0x0038:
                self = ._100m_4_2_0_8bit
            case 0x0039:
                self = ._93m_4_2_2_10bit
            case 0x003a:
                self = ._89m_4_2_2_10bit
            case 0x003b:
                self = ._75m_4_2_0_10bit
            case 0x003c:
                self = ._60m_4_2_0_8bit
            case 0x003d:
                self = ._50m_4_2_2_10bit
            case 0x003e:
                self = ._50m_4_2_0_10bit
            case 0x003f:
                self = ._50m_4_2_0_8bit
            case 0x0040:
                self = ._45m_4_2_0_10bit
            case 0x0041:
                self = ._30m_4_2_0_10bit
            case 0x0042:
                self = ._25m_4_2_0_8bit
            case 0x0043:
                self = ._16m_4_2_0_8bit
            default:
                return nil
            }
        case .canon:
            //TODO: [Canon] Implement
            return nil
        }
    }
    
    func value(for manufacturer: Manufacturer) -> PTPDevicePropertyDataType {
        switch manufacturer {
        case .sony:
            switch self {
                // None is returning the correct value, all others don't seem to be supported by PTP/IP
            case .none, .ps, .hq, .std, .vga, .slow, .sslow, .hs100, .hs120, .hs200, .hs240, ._240p_100m, ._200p_100m, ._240p_60m, ._200p_60m:
                return Word(0x0000)
            case ._120p_50m:
                return Word(0x0010)
            case ._100p_50m:
                return Word(0x0011)
            case ._60p_50m:
                return Word(0x0001)
            case ._50p_50m:
                return Word(0x0004)
            case ._30p_50m:
                return Word(0x0002)
            case ._25p_50m:
                return Word(0x0005)
            case ._24p_50m:
                return Word(0x0003)
            case ._30p_16m_alt:
                return Word(0x001a)
            case ._25p_16m_alt:
                return Word(0x001b)
            case ._120p_100m:
                return Word(0x001c)
            case ._100p_100m:
                return Word(0x001d)
            case ._120p_60m:
                return Word(0x001e)
            case ._100p_60m:
                return Word(0x001f)
            case ._30p_100m:
                return Word(0x0020)
            case ._25p_100m:
                return Word(0x0021)
            case ._24p_100m:
                return Word(0x0022)
            case ._30p_60m:
                return Word(0x0023)
            case ._25p_60m:
                return Word(0x0024)
            case ._24p_60m:
                return Word(0x0025)
            case ._60p_28m:
                return Word(0x0016)
            case ._50p_28m:
                return Word(0x0017)
            case ._60p_25m:
                return Word(0x0018)
            case ._50p_25m:
                return Word(0x0019)
            case ._30p_16m:
                return Word(0x0012)
            case ._25p_16m:
                return Word(0x0013)
            case ._30p_6m:
                return Word(0x0014)
            case ._25p_6m:
                return Word(0x0015)
            case ._60i_24m_fx:
                return Word(0x0006)
            case ._50i_24m_fx:
                return Word(0x0007)
            case ._60i_17m_fh:
                return Word(0x0008)
            case ._50i_17m_fh:
                return Word(0x0009)
            case ._60p_28m_ps:
                return Word(0x000a)
            case ._50p_28m_ps:
                return Word(0x000b)
            case ._24p_24m_fx:
                return Word(0x000c)
            case ._25p_24m_fx:
                return Word(0x000d)
            case ._24p_17m_fh:
                return Word(0x000e)
            case ._25p_17m_fh:
                return Word(0x000f)
            case ._600m_4_2_2_10bit:
                return Word(0x0026)
            case ._500m_4_2_2_10bit:
                return Word(0x0027)
            case ._400m_4_2_0_10bit:
                return Word(0x0028)
            case ._300m_4_2_2_10bit:
                return Word(0x0029)
            case ._280m_4_2_2_10bit:
                return Word(0x002a)
            case ._250m_4_2_2_10bit:
                return Word(0x002b)
            case ._240m_4_2_2_10bit:
                return Word(0x002c)
            case ._222m_4_2_2_10bit:
                return Word(0x002d)
            case ._200m_4_2_2_10bit:
                return Word(0x002e)
            case ._200m_4_2_0_10bit:
                return Word(0x002f)
            case ._200m_4_2_0_8bit:
                return Word(0x0030)
            case ._185m_4_2_2_10bit:
                return Word(0x0031)
            case ._150m_4_2_0_10bit:
                return Word(0x0032)
            case ._150m_4_2_0_8bit:
                return Word(0x0033)
            case ._140m_4_2_2_10bit:
                return Word(0x0034)
            case ._111m_4_2_2_10bit:
                return Word(0x0035)
            case ._100m_4_2_2_10bit:
                return Word(0x0036)
            case ._100m_4_2_0_10bit:
                return Word(0x0037)
            case ._100m_4_2_0_8bit:
                return Word(0x0038)
            case ._93m_4_2_2_10bit:
                return Word(0x0039)
            case ._89m_4_2_2_10bit:
                return Word(0x003a)
            case ._75m_4_2_0_10bit:
                return Word(0x003b)
            case ._60m_4_2_0_8bit:
                return Word(0x003c)
            case ._50m_4_2_2_10bit:
                return Word(0x003d)
            case ._50m_4_2_0_10bit:
                return Word(0x003e)
            case ._50m_4_2_0_8bit:
                return Word(0x003f)
            case ._45m_4_2_0_10bit:
                return Word(0x0040)
            case ._30m_4_2_0_10bit:
                return Word(0x0041)
            case ._25m_4_2_0_8bit:
                return Word(0x0042)
            case ._16m_4_2_0_8bit:
                return Word(0x0043)
            }
        case .canon:
            //TODO: [Canon] Implement
            return Word(0)
        }
    }
}
