//
//  CommunityCommentResponseModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/25.
//

import Foundation

struct CommunityCommentResponseModel: Codable {
    var data: CommentDataDetail
}

struct CommentDataDetail: Codable {
    var content: [CommentContentDetail]
    var totalPages: Int?
    var totalElements: Int?
    var last: Bool
    var numberOfElements: Int
}

struct CommentContentDetail: Codable {
    var status: Bool //삭제된 댓글인가(false면 삭제된 댓글)
    var id: Int //댓글 id
    var content: String?
    var anonymity: Bool?
    var anonymityId: Int?
    var user: CommentUserDetail?
    var isUserWithdraw: Bool?
    var isWriter: Bool?
    var isMine: Bool?
    var isModified: Bool? //수정된 댓글인가
    var childs: [CommentChildDetail]? //대댓글
    var createdAt: String?
    var modifiedAt: String?
}

struct CommentUserDetail: Codable {
    var status: Bool?
    var nickname: String?
    var gender: String?
    var profileImg: String?
    var role: String?
}

struct CommentChildDetail: Codable {
    var status: Bool?
    var id: Int?
    var content: String?
    var anonymity: Bool?
    var anonymityId: Int?
    var isWriter: Bool?
    var isMine: Bool?
    var isModified: Bool?
    var createdAt: String?
    var modifiedAt: String?
    var parent: CommentChildParentDetail?
}

struct CommentChildParentDetail: Codable {
    var status: Bool?
    var id: Int?
}
