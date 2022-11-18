//
//  RegionActionType.swift
//  FINPO
//
//  Created by 이동희 on 2022/11/18.
//

import Foundation

//추가지역 선택 시 사용될 행위
enum RegionActionType {
    case add(region: UniouRegion)
    case delete(index: Int)
    case first(userDetail: UserDataModel)
}
