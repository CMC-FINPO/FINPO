//
//  OpenAPIModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/20.
//

import Foundation

struct OpenAPIModel: Codable {
    var data: [OpenAPIDataDetail]
}

struct OpenAPIDataDetail: Codable {
    var id: Int
    var type: String
    var content: String
    var url: String
    var hidden: Bool
}
