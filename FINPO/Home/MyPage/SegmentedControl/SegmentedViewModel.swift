//
//  SegmentedViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/09.
//

import Foundation
import RxSwift
import RxCocoa

enum LoadMoreAction {
    case first(CommunityboardResponseModel)
    case loadMore(CommunityboardResponseModel)
}

protocol SegmentedViewModelType {
    var fetchMyWriting : AnyObserver<Void> { get }
    var fetchMyComment : AnyObserver<Void> { get }
    var fetchMyLiking  : AnyObserver<Void> { get }
    var loadMore       : AnyObserver<Void> { get }
    var setZero        : AnyObserver<Int>  { get }
    
    var mywritingResult   : Observable<LoadMoreAction> { get }
    var mycommentingResult: Observable<LoadMoreAction> { get }
    var mylikingResult    : Observable<LoadMoreAction> { get }
    var activated         : Observable<Bool> { get }
}

class SegmentedViewModel: SegmentedViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT //
    var fetchMyWriting: AnyObserver<Void>
    var fetchMyComment: AnyObserver<Void>
    var fetchMyLiking : AnyObserver<Void>
    var loadMore      : AnyObserver<Void>
    var setZero       : AnyObserver<Int>
    // OUTPUT //
    var mywritingResult   : Observable<LoadMoreAction>
    var mycommentingResult: Observable<LoadMoreAction>
    var mylikingResult    : Observable<LoadMoreAction>
    var activated         : Observable<Bool>
    
    init(domain: MyPageFetchable = MypageStore()) {
        let writingFetching = PublishSubject<Void>()
        let commentingFetching = PublishSubject<Void>()
        let likingFetching = PublishSubject<Void>()
        let page = BehaviorSubject<Int>(value: 0)
        let loadMoreObserver = PublishSubject<Void>()
        let zeroPageObserver = PublishSubject<Int>()
        let tempBoardPage = PublishSubject<[Int]>()
        
        let mywriting = PublishSubject<LoadMoreAction>()
        let mycommenting = PublishSubject<LoadMoreAction>()
        let myliking = PublishSubject<LoadMoreAction>()
        let activating = BehaviorSubject<Bool>(value: false)
        
        setZero = zeroPageObserver.asObserver()
        zeroPageObserver
            .bind(to: page)
            .disposed(by: disposeBag)
        
        //내가 작성한 게시글
        fetchMyWriting = writingFetching.asObserver()
        writingFetching.withLatestFrom(page.asObservable())
            .filter { $0 == 0 }
            .do(onNext: { _ in page.onNext(0) })
            .do(onNext: { _ in activating.onNext(true)})
            .map { domain.fetchMyWriting($0) }
            .flatMap { $0 }
            .do(onNext: { data in tempBoardPage.onNext(data.data.content.map { $0.id })})
            .map { LoadMoreAction.first($0) }
            .do(onNext: { _ in activating.onNext(false)})
            .bind(to: mywriting)
            .disposed(by: disposeBag)
        
        writingFetching.withLatestFrom(page.asObservable())
            .filter { $0 > 0 }
            .do(onNext: { _ in activating.onNext(true)})
            .map { domain.fetchMyWriting($0) }
            .flatMap { $0 }
            .do(onNext: { _ in activating.onNext(false)})
            .filter { !$0.data.last }
            .map { LoadMoreAction.loadMore($0) }
            .bind(to: mywriting)
            .disposed(by: disposeBag)
            
        mywritingResult = mywriting.asObservable()
        
        loadMore = loadMoreObserver.asObserver()
        loadMoreObserver.withLatestFrom(page.asObservable())
            .map { $0 + 1 }
            .do(onNext: { page.onNext($0)})
            .map { Int -> () in }
            .bind(to: writingFetching)
            .disposed(by: disposeBag)
            
        //댓글 단 글
        fetchMyComment = commentingFetching.asObserver()
        commentingFetching.withLatestFrom(page.asObservable())
            .filter { $0 == 0 }
            .do(onNext: { _ in page.onNext(0) })
            .do(onNext: { _ in activating.onNext(true)})
            .map { domain.fetchMyCommenting($0) }
            .flatMap { $0 }
            .map { LoadMoreAction.first($0) }
            .do(onNext: { _ in activating.onNext(false)})
            .bind(to: mycommenting)
            .disposed(by: disposeBag)
        
        commentingFetching.withLatestFrom(page.asObservable())
            .filter { $0 > 0 }
            .do(onNext: { _ in activating.onNext(true)})
            .map { domain.fetchMyCommenting($0) }
            .flatMap { $0 }
            .do(onNext: { _ in activating.onNext(false)})
            .filter { !$0.data.last }
            .map { LoadMoreAction.loadMore($0) }
            .bind(to: mycommenting)
            .disposed(by: disposeBag)
        
        loadMoreObserver.withLatestFrom(page.asObservable())
            .map { $0 + 1 }
            .do(onNext: { page.onNext($0)})
            .map { Int -> () in }
            .bind(to: commentingFetching)
            .disposed(by: disposeBag)
        
        mycommentingResult = mycommenting.asObserver()
        
        //좋아요 한 글
        fetchMyLiking = likingFetching.asObserver()
        likingFetching.withLatestFrom(page.asObservable())
            .filter { $0 == 0 }
            .do(onNext: { _ in page.onNext(0) })
            .do(onNext: { _ in activating.onNext(true)})
            .map { domain.fetchMyLiking($0) }
            .flatMap { $0 }
            .map { LoadMoreAction.first($0) }
            .do(onNext: { _ in activating.onNext(false)})
            .bind(to: myliking)
            .disposed(by: disposeBag)
        
        likingFetching.withLatestFrom(page.asObservable())
            .filter { $0 > 0 }
            .do(onNext: { _ in activating.onNext(true)})
            .map { domain.fetchMyLiking($0) }
            .flatMap { $0 }
            .do(onNext: { _ in activating.onNext(false)})
            .filter { !$0.data.last }
            .map { LoadMoreAction.loadMore($0) }
            .bind(to: myliking)
            .disposed(by: disposeBag)
        
        loadMoreObserver.withLatestFrom(page.asObservable())
            .map { $0 + 1 }
            .do(onNext: { page.onNext($0)})
            .map { Int -> () in }
            .bind(to: likingFetching)
            .disposed(by: disposeBag)
        
        mylikingResult = myliking.asObserver()
        
        activated = activating.distinctUntilChanged()
    }
}
