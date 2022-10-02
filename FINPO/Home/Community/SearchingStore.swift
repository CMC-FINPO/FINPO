//
//  SearchingStore.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/02.
//

import Foundation
import RxSwift

protocol SearchingFetchable {
    func fetchSearchedBoard() -> Observable<Void>
}

class SearchingStore: SearchingFetchable {
    func fetchSearchedBoard() -> Observable<Void> {
        
    }
}

