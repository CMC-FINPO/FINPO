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
    //댓글 수정
    var commentDataObserver: AnyObserver<isNest> { get }
    var editedCommentTextObserver: AnyObserver<String> { get }
    var confirmButtonObserver: AnyObserver<Void> { get }
    
    //댓글 신고
    var commentReportObserver: AnyObserver<(commentId: SortIsBoard, reportId: Int)> { get }
    
    var editButtonTapped: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
    
    var reportOutput: Observable<Bool> { get }
}

class EditCommentViewModel: EditCommentViewModelType {
    let disposeBag = DisposeBag()
    
    //INPUT
    var commentDataObserver: AnyObserver<isNest>
    var editedCommentTextObserver: AnyObserver<String>
    var confirmButtonObserver: AnyObserver<Void>
    
    var commentReportObserver: AnyObserver<(commentId: SortIsBoard, reportId: Int)>
    
    //OUTPUT
    var editButtonTapped: Observable<Bool>
    var errorMessage: Observable<NSError>
    
    var reportOutput: Observable<Bool>
    
    init(domain: CommentEditUseCase =
         DefaultEidtUseCase(
            commentEditRepository: DefaultCommentEditRepository(
                commentEditNetworkService: CommentEditNetworkService()))) {
        let data = PublishSubject<isNest>()
        let text = PublishSubject<String>()
        let confirm = PublishSubject<Void>()
        let id = PublishSubject<Int>()
        
        let report = PublishSubject<(commentId: SortIsBoard, reportId: Int)>()
        
        let editRsl = PublishSubject<Bool>()
        let error = PublishSubject<Error>()
        
        let reportRsl = PublishSubject<Bool>()
        
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
        

        commentReportObserver = report.asObserver()
        reportOutput = reportRsl.asObserver()
        
        report
            .flatMap { (sort, reportId) -> Observable<EditResponse> in
                switch sort {
                case .board(let boardId):
                    return domain.reportBoard(pageId: boardId, reportId: reportId)
                case .comment(let commentId):
                    return domain.reportComment(commentId: commentId, reportId: reportId)
                }
            }
            .map { $0 }
            .bind { reportRsl.onNext($0.success) }
            .disposed(by: disposeBag)
                
    }
}
