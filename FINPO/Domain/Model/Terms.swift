//
//  Terms.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/05.
//

import Foundation

enum TermsType {
    case main
    case sub
}

struct Terms {
    let termsID: String?
    let title: String
    let contents: String?
    let isMandatory: Bool
    var isAccept: Bool = false
    let type: TermsType
    
    static func loadSampleData() -> [[Terms]] {
        let terms1: [Terms] = [
            .init(termsID: "1",
                  title: "이용약관 동의",
                  contents: "blablabla",
                  isMandatory: true,
                  type: .main
                 ),
        ]
        
        let terms2: [Terms] = [
            .init(termsID: "2",
                  title: "개인정보 수집 및 이용동의",
                  contents: "blablabla",
                  isMandatory: true,
                  type: .main
                 ),
        ]
        
        let terms3: [Terms] = [
            .init(termsID: "3",
                  title: "만 14세 이상입니다",
                  contents: "",
                  isMandatory: true,
                  type: .main
                 )
        ]
        
        let terms4: [Terms] = [
            .init(termsID: nil,
                  title: "마케팅 정보 수신 동의",
                  contents: "blablabla",
                  isMandatory: false,
                  type: .main
                 ),
//            .init(
//                termsID: "3",
//                title: "개인정보 제 3자 제공 동의",
//                contents: "blabla",
//                isMandatory: false,
//                type: .sub
//            ),
//            .init(
//                termsID: "4",
//                title: "결제 이용내역 제공 동의",
//                contents: "blabla",
//                isMandatory: false,
//                type: .sub
//            ),
        ]
        return [terms1, terms2, terms3, terms4]
    }
}
