//
//  SearchModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/22.
//

import Foundation
import Alamofire

struct SearchPolicyResponse: Codable {
    var data: Contents?
}

struct Contents: Codable {
    var content: [ContentsDetail]
}

struct ContentsDetail: Codable {
    var id: Int
    var title: String?
    var content: String?
    var institution: String?
    var supportScale: String?
    var support: String?
    var period: String?
    var openApiType: String?
    var modifiedAt: String?
    var category: CategoryDetail?
    var region: RegionDetail?
}

struct CategoryDetail: Codable {
    var id: Int
    var name: String
    var parent: ParentDetail
}

struct ParentDetail: Codable {
    var id: Int
    var name: String
}

struct RegionDetail: Codable {
    var id: Int
    var name: String
    var parent: RegionParentDetail
}

struct RegionParentDetail: Codable {
    var id: Int
    var name: String
}
