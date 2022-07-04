//
//  ServiceInfoViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/02.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ServiceInfoViewController: UIViewController {
    
    var acceptedDetailId: Int?
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    
    func initialize(id: Int) {
        self.acceptedDetailId = id
        print("서비스 인포 뷰 받은 아이디값: \(self.acceptedDetailId)")
    }
    
    private let policyTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "정책 유형"
        label.numberOfLines = 0
        return label
    }()
    
    public var policyTypeCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        flow.minimumInteritemSpacing = 5
        flow.minimumLineSpacing = 3
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsLargeContentViewer = false
        return cv
    }()
    
    private let serviceInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "지원 내용"
        return label
    }()
    
    public var serviceInfoCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        flow.scrollDirection = .horizontal
        flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.layer.masksToBounds = true
        cv.layer.cornerRadius = 5
        cv.isScrollEnabled = false
        cv.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.3)
        return cv
    }()
    
    private let institutionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "주최/주관 기관"
        return label
    }()
    
    var institutionNameValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.numberOfLines = 0
        return label
    }()
    
    private let verticalSeparatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "C4C4C5")
        return view
    }()
    
    private let scaleTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "지원 규모"
        return label
    }()
    
    var scaleValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.numberOfLines = 0
        return label
    }()
    
    private let supportPeriodTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "지원 기간"
        return label
    }()
    
     var supportPeriodValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
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
//        self.serviceInfoCollectionView.register(ServiceTypeCollectionViewCell.self, forCellWithReuseIdentifier: "ServiceTypeCollectionViewCell")
    }
    
    fileprivate func setLayout() {
        view.addSubview(policyTypeLabel)
        policyTypeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(policyTypeCollectionView)
        policyTypeCollectionView.snp.makeConstraints {
            $0.top.equalTo(policyTypeLabel.snp.bottom).offset(5)
            $0.leading.equalTo(policyTypeLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24) //cell 23
        }
        
        view.addSubview(serviceInfoLabel)
        serviceInfoLabel.snp.makeConstraints {
            $0.top.equalTo(policyTypeCollectionView.snp.bottom).offset(15)
            $0.leading.equalTo(policyTypeLabel.snp.leading)
        }
        
        view.addSubview(serviceInfoCollectionView)
        serviceInfoCollectionView.snp.makeConstraints {
            $0.top.equalTo(serviceInfoLabel.snp.bottom).offset(15)
            $0.leading.equalTo(policyTypeLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160)
        }
        
        view.addSubview(verticalSeparatorLineView)
        verticalSeparatorLineView.snp.makeConstraints {
            $0.top.equalTo(serviceInfoCollectionView.snp.bottom).offset(25)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(60)
        }
        
        view.addSubview(institutionTitleLabel)
        institutionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(serviceInfoCollectionView.snp.bottom).offset(25)
            $0.leading.equalTo(policyTypeLabel.snp.leading)
        }
        
        view.addSubview(institutionNameValueLabel)
        institutionNameValueLabel.snp.makeConstraints {
            $0.top.equalTo(institutionTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(institutionTitleLabel.snp.leading)
            $0.trailing.equalTo(verticalSeparatorLineView.snp.leading).inset(5)
        }
        
        view.addSubview(scaleTitleLabel)
        scaleTitleLabel.snp.makeConstraints {
            $0.top.equalTo(institutionTitleLabel.snp.top)
            $0.leading.equalTo(verticalSeparatorLineView.snp.trailing).offset(25)
        }
        
        view.addSubview(scaleValueLabel)
        scaleValueLabel.snp.makeConstraints {
            $0.top.equalTo(scaleTitleLabel.snp.bottom).offset(8).priority(999)
            $0.leading.equalTo(scaleTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(5)
        }
        
        view.addSubview(supportPeriodTitleLabel)
        supportPeriodTitleLabel.snp.makeConstraints {
            $0.top.equalTo(institutionNameValueLabel.snp.bottom).offset(25)
            $0.leading.equalTo(institutionTitleLabel.snp.leading)
        }
        
        view.addSubview(supportPeriodValueLabel)
        supportPeriodValueLabel.snp.makeConstraints {
            $0.top.equalTo(supportPeriodTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(supportPeriodTitleLabel.snp.leading)
        }
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver{ _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
//                guard let id = self.acceptedDetailId else { return }
//                self.viewModel.input.serviceInfoObserver.accept(self.acceptedDetailId ?? 1000)
//                self.viewModel.input.serviceInfoObserver.accept(id)
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
//        viewModel.output.serviceInfoOutput
//            .asObservable()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] data in
//                guard let self = self else { return }
//                self.institutionNameValueLabel.text = data.data.institution ?? ""
//                self.scaleValueLabel.text = "총 \(data.data.supportScale ?? "")"
//                self.supportPeriodValueLabel.text = data.data.modifiedAt ?? "123123"
//            }).disposed(by: disposeBag)
    }
}
