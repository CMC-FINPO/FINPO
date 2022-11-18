//
//  AlarmModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/11.
//

import Foundation

struct AlarmModel: Codable {
    var data: AlarmData
}

struct AlarmData: Codable {
    var content: [AlarmContentDetail]
}

struct AlarmContentDetail: Codable {
    var id: Int //Alarm Id
    var type: String //"COMMENT" or "POLICY"
    var policy: PolicyDetailInformation?
    var comment: CommentDetailInformation?
    var region: [RegionDetail]?
}

struct CommentDetailInformation: Codable {
    var status: Bool
    var id: Int
    var content: String
    var anonymity: Bool
    var isUserWithdraw: Bool?
    var isWriter: Bool
    var isModified: Bool
    var createdAt: String
    var modifiedAt: String?
    var post: PostDetail
}
