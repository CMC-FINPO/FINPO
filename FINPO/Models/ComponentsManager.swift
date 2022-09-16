//
//  ComponentsManager.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/28.
//

import Foundation
import UIKit

extension UIColor {
    static let B01 = UIColor(hexString: "000000")
    static let W01 = UIColor(hexString: "FFFFFF")
    static let G01 = UIColor(hexString: "494949")
    static let G02 = UIColor(hexString: "616161")
    static let G03 = UIColor(hexString: "999999")
    static let G04 = UIColor(hexString: "A2A2A2")
    static let G05 = UIColor(hexString: "C4C4C5")
    static let G06 = UIColor(hexString: "D9D9D9")
    static let G07 = UIColor(hexString: "EBEBEB")
    static let G08 = UIColor(hexString: "F0F0F0")
    static let G09 = UIColor(hexString: "F9F9F9")
    static let P01 = UIColor(hexString: "5B43EF")
    static let E12 = UIColor(hexString: "FF3C00")
    
}

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
