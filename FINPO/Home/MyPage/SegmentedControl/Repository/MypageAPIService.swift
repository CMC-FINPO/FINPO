//
//  MypageAPIService.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/09.
//

import Foundation
import RxSwift
import Alamofire

class MypageAPIService {
    static func fetchMywritingRx(_ page: Int) -> Observable<Data> {
        return Observable.create { observer in
            fetchMywriting(page) { result in
                switch result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let err):
                    observer.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
//    static func fetchMywriting(_ page: Int, onComplete: @escaping (Result<CommunityboardResponseModel, Error>) -> Void) {
//        let url = BaseURL.url.appending("post/me?page=\(page)&size=5&sort=id,desc")
//        let header = ApiManager.createHeader(token: KeyChain.read(key: KeyChain.accessToken)!)
//        API.session.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor(), requestModifier: nil)
//            .responseDecodable(of: CommunityboardResponseModel.self) { result in
//                switch result.value {
//                case .some(let data):
//                    onComplete(.success(data))
//                case .none:
//                    break
//                }
//            }
//    }
    
    static func fetchMywriting(_ page: Int, onComplete: @escaping (Result<Data, Error>) -> Void) {
        let url = BaseURL.url.appending("post/me?page=\(page)&size=5&sort=id,desc")
        let header = ApiManager.createHeader(token: KeyChain.read(key: KeyChain.accessToken)!)
        API.session.request(url, method: .get, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
            .response { data in
                switch data.result {
                case .success(let data):
                    onComplete(.success(data ?? Data()))
                case .failure(let err):
                    onComplete(.failure(err))
                }
            }
    }
    
    static func fetchMyCommentingRx(_ page: Int) -> Observable<Data> {
        return Observable.create { observer in
            fetchMyCommenting(page) { result in
                switch result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let err):
                    observer.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
    static func fetchMyCommenting(_ page: Int, onComplete: @escaping (Result<Data, Error>) -> Void) {
        let url = BaseURL.url.appending("post/comment/me?page=\(page)&size=5&sort=id,desc")
        let header = ApiManager.createHeader(token: KeyChain.read(key: KeyChain.accessToken)!)
        API.session.request(url, method: .get, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
            .response { data in
                switch data.result {
                case .success(let data):
                    onComplete(.success(data ?? Data()))
                case .failure(let err):
                    onComplete(.failure(err))
                }
            }
    }
    
    static func fetchMyLikingRx(_ page: Int) -> Observable<Data> {
        return Observable.create { observer in
            fetchMyLiking(page) { result in
                switch result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let err):
                    observer.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
    static func fetchMyLiking(_ page: Int, onComplete: @escaping (Result<Data, Error>) -> Void) {
        let url = BaseURL.url.appending("post/like/me?page=\(page)&size=5&sort=id,desc")
        let header = ApiManager.createHeader(token: KeyChain.read(key: KeyChain.accessToken)!)
        API.session.request(url, method: .get, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
            .response { data in
                switch data.result {
                case .success(let data):
                    onComplete(.success(data ?? Data()))
                case .failure(let err):
                    onComplete(.failure(err))
                }
            }
    }
}
