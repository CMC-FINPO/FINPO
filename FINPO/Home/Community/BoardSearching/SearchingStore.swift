//
//  SearchingStore.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/02.
//

import Foundation
import RxSwift
import Alamofire

protocol SearchingFetchable {
    func fetchSearchedBoard(page: Int, content: String) -> Observable<CommunityboardResponseModel>
}

class SearchingStore: SearchingFetchable {
    var url = BaseURL.url.appending("post/search")
    
    func fetchSearchedBoard(page: Int, content: String) -> Observable<CommunityboardResponseModel> {
        let param: Parameters = [
            "sort": "id,desc",
            "page": page,
            "size": 10,
            "content": content
        ]
        return ApiManager.getData(with: param, from: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", to: CommunityboardResponseModel.self, encoding: URLEncoding.default)
    }
}

