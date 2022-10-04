//
//  EditStore.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/03.
//

import Foundation
import RxSwift
import Alamofire

protocol EditFetchable {
    func editComment(commentId: Int, content: String) -> Observable<CommunityCommentResponseModel>
}

class EditStore: EditFetchable {
    var url = BaseURL.url.appending("comment/")
    
    func editComment(commentId: Int, content: String) -> Observable<CommunityCommentResponseModel> {
        let param: Parameters = [
            "content": content
        ]
        return ApiManager.postData(with: param, from: url.appending("\(commentId)"), to: CommunityCommentResponseModel.self, encoding: URLEncoding.default)
    }
}
