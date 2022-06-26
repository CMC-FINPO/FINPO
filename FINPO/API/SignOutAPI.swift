//
//  SignOutAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/21.
//

import Foundation
import UIKit
import Alamofire

//회원탈퇴(명칭 미스)
struct SignOutAPI {
    static func signoutWithAuthGoogle(accessToken: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        var valid: Bool = false
        let url = "https://dev.finpo.kr/user/me"
        let header: HTTPHeaders = [
            "Content-Type": "application/json;charset=UTF-8",
            "Authorization": "Bearer ".appending(accessToken)
        ]
        let parameter: Parameters = [
            "access_token": UserDefaults.standard.string(forKey: "SocialAccessToken") ?? ""
        ]
        
        AF.request(url, method: .delete, parameters: parameter, encoding: JSONEncoding.default, headers: header)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let result = json?["data"] as? Bool ?? false
                            print("서버 계정 삭제 성공여부: \(result)")
                            valid = result
                            completion(.success(valid))
                        }
                    }
                case .failure(let error):
                    print("서버 및 소셜 연동 해지 실패 !")
                    completion(.failure(error))
                    break
                }
            }
    }
    
    static func signoutWithAuthKakao(accessToken: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        var valid: Bool = false
        let url = "https://dev.finpo.kr/user/me"
        let header: HTTPHeaders = [
            "Content-Type": "application/json;charset=UTF-8",
            "Authorization": "Bearer ".appending(accessToken)
        ]
        
        AF.request(url, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: header)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let result = json?["data"] as? Bool ?? false
                            print("서버 계정 삭제 성공여부: \(result)")
                            valid = result
                            completion(.success(valid))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                    break
                }
            }
    }
    
    static func signoutWithAuthApple(accessToken: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        var valid: Bool = false
        let url = "https://dev.finpo.kr/user/me"
        let header: HTTPHeaders = [
            "Content-Type": "application/json;charset=UTF-8",
            "Authorization": "Bearer ".appending(accessToken)
        ]
        
        AF.request(url, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: header)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let result = json?["data"] as? Bool ?? false
                            print("서버 계정 삭제 성공여부: \(result)")
                            valid = result
                            completion(.success(valid))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                    break
                }
            }
    }
}
