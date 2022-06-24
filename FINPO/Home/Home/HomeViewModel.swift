//
//  HomeViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/22.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class HomeViewModel {
    
    enum Action {
        case load([Contents])
        case loadMore(Contents)
    }
    
    let disposeBag = DisposeBag()
    
    var input = INPUT()
    var output = OUTPUT()
    
    var dataSource = [Contents]()
    var currentPage = 0
    
    struct INPUT {
        let textFieldObserver = PublishRelay<String>()
//        let loadObserver = PublishRelay<Void>()
        let loadMoreObserver = PublishRelay<Void>()
//        let currentPage = BehaviorRelay<Int>(value: 0)
        let currentPage = PublishRelay<Int>()
    }
    
    struct OUTPUT {
        var textFieldResult = PublishRelay<Contents>()
        
        var policyResult = PublishRelay<Action>()
    }
    
    init() {
        ///INPUT
        input.loadMoreObserver
            .subscribe(onNext: { _ in
                self.input.currentPage.accept(self.currentPage + 1)
            }).disposed(by: disposeBag)
        
        //테이블 끝 이벤트와 현재 textField 최신값을 가져오기
        _ = Observable.combineLatest(
            input.loadMoreObserver.asObservable(),
            input.currentPage.asObservable(),
            input.textFieldObserver.asObservable())
            .flatMap { _, page, text in
                SearchPolicyAPI.searchPolicyAPI(title: text, at: page)}
            .subscribe(onNext: { policyDat in
                self.output.policyResult.accept(Action.loadMore(Contents(content: policyDat.data!.content)))
            }).disposed(by: disposeBag)
           
        
        ///OUTPUT
        input.textFieldObserver
            .debounce(RxTimeInterval.microseconds(10), scheduler: MainScheduler.instance)
            .flatMap { SearchPolicyAPI.searchPolicyAPI(title: $0) }
            .subscribe(onNext: { policyDat in
//                self.output.textFieldResult.accept(Contents(content: policyDat.data!.content))
                /// 맨 처음 로드 값 넣어주기
                self.currentPage = 0
//                self.input.currentPage.accept(0)
                self.output.policyResult.accept(Action.load([Contents(content: policyDat.data!.content)]))
            }).disposed(by: disposeBag)
        
        
        
//        self.output.textFieldResult
//            .subscribe(onNext: { policy in
//                self.output.policyResult.accept(Action.load([policy]))
//            }).disposed(by: disposeBag)
        
    }
}
