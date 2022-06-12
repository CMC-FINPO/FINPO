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
    var email: String = ""
    var region: [Int] = []
    var category: [Int] = []
//    var region1: String = ""
//    var region2: String = ""
//    var profileImg: String = ""
    
    func toDic() -> Parameters {
        let parameter:Parameters = [
            "name": self.name,
            "nickname" : self.nickname,
            "birth":self.birth,
            "gender": self.gender, //Male, Female, Private(아직 미정상태)
            "email": self.email,
//            "region": self.region
//            "region1": self.region1,
//            "region2": self.region2,
//            "profileImg": self.profileImg
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
//    var parent: [SubParent]
//
//    struct SubParent: Codable {
//        var id: Int
//        var name: String
//    }
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
