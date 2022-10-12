//
//  PostCommentResponseModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/30.
//

import Foundation

struct PostCommentResponseModel: Codable {
    var data: PostDataDetail
}

struct PostDataDetail: Codable {
    var status: Bool
    var id: Int
    var content: String
    var anonymity: Bool
    var user: CommentUserDetail
    var isWriter: Bool
    var isMine: Bool
    var isModified: Bool
    var createdAt: String?
    var modifiedAt: String?
    var post: PostDetail
}

struct PostDetail: Codable {
    var status: Bool
    var id: Int
    var content: String
    var anonymity: Bool?
    var likes: Int
    var hits: Int
    var user: CommentUserDetail
    var isWriter: Bool?
    var isLiked: Bool?
    var isBookmarked: Bool?
    var isMine: Bool?
    var isModified: Bool?
    var createdAt: String?
    var modifiedAt: String?
}
