//
//  CommunityboardResponseModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/22.
//

import Foundation

struct CommunityboardResponseModel: Codable {
    var data: CommunityDataModel
}

struct CommunityDataModel: Codable {
    var content: [CommunityContentModel]
    var totalElements: Int
    var last: Bool //현재가 마지막 페이지인가
    var first: Bool
}

struct CommunityContentModel: Codable {
    var status: Bool? //글 상태 (삭제 시 false)
    var id: Int //글 id
    var content: String //글 내용
    var anonymity: Bool //글작성자 익명여부
    var likes: Int //글 좋아요수
    var hits: Int //글 조회수
    var countOfComment: Int? //댓글수
    var isMine: Bool //내가 작성한 글인가
    var isLiked: Bool //좋아요 한 글인가
    var isBookmarked: Bool //북마크 한 글인가
    var isModified: Bool
    var modified: Bool? //수정된 글인가
    var createdAt: String //작성일
    var modifiedAt: String //수정일
    var user: CommunityUserDetail?
}

struct CommunityUserDetail: Codable {
    var status: Bool?
    var nickname: String?
    var gender: String?
    var profileImg: String?
    var role: String?
}

///좋아요, 북마크
struct CommunityLikeResponseModel: Codable {
    var data: CommunityContentModel
}
