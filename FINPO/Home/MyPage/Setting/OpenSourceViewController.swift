//
//  OpenSourceViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/20.
//

/*
 
 HomeBrew - https://github.com/mono0926/LicensePlist
 사용으로 인해 미사용
  
 */

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class OpenSourceViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = CategoryAlarmViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var openAPITableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.bounces = false
        tv.separatorInset.left = 0
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        tv.layer.masksToBounds = true
        tv.layer.cornerRadius = 5
        return tv
    }()
    
    fileprivate func setAttribute() {
        
    }
    
    fileprivate func setLayout() {
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                self?.viewModel.input.openAPIObserver.accept(())
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.sendOpenAPI
            .scan(into: [OpenAPIDataDetail](), accumulator: { models, action in
                switch action {
                case .server(let fromServer):
                    for i in 0..<(fromServer.data.count) {
                        models.append(fromServer.data[i])
                    }
                case .ios:
                    break
                }
            })
            .asObservable()
            .subscribe(onNext: { [weak self] data in
                
            }).disposed(by: disposeBag)
    }
    
}
