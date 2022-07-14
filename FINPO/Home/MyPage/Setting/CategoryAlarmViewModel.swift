//
//  CategoryAlarmViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/14.
//

import Foundation
import RxCocoa
import RxSwift

class CategoryAlarmViewModel {
    let disposeBag = DisposeBag()
    let input = INPUT()
    var output = OUTPUT()
    
    enum addWholeCategory {
        case whole(InterestingAPIResponse)
        case parent(MyAlarmIsOnModel)
    }
    
    ///INPUT
    struct INPUT {
        ///내 관심 카테고리 조회
        let myInterestCategoryObserver = PublishRelay<Void>()
        
        ///전체 스위치 조작 -> API 전체 Sub
        let didTappedWholeSwitchObserver = PublishRelay<Bool>()
        
        ///개별 카테고리 스위치 조작
        let didTappedCellSwitchIdObserver = PublishRelay<Int>()
        let didTappedCellSwitchSubsObserver = PublishRelay<Bool>()
    }
        
    ///OUTPUT
    struct OUTPUT {
        ///종합한거 뷰컨 전달
        var sendResultCategory = PublishRelay<MyAlarmIsOnModel>()
    }
    
    init() {
        ///
        ///INPUT
        ///
        
        ///내 관심 카테고리 조회
        input.myInterestCategoryObserver
            .flatMap { FCMAPI.getMyInterestCategoryAlarmList() }
            .subscribe(onNext: { [weak self] interest in
                var isAllTrue = [Bool]()
                for i in 0..<interest.data.interestCategories.count {
                    isAllTrue.append(interest.data.interestCategories[i].subscribe)
                }
                isAllTrue.contains(false) ? (CategoryAlarmViewController.editWholeSwitch = false) :
                (CategoryAlarmViewController.editWholeSwitch = true)
                self?.output.sendResultCategory.accept(interest)
            }).disposed(by: disposeBag)
                
        ///전체 스위치 조작 -> API 전체 Sub 결정
        input.didTappedWholeSwitchObserver
            .map { valid in
                if valid { //True -> 전체 구독
                    let regisToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
                    FCMAPI.subAll(token: regisToken, subOrNot: valid)
                        .subscribe(onNext: { isOnModel in
                            CategoryAlarmViewController.editWholeSwitch = true
                            self.output.sendResultCategory.accept(isOnModel)
                            
                        }).disposed(by: self.disposeBag)
                } else { //false -> 전체 구독 해지
                    FCMAPI.cancelAllSub(subOrNot: valid)
                        .subscribe(onNext: { isOnModel in
                            CategoryAlarmViewController.editWholeSwitch = false
                            self.output.sendResultCategory.accept(isOnModel)
                        }).disposed(by: self.disposeBag)
                }
            }
            .subscribe(onNext: {
                print("방출")
            }).disposed(by: disposeBag)
        
        
        
        ///개별 스위치 조작 -> 개별 스위치 상태 변경 및 전체 알림 스위치의 보여지는 상태 변경
        _ = Observable.zip(self.input.didTappedCellSwitchIdObserver, self.input.didTappedCellSwitchSubsObserver, resultSelector: { id, isSubs in
            //구독 분기 처리
            if(isSubs) {
                FCMAPI.editCellSubs(id: id, subOrNot: isSubs)
                    .subscribe(onNext: { isOnMyModel in
                        ///전체 알림이 아닌 전체 셀의 sub가 true라면 전체 알림 뷰 버튼 수정
                        var isAllTrue = [Bool]()
                        for i in 0..<(isOnMyModel.data.interestCategories.count) {
                            if(isOnMyModel.data.interestCategories[i].subscribe) {
                                isAllTrue.append(true)
                            } else { isAllTrue.append(false) } //하나라도 구독 아니라면 전체 알림 스위치 !isOn
                        }
                        isAllTrue.contains(false) ? (CategoryAlarmViewController.editWholeSwitch = false) : (CategoryAlarmViewController.editWholeSwitch = true)
                        self.output.sendResultCategory.accept(isOnMyModel)
                    }).disposed(by: self.disposeBag)
            } else { //개별 셀의 구독을 해지할 경우
                FCMAPI.editCellSubs(id: id, subOrNot: isSubs)
                    .subscribe(onNext: { isOnMyModel in
                        //어차피 하나의 셀을 구독해지하므로 바로 전체 알림 스위치 !isOn
                        CategoryAlarmViewController.editWholeSwitch = false
                        self.output.sendResultCategory.accept(isOnMyModel)
                    }).disposed(by: self.disposeBag)
            }
        })
        .subscribe(onNext: {
            print("개별 셀 구독 여부 방출 완료")
        }).disposed(by: disposeBag)
        
    }
}
