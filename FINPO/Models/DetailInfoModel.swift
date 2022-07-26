//
//  DetailInfoModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/02.
//

import Foundation

struct DetailInfoModel: Codable {
    var data: PolicyDetailInformation
}

struct PolicyDetailInformation: Codable {
    var id: Int
    var title: String?
    var content: String?
    var institution: String?
    var supportScale: String?
    var support: String?
    var period: String?
    var startDate: String?
    var endDate: String?
    var process: String?
    var announcement: String?
    var detailUrl: String?
    var openApiType: String?
    var modifiedAt: String?
    var category: CategoryDetail? // parent: ParentDetail
    var region: RegionDetail? // parent: RegionParentDetail
    var hits: Int
    var countOfInterest: Int?
    var isInterest: Bool?
}
