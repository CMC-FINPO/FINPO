//
//  WriteMySelfViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/14.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

final class WriteMySelfViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let dummyItems = Observable.just([
        " Usage of text input box ",
        " Usage of switch button ",
        " Usage of progress bar ",
        " Usage of text labels ",
        ])
    
    private var boardTableView: UITableView = {
//        let tv = UITableView(frame: self.view.frame, style: .plain)
        let tv = UITableView()
        tv.rowHeight = CGFloat(150)
        tv.bounces = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
        
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        
        boardTableView.register(BoardTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    fileprivate func setLayout() {
        view.addSubview(boardTableView)
        boardTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    fileprivate func setInputBind() {

    }
    
    fileprivate func setOutputBind() {
        dummyItems
            .bind(to: boardTableView.rx.items(cellIdentifier: "cell", cellType: BoardTableViewCell.self)) { (index, element, cell) in
                
            }.disposed(by: disposeBag)
    }
    
}
