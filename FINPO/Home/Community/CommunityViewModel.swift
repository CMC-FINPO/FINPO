//
//  CommunityViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/29.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class CommunityViewModel {
    
    let disposeBag = DisposeBag()
    
    var currentPage = 0
    
    let input = INPUT()
    var output = OUTPUT()
    
    ///INPUT
    struct INPUT {
        let loadBoardObserver = PublishRelay<boardSorting>()
        let loadMoreObserver = PublishRelay<Void>()
        
        ///게시글 좋아요, 북마크
        let likeObserver = PublishRelay<Int>()
        let unlikeObserver = PublishRelay<Int>()
        let doBookmarkObserver = PublishRelay<Int>()
        let undoBookmarkObserver = PublishRelay<Int>()
        //trigger
        let triggerObserver = PublishRelay<Void>()
        
        //indicator
        let activating = BehaviorSubject<Bool>(value: false)
    }
        
    ///OUTPUT
    struct OUTPUT {
        var loadBoardOutput = PublishRelay<isLoadMoreAction>()
        
        var activated: Observable<Bool>?
        
        var errorValue = PublishRelay<Error>()
    }
    
    enum boardSorting {
        case latest
        case popular
        
        var sortingURL: String {
            switch self {
            case .latest:
                return "post/search?&size=5&sort=id,desc"
            case .popular:
                return "post/search?&size=5&sort=createdAt,likes"
            }
        }
    }
    
    enum isLoadMoreAction {
        case first(CommunityboardResponseModel)
        case loadMore(CommunityboardResponseModel)
        case edited(CommunityContentModel)
    }
    
    enum likeCheckAction {
        case isLike(id: Int)
        case notLike(id: Int)
        
        var sortingURL: String {
            switch self {
            case .isLike(let id), .notLike(let id):
                return "post/\(id)/like"
            }
        }
    }
    
    enum bookmarkCheckAction {
        case add(id: Int)
        case delete(id: Int)
        
        var sortingURL: String {
            switch self {
            case .add(let id), .delete(let id):
                return "post/\(id)/bookmark"
            }
        }
    }

    
    init() {
        output.activated = input.activating.distinctUntilChanged()
        
        input.loadBoardObserver
            .do { [weak self] _ in self?.input.activating.onNext(true) }
            .map { action in
                switch action {
                case .latest:
                    ApiManager.getData(
                        from:BaseURL.url.appending("\(boardSorting.latest.sortingURL)&page=\(self.currentPage)"),
                        to: CommunityboardResponseModel.self,
                        encoding: URLEncoding.default
                    ).subscribe(onNext: { data in
                        self.output.loadBoardOutput.accept(.first(data))
                    }).disposed(by: self.disposeBag)
                case .popular:
                    ApiManager.getData(
                        from: BaseURL.url.appending("\(boardSorting.popular.sortingURL)&page=\(self.currentPage)"),
                    to: CommunityboardResponseModel.self,
                    encoding: URLEncoding.default)
                    .subscribe(onNext: { data in
                        self.output.loadBoardOutput.accept(.first(data))
                    }).disposed(by: self.disposeBag)
                }
            }
            .do {[weak self] _ in self?.input.activating.onNext(false)}
            .subscribe(onNext: {
                print("게시판 로드")
            }).disposed(by: disposeBag)
        
        
        ///추가 로드
        input.loadMoreObserver
            .withLatestFrom(input.loadBoardObserver) { _, action in
                self.currentPage += 1
                switch action {
                case .latest:
                    ApiManager.getData(
                        from: BaseURL.url.appending("\(boardSorting.latest.sortingURL)&page=\(self.currentPage)"),
                        to: CommunityboardResponseModel.self,
                        encoding: URLEncoding.default
                    ).subscribe(onNext: { data in
                        self.output.loadBoardOutput.accept(.loadMore(data))
                    }).disposed(by: self.disposeBag)
                case .popular:
                    ApiManager.getData(
                        from: BaseURL.url.appending("\(boardSorting.popular.sortingURL)&page=\(self.currentPage)"),
                    to: CommunityboardResponseModel.self,
                    encoding: URLEncoding.default)
                    .subscribe(onNext: { data in
                        self.output.loadBoardOutput.accept(.loadMore(data))
                    }).disposed(by: self.disposeBag)
                }
            }.subscribe(onNext: { _ in
                print("게시판 추가로드")
            }).disposed(by: disposeBag)
        
        ///좋아요 추가
        input.likeObserver
            .flatMap { id in ApiManager.postData(
                from: BaseURL.url.appending("\(likeCheckAction.isLike(id: id).sortingURL)"),
                to: CommunityLikeResponseModel.self,
                encoding: URLEncoding.default) }
            .subscribe(onNext: { [weak self] editedData in
                self?.input.triggerObserver.accept(())
            }, onError: { [weak self] error in
                self?.output.errorValue.accept(error)
            }
            ).disposed(by: disposeBag)
        
        input.unlikeObserver
            .flatMap { id in ApiManager.deleteData(
                from: BaseURL.url.appending("\(likeCheckAction.notLike(id: id).sortingURL)"),
                to: CommunityLikeResponseModel.self,
                encoding: URLEncoding.default) }
            .subscribe(onNext: { [weak self] editedData in
                self?.input.triggerObserver.accept(())
            }).disposed(by: disposeBag)
        
        input.doBookmarkObserver
            .flatMap { id in ApiManager.postData(
                from: BaseURL.url.appending("\(bookmarkCheckAction.add(id: id).sortingURL)"),
                to: CommunityLikeResponseModel.self,
                encoding: URLEncoding.default) }
            .subscribe(onNext: { [weak self] editedData in
                self?.input.triggerObserver.accept(())
            }).disposed(by: disposeBag)
        
        input.undoBookmarkObserver
            .flatMap { id in ApiManager.deleteData(
                from: BaseURL.url.appending("\(bookmarkCheckAction.delete(id: id).sortingURL)"),
                to: CommunityLikeResponseModel.self,
                encoding: URLEncoding.default) }
            .subscribe(onNext: { [weak self] editedData in
                self?.input.triggerObserver.accept(())
            }).disposed(by: disposeBag)
        
        input.triggerObserver
            .withLatestFrom(input.loadBoardObserver) { _, action in
                switch action {
                case .latest:
                    self.input.loadBoardObserver.accept(.latest)
                    if(self.currentPage > 0) {
                        for i in 1..<(self.currentPage) where self.currentPage > 0 {
                            ApiManager.getData(
                                from: BaseURL.url.appending("\(boardSorting.latest.sortingURL)&page=\(i)"),
                                to: CommunityboardResponseModel.self,
                                encoding: URLEncoding.default
                            ).subscribe(onNext: { data in
                                self.output.loadBoardOutput.accept(.loadMore(data))
                            }).disposed(by: self.disposeBag)
                        }
                    }
                case .popular:
                    self.input.loadBoardObserver.accept(.popular)
                    if(self.currentPage > 0) {
                        for i in 1..<(self.currentPage) {
                            ApiManager.getData(
                                from: BaseURL.url.appending("\(boardSorting.popular.sortingURL)&page=\(i)"),
                            to: CommunityboardResponseModel.self,
                            encoding: URLEncoding.default)
                            .subscribe(onNext: { data in
                                self.output.loadBoardOutput.accept(.loadMore(data))
                            }).disposed(by: self.disposeBag)
                        }
                    }
                }
            }.subscribe(onNext: {
                print("좋아요/북마크 갱신 후 재로드")
            }).disposed(by: disposeBag)
    }
}
