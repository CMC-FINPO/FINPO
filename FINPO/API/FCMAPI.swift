//
//  FCMAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/11.
//

import Foundation
import Alamofire
import RxSwift

struct FCMAPI {
    static func addFCMPermission() -> Observable<Bool> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("notification/me")
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            print("ddddd: \(LoginDetailViewController.isCMAllow)")
            let fcmToken = UserDefaults.standard.string(forKey: "fcmToken")
            let isPermissioned = UserDefaults.standard.bool(forKey: "FCMpermission")
            let parameter: Parameters = [
                "subscribe": isPermissioned,
                "registrationToken": fcmToken,
                "adSubscribe": LoginDetailViewController.isCMAllow
            ]
            
            API.session.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: header)
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["success"] as? Bool ?? false
                                print("전체 알림 받기 설정 결과: \(result)")
                                observer.onNext(result)
                            }
                        }
                    case .failure(let err):
                        print("전체 알림 받기 에러 발생: \(err)")
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func getMyInterestCategoryAlarmList() -> Observable<MyAlarmIsOnModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("notification/me")
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: MyAlarmIsOnModel.self) { response in
                    switch response.result {
                    case .success(let interest):
                        observer.onNext(interest)
                    case .failure(let err):
                        print("내 관심 카테고리 알람 가져오기 실패: \(err)")
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func cancelAllSub(subOrNot: Bool) -> Observable<MyAlarmIsOnModel> {
        return Observable.create { observer in
            
            let url = BaseURL.url.appending("notification/me")
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            let parameter: Parameters = [
                "subscribe": subOrNot
            ]
            
            AF.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: MyAlarmIsOnModel.self) { response in
                    switch response.result {
                    case .success(let myAlarmDataModel):
                        observer.onNext(myAlarmDataModel)
                    case .failure(let err):
                        print("전체 구독 해제 에러 발생")
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    //전체알림 클릭 시
    static func subAll(token: String, subOrNot: Bool) -> Observable<MyAlarmIsOnModel> {
        return Observable.create { observer in
        
            let urlStr = BaseURL.url.appending("notification/me")
            let url = URL(string: urlStr)
            var request = URLRequest(url: url!)
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            
            let parameter: Parameters = [
                "subscribe": subOrNot,
                "registrationToken":token
            ]
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameter, options: [])
            
            AF.request(request)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: MyAlarmIsOnModel.self) { response in
                    switch response.result {
                    case .success(let isOnMyModel):
                        observer.onNext(isOnMyModel)
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func editCellSubs(id: Int, subOrNot: Bool) -> Observable<MyAlarmIsOnModel> {
        return Observable.create { observer in
            
            let urlStr = BaseURL.url.appending("notification/me")
            let url = URL(string: urlStr)
            var request = URLRequest(url: url!)
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""

            request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            
            let parameter: [String: [[String: Any]]] = [
                "interestCategories": [[
                    "subscribe": subOrNot,
                    "id": id
                ]]
            ]
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            
            AF.request(request)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: MyAlarmIsOnModel.self) { response in
                    switch response.result {
                    case .success(let isOnMyModel):
                        observer.onNext(isOnMyModel)
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func editRegionCellSubs(id: Int, subOrNot: Bool) -> Observable<MyAlarmIsOnModel> {
        return Observable.create { observer in
            
            let urlStr = BaseURL.url.appending("notification/me")
            let url = URL(string: urlStr)
            var request = URLRequest(url: url!)
            
//            let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            ///UserDefaults -> keychain
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""

            request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            
            let parameter: [String: [[String: Any]]] = [
                "interestRegions": [[
                    "subscribe": subOrNot,
                    "id": id
                ]]
            ]
            
            let header: HTTPHeaders = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer ".appending(accessToken)
            ]
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            
            AF.request(request)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: MyAlarmIsOnModel.self) { response in
                    switch response.result {
                    case .success(let isOnMyModel):
                        observer.onNext(isOnMyModel)
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func adSubscribe(valid: Bool) {
        let url = BaseURL.url.appending("notification/me")
        
//        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        ///UserDefaults -> keychain
        let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json;charset=UTF-8",
            "Authorization": "Bearer ".appending(accessToken)
        ]
        
        print("광고수신여부: \(valid)")
        
        let parameter: Parameters = [
            "adSubscribe": valid
        ]
        
        AF.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: header, interceptor: MyRequestInterceptor())
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let result = json?["data"] as? [String: Any] ?? [:]
                            let adSubscribe = result["adSubscribe"] as? Bool ?? false
                            let isSuccess = result["success"] as? Bool ?? false
                            print("광고 변경 여부: \(isSuccess)")
                            print("현재 광고 수신 상태: \(adSubscribe)")
                        }
                    }
                case .failure(let err):
                    print("광고 변경 실패: \(err)")
                }
            }
        
    }
}
