//
//  MyAuthenticationCredential.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/15.
//

import Foundation
import Alamofire

struct MyAuthenticationCredential: AuthenticationCredential {
    let accessToken: String
    let refreshToken: String
//    let expiredAt: Date //일단 없이 테스트

    // 유효시간이 앞으로 5분 이하 남았다면 refresh가 필요하다고 true를 리턴 (false를 리턴하면 refresh 필요x)
//    var requiresRefresh: Bool { Date(timeIntervalSinceNow: 60 * 5) > expiredAt }
    var requiresRefresh: Bool = false
}
