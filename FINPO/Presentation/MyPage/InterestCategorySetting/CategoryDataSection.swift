//
//  CategoryDataSection.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/14.
//

import Foundation
import RxDataSources

struct CategoryDataSection {
    var header: String
    var items: [MyInterestSectionType]
}

extension CategoryDataSection: SectionModelType {
    typealias Item = MyInterestSectionType
    
    init(original: CategoryDataSection, items: [MyInterestSectionType]) {
        self = original
        self.items = items
    }
    
}

enum MyInterestSectionType {
    case job(ChildDetail)
    case living(ChildDetail)
    case education(ChildDetail)
    case participation(ChildDetail)
    case purpose(UserPurpose)
}

enum MyInterestMenuType {
    case job
    case living
    case education
    case participation
    case purpose
    
    var title: String {
        switch self {
        case .job: return "일자리"
        case .living: return "생활안정"
        case .education: return "교육 문화"
        case .participation: return "참여 공간"
        case .purpose: return "이용 목적"
        }
    }
}
