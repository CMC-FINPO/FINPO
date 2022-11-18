//
//  MyPolicyTestModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/16.
//

import Foundation

struct MyPolicyTestModel: Codable {
    var data: MyPolicyDataDetail
}

struct MyPolicyDataDetail: Codable {
    var content: [MyPolicyContentDetail]
    var last: Bool
    var first: Bool
    var totalElements: Int
    var totalPages: Int
    var number: Int
    var size: Int
    var numberOfElements: Int
    var empty: Bool
    var pageable: MyPolicyPageableDetail
}

struct MyPolicyContentDetail: Codable {
    var id: Int
    var status: Bool
    var title: String
    var institution: String?
    var createdAt: String?
    var region: RegionDetail
    var countOfInterest: Int
    var isInterest: Bool
}

struct MyPolicyPageableDetail: Codable {
    var sort: MyPolicySortDetail
    var offset: Int?
    var pageNumber: Int?
    var pageSize: Int?
    var paged: Bool?
    var unpaged: Bool?
}

struct MyPolicySortDetail: Codable {
    var empty: Bool?
    var sorted: Bool?
    var unsorted: Bool?
    
}
