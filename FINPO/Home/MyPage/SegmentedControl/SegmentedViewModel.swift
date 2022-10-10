//
//  SegmentedViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/09.
//

import Foundation
import RxSwift
import RxCocoa

enum LoadMoreAction {
    case first(CommunityboardResponseModel)
    case loadMore(CommunityboardResponseModel)
}

protocol SegmentedViewModelType {
    var fetchMyWriting : AnyObserver<Void> { get }
    var loadMore       : AnyObserver<Void> { get }
    var mywritingResult: Observable<LoadMoreAction> { get }
}

class SegmentedViewModel: SegmentedViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT //
    var fetchMyWriting: AnyObserver<Void>
    var loadMore      : AnyObserver<Void>
    // OUTPUT //
    var mywritingResult: Observable<LoadMoreAction>
    
    init(domain: MyPageFetchable = MypageStore()) {
        let writingFetching = PublishSubject<Void>()
        let page = BehaviorSubject<Int>(value: 0)
        let loadMoreObserver = PublishSubject<Void>()
        
        let mywriting = PublishSubject<LoadMoreAction>()
        
        fetchMyWriting = writingFetching.asObserver()
        writingFetching.withLatestFrom(page.asObservable())
            .filter { $0 == 0 }
            .map { domain.fetchMyWriting($0) }
            .flatMap { $0 }
            .map { LoadMoreAction.first($0) }
            .bind(to: mywriting)
            .disposed(by: disposeBag)
        
        writingFetching.withLatestFrom(page.asObservable())
            .filter { $0 > 0 }
            .map { domain.fetchMyWriting($0) }
            .flatMap { $0 }
            .filter { !$0.data.last }
            .map { LoadMoreAction.loadMore($0) }
            .bind(to: mywriting)
            .disposed(by: disposeBag)
            
        mywritingResult = mywriting.asObservable()
        
        loadMore = loadMoreObserver.asObserver()
        loadMoreObserver.withLatestFrom(page.asObservable())
            .map { $0 + 1 }
            .do(onNext: { page.onNext($0)})
            .map { Int -> () in }
            .bind(to: writingFetching)
            .disposed(by: disposeBag)
            
    }
}
