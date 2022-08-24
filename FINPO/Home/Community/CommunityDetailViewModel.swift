//
//  CommunityDetailViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/24.
//

import Foundation
import RxSwift
import RxRelay
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
    }
    
    struct OUTPUT {
        var loadDetailBoardOutput = PublishRelay<CommunityDetailBoardResponseModel>()
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
        
    }
}
