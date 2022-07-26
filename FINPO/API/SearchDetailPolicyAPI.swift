//
//  SearchDetailPolicyAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/02.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

struct SearchDetailPolicyAPI {
    static func searchDetailPolicy(id: Int) -> Observable<DetailInfoModel> {
        return Observable.create { observer in
            let url = BaseURL.url.appending("policy/\(id)")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            API.session.request(url, method: .get, parameters: nil, encoding: URLEncoding(destination: .httpBody), headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(DetailInfoModel.self, from: jsonData)
                            observer.onNext(json)
                        } catch(let error) {
                            print("알 수 없는 에러발생: \(error)")
                        }
                    case .failure(let error):
                        print("에러 발생!!: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
}
