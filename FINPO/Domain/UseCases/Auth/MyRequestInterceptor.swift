//
//  MyRequestInterceptor.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/04.
//

import Foundation
import Alamofire

class MyRequestInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
//        guard urlRequest.url?.absoluteString.hasPrefix(BaseURL.url) == true,
//              let accessToken = KeyChain.read(key: KeyChain.accessToken) else {
//            completion(.success(urlRequest))
//            return
//        }
        guard urlRequest.url?.absoluteString.hasPrefix(BaseURL.url) == true,
                let refreshToken = KeyChain.read(key: KeyChain.refreshToken), let accessToken = KeyChain.read(key: KeyChain.accessToken) else {
//            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        
        
        urlRequest.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
//        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        ///added
//        urlRequest.setValue(refreshToken, forHTTPHeaderField: "refreshToken")
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        let url = BaseURL.url.appending("oauth/reissue")
        let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
        let refreshToken = KeyChain.read(key: KeyChain.refreshToken) ?? ""
        
        let parameter: Parameters = [
            "accessToken": accessToken,
            "refreshToken": refreshToken
        ]
        
        API.session.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .response { response in
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
                            completion(.retry)
                        }
                    }
                case .failure(let error):
                    print("토큰 리프레시 실패!: \(error.localizedDescription)")
                    print("리스폰스:\(response.response)")
                    completion(.doNotRetryWithError(error))
                }
            }
    }
}
