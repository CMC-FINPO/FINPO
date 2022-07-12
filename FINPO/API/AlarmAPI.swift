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
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(AlarmModel.self, from: jsonData)
                            observer.onNext(json)
                        } catch(let err) {
                            print("알림 데이터 가져오기 실패!: \(err)")
                        }
                    case .failure(let err):
                        print("에러 발생!!: \(err)")
                        observer.onError(err)
                    }
                }
                
                
            return Disposables.create()
        }
    }
    
    static func deleteMyAlarm(policyId: Int) -> Observable<Bool> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("notification/history/\(policyId)")
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            API.session.request(url, method: .delete, parameters: nil, encoding: URLEncoding.queryString, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<600)
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try response.result.get() as? [String: Any]
                            print("제이슨 데이터: \(jsonData)")
                            let result = jsonData?["success"] as? Bool ?? false
                            print("알림 삭제 결과: \(result)")
                            observer.onNext(result)
                        } catch(let err) {
                            print("err occured: \(err)")
                        }
                        
                    case .failure(let err):
                        print("알림 삭제 실패 에러: \(err)")
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
}
