//
//  BookmarkViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/10.
//

import Foundation
import RxSwift
import RxCocoa

class BookmarkViewModel {
    let disposeBag = DisposeBag()
    
    let user = User.instance
    let input = INPUT()
    var output = OUTPUT()
    
    struct INPUT {
        let getUserInterestedInfo = PublishRelay<Void>()
        let getMyCategoryObserver = PublishRelay<Void>()
        let getMyInterestPolicyObserver = PublishRelay<Void>()
    }
    
    struct OUTPUT {
        var sendUserInterestedOutput = PublishRelay<UserParticipatedModel>()
        var sendMyCategoryOutput = PublishRelay<MyCategoryModel>()
        var sendMyInterestPoliciesOutput = PublishRelay<UserParticipatedModel>()
    }
    
    init() {
        input.getUserInterestedInfo
            .flatMap { UserInfoAPI.getUserInterestedInfo() }
            .subscribe(onNext: { [weak self] userData in
                self?.output.sendUserInterestedOutput.accept(userData)
            }).disposed(by: disposeBag)
        
        input.getMyCategoryObserver
            .flatMap { UserInfoAPI.getMyCategory() }
            .subscribe(onNext: { [weak self] category in
                self?.output.sendMyCategoryOutput.accept(category)
            }).disposed(by: disposeBag)
        
        input.getMyInterestPolicyObserver
            .flatMap { UserInfoAPI.getUserInterestedInfo() }
            .subscribe(onNext: { [weak self] policies in
                self?.output.sendMyInterestPoliciesOutput.accept(policies)
            }).disposed(by: disposeBag)
    }
    
}
