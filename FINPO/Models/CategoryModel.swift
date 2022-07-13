//
//  CategoryModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/30.
//

import Foundation

struct CategoryModel: Codable {
    var data: [CategoryDetails]
}

struct CategoryDetails: Codable {
    var id: Int
    var name: String
    var childs: [ChildDetail]
}

struct ChildDetail: Codable {
    var id: Int
    var name: String
}

//내 관심카테고리 모델
struct MyCategoryModel: Codable {
    var data: [myInterestCategory]
}

struct myInterestCategory: Codable {
    var id: Int
    var name: String
    var img: String
}
