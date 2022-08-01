//
//  LastSignUpAPI.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/28.
//

import Foundation
import Alamofire

struct LastSignUpAPI {
    static func lastSignUpAPI(regionId: [Int]) {

//        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        ///UserDefaults -> keychain
        let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
        
        let urlStr = BaseURL.url.appending("region/me")
        
        let url = URL(string: urlStr)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer ".appending(accessToken), forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        request.httpBody = try! JSONSerialization.data(withJSONObject: regionId.map({["regionId":$0]}))
        
        API.session.request(request)
            .validate()
            .response { (response) in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let result = json?["success"] as? Bool ?? false
                            print("결과: \(result)")
                        } catch { print("에러 발생") }
                    }
                case .failure(let err):
                    print("에러 발생: \(err)")
                }
            }
    }
}
