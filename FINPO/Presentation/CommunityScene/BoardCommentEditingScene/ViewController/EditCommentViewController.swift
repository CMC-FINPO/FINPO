//
//  EditCommentViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/03.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class EditCommentViewController: UIViewController {
    
    let viewModel: EditCommentViewModelType
    let disposeBag = DisposeBag()
    let data: isNest?
    
    init(viewModel: EditCommentViewModelType = EditCommentViewModel(), data: isNest) {
        self.viewModel = viewModel
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = EditCommentViewModel()
        data = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.P01, for: .normal)
        button.setTitle("완료", for: .normal)
        return button
    }()
    
    private lazy var editTextView: UITextView = {
        let view = UITextView()
        view.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        view.returnKeyType = .done
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor.G06.cgColor
        view.layer.borderWidth = 1
        view.delegate = self
        return view
    }()
    
    private var titleText: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        lbl.text = "수정"
        return lbl
    }()
    
    private func setAttribute() {
        view.backgroundColor = UIColor.G09
        
        navigationItem.titleView = titleText
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmButton)
    }
    
    private func setLayout() {
        view.addSubview(editTextView)
        editTextView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(170)
        }
    }
    
    private func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .do(onNext: { [weak self] _ in
                guard let data = self?.data else { return }
                self?.viewModel.commentDataObserver.onNext(data)
            })
            .drive(onNext: { [weak self] _ in
                if let data = self?.data {
                    switch data {
                    case .nest(let nestData):
                        self?.editTextView.text = nestData.content
                    case .normal(let normal):
                        self?.editTextView.text = normal.content
                    }
                }
            }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind(to: viewModel.confirmButtonObserver)
            .disposed(by: disposeBag)
                
        editTextView.rx.text
            .map { $0 ?? "" }
            .distinctUntilChanged()
            .bind(to: viewModel.editedCommentTextObserver)
            .disposed(by: disposeBag)
    }
    
    private func setOutputBind() {
        viewModel.editButtonTapped
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] finished in
                if finished { self?.navigationController?.popViewController(animated: true)}
            }).disposed(by: disposeBag)
        
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] err in
                self?.showAlert("댓글 수정 실패", err)
            }).disposed(by: disposeBag)
    }
}

extension EditCommentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .secondaryLabel else { return }
        textView.text = nil
        textView.textColor = .label
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
