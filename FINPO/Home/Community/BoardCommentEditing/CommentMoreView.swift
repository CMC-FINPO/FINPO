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

class CommentMoreView: NSObject {
    
    let disposeBag    = DisposeBag()
    var viewController: UIViewController?
    var delegateData  : isNest?
    
    let option     = ["수정하기", "삭제하기", "신고하기", "차단하기"]
    let onData     : AnyObserver<CommentContentDetail>
    let nestOnData : AnyObserver<CommentChildDetail>
    
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
        view.backgroundColor = .green
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
    
    func showView(to cell: UITableViewCell, on vc: UIViewController?) {
        self.viewController = vc
        cell.contentView.addSubview(backgroundView)
        backgroundView.frame = cell.bounds

        cell.contentView.addSubview(moreView)
        moreView.frame = CGRect(x: cell.bounds.maxX-100, y: 5, width: 80, height: 100)
        
    }
    
}

extension CommentMoreView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        cell.textLabel?.text = option[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return option.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.moreView.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
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
                    self.viewController?.showReport(id: normal.id)
                case .nest(let nest):
                    self.viewController?.showReport(id: nest.id ?? -1)
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
                    self.viewController?.showBlockAlert(id: normal.id)
                case .nest(let nest):
                    if let isMine = nest.isMine, isMine {
                        self.viewController?.showAlert("자기 자신은 차단할 수 없습니다", "")
                        return
                    }
                    self.viewController?.showBlockAlert(id: nest.id ?? -1)
                }
            }
        }
        
    }
    
}
