//
//  UserResponseModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/13.
//

import Foundation

struct UserResponseModel: Codable {
    var data: UserDataDetails
}

struct UserDataDetails: Codable {
    var id: Int
    var status: Bool
    var name: String
    var nickname: String
    var birth: String
    var gender: String
    var statusId: Int?
    var profileImg: String?
    var oAuthType: String
    var defaultRegion: DefaultRegionDetail
}

struct DefaultRegionDetail: Codable {
    var id: Int
    var name: String
    var status: Bool
}

