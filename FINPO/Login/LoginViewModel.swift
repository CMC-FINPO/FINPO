//
//  LoginViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/02.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Alamofire
import KakaoSDKUser
import AuthenticationServices
import KakaoSDKCommon
import RxKakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import RxKakaoSDKUser


class LoginViewModel {
    
    let disposeBag = DisposeBag()
    var user = User()
    
    var accessToken = ""
    
    let input = INPUT()
    var output = OUTPUT()
    
    struct INPUT {
        let kakaoSignUpObserver = PublishRelay<Void>()
        
        let nameObserver = PublishRelay<String>()
        let nickNameObserver = PublishRelay<String>()
        let birthObserver = PublishRelay<String>()
        let genderObserver = PublishRelay<Gender>()
        let emailObserver = PublishRelay<String>()
    }
    
    struct OUTPUT {
        var goKakaoSignUp = PublishRelay<Bool>()
        var isNicknameValid = PublishRelay<Bool>()
        var genderValid: Driver<Gender> = PublishRelay<Gender>().asDriver(onErrorJustReturn: .none)
        var isEmailValid = PublishRelay<Bool>()
        var buttonValid:Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
        
        var errorValue = PublishRelay<Error>()
    }
    
    init() {
        
        ///INPUT
        input.kakaoSignUpObserver
            .flatMap { self.kakaoLogin() }
            .subscribe({ valid in
                switch valid {
                case .next(let validation):
                    print("주입되었음")
                    self.output.goKakaoSignUp.accept(validation)
                case .completed:
                    break
                case .error(let error):
                    self.output.errorValue.accept(error)
                }
            }).disposed(by: disposeBag)
        
        input.nameObserver.subscribe(onNext: { name in
            self.user.name = name
        }).disposed(by: disposeBag)
        
        input.nickNameObserver.subscribe(onNext: { nickName in
            self.user.nickname = nickName
        }).disposed(by: disposeBag)
        
        //check nickname validation
        input.nickNameObserver
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { _ in self.checkNicknameValid() }
            .subscribe({ valid in
                switch valid {
                case .next(let valid):
                    self.output.isNicknameValid.accept(valid)
                case .completed:
                    break
                case.error(let error):
                    self.output.errorValue.accept(error)
                }
            }).disposed(by: disposeBag)
        
        input.birthObserver.subscribe(onNext: { birth in
            self.user.birth = birth
        }).disposed(by: disposeBag)
        
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
        
        input.emailObserver.subscribe(onNext: { email in
            self.user.email = email
        }).disposed(by: disposeBag)
        
                
        ///OUTPUT
        output.genderValid = input.genderObserver.asDriver(onErrorJustReturn: .none)
        
        input.emailObserver
            .flatMap { self.checkEmail(email: $0)}
            .observe(on: MainScheduler.asyncInstance)
            .subscribe({ valid in
                switch valid {
                case .next(_ ):
                    self.checkEmailValid().subscribe(onNext: { v in
                        self.output.isEmailValid.accept(v)
                    }).disposed(by: self.disposeBag)
                case .completed:
                    break
                case .error(let error):
                    self.output.errorValue.accept(error)
                }
            }).disposed(by: disposeBag)
        
        //input.nickNameObserver.asDriver(onErrorJustReturn: "")
        //input.emailObserver.asDriver(onErrorJustReturn: "")
        //TODO: 버튼 활성화 조건 맞추기
        output.buttonValid = Driver.combineLatest(input.nameObserver.asDriver(onErrorJustReturn: ""),
                                                  output.isNicknameValid.asDriver(onErrorJustReturn: false),
                                                  input.birthObserver.asDriver(onErrorJustReturn: ""),
                                                  input.genderObserver.asDriver(onErrorJustReturn: .none),
                                                  output.isEmailValid.asDriver(onErrorJustReturn: false),
                                                  resultSelector: { (a, b, c, d, e) in
            if a != "" && b != false  && c != "" && d != .none && e != false {
                return true
            }
            return false
        }).asDriver(onErrorJustReturn: false)
   
    }
    
    //유저 정보 입력받기 전 kakao api server에서 accesstoken get
    private func kakaoLogin() -> Observable<Bool> {
        return Observable.create { observer in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .subscribe(onNext: { (oauthToken) in
                        print("loginWithKakaoTalk() success.")
                        observer.onNext(true)
                    }, onError: { (error) in
                        print("error occured: \(error)")
                        observer.onError(error)
                    }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    private func checkNicknameValid() -> Observable<Bool> {
        return Observable.create { observer in
            let encodedNickname = self.user.nickname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            let url = "https://dev.finpo.kr/user/check-duplicate?nickname=\(encodedNickname)"
            let parameter: Parameters = [
                "nickname": self.user.nickname
            ]
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8"
            ]
            
            AF.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header)
                .validate(statusCode: 200..<300)
                .response { response in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["data"] as? Bool ?? false
                                if result {
                                    print("중복된 이메일")
                                    observer.onNext(false)
                                } else {
                                    print("중복되지 않은 이메일")
                                    observer.onNext(true)
                                }
                            }
                        }
                    case .failure(let error):
                        print("에러발생!!!")
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
    
    private func checkEmail(email: String) -> Observable<Bool> {
        return Observable.create { observer in
            if (!email.isEmpty && email.contains("@") && email.contains(".")) {
                observer.onNext(true)
            }
            else {
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func checkEmailValid() -> Observable<Bool> {
        return Observable.create { observer in
            
            let url = "https://dev.finpo.kr/user/check-duplicate?email=\(self.user.email)"
  
            let parameter: Parameters = [
                "email": self.user.email
            ]
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8"
            ]
            
            AF.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header)
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["data"] as? Bool ?? false
                                print(self.user.email)
                                print("email check api 성공, 이메일 겹침여부 \(result)!")
                                if result == true { //중복일 때
                                    observer.onNext(true)
                                } else {
                                    observer.onNext(false) //중복 아닐 때
                                }
                                
                            }
                        }
                    case .failure(let error):
                        print("email Valite 에러발생!!!: \(error)")
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }

    }
    
}
