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

struct EditResponse: Codable {
    var success : Bool
    var errorCode : Int
    var message : String
    var data : Bool
}

protocol EditFetchable {
    func editComment(commentId: Int, content: String) -> Observable<Response>
    
    func deleteComment(id: Int)
    
    func reportComment(commentId: Int, reportId: Int) -> Observable<EditResponse>
    
    func blockUser(commentId: Int)
}

class EditStore: EditFetchable {
    var url = BaseURL.url.appending("comment/")

    func editComment(commentId: Int, content: String) -> Observable<Response> {
        let param: Parameters = [
            "content": content
        ]
        return ApiManager.putData(with: param, from: url.appending("\(commentId)"), to: Response.self, encoding: JSONEncoding.default)
    }
    
    func deleteComment(id: Int)  {
        ApiManager.deleteDataWithoutRx(from: url.appending("\(id)"), to: EditResponse.self, encoding: URLEncoding.default)
    }
    
    func reportComment(commentId: Int, reportId: Int) -> Observable<EditResponse> {
        let reportIdParam: Parameters = [
            "id": reportId
        ]
        let param: Parameters = [
            "report": reportIdParam
        ]
        return ApiManager.postData(with: param, from: url.appending("\(commentId)/report"), to: EditResponse.self, encoding: JSONEncoding.default)
    }
    
    func blockUser(commentId: Int) {
        ApiManager.postDataWithoutRx(from: url.appending("\(commentId)/block"), to: EditResponse.self, encoding: URLEncoding.default)
    }
    
}
