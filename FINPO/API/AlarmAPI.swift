//
//  AlarmAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/11.
//

import Foundation
import Alamofire
import RxSwift

struct AlarmAPI {
    static func getMyAlarmList() -> Observable<AlarmModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("notification/history/me?page=0&size=5&sort=id,desc")
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            API.session.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .responseDecodable(of: AlarmModel.self) { response in
                    switch response.value {
                    case .some(let data):
                        print("가져온 알람 데이터: \(data)")
                        observer.onNext(data)
                    case .none:
                        observer.onCompleted()
                    }
                }
                
            return Disposables.create()
        }
    }
}
