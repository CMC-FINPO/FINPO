//
//  UserDataModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/06.
//

import Foundation

struct UserDataModel: Codable {
    var data: [UserDataDetail]
}

struct UserDataDetail: Codable {
    //id: 0, 100, 200 - 서울전체, 경기전체, 부산전체
    var id: Int
    var region: RegionDetail //id, name, status, parent(RegionParentDetail?)
    var isDefault: Bool
    var subscribe: Bool?
}

//미리보기
/*
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

 */
