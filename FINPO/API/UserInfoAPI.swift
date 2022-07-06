//
//  UserInfoAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/06.
//

import Foundation
import Alamofire
import RxSwift

struct UserInfoAPI {
    static func getUserInfo() -> Observable<UserDataModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("region/me")
            
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
                            let json = try JSONDecoder().decode(UserDataModel.self, from: jsonData)
                            print("내 거주지역, 관심지역 정보 가져오기 성공!")
                            observer.onNext(json)
                        } catch(let error) {
                            print("내 지역 가져오기 실패: \(error)")
                        }
                    case .failure(let error):
                        print("내 지역 가져오기 실패: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func saveInterestRegion(interestRegionId: [Int]) -> Observable<Bool> {
        return Observable.create { observer in
            
            let urlStr = BaseURL.url.appending("region/me")
            let url = URL(string: urlStr)
            var request = URLRequest(url: url!)
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            request.httpBody = try! JSONSerialization.data(withJSONObject: interestRegionId.map({["regionId":$0]}))
            
            API.session.request(request, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                print("관심지역 수정 결과: \(result)")
                            } 
                        }
                    case .failure(let err):
                        print("관심지역 수정 에러발생: \(err)")
                    }
                }
            
            return Disposables.create()
        }
    }
}
