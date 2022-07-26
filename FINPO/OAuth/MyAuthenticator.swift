//
//  MyAuthenticator.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/15.
//

import Foundation
import Alamofire

//api 요청시에 interceptor 파라미터로 전달하면 요청이 실패했을 때 OAuthenticatio에 구현된 메서드가 자동으로 호출됨
class MyAuthenticator: Authenticator {
    
    typealias Credential = MyAuthenticationCredential
    
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        // 1. header에 토큰 추가
        print("apply 시작!!!")
//        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
//        urlRequest.headers.add(name: "accessToken", value: credential.accessToken)
//        urlRequest.headers.add(name: "refreshToken", value: credential.refreshToken)

//        urlRequest.addValue(credential.accessToken, forHTTPHeaderField: "Authorization")
//        urlRequest.addValue(credential.refreshToken, forHTTPHeaderField: "refreshToken")
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        // 2. true 리턴 시 isRequest, false 리턴 시 종료
        // 401 = 인증에러이며, 이 경우만 refresh 되도록 필터링

        return response.statusCode == 401
//        return true
    }
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        // 3. bearerToken의 urlRequest대해서만 refresh를 시도 (true)
        // true 리턴 시 refresh, false 리턴 시 apply
        
//        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
//        return urlRequest.headers["Authorization"] == bearerToken //원본
//        return urlRequest.headers["Authorization"] == bearerToken
        return true
    }
    
    func refresh(_ credential: Credential, for session: Session, completion: @escaping (Result<Credential, Error>) -> Void) {
        // 4. token을 refresh
        
        let url = BaseURL.url.appending("oauth/reissue")
        let parameter: Parameters = [
            "accessToken": UserDefaults.standard.string(forKey: "accessToken") ?? "",
            "refreshToken": UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        ]
        
        print("\(UserDefaults.standard.string(forKey: "accessToken") ?? "")")
        print("\(UserDefaults.standard.string(forKey: "refreshToken") ?? "")")
        
        DispatchQueue.main.async {
            AF.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response { (response) in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                print("토큰갱신 성공!!!")
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["data"] as? [String: Any] ?? [:]
                                let accessToken = result["accessToken"] as? String ?? ""
                                let refreshToken = result["refreshToken"] as? String ?? ""
                                let accessTokenExpiresIn = result["accessTokenExpiresIn"] as? Int ?? Int()
                                let accessTokenExpireDate = Date(milliseconds: Int64(accessTokenExpiresIn))
                                UserDefaults.standard.set(accessToken, forKey: "accessToken")
                                UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                                UserDefaults.standard.set(accessTokenExpireDate, forKey: "accessTokenExpiresIn")
                                let credential = MyAuthenticationCredential(
                                    accessToken: accessToken,
                                    refreshToken: refreshToken,
                                    expiredAt: accessTokenExpireDate)
                                completion(.success(credential))
                             }
                        }
                    case .failure(let error):
                        print("토큰 갱신 에러 발생: \(error)")
                        print("요청한 액세스 토큰: \(credential)")
                        completion(.failure(error))
                    }
                }
        }
    }

}
