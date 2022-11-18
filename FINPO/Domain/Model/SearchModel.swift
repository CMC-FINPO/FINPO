//
//  SearchModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/22.
//

import Foundation
import Alamofire
import SwiftUI

struct SearchPolicyResponse: Codable {
    var data: Contents?
}

struct Contents: Codable {
    var content: [ContentsDetail]
    var last: Bool?
    var first: Bool?
    var totalElements: Int?
    var totalPages: Int?
    var number: Int?
    var size: Int?
    var numberOfElements: Int?
    var empty: Bool?
}

struct ContentsDetail: Codable {
    var id: Int? //상세정보 검색용
    var title: String? //
    var status: Bool?
    var content: String?
    var institution: String? //
    var isInterest: Bool //
    var createdAt: String?
//    var supportScale: String?
//    var support: String?
//    var period: String?
//    var openApiType: String?
//    var modifiedAt: String?
    var category: CategoryDetail?
    var countOfInterest: Int? //
    var region: RegionDetail? //
}

struct CategoryDetail: Codable {
    var id: Int?
    var name: String
    var parent: ParentDetail
}

struct ParentDetail: Codable {
    var id: Int
    var name: String
    var img: String?
}

struct RegionDetail: Codable {
    var id: Int
    var name: String
    var status: Bool?
    var parent: RegionParentDetail?
}

struct RegionParentDetail: Codable {
    var id: Int
    var name: String
    var status: Bool?
}

///데이터 Response Model
struct SearchPolicyPopularResponse: Codable {
    var data: PopularContent?
}

struct PopularContent: Codable {
    var content: [PopularContentDetail]
}

struct PopularContentDetail: Codable {
    var id: Int
    var title: String
    var institution: String
    var isInterest: Bool
    var region: PopularRegionDetail?
}

struct PopularRegionDetail: Codable {
    var id: Int
    var name: String
}

/// 내 거주지역 조회 모델

struct MyRegionList: Codable {
    var data: [DataDetail]
}

struct DataDetail: Codable {
    var region: RegionDetail
    var isDefault: Bool
}
/*
 struct RegionDetail: Codable {
     var id: Int -> 이걸로 정책 지역 필터링 검색
     var name: String
     var status: Bool?
     var parent: RegionParentDetail?
 }
 
 
 */
