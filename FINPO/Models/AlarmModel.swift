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
    var id: Int
    var type: String
    var policy: PolicyDetailInformation
    var region: [RegionDetail]?
}
