//
//  TagLoadType.swift
//  FINPO
//
//  Created by 이동희 on 2022/11/18.
//

import Foundation

enum TagLoadAction {
    case isFirstLoad([DataDetail])
    case delete(at: Int)
    case add(DataDetail)
    case deleteAll
}
