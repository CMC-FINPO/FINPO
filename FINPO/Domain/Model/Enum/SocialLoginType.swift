//
//  SocialLoginType.swift
//  FINPO
//
//  Created by 이동희 on 2022/11/18.
//

import Foundation
import GoogleSignIn

enum SocialLoginType {
    case kakao
    case google(GIDGoogleUser)
    case apple(String)
}
