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
    var contentText: AnyObserver<String> { get }
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
    var contentText: AnyObserver<String>
//    var search: AnyObserver<CommunityboardResponseModel>
    
    //OUTPUT
    var fetchBoard: Observable<CommunityboardResponseModel>
    
    init(domain: SearchingFetchable = SearchingStore()) {
        let text = PublishSubject<String>()
        let pageObserver = PublishSubject<Void>()
        let page = BehaviorSubject<Int>(value: 0)
        let temp = PublishSubject<String>()

        var activating = BehaviorSubject<Bool>(value: false)
        
        
        // INPUT //
        
        contentText = text.asObserver()
        text
            .map { $0 }
            .do(onNext: { _ in page.onNext(0)})
            .bind(onNext: { temp.onNext($0)} )
            .disposed(by: disposeBag)
                
        text
            .take(1)
            .map { _ -> Int in return 0 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
        increasePage = pageObserver.asObserver()
        pageObserver
            .flatMap { _ in page }
            .debug()
            .map { $0 + 1 }.reduce(0, accumulator: +)
            .bind(to: page)
            .disposed(by: disposeBag)
      
        
        // OUTPUT //

        fetchBoard = page.asObservable()
            .withLatestFrom(temp.asObservable(), resultSelector: { (page, text ) in (page, text)
            })
            .map { ($0.0, $0.1) }
            .do(onNext: { debugPrint("페이지: \($0.0)")})
            .flatMap { page, text -> Observable<CommunityboardResponseModel> in
                domain.fetchSearchedBoard(page: page, content: text)
            }
            
              
    }
    
}
