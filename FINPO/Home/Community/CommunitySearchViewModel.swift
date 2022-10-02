//
//  CommunitySearchViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/02.
//

import Foundation
import RxSwift

protocol CommunitySearchViewModelType {
    var increasePage: AnyObserver<Void> { get }
    var contentText: AnyObserver<(content: String, page: Int)> { get }
//    var search: AnyObserver<CommunityboardResponseModel> { get }
    
    var fetchBoard: Observable<CommunityboardResponseModel> { get }
}

enum LoadAction {
    case first(content: String, page: Int)
    case notFirst
}

class CommunitySearchViewModel: CommunitySearchViewModelType {
    let disposeBag = DisposeBag()
    
    //INPUT
    var increasePage: AnyObserver<Void>
    var contentText: AnyObserver<(content: String, page: Int)>
//    var search: AnyObserver<CommunityboardResponseModel>
    
    //OUTPUT
    var fetchBoard: Observable<CommunityboardResponseModel>
    
    init(domain: SearchingFetchable = SearchingStore()) {
        let text = PublishSubject<(content: String, page: Int)>()
        let pageObserver = PublishSubject<Void>()
        let page = BehaviorSubject<Int>(value: 0)
        let temp = PublishSubject<(content: String, page: Int)>()

        var activating = BehaviorSubject<Bool>(value: false)
        
        
        // INPUT //
        contentText = text.asObserver()
        text
            .map { ($0.0, $0.1) }
//            .do(onNext: { _ in page.onNext(0)})
            .bind(onNext: { temp.onNext($0)} )
            .disposed(by: disposeBag)
        
        text
            .take(1)
            .do(onNext: { _ in debugPrint("한 번만")})
            .bind(onNext: { _ in page.onNext(0)})
            .disposed(by: disposeBag)
            
        
        increasePage = pageObserver.asObserver()
        pageObserver
            .flatMap { _ in page }
            .map { $0 + 1 }.reduce(0, accumulator: +)
            .subscribe(onNext: { page.onNext($0) })
            .disposed(by: disposeBag)
      
        
        // OUTPUT //
        
        fetchBoard = Observable.combineLatest(
            temp.asObservable(),
            page.asObservable())
            .flatMap { type, page -> Observable<CommunityboardResponseModel> in
                domain.fetchSearchedBoard(page: page, content: type.content)
            }
    }
    
}
