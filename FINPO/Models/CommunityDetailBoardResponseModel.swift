//
//  CommunityDetailBoardResponseModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/24.
//

import Foundation

struct CommunityDetailBoardResponseModel: Codable {
    var data: BoardDataDetail
}

struct BoardDataDetail: Codable {
    var status: Bool
    var id: Int
    var content: String
    var anonymity: Bool
    var likes: Int
    var hits: Int
    var countOfComment: Int
    var user: CommunityUserDetail?
    var isMine: Bool
    var isLiked: Bool
    var isBookmarked: Bool
    var isModified: Bool
    var createdAt: String
    var modifiedAt: String
    var imgs: [BoardImgDetail]?
}

struct BoardImgDetail: Codable {
    var img: String
    var order: Int
}
