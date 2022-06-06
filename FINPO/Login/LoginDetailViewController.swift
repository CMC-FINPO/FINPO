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
    
    var viewModel = LoginDetailViewModel()
    let disposebag = DisposeBag()
    var isCheckedBtnAllAccept: Bool = false {
        didSet {
            let checkImageName = isCheckedBtnAllAccept ? "checkmark.circle.fill" : "checkmark.circle"
            allAcceptButton.setImage(UIImage(systemName: checkImageName), for: .normal)
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
        progressBar.trackTintColor = .lightGray.withAlphaComponent(0.5)
        progressBar.progressTintColor = .systemPurple
        progressBar.progress = 0.2
        progressBar.clipsToBounds = true
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "1/6"
        label.textAlignment = .center
        label.textColor = UIColor.systemGray.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
        
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "약관에 동의해주세요"
        label.textColor = .black
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private var allAcceptButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
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
        button.layer.cornerRadius = 20
        return button
    }()
    
    
    private func setAttribute() {
        tableView.delegate = self
        tableView.dataSource = self
        let nibName = String(describing: TermsCell.self)
        tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
        acceptButton.setBackgroundColor(.systemBlue, for: .normal)
        acceptButton.setBackgroundColor(.lightGray.withAlphaComponent(0.6), for: .disabled)
    }
    
    private func setLayout() {
        view.backgroundColor = .white
        
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(10)
        }
        progressBar.layer.cornerRadius = 5
        
        view.addSubview(progressLabel)
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.top)
            $0.leading.equalTo(progressBar.snp.trailing).offset(15)
            $0.height.equalTo(10)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
        }
        
        view.addSubview(allAcceptButton)
        allAcceptButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(35)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.height.equalTo(30)
        }
        allAcceptButton.layer.cornerRadius = 15
        
        view.addSubview(allAcceptLabel)
        allAcceptLabel.snp.makeConstraints {
            $0.leading.equalTo(allAcceptButton.snp.trailing).offset(10)
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
    
    private func setInputBind() {
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
    }
    
    private func setOutputBind() {
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
