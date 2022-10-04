//
//  CommentMoreView.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/25.
//

import Foundation
import UIKit
import RxSwift

class CommentMoreView: NSObject {
    
    let disposeBag = DisposeBag()
    var viewController: UIViewController?
    var delegateData: CommentContentDetail?
    
    let option    = ["수정하기", "삭제하기", "신고하기", "차단하기"]
    let onData    : AnyObserver<CommentContentDetail>
//    let outputData: Observable<CommentContentDetail>
    
    override init() {
        let data       = PublishSubject<CommentContentDetail>()
        let outputInfo = PublishSubject<CommentContentDetail>()
        
        onData     = data.asObserver()
//        outputData = outputInfo.asObservable()
        
        data
            .map { $0 }
            .debug()
            .bind { outputInfo.onNext($0) }
            .disposed(by: disposeBag)

        super.init()
        
        outputInfo
            .debug()
            .bind { data in
                self.delegateData = data
            }
            .disposed(by: disposeBag)
        
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
        cell.contentView.addSubview(backgroundView)
        backgroundView.frame = cell.bounds

        cell.contentView.addSubview(moreView)
        moreView.frame = CGRect(x: cell.bounds.maxX-100, y: 5, width: 80, height: 100)
        
        self.viewController = vc
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
        if indexPath.row == 0 {
            debugPrint("Tapped")
            self.moreView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            let vc = EditCommentViewController(data: delegateData!)
            vc.modalPresentationStyle = .fullScreen
            self.viewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
