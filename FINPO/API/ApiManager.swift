//
//  ApiManager.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/22.
//

import Foundation
import Alamofire
import RxSwift
import UIKit

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
    
    static func createImagePostHeader(token: String) -> HTTPHeaders {
        let header: HTTPHeaders = [
            "Content-Type":"application/x-www-form-urlencoded;charset=UTF-8; boundary=6o2knFse3p53ty9dmcQvWAIx1zInP11uCfbm",
            "Authorization":"Bearer ".appending(token)
        ]
        return header
    }
    
    static func getData<T: Decodable>(with param: Encodable? = nil, from url: String, to model: T.Type, encoding: ParameterEncoding) -> Observable<T> {
        return Observable.create { observer in
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            let header = ApiManager.createHeader(token: accessToken)
            
            API.session.request(url, method: .get, parameters: param?.dictionary, encoding: encoding, headers: header, interceptor: MyRequestInterceptor())
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
    
    static func postData<T: Decodable>(with param: Parameters? = nil, from url: String, to model: T.Type, encoding: ParameterEncoding) -> Observable<T> {
        return Observable.create { observer in
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            let header = ApiManager.createHeader(token: accessToken)
            
            let queue = DispatchQueue.global(qos: .utility)
            API.session.request(url, method: .post, parameters: param, encoding: encoding, headers: header, interceptor: MyRequestInterceptor())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: model.self, queue: queue, completionHandler: { response in
                    switch response.value {
                    case .some(let models):
                        observer.onNext(models)
                    case .none:
                        observer.onError(response.error!)
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
    
    static func postImage<T: Decodable>(with images: [UIImage], from url: String, to model: T.Type, encoding: ParameterEncoding) -> Observable<T> {
        return Observable.create { observer in
            print("이미지 비었니?\(images.isEmpty)")
            var imageData: [Data] = [Data]()
            for image in images {
                imageData.append(image.jpegData(compressionQuality: 1)!)
            }
            let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
            let header = ApiManager.createImagePostHeader(token: accessToken)
            DispatchQueue.global().async {
                API.session.upload(multipartFormData: { multipart in
                    for imgData in imageData {
                        multipart.append(imgData, withName: "imgFiles", fileName: "imagefile.jpeg", mimeType: "image/jpeg")
                    }
                }, to: url, headers: header, interceptor: MyRequestInterceptor())
                .responseDecodable(of: model.self) { response in
                    switch response.value {
                    case .some(let models):
                        observer.onNext(models)
                    case .none:
                        observer.onError(NetworkError.imagePostError)
                    }
                }
            }            
            return Disposables.create()
        }
    }
    
    static func checkTokenValidation() -> Bool {
        let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
        let refreshToken = KeyChain.read(key: KeyChain.refreshToken) ?? ""
        let url = BaseURL.url.appending("oauth/reissue")
        
        let parameter: Parameters = [
            "accessToken": accessToken,
            "refreshToken": refreshToken
        ]
        
        var apiResult: Bool = false
        
        ///비동기 처리의 동기화 -> 세마포어 사용
        let semaphore = DispatchSemaphore(value: 0)
        //alamofre의 completion handler가({}) DispatchQueue.main에서 실행되므로, DispatchSemaphore를 DispatchQueue.main 실행하게 되면 completionHandler의 실행까지 멈춰버리므로 데드락 발생
        let queue = DispatchQueue.global(qos: .utility) //Main Queue에서 작동하는 걸 Global Queue로 바꿈
        //따라서 completionHandler를 DispatchQueue.main 이외의 스레드로 실행하면 되기에 response 매개변수에 실행하고자 하는 queue로 교체
        
        API.session.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .response(queue: queue) { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let result = json?["data"] as? [String: Any] ?? [:]
                            let accessToken = result["accessToken"] as? String ?? ""
                            let refreshToken = result["refreshToken"] as? String ?? ""
                            let accessTokenExpiresIn = result["accessTokenExpiresIn"] as? Int ?? 0
                            let accessTokenExpireDate = Date(milliseconds: Int64(accessTokenExpiresIn))
                            KeyChain.create(key: KeyChain.accessToken, token: accessToken)
                            KeyChain.create(key: KeyChain.refreshToken, token: refreshToken)
                            UserDefaults.standard.set(accessTokenExpireDate, forKey: "accessTokenExpiresIn")
                            print("갱신된 액세스 토큰: \(accessToken)")
                            print("갱신된 리프레시 토큰: \(refreshToken)")
                            print("토큰 갱신 성공!!!!")
                            apiResult = true
                        }
                    }
                case .failure(let error):
                    print("토큰 리프레시 실패!: \(error.localizedDescription)")
                    print("리스폰스:\(response.response)")
                    apiResult = false
                
                }
                semaphore.signal()
            }
        semaphore.wait()
        return apiResult

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

enum NetworkError: Error {
    case imagePostError
}
