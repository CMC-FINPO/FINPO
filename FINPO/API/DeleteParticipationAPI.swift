//
//  DeleteParticipationAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/18.
//

import Foundation
import Alamofire
import RxSwift

struct DeleteParticipationAPI {
    static func deletePolicy(id: Int) -> Observable<Bool> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("policy/joined/\(id)")
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                print("참여 정책 삭제 결과: \(result)")
                                observer.onNext(result)
                            }
                        }
                    case .failure(let err):
                        print("참여 정책 삭제 에러 발생: \(err)")
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
}
