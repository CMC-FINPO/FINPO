//
//  BoardEditViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/06.
//

import Foundation
import RxSwift
import RxCocoa

protocol BoardEditViewModelType {
    var getOriginData: AnyObserver<Int> { get }
    var textObserver : AnyObserver<String> { get }
    var editedImg    : BehaviorRelay<[String]> { get }
    var selectedImg  : AnyObserver<[UIImage]> { get }
    var uploadObserver: AnyObserver<Void> { get }
    
    var originData: PublishRelay<CommunityDetailBoardResponseModel> { get }
    var getOriginText: Observable<String> { get }
    var uploadResult: Observable<Bool> { get }
    var activated : Observable<Bool> { get }
}

class BoardEditViewModel: BoardEditViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT //
    var getOriginData: AnyObserver<Int>
    var textObserver: AnyObserver<String>
    var editedImg    : BehaviorRelay<[String]>
    var selectedImg  : AnyObserver<[UIImage]>
    var uploadObserver: AnyObserver<Void>
    
    // OUTPUT //
    var originData: PublishRelay<CommunityDetailBoardResponseModel>
    var getOriginText: Observable<String>
    var uploadResult: Observable<Bool>
    var activated: Observable<Bool>
    
    init(domain: EditFetchable = EditStore()) {
        let pageId = PublishSubject<Int>()
        let getData = PublishSubject<Int>()
        let getOriginTexts = PublishSubject<String>()
        let texting = PublishSubject<String>()
        let storedImg = BehaviorRelay<[String]>(value: [])
        let selectedImgs = BehaviorSubject<[UIImage]>(value: [])
        let uploadTapped = PublishSubject<Void>()
        
        let originDataSubject = PublishRelay<CommunityDetailBoardResponseModel>()
        let activating = PublishSubject<Bool>()
        
        getOriginData = getData.asObserver()
        getOriginText = getOriginTexts.asObserver()
        
        getData
            .do(onNext: { id in pageId.onNext(id)} )
            .flatMap { domain.getBoardData(pageId: $0) }
            .map { $0 }
            .do(onNext: { getOriginTexts.onNext($0.data.content) })
            .debug()
            .bind { originDataSubject.accept($0) }
            .disposed(by: disposeBag)
        
        originData = originDataSubject
        
        editedImg = storedImg
        
        textObserver = texting.asObserver()
        
        uploadObserver = uploadTapped.asObserver()
        uploadResult = uploadTapped.withLatestFrom(Observable.combineLatest(pageId.asObservable(), texting.asObservable(), editedImg.asObservable(), resultSelector: { pageId, text, imgUrls in
            (pageId, text, imgUrls)
        }))
        .do(onNext: { _ in activating.onNext(true)})
        .flatMap { domain.uploadBoard(pageId: $0, text: $1, imgUrls: $2) }
        .map { $0.data.isMine }
        .do(onNext: { _ in activating.onNext(false)})
        
        activated = activating.distinctUntilChanged()
        
        selectedImg = selectedImgs.asObserver()
        selectedImgs
            .do(onNext: { _ in activating.onNext(true)})
            .flatMap { domain.getImageUrl(imgs: $0) }
            .bind { [weak self] response in
                guard let self = self else { return }
                var originImgs = self.editedImg.value
                originImgs += response.data.imgUrls
                var data = [BoardImgDetail]()
                for i in 0..<originImgs.count {
                    data.append(BoardImgDetail(img: originImgs[i], order: i))
                }
                originDataSubject.accept(CommunityDetailBoardResponseModel(data: BoardDataDetail(status: false, id: -1, content: "", anonymity: false, likes: 0, hits: 0, countOfComment: 0, user: nil, isMine: false, isLiked: false, isBookmarked: false, isModified: false, createdAt: "", modifiedAt: "", imgs: data)))
                activating.onNext(false)
            }
            .disposed(by: disposeBag)
        
        
    }
}
