//
//  MyInterestCategoryModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/13.
//

import Foundation

struct MyInterestCategoryModel: Codable {
    var data: [InterestCategoryDataDetail]
}

struct InterestCategoryDataDetail: Codable {
    var id: Int
    var category: InterestCategoriesDetail
    var subscribe: Bool
}

struct InterestCategoriesDetail: Codable {
    var id: Int
    var name: String
    var parent: ParentDetail
}
