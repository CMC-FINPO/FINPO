//
//  SocialLoginAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/12.
//

import Foundation
import RxSwift
import Alamofire
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser


struct SocialLoginAPI {
    static func loginWithKakao(url: String, socialToken: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let header: HTTPHeaders = [
            "Content-Type": "application/json;charset=UTF-8",
            "Authorization": "Bearer ".appending(socialToken)
        ]
        ///서버 회원가입 상태 체크
        AF.request(
            url,
            method: .get,
            encoding: URLEncoding.default,
            headers: header
        )
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            //이미 회원가입 한 유저라면
                            if response.response?.statusCode == 200 {
                                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                let result = json?["data"] as? [String:Any]
                                let accessToken = result?["accessToken"] as? String ?? ""
                                let refreshToken = result?["refreshToken"] as? String ?? ""
                                KeyChain.create(key: KeyChain.accessToken, token: accessToken)
                                KeyChain.create(key: KeyChain.refreshToken, token: refreshToken)
                                KeyChain.create(key: KeyChain.socialType, token: "kakao")
                                LoginViewModel.socialType = "kakao"
                                ///회원가입 된 상태 -> 로그인 진행(True)
                                completion(.success(true))
                            }
                            //회원가입 대상이라면
                            else if response.response?.statusCode == 202 {
                                completion(.success(false))
                            }
                        }
                    }
                case .failure(let err):
                    completion(.failure(err))
                }
            }
    }
}
