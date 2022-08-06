//
//  MyPageViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/13.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

class MyPageViewModel {
    let disposeBag = DisposeBag()
    
    let user = User.instance
    let input = INPUT()
    var output = OUTPUT()
    
    ///참여 정책 조회 및 삭제 액션
    enum IsSearchModeOrDeleteModeAction {
        case searchMode(UserParticipatedModel)
        case deleteMode(UserParticipatedModel)
    }
    
    ///INPUT
    struct INPUT {
        let loadUserDataObserver = PublishRelay<Void>()
        let selectedProfileImageObserver = PublishRelay<UIImage>()

        ///거주지역 수정 후 뷰 pop
        let popViewObserver = PublishRelay<Bool>()
        
        ///참여 정책 조회 및 수정
        let getUserParticipatedInfo = PublishRelay<Void>()
        
        ///유저 관심사 부모카테고리
        let loadUserInterestedThingsObserver = PublishRelay<Void>()
        
        ///삭제 버튼 옵저버 -> 참여 정책 조회하기
        let changeToDeleteMode = PublishRelay<Void>()
        let returnOriginalMode = PublishRelay<Void>()
        ///삭제 옵저버
        let participatedPolicyDeleteObserver = PublishRelay<Int>()
        
        var bookmarkObserver = PublishRelay<Int>()
        let bookmarkDeleteObserver = PublishRelay<Int>()
    }
        
    ///OUTPUT
    struct OUTPUT {
        var getUserData = PublishRelay<User>()
        var updateProfileImage = PublishRelay<String>()
        
        //거주지역 수정 후 뷰 pop
        var popViewOutput = PublishRelay<Bool>()
        
        ///참여 정책 조회 및 수정
//        var sendUserParticipatedInfo = PublishRelay<UserParticipatedModel>()
        var sendUserParticipatedInfo = PublishRelay<IsSearchModeOrDeleteModeAction>()
        
        ///유저 관심사 부모 카테고리 방출
        var sendUserInterestedThings = PublishRelay<MyCategoryModel>()
    }
    
    init() {
        input.loadUserDataObserver
            .flatMap { self.getProfileInfo() }
            .subscribe(onNext: { value in
                self.output.getUserData.accept(value)
            }).disposed(by: disposeBag)
        
        input.selectedProfileImageObserver
            .flatMap { self.updateProfileImage($0) }
            .subscribe(onNext: { profileURLStr in
                self.output.updateProfileImage.accept(profileURLStr)
            }).disposed(by: disposeBag)
        
        input.popViewObserver
            .subscribe(onNext: { valid in
                if valid {
                    self.output.popViewOutput.accept(valid)
                }
            }).disposed(by: disposeBag)
        
        ///여기서 참여 정책 컬렉션뷰에 초기 뿌려줌
        input.getUserParticipatedInfo
            .flatMap { UserInfoAPI.getUserParticipatedInfo() }
            .subscribe(onNext: { participatedInfo in
//                self.output.sendUserParticipatedInfo.accept(participatedInfo)
                self.output.sendUserParticipatedInfo.accept(.searchMode(participatedInfo))
            }).disposed(by: disposeBag)
        
        input.changeToDeleteMode
            .flatMap { UserInfoAPI.getUserParticipatedInfo() }
            .subscribe(onNext: { changeAndSendParticipatedInfo in
                ParticipationViewController.regionLabelLength.removeAll()
                for i in 0..<(changeAndSendParticipatedInfo.data.count) {
                    let str = changeAndSendParticipatedInfo.data[i].policy.region.parent?.name ?? "" + " " + changeAndSendParticipatedInfo.data[i].policy.region.name
                    ParticipationViewController.regionLabelLength.append(str)
                }
                self.output.sendUserParticipatedInfo.accept(.deleteMode(changeAndSendParticipatedInfo))
            }).disposed(by: disposeBag)
        
        input.returnOriginalMode
            .flatMap { UserInfoAPI.getUserParticipatedInfo() }
            .subscribe(onNext: { changeAndSendParticipatedInfo in
                self.output.sendUserParticipatedInfo.accept(.searchMode(changeAndSendParticipatedInfo))
            }).disposed(by: disposeBag)
        
        ///북마크 등록/삭제 여부에 따른 옵저버 방출
        input.bookmarkObserver
            .flatMap { BookMarkAPI.addBookmark(polidyId: $0) } //북마크 추가 API
            .subscribe(onNext: { valid in
                self.input.getUserParticipatedInfo.accept(())
            }).disposed(by: disposeBag)
        
        ///북마크 삭제
        input.bookmarkDeleteObserver
            .flatMap { BookMarkAPI.deleteBookmark(polidyId: $0) }
            .subscribe(onNext: { valid in
                self.input.getUserParticipatedInfo.accept(())
            }).disposed(by: disposeBag)
        
        ///참여 정책 삭제
        input.participatedPolicyDeleteObserver
            .flatMap { DeleteParticipationAPI.deletePolicy(id: $0) }
            .flatMap { _ in UserInfoAPI.getUserParticipatedInfo() }
            .subscribe(onNext: { participatedInfo in
                self.output.sendUserParticipatedInfo.accept(.deleteMode(participatedInfo))
            }).disposed(by: disposeBag)
        
        //유저 관심사 방출
        input.loadUserInterestedThingsObserver
            .flatMap { UserInfoAPI.getMyCategory() }
            .subscribe(onNext: { categories in
                for i in 0..<categories.data.count {
                    MyPageViewController.interestThingsString.append(categories.data[i].name)
                }
                self.output.sendUserInterestedThings.accept(categories)
            }).disposed(by: disposeBag)
        
    }
    
