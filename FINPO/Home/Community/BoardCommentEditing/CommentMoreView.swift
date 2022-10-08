//
//  CommentMoreView.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/25.
//

import Foundation
import UIKit
import RxSwift

enum isNest {
    case normal(CommentContentDetail)
    case nest(CommentChildDetail)
}

enum MoreList {
    case comment
    case board
    
    var option: [String] {
        switch self {
        case .comment: return ["수정하기", "삭제하기", "신고하기", "차단하기"]
        case .board: return ["글 수정하기", "글 삭제하기", "신고하기", "차단하기"]
        }
    }
    
}

class CommentMoreView: NSObject {
    
    let disposeBag    = DisposeBag()
    var viewController: UIViewController?
    var delegateData  : isNest?
    
    var option     : MoreList?
    let onData     : AnyObserver<CommentContentDetail>
    let nestOnData : AnyObserver<CommentChildDetail>
    //게시글 수정용
    var pageId     : Int?
    var boardData  : CommunityContentModel?
    
    override init() {

        let data       = PublishSubject<CommentContentDetail>()
        let outputInfo = PublishSubject<CommentContentDetail>()
        let nestData   = PublishSubject<CommentChildDetail>()
        let nestOutputInfo = PublishSubject<CommentChildDetail>()
        
        onData     = data.asObserver()
        nestOnData = nestData.asObserver()
        
        data
            .map { $0 }
            .debug()
            .bind { outputInfo.onNext($0) }
            .disposed(by: disposeBag)
        
        nestData
            .map { $0 }
            .bind { nestOutputInfo.onNext($0) }
            .disposed(by: disposeBag)

        super.init()
        
        outputInfo
            .debug()
            .bind { data in
                self.delegateData = .normal(data)
            }.disposed(by: disposeBag)
            
        
        nestOutputInfo
            .bind { data in
                self.delegateData = .nest(data)
            }.disposed(by: disposeBag)
        
    }
    
    public lazy var moreView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.bounces = false
        view.layer.masksToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.cornerRadius = 5
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    public var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray.withAlphaComponent(0.1)
        return view
    }()
    
    func showView(to cell: UITableViewCell, on vc: UIViewController?, option: MoreList, pageId: Int?, boardData: CommunityContentModel?) {
        self.viewController = vc
        self.option = option
  
        
        switch option {
        case .comment:
            cell.contentView.addSubview(backgroundView)
            backgroundView.frame = cell.bounds

            cell.contentView.addSubview(moreView)
            moreView.frame = CGRect(x: cell.bounds.maxX-100, y: 5, width: 80, height: 100)
        case .board:
            self.pageId = pageId
            self.boardData = boardData
            guard let targetView = vc?.view else { return }
            targetView.addSubview(backgroundView)
            backgroundView.frame = targetView.bounds
            
            targetView.addSubview(moreView)
            moreView.frame = CGRect(x: targetView.bounds.maxX-100, y: targetView.bounds.minY+85, width: 80, height: 100)
        }

        
    }
    
}

extension CommentMoreView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        if let option = option?.option {
            cell.textLabel?.text = option[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let option = option?.option {
            return option.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.moreView.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
        guard let option = option else { return }
        switch option {
        case .board:
            //게시글 수정
            if indexPath.row == 0 {
                if let isMine = self.boardData?.isMine, !isMine {
                    self.viewController?.showAlert("자신의 글만 수정할 수 있습니다.", "글 수정 실패")
                    return
                }
                let vc = BoardEditViewController(pageId: pageId ?? -1)
                vc.modalPresentationStyle = .fullScreen
                self.viewController?.navigationController?.pushViewController(vc, animated: true)
            }
            // 게시글 삭제
            else if indexPath.row == 1 {
                if let isMine = self.boardData?.isMine, !isMine {
                    self.viewController?.showAlert("자신의 글만 삭제할 수 있습니다.", "글 삭제 실패")
                    return
                }
                self.viewController?.deleteBoard(id: pageId ?? -1)
            }
            // 게시글 신고
            else if indexPath.row == 2 {
                if let isMine = self.boardData?.isMine, isMine {
                    self.viewController?.showAlert("자신 자신은 신고할 수 없습니다.", "")
                    return
                }
                self.viewController?.showReport(id: .board(pageId ?? -1))
            }
            // 게시글 유저 차단
            else if indexPath.row == 3 {
                if let isMine = self.boardData?.isMine, isMine {
                    self.viewController?.showAlert("자기 자신은 차단할 수 없습니다.", "")
                    return
                }
                self.viewController?.showBlockAlert(id: .board(pageId ?? -1))
            }
        case .comment:
            //댓글 수정
            if indexPath.row == 0 {
                let vc = EditCommentViewController(data: delegateData!)
                vc.modalPresentationStyle = .fullScreen
                self.viewController?.navigationController?.pushViewController(vc, animated: true)
            }
            //댓글 삭제
            else if indexPath.row == 1 {
                if let delegateData = delegateData {
                    switch delegateData {
                    case .normal(let normal):
                        self.viewController?.commentDeleteAlert(id: normal.id)
                    case .nest(let nest):
                        self.viewController?.commentDeleteAlert(id: nest.id ?? -1)
                    }
                }
            }
            //댓글 신고
            else if indexPath.row == 2 {
                if let delegateData = delegateData {
                    switch delegateData {
                    case .normal(let normal):
                        self.viewController?.showReport(id: .comment(normal.id))
                    case .nest(let nest):
                        self.viewController?.showReport(id: .comment(nest.id ?? -1))
                    }
                }
            }
            //댓글 작성 유저 차단
            else if indexPath.row == 3 {
                if let delegateData = delegateData {
                    switch delegateData {
                    case .normal(let normal):
                        if let isMine = normal.isMine, isMine {
                            self.viewController?.showAlert("자기 자신은 차단할 수 없습니다", "")
                            return
                        }
                        self.viewController?.showBlockAlert(id: .comment(normal.id))
                    case .nest(let nest):
                        if let isMine = nest.isMine, isMine {
                            self.viewController?.showAlert("자기 자신은 차단할 수 없습니다", "")
                            return
                        }
                        self.viewController?.showBlockAlert(id: .comment(nest.id ?? -1))
                    }
                }
            }
        }
        
        
    }
    
}
