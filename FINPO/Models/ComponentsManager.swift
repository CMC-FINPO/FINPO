//
//  ComponentsManager.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/28.
//

import Foundation

struct ComponentsManager {
    enum CustomColor {
        case B01
        case W01
        case G01
        case G02
        case G03
        case G04
        case G05
        case G06
        case G07
        case G08
        case G09
        case P01
        case E12
        
        var toString: String {
            switch self {
            case .B01: return "000000"
            case .W01: return "FFFFFF"
            case .G01: return "494949"
            case .G02: return "616161"
            case .G03: return "999999"
            case .G04: return "A2A2A2"
            case .G05: return "C4C4C5"
            case .G06: return "D9D9D9"
            case .G07: return "EBEBEB"
            case .G08: return "F0F0F0"
            case .G09: return "F9F9F9"
            case .P01: return "5B43EF"
            case .E12: return "FF3C00"
            }
        }
    }
}
