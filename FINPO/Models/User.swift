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
    var region1: String = ""
    var region2: String = ""
//    var profileImg: String = ""
    
    func toDic() -> Parameters {
        let parameter:Parameters = [
            "name": self.name,
            "nickname" : self.nickname,
            "birth":self.birth,
            "gender": self.gender, //Male, Female, Private(아직 미정상태)
            "email": self.email,
            "region1": self.region1,
            "region2": self.region2,
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
