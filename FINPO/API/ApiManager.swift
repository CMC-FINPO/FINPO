//
//  ApiManager.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/22.
//

import Foundation
import Alamofire
import RxSwift

struct ApiManager {
//    static func getData<T: Decodable>(with param: Encodable? = nil, from url: String, to model: NSDictionary?, completion: @escaping(_ data: T?, _ error: String?) -> ()) {
//
//    }
    
    static func createHeader(token: String) -> HTTPHeaders {
        let header: HTTPHeaders = [
            "Content-Type": "application/json;charset=UTF-8",
            "Authorization": "Bearer ".appending(token)
        ]
        return header
    }
    
    static func getData<T: Decodable>(with param: Encodable? = nil, from url: String, to model: Codable?, encoding: ParameterEncoding) -> Observable<T> {
        return Observable.create { observer in
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            let header = ApiManager.createHeader(token: accessToken)
            
            API.session.request(url, method: .get, parameters: param?.dictionary, encoding: encoding, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: T.self, completionHandler: { response in
                    switch response.value {
                    case .some(let models):
                        observer.onNext(models)
                    case .none:
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create()
        }
    }
    
    static func postData<T: Decodable>(with param: Encodable? = nil, from url: String, to model: T.Type, encoding: ParameterEncoding) -> Observable<T> {
        return Observable.create { observer in
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            let header = ApiManager.createHeader(token: accessToken)
            
            API.session.request(url, method: .post, parameters: param?.dictionary, encoding: encoding, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: model.self, completionHandler: { response in
                    switch response.value {
                    case .some(let models):
                        observer.onNext(models)
                    case .none:
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create()
        }
    }
    
    static func deleteData<T: Decodable>(with param: Encodable? = nil, from url: String, to model: T.Type, encoding: ParameterEncoding) -> Observable<T> {
        return Observable.create { observer in
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            let header = ApiManager.createHeader(token: accessToken)
            
            API.session.request(url, method: .delete, parameters: param?.dictionary, encoding: encoding, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: model.self, completionHandler: { response in
                    switch response.value {
                    case .some(let models):
                        observer.onNext(models)
                    case .none:
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create()
        }
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            print("Dictionary is nil")
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
