//
//  BoolResponseModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/22.
//

import Foundation

struct BookmarkResponseModel: Codable {
    var success: Bool
    var data: BookmarkDataDetail
}

struct BookmarkDataDetail: Codable {
    var id: Int
    var policy: BookmarkPolicyDetail?
}

struct BookmarkPolicyDetail: Codable {
    var id: Int
    var status: Bool
    var title: String
    var institution: String?
    var createdAt: String
    var region: RegionDetail
}
