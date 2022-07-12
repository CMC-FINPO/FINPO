//
//  AlarmViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/11.
//

import Foundation
import RxSwift
import RxCocoa

class AlarmViewModel {
    enum loadTableViewAction {
        case first(data: AlarmModel)
        case delete(data: AlarmModel)
    }
    
    let disposeBag = DisposeBag()
    
    let input = INPUT()
    var output = OUTPUT()
    
    ///INPUT
    struct INPUT {
        let getMyAlarmList = PublishRelay<Void>()
        let getMyDeleteAlarmList = PublishRelay<Void>()
        let navTreshButtonTapped = PublishRelay<Void>()
        
        let didTappedDeleteButtonObserver = PublishRelay<Int>()
    }
        
    ///OUTPUT
    struct OUTPUT {
        var sendAlarmList = PublishRelay<loadTableViewAction>()
        
        var didCompletedDelete = PublishRelay<Bool>()
    }
    
    init() {
        input.getMyAlarmList
            .flatMap { AlarmAPI.getMyAlarmList() }
            .subscribe(onNext: { data in
                self.output.sendAlarmList.accept(.first(data: data))
            }).disposed(by: disposeBag)
        
        input.getMyDeleteAlarmList
            .flatMap { AlarmAPI.getMyAlarmList() }
            .subscribe(onNext: { data in
                self.output.sendAlarmList.accept(.delete(data: data))
            }).disposed(by: disposeBag)
        
        input.didTappedDeleteButtonObserver
            .flatMap { AlarmAPI.deleteMyAlarm(policyId: $0) }
            .subscribe(onNext: { valid in
                self.output.didCompletedDelete.accept(valid)
            }).disposed(by: disposeBag)
        
    }
}
