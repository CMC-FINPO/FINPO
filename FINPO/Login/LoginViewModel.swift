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
import GoogleSignIn

//추가지역 선택 시 사용될 행위
enum RegionActionType {
    case add(region: UniouRegion)
    case delete(index: Int)
}

enum SocialLoginType {
    case kakao
    case google
    case apple
}

class LoginViewModel {
    
    let disposeBag = DisposeBag()
    var user = User.instance
    var mainRegion: [MainRegion] = [MainRegion](repeating: MainRegion.init(id: -1, name: "빈값"), count: 5)
    var subRegion: [SubRegion] = []
    var interested: [MainInterest] = []
    var unionRegion: [UniouRegion] = []
    var addedRegionCheck: [String] = []
    var purposeBag: [Int] = []
    static var isMainRegionSelected: Bool = false
    static var isInterestRegionSelected: Bool = false
    static var socialType: String = ""
    
    let input = INPUT()
    var output = OUTPUT()
    
    struct INPUT {
        let appleSignUpObserver = PublishRelay<Void>()
        let kakaoSignUpObserver = PublishRelay<Void>()
        let googleSignUpObserver = PublishRelay<GIDGoogleUser>()
        let nameObserver = PublishRelay<String>()
        let nickNameObserver = PublishRelay<String>()
        let birthObserver = PublishRelay<String>()
        let genderObserver = PublishRelay<Gender>()
        let emailObserver = PublishRelay<String>()
        let subRegionTapped = PublishRelay<Int>()
        let regeionButtonObserver = PublishRelay<Bool>()
        let forUserInterestObserver = PublishRelay<Int>() //유저의 상위 카테고리 저장 (탭 될때)
        let interestButtonTapped = PublishRelay<Void>()
        let semiSignupConfirmButtonTapped = PublishRelay<Void>()
        let deleteTagObserver = PublishRelay<Int>()
        let statusButtonTapped = PublishRelay<Int>()
        let purposeButtonTapped = PublishRelay<Bool>()
        let statusPurposeButtonTapped = PublishRelay<Void>()
    }
    
    struct OUTPUT {
        var goAppleSignUp = PublishRelay<Bool>()
        var goKakaoSignUp = PublishRelay<Bool>()
        var goGoogleSignUp = PublishRelay<Bool>()
        var isNameValid = PublishRelay<Bool>()
        var isNicknameValid = PublishRelay<Bool>()
        var genderValid: Driver<Gender> = PublishRelay<Gender>().asDriver(onErrorJustReturn: .none)
        var isEmailValid = PublishRelay<Bool>()
        //MARK: LoginBasicInfoVC Button
        var buttonValid:Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
        var mainRegionUpdate = PublishRelay<[MainRegion]>()
        var subRegionUpdate = PublishRelay<[SubRegion]>()
//        var createRegionButton = PublishRelay<String>()
//        var createRegionButton = PublishRelay<UniouRegion>()
        var regionButton = PublishRelay<RegionActionType>()
        var unionedReion = PublishRelay<[UniouRegion]>()
        var regionButtonValid: Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
        var interestingNameOutput = PublishRelay<[MainInterest]>()
        var forUserInterestOutput = PublishRelay<[Int]>()
//        var interestButtonValid = PublishRelay<Bool>()
        var interestButtonValid: Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)
//        var isSemiSignupComplete = PublishRelay<Bool>()
        var isSemiSignupComplete = PublishRelay<User>()
        var getStatus = PublishRelay<[UserStatus]>()
        var getPurpose = PublishRelay<[UserPurpose]>()
        var statusPurposeButtonValid: Driver<Bool> = PublishRelay<Bool>().asDriver(onErrorJustReturn: false)

