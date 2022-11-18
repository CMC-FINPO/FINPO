//
//  OpenAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/20.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

struct OpenAPI {
    static func getOpenSourceAPI() -> Observable<OpenAPIModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("information/open-api")
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: OpenAPIModel.self) { response in
                    switch response.result {
                    case .success(let apiData):
                        observer.onNext(apiData)
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
}
