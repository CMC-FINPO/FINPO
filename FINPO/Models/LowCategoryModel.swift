//
//  LowCategoryModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/13.
//

import Foundation

struct LowCategoryModel: Codable {
    var data: [LowCategoryDataDetail]
}

struct LowCategoryDataDetail: Codable {
    var id: Int
    var name: String
    var parent: LowCategoryParentDetail
}

struct LowCategoryParentDetail: Codable {
    var id: Int
    var name: String
}
