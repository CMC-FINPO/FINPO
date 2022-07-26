//
//  CallCategoryAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/30.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

struct CallCategoryAPI {
    static func callCategory() -> Observable<CategoryModel> {
        return Observable.create { observer in
            let url = BaseURL.url.appending("policy/category/name/child-format")
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate()
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let json = try JSONDecoder().decode(CategoryModel.self, from: jsonData)
                            observer.onNext(json)
                        } catch(let err) {
                            print("알 수 없는 에러: \(err)")
                        }
                    case .failure(let error):
                        print("에러 발생: \(error)")
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
    
    static func callInterestCategory() -> Observable<MyInterestCategoryModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("policy/category/me")
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: MyInterestCategoryModel.self) { response in
                    switch response.value {
                    case .some(let interestCategories):
                        print("가져온 관심 카테고리: \(interestCategories)")
                        observer.onNext(interestCategories)
                    case .none:
                        observer.onCompleted()
                    }
                }
            return Disposables.create()
        }
    }
    
    static func callChildCategory() -> Observable<LowCategoryModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("policy/category/name?depth=2")
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: LowCategoryModel.self) { response in
                    switch response.result {
                    case .success(let categories):
                        observer.onNext(categories)
                    case .failure(let err):
                        print("전체 하위 카테고리 가져오기 에러: \(err)")
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func saveCategory(at: [Int]) -> Observable<Bool> {
        return Observable.create { observer in
            
            let urlStr = BaseURL.url.appending("policy/category/me")
            let url = URL(string: urlStr)
            var request = URLRequest(url: url!)
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: at.map({["categoryId":$0]}), options: [])
            
            AF.request(request, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                observer.onNext(result)
                            }
                        }
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func getParentCategory() -> Observable<InterestingAPIResponse> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("policy/category/name")
            
            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: InterestingAPIResponse.self) { response in
                    switch response.result {
                    case .success(let parent):
                        observer.onNext(parent)
                    case .failure(let err):
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create()
        }
    }
}
