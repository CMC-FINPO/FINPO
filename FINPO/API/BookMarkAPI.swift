//
//  BookMarkAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/05.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

struct BookMarkAPI {
    static func addBookmark(polidyId id: Int) -> Observable<Bool> {
        return Observable.create { observer in
            let url = BaseURL.url.appending("policy/interest")
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken")
            
            let header: HTTPHeaders = [
                "Content-Type":"application/json;charset=UTF-8",
                "Authorization":"Bearer ".appending(accessToken ?? "")
            ]
            
            let parameter: Parameters = [
                "policyId": id
            ]
            
            API.session.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                                as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                print("북마크 등록 결과: \(result)")
                                observer.onNext(result)
                            }
                        }
                    case .failure(let err):
                        print("북마크 등록 에러 발생: \(err)")
                        observer.onError(err)
                    }
                }

            return Disposables.create()
        }
    }
}
