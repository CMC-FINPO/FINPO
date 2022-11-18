//
//  CommentEditUseCase.swift
//  FINPO
//
//  Created by 이동희 on 2022/11/18.
//

import Foundation
import RxSwift

protocol CommentEditUseCase: AnyObject {
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

final class DefaultEidtUseCase: CommentEditUseCase {
    private let commentEditRepository: CommentEditRepository
    
    init(commentEditRepository: CommentEditRepository) {
        self.commentEditRepository = commentEditRepository
    }
        
    func editComment(commentId: Int, content: String) -> RxSwift.Observable<Response> {
        commentEditRepository.editComment(commentId: commentId, content: content)
    }
    
    func deleteComment(id: Int) {
        commentEditRepository.deleteComment(id: id)
    }
    
    func reportComment(commentId: Int, reportId: Int) -> RxSwift.Observable<EditResponse> {
        commentEditRepository.reportComment(commentId: commentId, reportId: reportId)
    }
    
    func blockUser(commentId: SortIsBoard) {
        commentEditRepository.blockUser(commentId: commentId)
    }
    
    func getBoardData(pageId: Int) -> RxSwift.Observable<CommunityDetailBoardResponseModel> {
        commentEditRepository.getBoardData(pageId: pageId)
    }
    
    func getImageUrl(imgs: [UIImage]) -> RxSwift.Observable<BoardImageResponseModel> {
        commentEditRepository.getImageUrl(imgs: imgs)
    }
    
    func uploadBoard(pageId: Int, text: String, imgUrls: [String]) -> RxSwift.Observable<CommunityDetailBoardResponseModel> {
        commentEditRepository.uploadBoard(pageId: pageId, text: text, imgUrls: imgUrls)
    }
    
    func deleteBoard(pageId: Int) {
        commentEditRepository.deleteBoard(pageId: pageId)
    }
    
    func reportBoard(pageId: Int, reportId: Int) -> RxSwift.Observable<EditResponse> {
        commentEditRepository.reportBoard(pageId: pageId, reportId: reportId)
    }
    

    
    
}
