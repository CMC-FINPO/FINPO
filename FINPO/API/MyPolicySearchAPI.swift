//
//  MyPolicySearchAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/05.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

struct MyPolicySearchAPI {
    //최신순 정렬
    static func searchMyPolicy(at page: Int = 0) -> Observable<SearchPolicyResponse> {
        return Observable.create { observer in
            
            let urlStr = BaseURL.url.appending("policy/me?&sort=id,desc")
            let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL(string: encodedStr)!
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            let parameter: Parameters = [
                "page": page,
                "size": 5
            ]
            
            AF.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(SearchPolicyResponse.self, from: jsonData)
                            observer.onNext(json)
                        } catch(let err) {
                            print(err)
                        }
                    case .failure(let err):
                        print(err)
                        observer.onError(err)
                    }
                }
            
            
            return Disposables.create()
        }
    }
    
    //인기순 정렬
    static func searchMyPolicyAsPopular(at page: Int = 0) -> Observable<SearchPolicyResponse> {
        return Observable.create { observer in
            
            let urlStr = BaseURL.url.appending("policy/me?size=10&sort=title,asc&sort=countOfInterest,desc")
            let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL(string: encodedStr)!
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            let parameter: Parameters = [
                "page": page
            ]
            
            AF.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(SearchPolicyResponse.self, from: jsonData)
                            observer.onNext(json)
                        } catch(let err) {
                            print(err)
                        }
                    case .failure(let err):
                        print(err)
                        observer.onError(err)
                    }
                }
            
            
            return Disposables.create()
        }
    }
}
