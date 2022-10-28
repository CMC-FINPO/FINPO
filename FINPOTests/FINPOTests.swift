//
//  FINPOTests.swift
//  FINPOTests
//
//  Created by 이동희 on 2022/10/12.
//

import XCTest
import RxSwift
import RxBlocking

class MypageAPIService {
    static func fetchMywritingRx(_ page: Int) -> Observable<Data> {
        let json = """
        {
        "data": {
            "content":  [ {
                "status": true,
                "id": 3994,
                "content": "안녕하세요",
                "anonymity": false,
                "likes": 1,
                "hits": 1,
                "countOfComment": 1,
                "user" : {
                        "status" : true,
                        "nickname" : "메이슨",
                        "gender" : "MALE",
                        "profileImg" : "https://dev.finpo.kr/upload/profile/1855b430-856d-4e2f-b8f0-554b66608cff.png",
                        "role" : "ROLE_USER"
                      },
                "isMine" : true,
                "isLiked" : false,
                "isBookmarked" : false,
                "isModified" : false,
                "createdAt" : "2022-08-31T19:04:35.810257778",
                "modifiedAt" : "2022-08-31T19:04:35.810257778"
                    }
                ],
        "totalElements" : 6,
        "last" : false,
        "first" : true
            }
        }
    """
        return Observable.just(json.data(using: .utf8) ?? Data())
    }
    
    static func fetchMyCommentingRx(_ page: Int) -> Observable<Data> {
        let json = """
        {
        "data": {
            "content":  [ {
                "status": true,
                "id": 3994,
                "content": "안녕하세요",
                "anonymity": false,
                "likes": 1,
                "hits": 1,
                "countOfComment": 1,
                "user" : {
                        "status" : true,
                        "nickname" : "메이슨",
                        "gender" : "MALE",
                        "profileImg" : "https://dev.finpo.kr/upload/profile/1855b430-856d-4e2f-b8f0-554b66608cff.png",
                        "role" : "ROLE_USER"
                      },
                "isMine" : true,
                "isLiked" : false,
                "isBookmarked" : false,
                "isModified" : false,
                "createdAt" : "2022-08-31T19:04:35.810257778",
                "modifiedAt" : "2022-08-31T19:04:35.810257778"
                    }
                ],
        "totalElements" : 6,
        "last" : false,
        "first" : true
            }
        }
    """
        return Observable.just(json.data(using: .utf8) ?? Data())
    }
    
    static func fetchMyLikingRx(_ page: Int) -> Observable<Data> {
        let json = """
        {
        "data": {
            "content":  [ {
                "status": true,
                "id": 3994,
                "content": "안녕하세요",
                "anonymity": false,
                "likes": 1,
                "hits": 1,
                "countOfComment": 1,
                "user" : {
                        "status" : true,
                        "nickname" : "메이슨",
                        "gender" : "MALE",
                        "profileImg" : "https://dev.finpo.kr/upload/profile/1855b430-856d-4e2f-b8f0-554b66608cff.png",
                        "role" : "ROLE_USER"
                      },
                "isMine" : true,
                "isLiked" : false,
                "isBookmarked" : false,
                "isModified" : false,
                "createdAt" : "2022-08-31T19:04:35.810257778",
                "modifiedAt" : "2022-08-31T19:04:35.810257778"
                    }
                ],
        "totalElements" : 6,
        "last" : false,
        "first" : true
            }
        }
    """
        return Observable.just(json.data(using: .utf8) ?? Data())
    }
}

class FINPOTests: XCTestCase {
    var domain: MypageStore!
    
    override func setUp() {
        domain = MypageStore()
    }
    func testGetMyWriting() {
        let expected: CommunityboardResponseModel =
        CommunityboardResponseModel(
            data: CommunityDataModel(
                content: [CommunityContentModel(
                    status: true,
                    id: 3994,
                    content: "안녕하세요",
                    anonymity: false,
                    likes: 1,
                    hits: 1,
                    countOfComment: 1,
                    isMine: true,
                    isLiked: false,
                    isBookmarked: false,
                    isModified: false,
                    modified: nil,
                    createdAt: "2022-08-31T19:04:35.810257778",
                    modifiedAt: "2022-08-31T19:04:35.810257778",
                    user: CommunityUserDetail(
                        status: true,
                        nickname: "메이슨",
                        gender: "MALE",
                        profileImg: "https://dev.finpo.kr/upload/profile/1855b430-856d-4e2f-b8f0-554b66608cff.png",
                        role: "ROLE_USER")
                )],
                totalElements: 6,
                last: false,
                first: true))
        let myWritings: CommunityboardResponseModel = try! domain.fetchMyWriting(0).toBlocking().first()!
        XCTAssertEqual(expected, myWritings)
    }
}
