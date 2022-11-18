//
//  CommentEditNetworkService.swift
//  FINPO
//
//  Created by 이동희 on 2022/11/18.
//

import Foundation
import Alamofire
import RxSwift

final class CommentEditNetworkService {
    
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
    
    func blockUser(commentId: SortIsBoard) {
        switch commentId {
        case .board(let pageId):
            let boardUrl = BaseURL.url.appending("post/\(pageId)/block")
            ApiManager.postDataWithoutRx(from: boardUrl, to: EditResponse.self, encoding: URLEncoding.default)
        case .comment(let commentId):
            ApiManager.postDataWithoutRx(from: url.appending("\(commentId)/block"), to: EditResponse.self, encoding: URLEncoding.default)
        }
    }
    
    func getBoardData(pageId: Int) -> Observable<CommunityDetailBoardResponseModel> {
        let Boardurl = BaseURL.url.appending("post/")
        return ApiManager.getData(from: Boardurl.appending("\(pageId)"), to: CommunityDetailBoardResponseModel.self, encoding: URLEncoding.default)
    }
    
    func getImageUrl(imgs: [UIImage]) -> Observable<BoardImageResponseModel> {
        let boardUrl = BaseURL.url.appending("upload/post")
        return ApiManager.postImage(with: imgs, from: boardUrl, to: BoardImageResponseModel.self, encoding: URLEncoding.default)
    }
    
    func uploadBoard(pageId: Int, text: String, imgUrls: [String]) -> Observable<CommunityDetailBoardResponseModel> {
        let boardUrl = BaseURL.url.appending("post/\(pageId)")
        let param = toDic(imgUrls: imgUrls, text: text)
        return ApiManager.putData(with: param, from: boardUrl, to: CommunityDetailBoardResponseModel.self, encoding: JSONEncoding.default)
    }
    
    func deleteBoard(pageId: Int) {
        let boardUrl = BaseURL.url.appending("post/\(pageId)")
        ApiManager.deleteDataWithoutRx(from: boardUrl, to: Response.self, encoding: URLEncoding.default)
    }
    
    func reportBoard(pageId: Int, reportId: Int) -> Observable<EditResponse> {
        let boardUrl = BaseURL.url.appending("post/\(pageId)/report")
        let reportIdParam: Parameters = [
            "id": reportId
        ]
        let param: Parameters = [
            "report": reportIdParam
        ]
        return ApiManager.postData(with: param, from: boardUrl, to: EditResponse.self, encoding: JSONEncoding.default)
    }
    
    func toDic(imgUrls: [String], text: String, isAnony: Bool = false) -> Parameters {
        var dics = [[String:Any]]()
        if imgUrls[0] == "" {
            let paramters: Parameters = [
                "content": text,
                "anonymity": isAnony
            ]
            return paramters
        } else {
            for i in 0..<imgUrls.count {
                let param: Parameters = [
                    "img":imgUrls[i],
                    "order": i
                ]
                dics.append(param)
            }
        }
        let parameters: Parameters = [
            "imgs": dics,
            "anonymity": isAnony,
            "content": text
        ]
        return parameters
    }
}
