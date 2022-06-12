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
    var user = User.instance
    var mainRegion: [MainRegion] = [MainRegion](repeating: MainRegion.init(id: -1, name: "빈값"), count: 5)
    var subRegion: [SubRegion] = []
    var interested: [MainInterest] = []
        
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
//        let subRegionTapped = PublishRelay<IndexPath>()
        let subRegionTapped = PublishRelay<Int>()
        let forUserInterestObserver = PublishRelay<Int>() //유저의 상위 카테고리 저장 (탭 될때)
        let interestButtonTapped = PublishRelay<Void>()
    }
    
    struct OUTPUT {
        var goKakaoSignUp = PublishRelay<Bool>()
        var isNicknameValid = PublishRelay<Bool>()
        var genderValid: Driver<Gender> = PublishRelay<Gender>().asDriver(onErrorJustReturn: .none)
        var isEmailValid = PublishRelay<Bool>()
        //MARK: LoginBasicInfoVC Button
        var buttonValid:Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
        var mainRegionUpdate = PublishRelay<[MainRegion]>()
        var subRegionUpdate = PublishRelay<[SubRegion]>()
        var createRegionButton = PublishRelay<String>()
        var regionButtonValid: Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
        var interestingNameOutput = PublishRelay<[MainInterest]>()
        var forUserInterestOutput = PublishRelay<[Int]>()
//        var interestButtonValid = PublishRelay<Bool>()
        var interestButtonValid: Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
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
        
        input.forUserInterestObserver
            .subscribe(onNext: { id in
                if (self.user.category.contains(id)) {
                    print("중복된 값")
                } else {
                    self.user.category.append(id)
                    print("중복 전 \(self.user.category)")
                }
            }).disposed(by: disposeBag)
        
//        input.interestButtonTapped
//            .subscribe(onNext: {
//                if(self.user.category.count > 0) {
//                    print("asdkjalksdjl")
//                    self.output.interestButtonValid.accept(true)
//                } else {
//                    print("펄스펄스")
//                    self.output.interestButtonValid.accept(false)
//                }
//            }).disposed(by: disposeBag)
                        
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
        
        input.subRegionTapped
//            .distinctUntilChanged()
            .debounce(RxTimeInterval.microseconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: { indexPath in
                if((indexPath == 0) || (indexPath == 100) || (indexPath == 200)) {
                    self.output.createRegionButton.accept("\(self.subRegion[indexPath].name)")
                    for i in indexPath+1...(indexPath + self.subRegion.count) {
                        self.user.region.append(self.subRegion[i-indexPath-1].id)
                    }
                } else {
                    self.output.createRegionButton.accept("\(self.mainRegion[self.subRegion[indexPath].id / 100].name) " + "\(self.subRegion[indexPath].name)")
                }
                
                if (self.user.region.contains(self.subRegion[indexPath].id)) {
                    self.output.errorValue.accept(viewModelError.alreadyExistElement)
                } else {
                    self.user.region.append(self.subRegion[indexPath].id)
                    print("viewmodel \(self.user.region)")
                }
            }).disposed(by: disposeBag)
        
        output.regionButtonValid = output.createRegionButton
            .map { !$0.contains("👀") }
            .asDriver(onErrorJustReturn: false)
        
        output.interestButtonValid = input.interestButtonTapped
            .map { _ in
                if(self.user.category.count > 0) {
                    print("dlaklsdjlaksdjlaksjdlaks")
                    return true
                } else {
                    print("akjsdlakjsdlakj")
                    return false }
            }
            .asDriver(onErrorJustReturn: false)
   
        
    }
    
    ///유저 정보 입력받기 전 kakao api server에서 accesstoken get
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
//                                    observer.onNext(true) //MARK: TEST 중복 아닐 때
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
    
    func getMainRegionDataToTableView() {
        let url = "https://dev.finpo.kr/region/name"
        
        DispatchQueue.main.async {
            AF.request(url).responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    do {
                        // 반환값을 Data 타입으로 전환
                        let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                        var json = try JSONDecoder().decode(MainRegionAPIResponse.self, from: jsonData)
                                                
                        for _ in 0..<json.data.count {
                            json.data.sort {
                                $0.id < $1.id
                            }
                        }
                        self.mainRegion = json.data
                        self.output.mainRegionUpdate.accept(self.mainRegion)
                    } catch(let err) {
                        print(err.localizedDescription)
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }

    }
    
    func getSubRegionDataToTableView(_ parentId: Int = 0) {
        let searchMainRegionNum = (parentId % 100) * 100
        let url = "https://dev.finpo.kr/region/name?parentId=\(searchMainRegionNum)"

        DispatchQueue.main.async {
            AF.request(url).responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    do {
                        // 반환값을 Data 타입으로 전환
//                        let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                        let jsonData = try JSONSerialization.data(withJSONObject: res, options: [])
                        var json = try JSONDecoder().decode(SubRegionAPIRsponse.self, from: jsonData)
                        json.data.append(SubRegion(id: parentId, name: "\(self.mainRegion[parentId].name) 전체"))
                        for _ in 0..<json.data.count {
                            json.data.sort {
                                $0.id < $1.id
                            }
                        }
                        self.subRegion = json.data                        
                        self.output.subRegionUpdate.accept(self.subRegion)
                    } catch(let err) {
                        print(err.localizedDescription)
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }

    }
    
    func getInterestCVMenuData() {
        let url = "https://dev.finpo.kr/policy/category/name"

        DispatchQueue.main.async {
            AF.request(url).responseJSON { (response) in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        var json = try JSONDecoder().decode(InterestingAPIResponse.self, from: jsonData)
                        for _ in 0..<json.data.count {
                            json.data.sort {
                                $0.id < $1.id
                            }
                        }
                        self.interested = json.data //[(id: 1, name: "일자리"), (id:2,...)
                        self.output.interestingNameOutput.accept(self.interested)
                    } catch(let err) {
                        print(err.localizedDescription)
                        self.output.errorValue.accept(err)
                    }
                case .failure(let error):
                    print(error)
                    self.output.errorValue.accept(error)
                }
            }
        }
    }
    
    
    
}

enum viewModelError: Error {
    case alreadyExistElement
}
