//
//  API.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/22.
//

import Foundation
import Alamofire

class API {
    static let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        let apiLogger = APIEventLogger()
        return Session(configuration: configuration, eventMonitors: [apiLogger])
    }()
}