        var errorValue = PublishRelay<Error>()
    }
    
    init() {        
        ///INPUT
        
        input.appleSignUpObserver
            .subscribe(onNext: { [weak self] in
                self?.output.goAppleSignUp.accept(true)
            }).disposed(by: disposeBag)
        
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
        
        input.googleSignUpObserver
            .flatMap { user in self.googleLogin(user: user) }
            .subscribe({ valid in
                switch valid {
                case .next(let validation):
                    print("구글 로그인 성공 시")
                    self.output.goGoogleSignUp.accept(validation)
                case .completed:
                    break
                case .error(let error):
                    self.output.errorValue.accept(error)
                }
            }).disposed(by: disposeBag)
        
        input.nameObserver.subscribe(onNext: { name in
            if(name.count > 14) {
                self.output.isNameValid.accept(false)
            } else {
                self.output.isNameValid.accept(true)
                self.user.name = name
            }
        }).disposed(by: disposeBag)
        
        input.nickNameObserver.subscribe(onNext: { nickName in
            print("닉네임 옵저버에 저장됨")
            self.user.nickname = nickName
            print("저장된 닉네임: \(self.user.nickname)")
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
        
        input.deleteTagObserver
            .subscribe(onNext: {
                [weak self] indexPath in
                self?.output.regionButton.accept(.delete(index: indexPath))
                self?.user.interestRegion.remove(at: indexPath)
                print("삭제 후 갱신된 추가 관심지역 리스트: \(self?.user.interestRegion)")
            }).disposed(by: disposeBag)
        
        input.statusButtonTapped
            .subscribe(onNext: { [weak self] int in
                self?.user.status = int
            }).disposed(by: disposeBag)
        
        input.statusPurposeButtonTapped
            .flatMap { self.setStatusPurposeToUser() }
            .subscribe(onNext: { _ in
                print("유저 현재 상태 업데이트 성공!")
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
        
        input.subRegionTapped
//            .distinctUntilChanged()
            .debounce(RxTimeInterval.microseconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: { indexPath in
                //전체 지역 선택 시
                if((indexPath == 0) || (indexPath == 100) || (indexPath == 200)) {
                    for i in indexPath+1...(indexPath + self.subRegion.count) {
                        self.user.region.append(self.subRegion[i-indexPath-1].id)
                    }
                    let union = UniouRegion.init(unionRegionName: "\(self.subRegion[indexPath].name)")
                    self.output.unionedReion.accept([union])
                    self.output.regionButton.accept(.add(region: union))
                }
                //구 선택 시
                else {
                    let union = UniouRegion.init(unionRegionName: "\(self.mainRegion[self.subRegion[indexPath].id / 100].name) " + "\(self.subRegion[indexPath].name)")
                    //메인 거주 지역
                    self.output.unionedReion.accept([union])
                    //추가 관심 지역
                    self.output.regionButton.accept(.add(region: union))
                }
                
                //추가 관심지역
                if(self.user.interestRegion.contains(self.subRegion[indexPath].id)) {
                    self.output.errorValue.accept(viewModelError.alreadyExistAccount)
                } else if(self.user.region.count >= 1) {
                    self.user.interestRegion.append(self.subRegion[indexPath].id)
                }
                
                //main 거주지역
                if (self.user.region.contains(self.subRegion[indexPath].id)) {
                    self.output.errorValue.accept(viewModelError.alreadyExistElement)
                } else if(!LoginViewModel.isMainRegionSelected) {
                    self.user.region.append(self.subRegion[indexPath].id)
                    LoginViewModel.isMainRegionSelected = true
                    print("viewmodel user selected region \(self.user.region)")
                }

            }).disposed(by: disposeBag)
        
        output.regionButtonValid = input.regeionButtonObserver
            .map { $0 }
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
        
        output.statusPurposeButtonValid = Driver.combineLatest(
            input.statusButtonTapped.asDriver(onErrorJustReturn: 0),
            input.purposeButtonTapped.asDriver(onErrorJustReturn: false),
            resultSelector: { status, purpose  in
                if(status != 0 && purpose != false) {
                    return true
                } else { return false }
            })
            
        
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
                                UserDefaults.standard.setValue("kakao", forKey: "socialType")
                                LoginViewModel.socialType = "kakao"
                                //TODO: get data using accessToken, refreshToken check here
//                                PredictAPI.predictWithAuth()
                                observer.onNext(true)
                            }
                        }
                        //소셜 액세스 토큰
                        self.user.accessTokenFromSocial = oauthToken.accessToken
                        
                        print("카카오 엑세스 토큰 from kakao api server: \(self.user.accessTokenFromSocial)")
                    }, onError: { (error) in
                        print("error occured: \(error)")
                        observer.onError(error)
                    }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    private func googleLogin(user: GIDGoogleUser) -> Observable<Bool> {
        return Observable.create { observer in
            user.authentication.do { authentication, error in
                guard error == nil else { return }
                guard let authentication = authentication else { return }
                //소셜 액세스 토큰
                self.user.accessTokenFromSocial = authentication.accessToken
                
                self.user.profileImg = user.profile?.imageURL(withDimension: 200)
                
                self.input.nickNameObserver.accept(user.profile?.name ?? "")
                print("구글 유저 이름: \(user.profile?.name ?? "")")
                UserDefaults.standard.setValue("google", forKey: "socialType")
                LoginViewModel.socialType = "google"
                print("구글 로그인 성공! 액세스 토큰: \(authentication.accessToken)")
                UserDefaults.standard.setValue(authentication.accessToken, forKey: "SocialAccessToken")
                observer.onNext(true)
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
            DispatchQueue.main.async {
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
            let socialType = UserDefaults.standard.string(forKey: "socialType") ?? ""
            let url = "https://dev.finpo.kr/oauth/register/".appending(socialType)
            print("소셜타입: \(socialType)")
            print(url)
            let parameter = self.user.toDic()
            print(parameter)
            let header: HTTPHeaders = [
                "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8;boundary=6o2knFse3p53ty9dmcQvWAIx1zInP11uCfbm",
                "Authorization":"Bearer ".appending((self.user.accessTokenFromSocial))
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
//                            let accessTokenExpiresIn = jsonData?["accessTokenExpiresIn"] as? Date
                            let accessTokenExpiresIn = jsonData?["accessTokenExpiresIn"] as? Int ?? Int()
                            print("accessTokenExpiresIn 값: \(accessTokenExpiresIn)")
                            let accessTokenExpireDate = Date(milliseconds: Int64(accessTokenExpiresIn) )
                            print("accessTokenExpireDate 값: \(accessTokenExpireDate)")
                            //accessTokenExpireDate 값: 1970-01-01 00:00:00 +0000
//                            let dateFormatter = DateFormatter()
                            
                            //API 액세스 토큰
                            self.user.accessToken = accessToken ?? ""
//                            self.user.accessTokenFromSocial = accessToken ?? ""//필요없을듯
                            self.user.refreshToken = refreshToken ?? ""//필요없을듯
                            UserDefaults.standard.set(self.user.accessToken, forKey: "accessToken")
                            UserDefaults.standard.set(self.user.refreshToken, forKey: "refreshToken")
                            UserDefaults.standard.set(accessTokenExpireDate, forKey: "accessTokenExpiresIn")
//                            _ = MyAuthenticationCredential(accessToken: accessToken ?? "", refreshToken: refreshToken ?? "", expiredAt: accessTokenExpiresIn ?? Date())
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
    
    func getStatus() {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        let url = "https://dev.finpo.kr/user/status/name"
        let header: HTTPHeaders = [
            "Content-Type": "application/json;charset=UTF-8",
            "Authorization":"Bearer ".appending(accessToken)
        ]
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: header)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let statusData):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: statusData, options: [])
                        var json = try JSONDecoder().decode(UserStatusAPIResponse.self, from: jsonData)
                        print("스태이터스 리스폰스 성공")
                        for _ in 0..<json.data.count {
                            json.data.sort {
                                $0.id < $1.id
                            }
                        }
                        self.output.getStatus.accept(json.data)
                    } catch(let err) {
                        print(err.localizedDescription)
                    }
                case .failure(let error):
                    self.output.errorValue.accept(error)
                }
            }
    }
    
    func getPurpose() {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        let url = "https://dev.finpo.kr/user/purpose/name"
        let header: HTTPHeaders = [
            "Content-Type": "application/json;charset=UTF-8",
            "Authorization":"Bearer ".appending(accessToken)
        ]
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let purposeData):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: purposeData, options: [])
                        var json = try JSONDecoder().decode(UserPurposeAPIResponse.self, from: jsonData)
                        print("유저 이용목적 리스폰스 성공")
                        for _ in 0..<json.data.count {
                            json.data.sort {
                                $0.id < $1.id
                            }
                        }
                        self.output.getPurpose.accept(json.data)
                    } catch (let err) {
                        print(err.localizedDescription)
                    }
                case .failure(let error):
                    self.output.errorValue.accept(error)
                }
            }
    }
    
    func setStatusPurposeToUser() -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let url = "https://dev.finpo.kr/user/me"
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            let parameter: Parameters = [
                "statusId": String(self.user.status),
                "purposeIds": self.purposeBag
            ]
            
            AF.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: header)
                .validate()
                .response { (response) in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["data"] as? [String: Any]
                                let statusId = result?["statusId"] as? Int
                                print("스테이터스 Id: \(statusId)")
                                self.user.status = statusId ?? Int()
                                print(self.user.status)
                                observer.onNext(true)
                            }
                        }
                    case .failure(let err):
                        observer.onError(err)
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
