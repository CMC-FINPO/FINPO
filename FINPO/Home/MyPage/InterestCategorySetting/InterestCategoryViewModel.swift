//
//  InterestCategoryViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/14.
//

import Foundation
import RxSwift
import RxCocoa

protocol InterestCategoryViewModelType {
    var firstLoad: AnyObserver<Void> { get }
    
//    var firstLoadOutput: Observable<MyInterestCategoryModel> { get }
}

final class InterestCategoryViewModel: InterestCategoryViewModelType {
    let disposeBag = DisposeBag()
    //INPUT
    var firstLoad: AnyObserver<Void>
    
    //OUTPUT
//    var firstLoadOutput: Observable<MyInterestCategoryModel>
    
    init(domain: CategoryFetchable = InterestCategoryStore()) {
        let firstObserver = PublishSubject<Void>()
        let firstOutput = BehaviorSubject<MyInterestCategoryModel>(value: .init(data: []))
        let firstAllCategory = BehaviorSubject<LowCategoryModel>(value: .init(data: []))
        firstLoad = firstObserver.asObserver()
        firstObserver
            .map { domain.getMyInteresting() }
            .flatMap { $0 }
            .map { $0 }
            .bind(to: firstOutput)
            .disposed(by: disposeBag)
        
        firstObserver
            .map { domain.getAllCategory() }
            .flatMap { $0 }
            .map { $0 }
            .bind(to: firstAllCategory)
            .disposed(by: disposeBag)
        
//        firstLoadOutput = firstOutput.asObservable()
        _ = Observable.zip(firstOutput.asObservable(), firstAllCategory.asObservable())
            .map { (interest, all) in
                
            }
        
            
    }
}
