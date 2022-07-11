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
    let disposeBag = DisposeBag()
    
    let input = INPUT()
    var output = OUTPUT()
    
    ///INPUT
    struct INPUT {
        let getMyAlarmList = PublishRelay<Void>()
    }
        
    ///OUTPUT
    struct OUTPUT {
        var sendAlarmList = PublishRelay<AlarmModel>()
    }
    
    init() {
        input.getMyAlarmList
            .flatMap { AlarmAPI.getMyAlarmList() }
            .subscribe(onNext: { [weak self] data in
                self.output.sendAlarmList.accept(data)
            }).disposed(by: disposeBag)
        
    }
}
