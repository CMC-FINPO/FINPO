//
//  BaseURL.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/30.
//

import Foundation

struct BaseURL {
    static var url: String = "https://api.finpo.kr/" //배포서버
//    static var url: String = "https://dev.finpo.kr/" //개발서버
    //문의
    static var ask: String = "https://forms.gle/29dvEJfe6S2GK6xh8"
    //이용약관
    static var agreement: String = "https://sites.google.com/view/finpo-terms/"
    //개인정보 처리 방침
    static var personalInfo: String = "https://sites.google.com/view/finpo-privacy/"
    //커뮤니티 이용 약관
    static var communityInfo: String = "https://sites.google.com/view/finpo-community-rule/"
}
