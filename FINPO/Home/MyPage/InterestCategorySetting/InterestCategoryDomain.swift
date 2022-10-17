//
//  InterestCategoryDomain.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/14.
//

import Foundation
import RxSwift
import Alamofire

//관심 카테고리
let url: String = BaseURL.url.appending("policy/category/")
let accessToken: String = KeyChain.read(key: KeyChain.accessToken) ?? ""
let header: HTTPHeaders = ApiManager.createHeader(token: accessToken)

protocol CategoryFetchable {
    func getAllCategory() -> Observable<LowCategoryModel>
    func getMyInteresting() -> Observable<MyInterestCategoryModel>
}

/*
 struct LowCategoryModel: Codable {
     var data: [LowCategoryDataDetail]
 }

 struct LowCategoryDataDetail: Codable {
     var id: Int
     var name: String
     var parent: LowCategoryParentDetail
 }

 struct LowCategoryParentDetail: Codable {
     var id: Int
     var name: String
 }
 */

final class InterestCategoryStore: CategoryFetchable {
    func getAllCategory() -> Observable<LowCategoryModel> {
        return ApiManager.getData(from: url.appending("name?depth=2"), to: LowCategoryModel.self, encoding: URLEncoding.default)
    }
    
    func getMyInteresting() -> Observable<MyInterestCategoryModel> {
        return ApiManager.getData(from: url.appending("me"), to: MyInterestCategoryModel.self, encoding: URLEncoding.default)
    }
}
