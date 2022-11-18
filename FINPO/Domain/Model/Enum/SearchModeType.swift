//
//  IsSearchModeOrDeleteModeActionType.swift
//  FINPO
//
//  Created by 이동희 on 2022/11/18.
//

import Foundation

///참여 정책 조회 및 삭제 액션
enum IsSearchModeOrDeleteModeAction {
    case searchMode(UserParticipatedModel)
    case deleteMode(UserParticipatedModel)
}
