//
//  User.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/06.
//

import Foundation
import Alamofire


class User: Codable {
    
    static var instance = User()
    
    var name: String = ""
    var nickname: String = ""
    var birth: String = ""
    var gender: String = ""
    var region: [Int] = [] //메인 거주지역
    var interestRegion: [Int] = []//추가 거주지역
    var category: [Int] = []
    var status: Int = 0
    var accessToken: String = ""
    var accessTokenFromSocial: String = ""
    var refreshToken: String = ""
    var profileImg: URL?
    
    func toDic() -> Parameters {
        let parameter:Parameters = [
            "name": self.name,
            "nickname" : self.nickname,
            "birth":self.birth,
            "gender": self.gender, //Male, Female
            "regionId": self.region[0], //메인 지역 (추가 전)
            "status": self.status,
            "profileImg": self.profileImg
        ]
        return parameter
    }
}

enum Gender {
    case male
    case female
    case none
}

///Main Region
struct MainRegionAPIResponse: Codable {
    var data: [MainRegion]
}

struct MainRegion: Codable {
    var id: Int
    var name: String
}

///Sub Region
struct SubRegionAPIRsponse: Codable {
    var data: [SubRegion]
}

struct SubRegion: Codable {
    var id: Int
    var name: String

}

struct UniouRegion: Codable {
    var unionRegionName: String
}

struct InterestingAPIResponse: Codable {
    var data: [MainInterest]
}

struct MainInterest: Codable {
    var id: Int
    var name: String
//    var name: Interesting
}

///user's interest area
enum Interesting {
    case job(_ selectJob: SelectJob)
    case living(_ selectLiving: SelectLiving)
    case education(_ selectEducation: SelectEducation)
    case participation(_ selectParticipation: SelectParticipation)
    
    enum SelectJob {
        case track
        case employment
        case foundation
    }
    
    enum SelectLiving {
        case support
        case health
    }
    
    enum SelectEducation {
        case training
        case culture
    }
    
    enum SelectParticipation {
        case social
        case space
        case extracurricular
    }
}

struct UserStatusAPIResponse: Codable {
    var data: [UserStatus]
}

struct UserStatus: Codable {
    var id: Int
    var name: String
}

///이용목적 전체 조회 모델
struct UserPurposeAPIResponse: Codable {
    var data: [UserPurpose]
}

struct UserPurpose: Codable {
    var id: Int
    var name: String
}
///내 이용목적 조회 모델
struct MyPurposeAPIResponse: Codable {
    var data: [Int]
}
