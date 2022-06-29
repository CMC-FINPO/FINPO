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
    
    enum SortAction {
        case latest
        case popular
    }
    
    enum TagLoadAction {
        case isFirstLoad([DataDetail])
        case delete(at: Int)
        case add([DataDetail])
    }
    
    let disposeBag = DisposeBag()
    
    var input = INPUT()
    var output = OUTPUT()
    
    var dataSource = [Contents]()
    var currentPage = 0
    var currentText = ""
    
    struct INPUT {
        let textFieldObserver = PublishRelay<String>()
        let loadMoreObserver = PublishRelay<Void>()
        let currentPage = PublishRelay<Int>()
        let sortActionObserver = PublishRelay<SortAction>()
        
        let isFirstLoadObserver = PublishRelay<Void>()
        let tagLoadActionObserver = PublishRelay<TagLoadAction>()
        

        var deleteTagObserver = PublishRelay<Int>()
        
    }
    
    struct OUTPUT {
        var textFieldResult = PublishRelay<Contents>()
        var policyResult = PublishRelay<Action>()
        var isFirstLoadOutput = PublishRelay<MyRegionList>()
        var regionButtonTapped = PublishRelay<RegionActionType>()
    }
    
    init() {
        ///INPUT
        input.loadMoreObserver
            .debug()
            .subscribe(onNext: { _ in
                print("테이블 load more Oberver 이벤트 방출......")
                self.currentPage += 1
                self.input.currentPage.accept(self.currentPage)
            }).disposed(by: disposeBag)
        
        input.isFirstLoadObserver
            .flatMap { CallMyRegionAPI.callMyRegion() }
            .subscribe(onNext: { list in
//                self.output.isFirstLoadOutput.accept(list)
                self.input.tagLoadActionObserver.accept(.isFirstLoad(list.data))
            }).disposed(by: disposeBag)
        
        input.deleteTagObserver
            .subscribe(onNext: { index in
                self.output.regionButtonTapped.accept(RegionActionType.delete(index: index))
            }).disposed(by: disposeBag)
        
        ///OUTPUT
                
        //정렬했을 때 -> Page 0 불러오기
        _ = Observable.combineLatest(
            input.sortActionObserver.asObservable(),
            input.textFieldObserver.asObservable())
//        .take(1)
        .flatMap({ (action, text) -> Observable<SearchPolicyResponse> in
            switch action {
            case .latest:
                self.currentText = text
                return SearchPolicyAPI.searchPolicyAPI(title: text)
            case .popular:
                self.currentText = text
                return SearchPolicyAPI.searchPolicyAsPopular(title: text)
            }
        })
        .subscribe(onNext: { policyData in
            self.output.policyResult.accept(Action.load([Contents(content: policyData.data!.content)]))
        }).disposed(by: disposeBag)
        
        //스크롤 내렸을 때 loadMore 하기
        _ = Observable.combineLatest(
            input.loadMoreObserver.asObservable(),
            input.currentPage.asObservable(),
//            input.textFieldObserver.asObservable(),
            input.sortActionObserver.asObservable())
        .flatMap({ (_, page, action) -> Observable<SearchPolicyResponse> in
            switch action {
            case .latest:
                print("스크롤 한 뒤 현재 페이지: \(page)")
                print("스크롤 한 뒤 현재 페이지: \(self.currentText)")
                return SearchPolicyAPI.searchPolicyAPI(title: self.currentText, at: page)
            case .popular:
                print("스크롤 한 뒤 현재 페이지: \(page)")
                return SearchPolicyAPI.searchPolicyAsPopular(title: self.currentText, at: page)
            }
        })
        .subscribe(onNext: { addedData in
            self.output.policyResult.accept(Action.loadMore(Contents(content: addedData.data!.content)))
        }).disposed(by: disposeBag)
        
        
        
    }
}
