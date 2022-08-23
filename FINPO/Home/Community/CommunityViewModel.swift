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
    }
        
    ///OUTPUT
    struct OUTPUT {
        var loadBoardOutput = PublishRelay<isLoadMoreAction>()
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
    }

    
    init() {
        
        input.loadBoardObserver
            .map { action in
                switch action {
                case .latest:
                    ApiManager.getData(
                        from:BaseURL.url.appending("\(boardSorting.latest.sortingURL)&page=\(self.currentPage)"),
                        to: CommunityboardResponseModel.self as? Codable,
                        encoding: URLEncoding.default
                    ).subscribe(onNext: { data in
                        self.output.loadBoardOutput.accept(.first(data))
                    }).disposed(by: self.disposeBag)
                case .popular:
                    ApiManager.getData(
                        from: BaseURL.url.appending("\(boardSorting.popular.sortingURL)&page=\(self.currentPage)"),
                    to: CommunityboardResponseModel.self as? Codable,
                    encoding: URLEncoding.default)
                    .subscribe(onNext: { data in
                        self.output.loadBoardOutput.accept(.first(data))
                    }).disposed(by: self.disposeBag)
                }
            }.subscribe(onNext: {
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
                        to: CommunityboardResponseModel.self as? Codable,
                        encoding: URLEncoding.default
                    ).subscribe(onNext: { data in
                        self.output.loadBoardOutput.accept(.loadMore(data))
                    }).disposed(by: self.disposeBag)
                case .popular:
                    ApiManager.getData(
                        from: BaseURL.url.appending("\(boardSorting.popular.sortingURL)&page=\(self.currentPage)"),
                    to: CommunityboardResponseModel.self as? Codable,
                    encoding: URLEncoding.default)
                    .subscribe(onNext: { data in
                        self.output.loadBoardOutput.accept(.loadMore(data))
                    }).disposed(by: self.disposeBag)
                }
            }.subscribe(onNext: { _ in
                print("게시판 추가로드")
            }).disposed(by: disposeBag)
        
    }
}
