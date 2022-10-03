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
    var DetailObserver: AnyObserver<Int> { get }
    
    var fetchBoard: Observable<CommunityboardResponseModel> { get }
    var activated: Observable<Bool> { get }
    var moveToDetail: Observable<CommunityContentModel> { get }
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
    var DetailObserver: AnyObserver<Int>
    
    //OUTPUT
    var fetchBoard: Observable<CommunityboardResponseModel>
    var activated: Observable<Bool>
    var moveToDetail: Observable<CommunityContentModel>
    
    init(domain: SearchingFetchable = SearchingStore()) {
        let text = PublishSubject<String>()
        let pageObserver = PublishSubject<Void>()
        let page = BehaviorSubject<Int>(value: 0)
        let temp = PublishSubject<String>()
        let pageId = PublishSubject<Int>()
        let boardData = PublishSubject<CommunityboardResponseModel>()

        let activating = BehaviorSubject<Bool>(value: false)
        
        // INPUT //
        
        contentText = text.asObserver()
        text
            .map { $0 }
            .bind(onNext: { temp.onNext($0)} )
            .disposed(by: disposeBag)
                
        text
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
        
        DetailObserver = pageId.asObserver()
       
        // OUTPUT //

        fetchBoard = page.asObservable()
            .withLatestFrom(temp.asObservable(), resultSelector: { (page, text ) in (page, text)
            })
            .do(onNext: { _ in activating.onNext(true)})
            .map { ($0.0, $0.1) }
            .do(onNext: { debugPrint("페이지: \($0.0)")})
            .flatMap { page, text -> Observable<CommunityboardResponseModel> in
                domain.fetchSearchedBoard(page: page, content: text)
            }
            .do(onNext: { model in boardData.onNext(model)})
            .do(onNext: { _ in activating.onNext(false)})
            
        activated = activating.distinctUntilChanged()
        
        moveToDetail = pageId.asObservable()
        .withLatestFrom(fetchBoard.asObservable(), resultSelector: { pageId, boardData in
            (pageId, boardData)
        })
        .map { ($0.0, $0.1) }
        .map ({ (pageId, model) -> CommunityContentModel in
            return model.data.content[pageId]
        })
                
              
    }
    
}
