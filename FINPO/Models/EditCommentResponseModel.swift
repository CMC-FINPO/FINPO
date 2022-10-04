//
//  EditCommentResponseModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/04.
//

import Foundation

struct EditCommentResponseModel: Codable {
    var status: Bool
    var id: Int
    var content : String
    var anonymity : Bool
    var isWriter : Bool
    var isMine : Bool
    var isModified : Bool
    var createdAt : String?
    var modifiedAt : String?
}
