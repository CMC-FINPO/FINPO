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
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let url = BaseURL.url.appending("user/purpose/name")

            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            
            API.session.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
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
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let url = BaseURL.url.appending("user/me/purpose")
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization":"Bearer ".appending(accessToken)
            ]
            
            API.session.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
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
}
