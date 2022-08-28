//
//  CommunityDetailViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import Alamofire

class CommunityDetailViewModel {
    
    let disposeBag = DisposeBag()
    
    let input = INPUT()
    var output = OUTPUT()
    
    var boardDetailURL = BaseURL.url.appending("post/")
    
    struct INPUT {
        let loadDetailBoardObserver = PublishRelay<Int>()
        
        let likeObserver = PublishRelay<likeAction>()
        let bookmarkObserver = PublishRelay<bookmarkAction>()
        
        let loadCommentObserver = PublishRelay<Int>()
        
        let commentCntObserver = PublishRelay<Int>()
    }
    
    struct OUTPUT {
        var loadDetailBoardOutput = PublishRelay<CommunityDetailBoardResponseModel>()
        
        var loadCommentOutput = PublishRelay<CommunityCommentResponseModel>()
        
        //댓글개수 리턴
        var commentCntOutput: Driver<Int> = PublishRelay<Int>().asDriver(onErrorJustReturn: -1)
    }
    
    enum likeAction {
        case doLike(id: Int)
        case undoLike(id: Int)
    }
    
    enum bookmarkAction {
        case doBook(id: Int)
        case undoBook(id: Int)
    }
    
    init() {
        input.loadDetailBoardObserver
            .flatMap { id in
                ApiManager.getData(
                    from: self.boardDetailURL.appending("\(id)"),
                    to: CommunityDetailBoardResponseModel.self,
                    encoding: URLEncoding.default
                )
                
            }.subscribe(onNext: { [weak self] boardDetail in
                self?.output.loadDetailBoardOutput.accept(boardDetail)
                self?.input.commentCntObserver.accept(boardDetail.data.countOfComment)
            }).disposed(by: disposeBag)
        
        input.likeObserver
            .map { actions in
                switch actions {
                case .doLike(let id):
                    ApiManager.postData(
                        from: BaseURL.url.appending("post/\(id)/like"),
                        to: CommunityLikeResponseModel.self,
                        encoding: URLEncoding.default
                    ).subscribe(onNext: { _ in
                        print("좋아요 등록 성공")
                    }).disposed(by: self.disposeBag)
                case .undoLike(let id):
                    ApiManager.deleteData(
                        from: BaseURL.url.appending("post/\(id)/like"),
                        to: CommunityLikeResponseModel.self,
                        encoding: URLEncoding.default
                    ).subscribe(onNext: { _ in
                        print("좋아요 해지 성공")
                    }).disposed(by: self.disposeBag)
                }
            }.subscribe(onNext: { _ in
                print("이벤트 방출")
            }).disposed(by: disposeBag)
        
        input.bookmarkObserver
            .map { action in
                switch action {
                case .doBook(let id):
                    ApiManager.postData(
                        from: BaseURL.url.appending("post/\(id)/bookmark"),
                        to: CommunityLikeResponseModel.self,
                        encoding: URLEncoding.default
                    ).subscribe(onNext: { _ in
                        print("북마크 등록 성공")
                    }).disposed(by: self.disposeBag)
                    
                case .undoBook(let id):
                    ApiManager.deleteData(
                        from: BaseURL.url.appending("post/\(id)/bookmark"),
                        to: CommunityLikeResponseModel.self,
                        encoding: URLEncoding.default
                    ).subscribe(onNext: { _ in
                        print("북마크 해지 성공")
                    }).disposed(by: self.disposeBag)
                }
            }.subscribe(onNext: { _ in
                print("이벤트 방출")
            }).disposed(by: disposeBag)
        
        input.loadCommentObserver
            .map { id in
                let parameter: Parameters = [
                    "page": 0,
                    "size": 10,
                    "sort": "id,asc"
                ]
                ApiManager.getData(
                    with: parameter as? Encodable,
                    from: BaseURL.url.appending("post/\(id)/comment"),
                    to: CommunityCommentResponseModel.self,
                    encoding: JSONEncoding.default
                ).subscribe(onNext: { [weak self] commentData in
                    self?.output.loadCommentOutput.accept(commentData)
                }).disposed(by: self.disposeBag)
            }.subscribe(onNext: {
                print("댓글 이벤트 방출")
            }).disposed(by: disposeBag)
        
        output.commentCntOutput =
        input.commentCntObserver.asDriver(onErrorJustReturn: -1)
    }
}
