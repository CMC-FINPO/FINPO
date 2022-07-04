//
//  ApplyInfoViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/02.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ApplyInfoViewController: UIViewController {
    
    var acceptedDetailId: Int?
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    
    func initialize(id: Int) {
        self.acceptedDetailId = id
    }
    
    private let policyLinkTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "신청 사이트"
        return label
    }()
    
    public var policyLinkValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.numberOfLines = 0
        return label
    }()
    
    private let policyProcedureTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "신청 절차"
        return label
    }()
    
    public var policyProcedureValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private let announcementTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "심사 및 발표"
        return label
    }()
    
    public var announcementValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private let etcTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "기타"
        return label
    }()
    
    public var etcValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    fileprivate func setAttribute() {
        
    }
    
    fileprivate func setLayout() {
        view.addSubview(policyLinkTitleLabel)
        policyLinkTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        view.addSubview(policyLinkValueLabel)
        policyLinkValueLabel.snp.makeConstraints {
            $0.top.equalTo(policyLinkTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(policyLinkTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(policyProcedureTitleLabel)
        policyProcedureTitleLabel.snp.makeConstraints {
            $0.top.equalTo(policyLinkValueLabel.snp.bottom).offset(25)
            $0.leading.equalTo(policyLinkValueLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(policyProcedureValueLabel)
        policyProcedureValueLabel.snp.makeConstraints {
            $0.top.equalTo(policyProcedureTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(policyProcedureTitleLabel.snp.leading)
            $0.trailing.equalTo(policyProcedureTitleLabel.snp.trailing)
        }
        
        view.addSubview(announcementTitleLabel)
        announcementTitleLabel.snp.makeConstraints {
            $0.top.equalTo(policyProcedureValueLabel.snp.bottom).offset(25)
            $0.leading.equalTo(policyLinkTitleLabel.snp.leading)
        }
        
        view.addSubview(announcementValueLabel)
        announcementValueLabel.snp.makeConstraints {
            $0.top.equalTo(announcementTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(announcementTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(etcTitleLabel)
        etcTitleLabel.snp.makeConstraints {
            $0.top.equalTo(announcementValueLabel.snp.bottom).offset(25)
            $0.leading.equalTo(policyLinkTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(etcValueLabel)
        etcValueLabel.snp.makeConstraints {
            $0.top.equalTo(etcTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(etcTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver{ _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        
    }
}
