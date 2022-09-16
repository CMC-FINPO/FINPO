//
//  CacheManager.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/14.
//

import Foundation
import UIKit

final class CacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}