    func getProfileInfo() -> Observable<User> {
        return Observable.create { observer in
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            let url = BaseURL.url.appending("user/me")
            let header: HTTPHeaders = [
                "Content-Type":"application/json;charset=UTF-8",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header, interceptor: MyRequestInterceptor(), requestModifier: nil)
                .validate()
                .response { (response) in
                switch response.result {
                case .success(let userData):
                    if let userData = userData {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: userData, options: []) as? [String: Any]
                            let result = json?["data"] as? [String: Any] ?? [:]
                            let nickName = result["nickname"] as? String ?? ""
                            let name = result["name"] as? String ?? ""
                            let birth = result["birth"] as? String ?? ""
                            let gender = result["gender"] as? String ?? ""
                            let profileImageURL = result["profileImg"] as? String ?? ""
                            self.user.nickname = nickName
                            self.user.name = name
                            self.user.birth = birth
                            self.user.gender = gender
                            self.user.profileImg = URL(string: profileImageURL)
                            
                            print("서버에서 불러온 유저정보: \(self.user.nickname)")
                            print("서버에서 불러온 유저정보: \(self.user.name)")
                            print("서버에서 불러온 유저정보: \(self.user.birth)")
                            print("서버에서 불러온 유저정보: \(self.user.gender)")
                            print("서버에서 불러온 유저정보: \(self.user.profileImg)")
                            observer.onNext(self.user)
                        }
                    }
                case .failure(let error):
                    print("에러 발생!: \(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func updateProfileImage(_ image: UIImage) -> Observable<String> {
        return Observable.create { observer in
            let imageData = image.jpegData(compressionQuality: 1)!
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            let url = BaseURL.url.appending("user/me/profile-img")
            let header: HTTPHeaders = [
                "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8; boundary=6o2knFse3p53ty9dmcQvWAIx1zInP11uCfbm",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            
            AF.upload(multipartFormData: { multipart in
                multipart.append(imageData, withName: "profileImgFile", fileName: "editedProfileImage.jpeg", mimeType: "image/jpeg")
            }, to: url , headers: header, interceptor: MyRequestInterceptor())
            .responseJSON { (response) in
                guard let statusCode = response.response?.statusCode else { return }
                switch statusCode {
                case 200..<299:
                    do {
                        let json = try response.result.get() as? [String: Any]
                        print("성공 시 제이슨: \(json)")
                        let jsonData = json?["data"] as? [String: Any] ?? [:]
                        let profileURLString = jsonData["profileImg"] as? String ?? ""
                        print("성공시 profileurlString: \(profileURLString)")
                        observer.onNext(profileURLString)
                    } catch { print("알수없는 에러")}
                default:
                    print("실패!! \(response.error)")
                }
            }
            return Disposables.create()
        }
        
    }
}
