//
//  CallMyRegionAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/28.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

struct CallMyRegionAPI {
    static func callMyRegion() -> Observable<MyRegionList> {
        return Observable.create { observer in
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            let url = BaseURL.url.appending("region/me")
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(MyRegionList.self, from: jsonData)
                            observer.onNext(json)
                        } catch(let err) {
                            print("알수없는 에러: \(err)")
                        }
                    case .failure(let err):
                        print("에러발생: \(err)")
                        observer.onError(err)
                    }
                }
            return Disposables.create()
        }
        
    }
}
