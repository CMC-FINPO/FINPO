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
    
    static func searchPolicyAPI(title: String, at page: Int = 0, to categories: [Int], in region: [Int]) -> Observable<SearchPolicyResponse> {

        return Observable.create { observer in
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let urlStr = BaseURL.url.appending("policy/search?size=10&sort=title,asc&sort=modifiedAt,desc")
            
            let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

            let url = URL(string: encodedStr)!
            
            let stringRegion = region.map { String($0) }
                .joined(separator: ",")
            
            let stringCategory = categories.map { String($0) }
                .joined(separator: ",")
            
            //만약 타이틀이 빈값이면 설정한 거주지역을 넣기
            let parameter: Parameters
            if title == "" {
                parameter = [
                    "region": stringRegion,
                    "category": stringCategory,
                    "page": page
                ]
            } else {
                parameter = [
                    "region": region,
                    "category": categories,
                    "page": page,
                    "title": title
                ]
            }
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
             
            //URLEncoding(arrayEncoding: .noBrackets)
            API.session.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(SearchPolicyResponse.self, from: jsonData)
//                            print("가져온 데이터: \(json)")
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
    
    static func searchPolicyAsPopular(title: String, at page: Int = 0, to categories: [Int], in region: [Int]) -> Observable<SearchPolicyResponse> {
        
        let user = User.instance
        
        return Observable.create { observer in
//            if(title == "") {
//                return Disposables.create()
//            }
            let accessToken = UserDefaults.standard.string(forKey: "accessToken")!
            print("타이틀: \(title), 불러 올 페이지: \(page)")
            let urlStr = BaseURL.url.appending("policy/search?size=10&sort=countOfInterest,desc")
            
            let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

            let url = URL(string: encodedStr)!
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            let stringRegion = region.map { String($0) }
                .joined(separator: ",")
            
            let stringCategory = categories.map { String($0) }
                .joined(separator: ",")
            
            let parameter: Parameters
            //만약 타이틀이 빈값이면 설정한 거주지역을 넣기
            if title == "" {
                parameter = [
                    "region": stringRegion,
                    "category": stringCategory,
                    "page": page
                ]
            } else {
                parameter = [
                    "region": region,
                    "category": categories,
                    "page": page,
                    "title": title
                ]
            }
            
            AF.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(SearchPolicyResponse.self, from: jsonData)
                            print("인기순 정렬 API 데이터 리스폰스: \(json)")
                            observer.onNext(json)
                        } catch(let err) {
                            print("인기순 불러오기 실패!!!")
                            print(err)
                        }
                    case .failure(let err):
                        print("인기순 정렬 API 에러 발생: \(err.localizedDescription)")
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
}
