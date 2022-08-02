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
    var adSubscribe: Bool?
    var interestCategories: [MyAlarmInterestCategory]
    var interestRegions: [MyAlarmInterestRegion]
}

struct MyAlarmInterestCategory: Codable {
    var id: Int
    var category: MyAlarmCategoryDetail
    var subscribe: Bool //관심 카테고리별 알림 구독 설정 여부
}

struct MyAlarmInterestRegion: Codable {
    var id: Int?
    var region: MyAlarmRegionDetail
    var isDefault: Bool
    var subscribe: Bool //관심 지역별 알림 구독 설정 여부
}

struct MyAlarmRegionDetail: Codable {
    var id: Int?
    var name: String?
    var status: Bool?
    var parent: MyAlarmRegionParentDetail
}

struct MyAlarmCategoryDetail: Codable {
    var id: Int?
    var name: String?
    var parent: MyAlarmCategoryParentDetail
}

struct MyAlarmCategoryParentDetail: Codable {
    var id: Int?
    var name: String?
    var img: String?
}

struct MyAlarmRegionParentDetail: Codable {
    var id: Int?
    var name: String?
    var status: Bool?
}

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
