//
//  EditStore.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/03.
//

import Foundation
import RxSwift
import Alamofire

struct Response: Codable {
    let success: Bool
    let data: EditCommentResponseModel
}

protocol EditFetchable {
    func editComment(commentId: Int, content: String) -> Observable<Response>
}

class EditStore: EditFetchable {
    var url = BaseURL.url.appending("comment/")

    func editComment(commentId: Int, content: String) -> Observable<Response> {
        let param: Parameters = [
            "content": content
        ]
        return ApiManager.putData(with: param, from: url.appending("\(commentId)"), to: Response.self, encoding: JSONEncoding.default)
    }
}
