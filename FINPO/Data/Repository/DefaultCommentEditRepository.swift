//
//  DefaultEditStore.swift
//  FINPO
//
//  Created by 이동희 on 2022/11/18.
//

import Foundation
import RxSwift
import Alamofire

final class DefaultCommentEditRepository: CommentEditRepository {
    
    private let commentEditNetworkService: CommentEditNetworkService
    
    init(commentEditNetworkService: CommentEditNetworkService) {
        self.commentEditNetworkService = commentEditNetworkService
    }
    
    var url = BaseURL.url.appending("comment/")

    func editComment(commentId: Int, content: String) -> Observable<Response> {

        return commentEditNetworkService.editComment(commentId: commentId, content: content)
    }
    
    //댓글 삭제
    func deleteComment(id: Int)  {
        return commentEditNetworkService.deleteComment(id: id)
    }
    
    //댓글 신고
    func reportComment(commentId: Int, reportId: Int) -> Observable<EditResponse> {
        return commentEditNetworkService.reportComment(commentId: commentId, reportId: reportId)
    }
    
    // 댓글, 게시글 유저 차단
    func blockUser(commentId: SortIsBoard) {
        return commentEditNetworkService.blockUser(commentId: commentId)
    }
    
    //게시글
    func getBoardData(pageId: Int) -> Observable<CommunityDetailBoardResponseModel> {
        return commentEditNetworkService.getBoardData(pageId: pageId)
    }
    
    //이미지 URL 가져오기
    func getImageUrl(imgs: [UIImage]) -> Observable<BoardImageResponseModel> {
        return commentEditNetworkService.getImageUrl(imgs: imgs)
    }
    
    //업로드
    func uploadBoard(pageId: Int, text: String, imgUrls: [String]) -> Observable<CommunityDetailBoardResponseModel> {
        return commentEditNetworkService.uploadBoard(pageId: pageId, text: text, imgUrls: imgUrls)
    }
    
    //게시글 삭제
    func deleteBoard(pageId: Int) {
        return commentEditNetworkService.deleteBoard(pageId: pageId)
    }
    
    //게시글 신고
    func reportBoard(pageId: Int, reportId: Int) -> Observable<EditResponse> {
        return commentEditNetworkService.reportBoard(pageId: pageId, reportId: reportId)
    }

}
