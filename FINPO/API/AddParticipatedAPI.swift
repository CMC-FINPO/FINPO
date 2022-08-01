//
//  AddParticipatedAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/04.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

struct AddParticipatedAPI {
    static func addParticipationToAPI(id: Int, with memo: String?) -> Observable<Bool> {
        return Observable.create { observer in
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let urlStr = BaseURL.url.appending("policy/joined")
            
            let parameter: Parameters
            
            //리퀘스트 필드
            parameter = [
                "policyId": id
            ]
//            else {
//                parameter = [
//                    "policyId": id,
//                    "memo": memo
//                ]
//            }
            
            print("정책아이디와 메모: \(memo ?? "")")
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            API.session.request(urlStr,
                                method: .post,
                                parameters: parameter,
                                encoding: JSONEncoding.default,
                                headers: header,
                                interceptor: MyRequestInterceptor())
                .validate()
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                let data = json?["data"] as? [String: Any]
                                let participatedId = data?["id"] as? Int
//                                let memo = data?["memo"] as? String
                                print("참여 정책 등록 결과: \(result) 그리고 추가된 리스폰스 메모: \(data)")
                                HomeViewModel.participatedId = participatedId ?? -1
                                observer.onNext(result)
                            }
                        }
                    case .failure(let err):
                        print("에러 발생: \(err)")
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func addMemoToAPI(id: Int, with memo: String?) -> Observable<Bool> {
        return Observable.create { observer in
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let urlStr = BaseURL.url.appending("policy/joined/\(id)")
            
            let parameter: Parameters = [
                "memo": memo!
            ]
            
            print("정책아이디와 메모: \(memo ?? "")")
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            API.session.request(urlStr, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate()
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                print("메모 수정 결과: \(result)")
                                observer.onNext(result)
                            }
                        }
                    case .failure(let err):
                        print("에러 발생: \(err)")
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
 
}
