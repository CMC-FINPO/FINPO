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
    
    let user = User()
    let input = INPUT()
    var output = OUTPUT()
    
    ///INPUT
    struct INPUT {
        let loadUserDataObserver = PublishRelay<Void>()
        let selectedProfileImageObserver = PublishRelay<UIImage>()
    }
        
    ///OUTPUT
    struct OUTPUT {
        var getUserData = PublishRelay<User>()
        var updateProfileImage = PublishRelay<String>()
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
        
    }
    
    func getProfileInfo() -> Observable<User> {
        return Observable.create { observer in
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let url = "https://dev.finpo.kr/user/me"
            let header: HTTPHeaders = [
                "Content-Type":"application/json;charset=UTF-8",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header, interceptor: nil, requestModifier: nil).response { (response) in
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
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let url = "https://dev.finpo.kr/user/me/profile-img"
            let header: HTTPHeaders = [
                "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8; boundary=6o2knFse3p53ty9dmcQvWAIx1zInP11uCfbm",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            
            AF.upload(multipartFormData: { multipart in
                multipart.append(imageData, withName: "profileImgFile", fileName: "\(self.user.nickname).jpeg", mimeType: "image/jpeg")
            }, to: url , headers: header)
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
