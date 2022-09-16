//
//  LoginDetailViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/02.
//

import Foundation
import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

class LoginDetailViewController: UIViewController {
    
    static var isCMAllow = false
    
    var viewModel = LoginDetailViewModel()
    let disposebag = DisposeBag()
    var isCheckedBtnAllAccept: Bool = false {
        didSet {
            let checkImageName = isCheckedBtnAllAccept ? "check1_active" : "check1_inactive"
            allAcceptButton.setImage(UIImage(named: checkImageName), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.trackTintColor = UIColor.G05
        progressBar.progressTintColor = UIColor.P01
        progressBar.progress = 1/6
        progressBar.clipsToBounds = true
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.G05
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.text = "1/6"
        return label
    }()
        
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        label.text = "약관에 동의해주세요"
        return label
    }()
    
    private var allAcceptButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "check1_inactive"), for: .normal)
        return button
    }()
    
    private var allAcceptLabel: UILabel = {
        let label = UILabel()
        label.text = "약관 전체 동의"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private var separatorLineView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        return separator
    }()
    
    private var tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        return tv
    }()
    
    private var acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("동의하기", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.backgroundColor = UIColor.G08
        return button
    }()
    
    fileprivate func setAttribute() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        tableView.delegate = self
        tableView.dataSource = self
        let nibName = String(describing: TermsCell.self)
        tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
        acceptButton.setBackgroundColor(UIColor.P01, for: .normal)
        acceptButton.setTitleColor(UIColor.W01, for: .normal)
        acceptButton.setBackgroundColor(UIColor.G08, for: .disabled)
        acceptButton.setTitleColor(UIColor.G02, for: .disabled)
    }
    
    fileprivate func setLayout() {
        view.backgroundColor = .white
        
        view.addSubview(progressBar)
        progressBar.layer.cornerRadius = 3
        progressBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(5)
        }
        
        view.addSubview(progressLabel)
        progressLabel.snp.makeConstraints {
            $0.centerY.equalTo(progressBar.snp.centerY)
            $0.leading.equalTo(progressBar.snp.trailing).offset(15)
            $0.height.equalTo(15)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(21)
        }
        
        view.addSubview(allAcceptButton)
        allAcceptButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(35)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.height.equalTo(25)
            $0.width.equalTo(25)
        }
//        allAcceptButton.layer.cornerRadius = 15
        
        view.addSubview(allAcceptLabel)
        allAcceptLabel.snp.makeConstraints {
            $0.leading.equalTo(allAcceptButton.snp.trailing).offset(15)
            $0.centerY.equalTo(allAcceptButton.snp.centerY)
        }
        
        view.addSubview(separatorLineView)
        separatorLineView.snp.makeConstraints {
            $0.top.equalTo(allAcceptButton.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(1)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(separatorLineView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(300)
        }
        
        view.addSubview(acceptButton)
        acceptButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(15)
        }

    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver(onErrorRecover: { _ in
            return .never()})
        .drive(onNext: { [weak self] _ in
            self?.viewModel.viewWillAppear() //get data from Terms Model
        }).disposed(by: disposebag)
        
        allAcceptButton.rx.tap.asDriver(onErrorRecover: { _ in
            return .never()})
        .drive(onNext: { [weak self] _ in
            self?.isCheckedBtnAllAccept.toggle()
            self?.viewModel.accpetAllTerms(self?.isCheckedBtnAllAccept)
        }).disposed(by: disposebag)
        
        acceptButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let vc = LoginBasicInfoViewController()
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposebag)
                        
    }
    
    fileprivate func setOutputBind() {
        viewModel.updateTermsContents.asDriver(onErrorRecover: { _ in
            return .never()})
        .drive(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposebag)
        
        viewModel.satisfyTermsPermission.asDriver(onErrorRecover: { _ in
            return .never()})
        .drive(onNext: { [weak self] isSatisfy in
            self?.acceptButton.isEnabled = isSatisfy
        }).disposed(by: disposebag)
        
        viewModel.acceptAllTerms.asDriver(onErrorRecover: { _ in
            return .never()})
        .drive(onNext: { [weak self] isAcceptAllTerms in
            self?.isCheckedBtnAllAccept = isAcceptAllTerms
        }).disposed(by: disposebag)
    }
    
}

extension LoginDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TermsCell.self)) as! TermsCell
        cell.selectionStyle = .none
        
        if(indexPath.section == 0) {
            cell.moveToButton.rx.tap.asDriver { _ in return .never()}
                .drive(onNext: { _ in
                    let link = BaseURL.agreement
                    if let url = URL(string: link) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }).disposed(by: cell.bag)
        }
        
        if(indexPath.section == 1) {
            cell.moveToButton.rx.tap.asDriver { _ in return .never()}
                .drive(onNext: { _ in
                    let link = BaseURL.personalInfo
                    if let url = URL(string: link) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }).disposed(by: cell.bag)
        }
        
        if(indexPath.section == 2) {
            cell.moveToButton.isHidden = true
        }

        cell.bind(viewModel.dataSource[indexPath.section][indexPath.row])
        cell.btnCheck.rx.tap.asDriver(onErrorRecover: { _ in return .never()})
            .drive(onNext: { [weak self] in
                self?.viewModel.didSelectTermsCell(indexPath: indexPath)
            }).disposed(by: cell.bag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectTermsCell(indexPath: indexPath)
    }
    
}
