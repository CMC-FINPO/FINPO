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
    }

    func fetchMyCommenting(_ page: Int) -> Observable<CommunityboardResponseModel> {
        return MypageAPIService.fetchMyCommentingRx(page)
    }
    
    func fetchMyLiking(_ page: Int) -> Observable<CommunityboardResponseModel> {
        return MypageAPIService.fetchMyLikingRx(page)
    }
}
