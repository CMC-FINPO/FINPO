//
//  MyAlarmIsOnModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/14.
//

import Foundation
import Alamofire

struct MyAlarmIsOnModel: Codable {
    var data: MyAlarmDataDetail
}

struct MyAlarmDataDetail: Codable {
    var subscribe: Bool //전체알림 구독 설정 여부
    var adSubscribe: Bool
    var interestCategories: [MyAlarmInterestCategory]
    var interestRegions: [MyAlarmInterestRegion]
}

struct MyAlarmInterestCategory: Codable {
    var id: Int?
    var category: CategoryDetail
    var subscribe: Bool //관심 카테고리별 알림 구독 설정 여부
}

struct MyAlarmInterestRegion: Codable {
    var id: Int?
    var region: RegionDetail
    var isDefault: Bool
    var subscribe: Bool //관심 지역별 알림 구독 설정 여부
}
