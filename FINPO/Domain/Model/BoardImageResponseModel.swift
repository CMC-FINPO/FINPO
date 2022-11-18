//
//  BoardImageResponseModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/28.
//

import Foundation

struct BoardImageResponseModel: Codable {
    var data: BoardImageDataDetail
}

struct BoardImageDataDetail: Codable {
    var imgUrls: [String]
}
