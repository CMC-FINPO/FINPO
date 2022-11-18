//
//  UserParticipatedModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/07.
//

import Foundation

struct UserParticipatedModel: Codable {
    var data: [ParticipationModel]
}

struct ParticipationModel: Codable {
    var id: Int
    var memo: String?
    var policy: UserPolicyDetail
}

struct UserPolicyDetail: Codable {
    var id: Int
    var title: String
    var institution: String?
    var isInterest: Bool
    var region: RegionDetail
}
