//
//  AlarmViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/11.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class AlarmViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let viewModel = AlarmViewModel()
    
    //네비게이션 Bar 버튼
    var refreshBarButton = UIBarButtonItem()
    var treshBarButton = UIBarButtonItem()
    let refreshButton = UIButton()
    let treshButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        ///네비게이션
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        ///네비게이션 버튼 생성(새로고침, 휴지통)
 
        refreshButton.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        refreshButton.setImage(UIImage(named: "Group 39"), for: .normal)
        refreshBarButton.customView = refreshButton
        
   
        treshButton.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        treshButton.setImage(UIImage(named: "delete"), for: .normal)
        treshBarButton.customView = treshButton
        
        self.navigationItem.rightBarButtonItems = [treshBarButton, refreshBarButton]
    }
    
    fileprivate func setLayout() {
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                self?.viewModel.input.getMyAlarmList.accept(())
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.sendAlarmList
        
    }
}
