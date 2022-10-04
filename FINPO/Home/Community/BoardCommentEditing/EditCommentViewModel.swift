//
//  EditCommentViewModel.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/03.
//

import Foundation
import RxSwift
import RxCocoa

protocol EditCommentViewModelType {
    var commentDataObserver: AnyObserver<isNest> { get }
    var editedCommentTextObserver: AnyObserver<String> { get }
    var confirmButtonObserver: AnyObserver<Void> { get }
    
    
    var editButtonTapped: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class EditCommentViewModel: EditCommentViewModelType {
    let disposeBag = DisposeBag()
    
    //INPUT
    var commentDataObserver: AnyObserver<isNest>
    var editedCommentTextObserver: AnyObserver<String>
    var confirmButtonObserver: AnyObserver<Void>
    
    //OUTPUT
    var editButtonTapped: Observable<Bool>
    var errorMessage: Observable<NSError>
    
    init(domain: EditFetchable = EditStore()) {
        let data = PublishSubject<isNest>()
        let text = PublishSubject<String>()
        let confirm = PublishSubject<Void>()
        let id = PublishSubject<Int>()
        
        let editRsl = PublishSubject<Bool>()
        let error = PublishSubject<Error>()
        
        commentDataObserver = data.asObserver() //id 추출
        data
            .map { $0 }
            .map { data -> Int
                in switch data {
            case .normal(let normalId):
                return normalId.id
            case .nest(let nestId):
                return nestId.id ?? -1
            }}
            .bind { id.onNext($0) }
            .disposed(by: disposeBag)
        
        
        editedCommentTextObserver = text.asObserver() //text 추출
        confirmButtonObserver = confirm.asObserver() //확인버튼 이벤트 추출
        
        editButtonTapped = editRsl.asObserver()
        
        errorMessage = error.map { $0 as NSError }
        
        confirm.withLatestFrom(Observable.combineLatest(
            id.asObservable(),
            text.asObservable(), resultSelector: { id, text in (id, text)
        }), resultSelector: { _, element in
            domain.editComment(commentId: element.0, content: element.1)
        })
        .flatMap { $0 }
        .map { $0.success }
        .do(onNext: { if !$0 {
            let err = NSError(domain: "자신이 작성한 글이 아니므로 수정할 수 없습니다", code: -1, userInfo: nil)
            error.onNext(err)
        }})
        .bind { editRsl.onNext($0) }
        .disposed(by: disposeBag)
        

        
//        editRsl
//            .do(onNext: { if !$0 {
//                let err = NSError(domain: "자신이 작성한 글이 아니므로 수정할 수 없습니다", code: -1, userInfo: nil)
//                error.onNext(err)
//            }})
//                .map { $0 }
                
        
        
    }
}
