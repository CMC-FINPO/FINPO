//
//  MypageStore.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/09.
//

import Foundation
import RxSwift

protocol MyPageFetchable {
    func fetchMyWriting(_ page: Int) -> Observable<CommunityboardResponseModel>
    func fetchMyCommenting(_ page: Int) -> Observable<CommunityboardResponseModel>
    func fetchMyLiking(_ page: Int) -> Observable<CommunityboardResponseModel>
}

class MypageStore: MyPageFetchable {
    func fetchMyWriting(_ page: Int) -> Observable<CommunityboardResponseModel> {
        return MypageAPIService.fetchMywritingRx(page)
            .map { data in
                guard let response = try? JSONDecoder().decode(CommunityboardResponseModel.self, from: data) else {
                    throw NSError(domain: "Decoding error", code: -1)
                }
                return response
            }
    }

    func fetchMyCommenting(_ page: Int) -> Observable<CommunityboardResponseModel> {
        return MypageAPIService.fetchMyCommentingRx(page)
            .map { data in
                guard let response = try? JSONDecoder().decode(CommunityboardResponseModel.self, from: data) else {
                    throw NSError(domain: "Decoding error", code: -1)
                }
                return response
            }
    }
    
    func fetchMyLiking(_ page: Int) -> Observable<CommunityboardResponseModel> {
        return MypageAPIService.fetchMyLikingRx(page)
            .map { data in
                guard let response = try? JSONDecoder().decode(CommunityboardResponseModel.self, from: data) else {
                    throw NSError(domain: "Decoding error", code: -1)
                }
                return response
            }
    }
}
