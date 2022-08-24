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
        
        let doLikeObserver = PublishRelay<Int>()
        let undoLikeObserver = PublishRelay<Int>()
    }
    
    struct OUTPUT {
        var loadDetailBoardOutput = PublishRelay<CommunityDetailBoardResponseModel>()
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
        
        input.doLikeObserver
            .flatMap { id in
                ApiManager.postData(
                    from: BaseURL.url.appending("post/\(id)/like"),
                    to: CommunityLikeResponseModel.self,
                    encoding: URLEncoding.default
                )
            }.subscribe(onNext: { data in
                print("좋아요 추가 성공")
            }).disposed(by: disposeBag)
        
        input.undoLikeObserver
            .flatMap { id in
                ApiManager.deleteData(
                    from: BaseURL.url.appending("post/\(id)/like"),
                    to: CommunityLikeResponseModel.self,
                    encoding: URLEncoding.default
                )
            }.subscribe(onNext: { data in
                print("좋아요 삭제 성공")
            }).disposed(by: disposeBag)
    }
}
