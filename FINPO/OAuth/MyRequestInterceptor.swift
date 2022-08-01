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
        guard urlRequest.url?.absoluteString.hasPrefix(BaseURL.url) == true,
              let accessToken = KeyChain.read(key: KeyChain.accessToken) else {
            completion(.success(urlRequest))
            return
        }
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: "accessToken")
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
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
//            "accessToken": UserDefaults.standard.string(forKey: "accessToken") ?? "",
//            "refreshToken": UserDefaults.standard.string(forKey: "refreshToken") ?? ""
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
                            let accessTokenExpiresIn = result["accessTokenExpiresIn"] as? Int ?? Int()
                            let accessTokenExpireDate = Date(milliseconds: Int64(accessTokenExpiresIn))
//                            UserDefaults.standard.set(accessToken, forKey: "accessToken")
//                            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                            KeyChain.create(key: KeyChain.accessToken, token: accessToken)
                            KeyChain.create(key: KeyChain.refreshToken, token: refreshToken)
                            UserDefaults.standard.set(accessTokenExpireDate, forKey: "accessTokenExpiresIn")
                            print("토큰 갱신 성공!!!!")
                            completion(.retry)
                        }
                    }
                case .failure(let error):
                    print("토큰 리프레시 실패!: \(error)")
                    completion(.doNotRetryWithError(error))
                }
            }
    }
}
