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
    
    private var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let policyLinkTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "신청 사이트"
        return label
    }()
    
    public var policyOpenURLButton: UIButton = {
        let button = UIButton()
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        button.isHidden = true
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        button.setTitle("바로가기", for: .normal)
        button.sizeToFit()
        button.setTitleColor(UIColor(hexString: "5B43EF"), for: .normal)
        button.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    public var policyLinkValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
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
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
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
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
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
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    public var askLinkButton: UIButton = {
        let button = UIButton()
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        button.isHidden = false
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        button.setTitle("바로가기", for: .normal)
        button.sizeToFit()
        button.setTitleColor(UIColor(hexString: "5B43EF"), for: .normal)
        button.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        return button
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
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(view.bounds.height/2 + 100)
        }
        
        contentView.addSubview(policyLinkTitleLabel)
        policyLinkTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(policyOpenURLButton)
        policyOpenURLButton.snp.makeConstraints {
            $0.top.equalTo(policyLinkTitleLabel.snp.top)
            $0.trailing.equalToSuperview().inset(21)
            $0.width.equalTo(58)
            $0.height.equalTo(22)
        }
        
        contentView.addSubview(policyLinkValueLabel)
        policyLinkValueLabel.snp.makeConstraints {
            $0.top.equalTo(policyLinkTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(policyLinkTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(policyProcedureTitleLabel)
        policyProcedureTitleLabel.snp.makeConstraints {
            $0.top.equalTo(policyLinkValueLabel.snp.bottom).offset(25)
            $0.leading.equalTo(policyLinkValueLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(policyProcedureValueLabel)
        policyProcedureValueLabel.snp.makeConstraints {
            $0.top.equalTo(policyProcedureTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(policyProcedureTitleLabel.snp.leading)
            $0.trailing.equalTo(policyProcedureTitleLabel.snp.trailing)
        }
        
        contentView.addSubview(announcementTitleLabel)
        announcementTitleLabel.snp.makeConstraints {
            $0.top.equalTo(policyProcedureValueLabel.snp.bottom).offset(25)
            $0.leading.equalTo(policyLinkTitleLabel.snp.leading)
        }
        
        contentView.addSubview(announcementValueLabel)
        announcementValueLabel.snp.makeConstraints {
            $0.top.equalTo(announcementTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(announcementTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(etcTitleLabel)
        etcTitleLabel.snp.makeConstraints {
            $0.top.equalTo(announcementValueLabel.snp.bottom).offset(25)
            $0.leading.equalTo(policyLinkTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(etcValueLabel)
        etcValueLabel.snp.makeConstraints {
            $0.top.equalTo(etcTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(etcTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(askLinkButton)
        askLinkButton.snp.makeConstraints {
            $0.top.equalTo(etcTitleLabel.snp.top)
            $0.trailing.equalToSuperview().inset(21)
            $0.width.equalTo(58)
            $0.height.equalTo(22)
        }
        
    }
    
    fileprivate func setInputBind() {
//        rx.viewWillAppear.take(1).asDriver{ _ in return .never()}
//            .drive(onNext: { [weak self] _ in
//                guard let self = self else { return }
//
//            }).disposed(by: disposeBag)
        
        askLinkButton.rx.tap
            .asDriver()
            .drive(onNext: {  _ in
                if let url = URL(string: BaseURL.ask) {
                    UIApplication.shared.open(url, options: [:])
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        
    }
}
