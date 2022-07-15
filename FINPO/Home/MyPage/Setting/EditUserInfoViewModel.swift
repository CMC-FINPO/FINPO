//
//  EditUserInfoViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/15.
//

import Foundation
import RxSwift
import RxCocoa

class EditUserInfoViewModel {
    let disposeBag = DisposeBag()
    let input = INPUT()
    var output = OUTPUT()
    
    var user = User.instance
    
    ///INPUT
    struct INPUT {
        let userInfoObserver = PublishRelay<Void>()
        
        ///회원정보 입력
        let nameObserver = PublishRelay<String>()
        let nickNameObserver = PublishRelay<String>()
        let birthObserver = PublishRelay<String>()
        let genderObserver = PublishRelay<Gender>()
        
        ///수정된 유저 서버 등록
        let didTappedConfirmButton = PublishRelay<Void>()
    }
        
    ///OUTPUT
    struct OUTPUT {
        var sendUserInfo = PublishRelay<UserResponseModel>()
        
        ///회원정보 정합성 체크 및 방출
        var isNameValid = PublishRelay<Bool>()
        var isNicknameValid = PublishRelay<Bool>()
        var genderValid: Driver<Gender> = PublishRelay<Gender>().asDriver(onErrorJustReturn: .none)
        var buttonValid:Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
        
        var isCompltedEdit = PublishRelay<Bool>()
    }
    
    init() {
        ///초기 유저 데이터 로드
        input.userInfoObserver
            .flatMap { UserInfoAPI.getUserWholeInfo() }
            .subscribe(onNext: { [weak self] userInfo in
                guard let self = self else { return }
                self.output.sendUserInfo.accept(userInfo)
            }).disposed(by: disposeBag)
        
        ///Name
        input.nameObserver.subscribe(onNext: { [weak self] name in
            guard let self = self else { return }
            if(name.count > 14) {
                self.output.isNameValid.accept(false)
            } else {
                self.output.isNameValid.accept(true)
                self.user.name = name
            }
        }).disposed(by: disposeBag)
        
        ///Nickname
        input.nickNameObserver.subscribe(onNext: { [weak self] nickName in
            guard let self = self else { return }
            self.user.nickname = nickName
        }).disposed(by: disposeBag)
        
        ///Nickname validation check
        input.nickNameObserver
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { str in UserInfoAPI.checkNicknameValidation(nickName: str) } //중복:true
            .subscribe({ valid in
                switch valid {
                case .next(let valid):
                    self.output.isNicknameValid.accept(valid) //중복되지 않으면 False 방출
                case .completed:
                    break
                case.error(_):
                    break
                }
            }).disposed(by: disposeBag)
        
        ///생년월일
        input.birthObserver.subscribe(onNext: { birth in
            self.user.birth = birth
        }).disposed(by: disposeBag)
        
        ///성별
        input.genderObserver.subscribe(onNext: { valid in
            switch valid {
            case .male:
                self.user.gender = "MALE"
            case .female:
                self.user.gender = "FEMALE"
            case .none:
                break
            }
        }).disposed(by: disposeBag)
        
        output.genderValid = input.genderObserver.asDriver(onErrorJustReturn: .none)
        
        ///확인 버튼 정합성
        output.buttonValid = Driver.combineLatest(output.isNameValid.asDriver(onErrorJustReturn: false),
                                                  output.isNicknameValid.asDriver(onErrorJustReturn: false),
                                                  input.birthObserver.asDriver(onErrorJustReturn: "errorTest"),
                                                  input.genderObserver.asDriver(onErrorJustReturn: .none),
                                                  resultSelector: { (a, b, c, d) in
        if a != false && b != true  && c != "" && d != .none {
                print("버튼 색 변경조건 완료 -> true 방출")
                return true
            }
            return false
        }).asDriver(onErrorJustReturn: false)
        
        ///수정된 유저 정보 서버 등록
        input.didTappedConfirmButton
            .flatMap { UserInfoAPI.saveEditedUserInfo(userInfo: self.user) }
            .subscribe(onNext: { [weak self] valid in
                self?.output.isCompltedEdit.accept(valid)
            }).disposed(by: disposeBag)
    }
}
