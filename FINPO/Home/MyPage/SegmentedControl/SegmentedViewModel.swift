//
//  SegmentedViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/09.
//

import Foundation
import RxSwift
import RxCocoa

protocol SegmentedViewModelType {
    var fetchMyWriting: AnyObserver<Void> { get }
    
    var mywritingResult: Observable<CommunityboardResponseModel> { get }
}

class SegmentedViewModel: SegmentedViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT //
    var fetchMyWriting: AnyObserver<Void>

    // OUTPUT //
    var mywritingResult: Observable<CommunityboardResponseModel>
    
    init(domain: MyPageFetchable = MypageStore()) {
        let writingFetching = PublishSubject<Void>()
        let page = BehaviorSubject<Int>(value: 0)
        
        let mywriting = PublishSubject<CommunityboardResponseModel>()
        
        fetchMyWriting = writingFetching.asObserver()
        writingFetching.withLatestFrom(page.asObservable())
            .map { domain.fetchMyWriting($0) }
            .flatMap { $0 }
            .bind(to: mywriting)
            .disposed(by: disposeBag)
            
        mywritingResult = mywriting.asObservable()
    }
}
