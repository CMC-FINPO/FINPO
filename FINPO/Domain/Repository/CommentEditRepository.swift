//
//  EditStore.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/03.
//

import Foundation
import RxSwift

struct Response: Codable {
    let success: Bool
    let data: EditCommentResponseModel
}

struct EditResponse: Codable {
    var success : Bool
    var errorCode : Int
    var message : String
    var data : Bool
}

struct UploadResponse: Codable {
    let success: Bool
    let data: CommunityDetailBoardResponseModel
}

protocol CommentEditRepository {
    func editComment(commentId: Int, content: String) -> Observable<Response>
    
    func deleteComment(id: Int)
    
    func reportComment(commentId: Int, reportId: Int) -> Observable<EditResponse>
    
    func blockUser(commentId: SortIsBoard)
    
    //게시글
    func getBoardData(pageId: Int) -> Observable<CommunityDetailBoardResponseModel>
    
    //이미지 url
    func getImageUrl(imgs: [UIImage]) -> Observable<BoardImageResponseModel>
    
    //업로드
    func uploadBoard(pageId: Int, text: String, imgUrls: [String]) -> Observable<CommunityDetailBoardResponseModel>
    
    //게시글 삭제
    func deleteBoard(pageId: Int)
    
    //게시글 신고
    func reportBoard(pageId: Int, reportId: Int) -> Observable<EditResponse>
}
