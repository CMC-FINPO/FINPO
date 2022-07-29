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
    
    private var verticalStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        
        return sv
    }()
    
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
//        flow.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        flow.minimumInteritemSpacing = 5
//        flow.minimumLineSpacing = 3
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsLargeContentViewer = false
        cv.isUserInteractionEnabled = false
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
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 50)
        flow.scrollDirection = .vertical
        flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.layer.masksToBounds = true
        cv.layer.cornerRadius = 5
        cv.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.3)
        return cv
    }()
    
    public var serviceInfoTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 50
        tv.separatorInset.left = 0
        tv.bounces = false
        tv.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.3)
        tv.layer.masksToBounds = true
        tv.layer.cornerRadius = 5
        tv.separatorInset.left = 0
        tv.separatorStyle = UITableViewCell.SeparatorStyle.none
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        return tv
    }()
    
    private let institutionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "494949")
        label.text = "주최/주관 기관"
        return label
    }()
    
    public var institutionNameValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
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
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
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
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
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
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
//            $0.top.leading.trailing.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(view.bounds.height/2 + 150)
        }
//        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
//        contentViewHeight.priority = .defaultLow
//        contentViewHeight.isActive = true
        
        
//        verticalStackView.addArrangedSubview(policyTypeLabel)
        contentView.addSubview(policyTypeLabel)
        policyTypeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
//        verticalStackView.addArrangedSubview(policyTypeCollectionView)
        contentView.addSubview(policyTypeCollectionView)
        policyTypeCollectionView.snp.makeConstraints {
            $0.top.equalTo(policyTypeLabel.snp.bottom).offset(5)
            $0.leading.equalTo(policyTypeLabel.snp.leading)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24) //cell 23
        }
        
//        verticalStackView.addArrangedSubview(serviceInfoLabel)
        contentView.addSubview(serviceInfoLabel)
        serviceInfoLabel.snp.makeConstraints {
            $0.top.equalTo(policyTypeCollectionView.snp.bottom).offset(15)
            $0.leading.equalTo(policyTypeLabel.snp.leading)
        }
        
//        verticalStackView.addArrangedSubview(serviceInfoCollectionView)
        contentView.addSubview(serviceInfoTableView)
        serviceInfoTableView.snp.makeConstraints {
            $0.top.equalTo(serviceInfoLabel.snp.bottom).offset(15)
            $0.leading.equalTo(policyTypeLabel.snp.leading)
            $0.trailing.equalTo(view.snp.trailing).inset(20)
//            $0.height.greaterThanOrEqualTo(50)
            $0.bottom.equalTo(serviceInfoLabel.snp.bottom).offset(150)
        }
        
//        verticalStackView.addArrangedSubview(verticalSeparatorLineView)
        contentView.addSubview(verticalSeparatorLineView)
        verticalSeparatorLineView.snp.makeConstraints {
            $0.top.equalTo(serviceInfoTableView.snp.bottom).offset(25)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(60)
        }
        
//        verticalStackView.addArrangedSubview(institutionTitleLabel)
        contentView.addSubview(institutionTitleLabel)
        institutionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(serviceInfoTableView.snp.bottom).offset(25)
            $0.leading.equalTo(policyTypeLabel.snp.leading)
        }
        
//        verticalStackView.addArrangedSubview(institutionNameValueLabel)
        contentView.addSubview(institutionNameValueLabel)
        institutionNameValueLabel.snp.makeConstraints {
            $0.top.equalTo(institutionTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(institutionTitleLabel.snp.leading)
            $0.trailing.equalTo(verticalSeparatorLineView.snp.leading).inset(5)
        }
        
//        verticalStackView.addArrangedSubview(scaleTitleLabel)
        contentView.addSubview(scaleTitleLabel)
        scaleTitleLabel.snp.makeConstraints {
            $0.top.equalTo(institutionTitleLabel.snp.top)
            $0.leading.equalTo(verticalSeparatorLineView.snp.trailing).offset(25)
        }
        
//        verticalStackView.addArrangedSubview(scaleValueLabel)
        contentView.addSubview(scaleValueLabel)
        scaleValueLabel.snp.makeConstraints {
            $0.top.equalTo(scaleTitleLabel.snp.bottom).offset(8).priority(999)
            $0.leading.equalTo(scaleTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(5)
        }
        
//        verticalStackView.addArrangedSubview(supportPeriodTitleLabel)
        contentView.addSubview(supportPeriodTitleLabel)
        supportPeriodTitleLabel.snp.makeConstraints {
            $0.top.equalTo(institutionNameValueLabel.snp.bottom).offset(35)
            $0.leading.equalTo(institutionTitleLabel.snp.leading)
        }
        
//        verticalStackView.addArrangedSubview(supportPeriodValueLabel)
        contentView.addSubview(supportPeriodValueLabel)
        supportPeriodValueLabel.snp.makeConstraints {
            $0.top.equalTo(supportPeriodTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(supportPeriodTitleLabel.snp.leading)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    fileprivate func setInputBind() {
        
    }
    
    fileprivate func setOutputBind() {

    }
}
