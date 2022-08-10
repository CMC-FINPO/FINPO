//
//  ForWhatAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/13.
//

import Foundation
import RxSwift
import Alamofire

struct ForWhatAPI {
    static func getAllForWhat() -> Observable<UserPurposeAPIResponse> {
        return Observable.create { observer in
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let url = BaseURL.url.appending("user/purpose/name")

            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: UserPurposeAPIResponse.self) { response in
                    switch response.result {
                    case .success(let forWhat):
                        observer.onNext(forWhat)
                    case .failure(let err):
                        print("이용목적 전체 조회 에러 발생: \(err)")
                        observer.onCompleted()
                    }
                }            
            
            return Disposables.create()
        }
    }
    
    ///내 이용목적 조회
    static func getMyAllForWhat() -> Observable<MyPurposeAPIResponse> {
        return Observable.create { observer in
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let url = BaseURL.url.appending("user/me/purpose")
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: MyPurposeAPIResponse.self) { response in
                    switch response.result {
                    case .success(let myPurpose):
                        observer.onNext(myPurpose)
                    case .failure(let err):
                        print("내 이용목적 가져오기 에러 발생: \(err)")
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func saveForWhat(forWhatIds: [Int]) -> Observable<Bool> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("user/me")
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            let parameter: Parameters = [
                "purposeIds": forWhatIds
            ]
            
            AF.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: UserResponseModel.self) { response in
                    switch response.result {
                    case .success(let user):
                        print("이용목적 등록완료! 리스폰스 유저 데이터: \(user)")
                        observer.onNext(true)
                    case .failure(let err):
                        observer.onError(err)
                    }
                }            
            
            return Disposables.create()
        }
    }
}
