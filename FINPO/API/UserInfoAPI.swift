//
//  UserInfoAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/06.
//

import Foundation
import Alamofire
import RxSwift

struct UserInfoAPI {
    static func getUserInfo() -> Observable<UserDataModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("region/me")
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(UserDataModel.self, from: jsonData)
                            print("내 거주지역, 관심지역 정보 가져오기 성공!")
                            observer.onNext(json)
                        } catch(let error) {
                            print("내 지역 가져오기 실패: \(error)")
                        }
                    case .failure(let error):
                        print("내 지역 가져오기 실패: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func saveInterestRegion(interestRegionId: [Int]) -> Observable<Bool> {
        return Observable.create { observer in
            
            let urlStr = BaseURL.url.appending("region/me")
            let url = URL(string: urlStr)
            var request = URLRequest(url: url!)
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            request.httpBody = try! JSONSerialization.data(withJSONObject: interestRegionId.map({["regionId":$0]}))
            
            AF.request(request, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                print("관심지역 수정 결과: \(result)")
                            } 
                        }
                    case .failure(let err):
                        print("관심지역 수정 에러발생: \(err)")
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func setMainRegion(mainRegionId: Int) -> Observable<Bool> {
        return Observable.create { observer in
            
            let urlStr = BaseURL.url.appending("region/my-default")
            let url = URL(string: urlStr)
            var request = URLRequest(url: url!)
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let parameter: Parameters = [
                "regionId": mainRegionId
            ]
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameter)
            
            AF.request(request, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                print("메인지역 수정 결과: \(result)")
                            }
                        }
                    case .failure(let err):
                        print("메인지역 수정 에러발생: \(err)")
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func getUserParticipatedInfo() -> Observable<UserParticipatedModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("policy/joined/me")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(UserParticipatedModel.self, from: jsonData)
                            print("유저 참여정책 데이터 GET!")
                            observer.onNext(json)
                        } catch(let error) {
                            print("내 참여정책 가져오기 실패: \(error)")
                        }
                    case .failure(let error):
                        print("내 참여정책 가져오기 실패: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func getUserInterestedInfo() -> Observable<UserParticipatedModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("policy/interest/me")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(UserParticipatedModel.self, from: jsonData)
                            print("유저 관심정책 데이터 GET!")
                            observer.onNext(json)
                        } catch(let error) {
                            print("내 관심정책 가져오기 실패: \(error)")
                        }
                    case .failure(let error):
                        print("내 관심정책 가져오기 실패: \(error)")
                        observer.onError(error)
                    }
                }
            
            
            return Disposables.create()
        }
    }
    
    static func getMyCategory() -> Observable<MyCategoryModel> {
        return Observable.create { observer in
                        
            let url = BaseURL.url.appending("policy/category/me/parent")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            DispatchQueue.main.async {
                AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: MyCategoryModel.self) { response in
                        switch response.value {
                        case .some(let data):
                            print("가져온 관심 카테고리 데이터: \(data)")
                            observer.onNext(data)
                        case .none:
                            observer.onCompleted()
                        }
                    }
            }
                        
            return Disposables.create()
        }
    }
    
    static func getUserWholeInfo() -> Observable<UserResponseModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("user/me")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            API.session.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: UserResponseModel.self) { response in
                    switch response.result {
                    case .success(let userInfo):
                        observer.onNext(userInfo)
                    case .failure(let err):
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func checkNicknameValidation(nickName: String) -> Observable<Bool> {
        return Observable.create { observer in
            
            let encodedNickname = nickName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            let url = BaseURL.url.appending("user/check-duplicate?nickname=\(encodedNickname)")
            
            let parameter: Parameters = [
                "nickname": encodedNickname
            ]
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            API.session.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .response { response in
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
    
    static func saveEditedUserInfo(userInfo: User) -> Observable<Bool> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("user/me")
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            let parameter: Parameters = [
                "name": userInfo.name,
                "nickname": userInfo.nickname,
                "birth": userInfo.birth,
                "gender": userInfo.gender
            ]
            
            API.session.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                observer.onNext(result)
                            }
                        }
                    case .failure(let err):
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create()
        }
    }
}
