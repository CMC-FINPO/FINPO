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
        
        //댓글작성 후 송신버튼 클릭 시 등록
        let commentBtnObserver = PublishRelay<Void>()
        let commentTextObserver = PublishRelay<String>()
        //댓글인지 대댓글인지 여부
        let isNestedObserver = PublishRelay<commentSendAction>()
        //커뮤니티 상세페이지 id
        let pageIdObserver = PublishRelay<Int>()
        //익명버튼 체크 활성화 옵저버
        let isAnonyBtnClicked = PublishRelay<Bool>()
    }
    
    struct OUTPUT {
        var loadDetailBoardOutput = PublishRelay<CommunityDetailBoardResponseModel>()
        
        var loadCommentOutput = PublishRelay<CommunityCommentResponseModel>()
        
        //댓글개수 리턴
        var commentCntOutput: Driver<Int> = PublishRelay<Int>().asDriver(onErrorJustReturn: -1)
        
        //댓글*대댓글 방출
        var sendComment: Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
    }
    
    enum likeAction {
        case doLike(id: Int)
        case undoLike(id: Int)
    }
    
    enum bookmarkAction {
        case doBook(id: Int)
        case undoBook(id: Int)
    }
    
    // 댓글*대댓글 액션 분할
    enum commentSendAction {
        case comment(id: Int)
        case nested(parentId: Int) //대댓글
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
        
        
        ///댓글작성
        _ = input.commentBtnObserver
            .withLatestFrom(Observable.combineLatest(input.commentTextObserver.asObservable(),
                                                     input.isNestedObserver.asObservable(),
                                                     input.pageIdObserver.asObservable(),
                                                     input.isAnonyBtnClicked.asObservable()))
        { ($0, $1.0, $1.1, $1.2, $1.3) }
            .debug()
            .subscribe(onNext: { _, text, nested, pageId, isAnony in
                switch nested {
                case .comment(let id):
                    let parameter: Parameters = [
                        "content": text,
                        "anonymity": isAnony
                    ]
                    ApiManager.postData(
                        with: parameter as? Parameters,
                        from: BaseURL.url.appending("post/\(id)/comment"),
                        to: PostCommentResponseModel.self,
                        encoding: JSONEncoding.default)
                    .subscribe(onNext: { [weak self] _ in
                        self?.input.loadCommentObserver.accept(id)
                    }).disposed(by: self.disposeBag)
                case .nested(let parentId):
                    let parameter: Parameters = [
                        "content": text,
                        "anonymity": isAnony,
                        "parent": ["id": parentId]
                    ]
                    ApiManager.postData(
                        with: parameter as? Parameters,
                        from: BaseURL.url.appending("post/\(pageId)/comment"),
                        to: PostCommentResponseModel.self,
                        encoding: JSONEncoding.default)
                    .subscribe(onNext: { [weak self] _ in
                        self?.input.loadCommentObserver.accept(pageId)
                    }).disposed(by: self.disposeBag)
                }
            }).disposed(by: disposeBag)
        
        input.isAnonyBtnClicked
            .subscribe(onNext: { valid in
                print(valid)
            }).disposed(by: disposeBag)
        
    }
}
