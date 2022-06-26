//
//  SearchPolicyAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/22.
//

import Foundation
import Alamofire
import UIKit
import RxSwift
import RxCocoa

struct SearchPolicyAPI {
//    static func searchPolicyAPI(title: String, completion: @escaping (Result<SearchPolicyResponse, Error>) -> Void) {
//        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        let accessToken = UserDefaults.standard.string(forKey: "accessToken")!
//
//        let url = "https://dev.finpo.kr/policy/search?title=\(encodedTitle)"
//
//        let parameter: Parameters = [
//            "title": encodedTitle
//        ]
//
//        let header: HTTPHeaders = [
//            "Content-Type": "application/json;charset=UTF-8",
//            "Authorization": "Bearer ".appending(accessToken)
//        ]
//
//
//        AF.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header)
//            .validate()
//            .responseJSON { (response) in
//                switch response.result {
//                case .success(let data):
//                    do {
//                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//                        let json = try JSONDecoder().decode(SearchPolicyResponse.self, from: jsonData)
//                        print("정책 조회 제이슨 리스폰스!!!: \(json)")
//                        completion(.success(json))
//                    } catch(let err) {
//                        print(err.localizedDescription)
//                    }
//                case .failure(let err):
//                    print(err.localizedDescription)
//                    break
//                }
//            }
//    }
    
    static func searchPolicyAPI(title: String, at page: Int = 0) -> Observable<SearchPolicyResponse> {
        return Observable.create { observer in
            if(title == "") {
                return Disposables.create()
            }
            print("들어온 페이지 값: \(page)")
//            print("들어온 타이틀 값: \(title)")
            let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!
//            print("인코딩된 타이틀 값: \(encodedTitle)")
            let accessToken = UserDefaults.standard.string(forKey: "accessToken")!
            
//            let url = "https://dev.finpo.kr/policy/search?title=\(encodedTitle)&region=107,4,10,11,102,104&category=9,10,11&page=0&size=5&sort=title,asc&sort=modifiedAt,desc"
            let urlStr = "https://dev.finpo.kr/policy/search?title=\(title)&category=9,10,11&page=\(page)&size=10&sort=title,asc&sort=modifiedAt,desc"
            
//            let parameter: Parameters = [
//                "title": encodedTitle,
////                "region": [107,4,10,11,102,104],
//                "category": [9,10,11],
//                "page": 0,
//                "size": 5,
//                "sort": ["title,asc", "modifiedAt,desc"]
//            ]
            
            let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

            let url = URL(string: encodedStr)!
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            //%25EB%25B6%2580%25EC%2582%25B0. %EB%B6%80%EC%82%B0
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//                            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                            let json = try JSONDecoder().decode(SearchPolicyResponse.self, from: jsonData)
                            observer.onNext(json)
                        } catch(let err) {
                            print(err.localizedDescription)
                        }
                    case .failure(let err):
                        print(err.localizedDescription)
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
}
