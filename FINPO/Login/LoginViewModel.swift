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
        let semiSignupConfirmButtonTapped = PublishRelay<Void>()
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
//        var isSemiSignupComplete = PublishRelay<Bool>()
        var isSemiSignupComplete = PublishRelay<User>()
        
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
            .flatMap { _ in self.checkNicknameValid() } //중복:true
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
        
//        input.emailObserver.subscribe(onNext: { email in
//            self.user.email = email
//        }).disposed(by: disposeBag)
        
        input.forUserInterestObserver
            .subscribe(onNext: { id in
                if (self.user.category.contains(id)) {
                    print("중복된 값")
                } else {
                    self.user.category.append(id)
                    print("중복 전 \(self.user.category)")
                }
            }).disposed(by: disposeBag)

                        
        ///OUTPUT
        output.genderValid = input.genderObserver.asDriver(onErrorJustReturn: .none)
        
//        input.emailObserver
//            .flatMap { self.checkEmail(email: $0)}
//            .observe(on: MainScheduler.asyncInstance)
//            .subscribe({ valid in
//                switch valid {
//                case .next(_ ):
//                    self.checkEmailValid().subscribe(onNext: { v in
//                        self.output.isEmailValid.accept(v)
//                    }).disposed(by: self.disposeBag)
//                case .completed:
//                    break
//                case .error(let error):
//                    self.output.errorValue.accept(error)
//                }
//            }).disposed(by: disposeBag)
                
        output.buttonValid = Driver.combineLatest(input.nameObserver.asDriver(onErrorRecover: { _ in return .never()}),
                                                  output.isNicknameValid.asDriver(onErrorJustReturn: false),
                                                  input.birthObserver.asDriver(onErrorJustReturn: "errorTest"),
                                                  input.genderObserver.asDriver(onErrorJustReturn: .none),
                                                  resultSelector: { (a, b, c, d) in
        if a != "" && b != true  && c != "" && d != .none {
                print("버튼 색 변경조건 완료 -> true 방출")
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
   
        input.semiSignupConfirmButtonTapped
            .flatMap { _ in self.semiSignup() }
            .subscribe( { valid in
                switch valid {
                case .next(let tr):
                    self.output.isSemiSignupComplete.accept(tr)
                case .error(let err):
                    self.output.errorValue.accept(err)
                case .completed:
                    break
                }
            }).disposed(by: disposeBag)
        
        
    }
    
    ///유저 정보 입력받기 전 kakao api server에서 accesstoken get
    private func kakaoLogin() -> Observable<Bool> {
        return Observable.create { observer in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .subscribe(onNext: { (oauthToken) in
                        print("loginWithKakaoTalk() success.")
                        UserApi.shared.me { user, error in
                            if let error = error {
                                self.output.errorValue.accept(error)
                            } else { ///회원정보 가져오기 성공 시
                                self.input.nickNameObserver.accept(user?.kakaoAccount?.profile?.nickname ?? "")
                                self.user.profileImg = user?.kakaoAccount?.profile?.profileImageUrl
                                observer.onNext(true)
                            }
                        }
                        self.user.accessTokenFromKAKAO = oauthToken.accessToken
                    
                        print("카카오 엑세스 토큰 from kakao api server: \(self.user.accessTokenFromKAKAO)")
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
                                    print("중복된 닉네임")
                                    observer.onNext(true)
                                } else {
                                    print("중복되지 않은 닉네임")
                                    observer.onNext(false)
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
    
//    private func checkEmail(email: String) -> Observable<Bool> {
//        return Observable.create { observer in
//            if (!email.isEmpty && email.contains("@") && email.contains(".")) {
//                observer.onNext(true)
//            }
//            else {
//                observer.onCompleted()
//            }
//
//            return Disposables.create()
//        }
//    }
    
//    private func checkEmailValid() -> Observable<Bool> {
//        return Observable.create { observer in
//
//            let url = "https://dev.finpo.kr/user/check-duplicate?email=\(self.user.email)"
//
//            let parameter: Parameters = [
//                "email": self.user.email
//            ]
//            let header: HTTPHeaders = [
//                "Content-Type": "application/json;charset=UTF-8"
//            ]
//
//            AF.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header)
//                .validate(statusCode: 200..<300)
//                .response { response in
//                    switch response.result {
//                    case .success(let data):
//                        if let data = data {
//                            do {
//                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                                let result = json?["data"] as? Bool ?? false
//                                print(self.user.email)
//                                print("email check api 성공, 이메일 겹침여부 \(result)!")
//                                if result == true { //중복일 때
//                                    observer.onNext(true)
//
//                                } else {
//                                    observer.onNext(false) //중복 아닐 때
////                                    observer.onNext(true) //MARK: TEST 중복 아닐 때
//                                }
//
//                            }
//                        }
//                    case .failure(let error):
//                        print("email Valite 에러발생!!!: \(error)")
//                        observer.onError(error)
//                    }
//                }
//            return Disposables.create()
//        }
//
//    }
    
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
    
    func semiSignup() -> Observable<User> {
        return Observable.create { observer in
            let url = "https://dev.finpo.kr/oauth/register/kakao"
            let parameter = self.user.toDic()
            let header: HTTPHeaders = [
                "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8;boundary=6o2knFse3p53ty9dmcQvWAIx1zInP11uCfbm",
                "Authorization":"Bearer ".appending((self.user.accessTokenFromKAKAO))
            ]
            
            AF.upload(multipartFormData: { (multipart) in
                for (key, value) in parameter {
                    multipart.append("\(value)".data(using: .utf8, allowLossyConversion: false)!, withName: "\(key)")
                    print("multipart 데이터 추가 됨")
                }
            }, to: url, method: .post, headers: header).responseJSON {
                (response) in
                guard let statusCode = response.response?.statusCode else {
                    print("status code is not valid")
                    return
                }
                print("스태이터스 코드: \(statusCode)")
                switch statusCode {
                case 200..<299:
                    print("회원정보 등록 진행 중(이게 보인다고 반드시 성공은 아니며, 중복인 경우가 포함)")
                    do {
                        let json = try response.result.get() as? [String: Any]
                        let errorCode = json?["errorCode"] as? Int ?? 0
                        if (errorCode == 20002) {
                            print("이미 등록된 회원입니다.")
                            observer.onError(viewModelError.alreadyExistAccount)
                        } else {
                            let jsonData = json?["data"] as? [String: Any]
                            let accessToken = jsonData?["accessToken"] as? String
                            let refreshToken = jsonData?["refreshToken"] as? String
                            self.user.accessTokenFromKAKAO = accessToken ?? ""
                            self.user.refreshToken = refreshToken ?? ""
                            observer.onNext(self.user)
                        }
                    } catch { print("알 수 없는 에러 발생") }
                    
                default:
                    print("실패!!: \(response.error)")
                    observer.onError(viewModelError.alreadyExistElement)
                }
            }
            return Disposables.create()
        }
    }
    
    
}

enum viewModelError: Error {
    case alreadyExistElement
    case alreadyExistAccount
}
