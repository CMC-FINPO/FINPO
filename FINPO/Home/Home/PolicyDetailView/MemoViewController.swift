//
//  MemoViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/05.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MemoViewController: UIViewController {
    
    let textViewPlaceHolder = "정책을 참여한 날짜, 이유 등 메모를 남겨보세요"
    
    let disposeBag = DisposeBag()
    var viewModel: HomeViewModel?
    var id: Int?
    var participatedPolicyId: Int?
    
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    let defaultHeight: CGFloat = 300
    let dismissibleHeight: CGFloat = 100
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // keep updated with new height
    var currentContainerHeight: CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardUp(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRectangle = keyboardFrame.cgRectValue
       
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
    
    func setupProperty(id: Int, on viewModel: HomeViewModel, participatedId: Int) {
        self.id = id
        self.viewModel = viewModel
        self.participatedPolicyId = participatedId
    }
    
    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    let maxDimmedAlpha: CGFloat = 0.6
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "메모 작성"
        label.textColor = UIColor(hexString: "000000")
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        return label
    }()
    
    private var separatorLineView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        return separator
    }()
    
    private var memoTextView: UITextView = {
        let tv = UITextView()
        tv.text = "정책을 참여한 날짜, 이유 등 메모를 남겨보세요"
        return tv
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private var acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("작성하기", for: .normal)
        button.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
        button.setBackgroundColor(UIColor(hexString: "5B43EF"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 3
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    fileprivate func setAttribute() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(animateDismissView))
        dimmedView.addGestureRecognizer(gesture)
        memoTextView.delegate = self
    }
    
    fileprivate func setLayout() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // 6. Set container to default height
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        // 7. Set bottom constant to 0 -> defaultHeight
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.safeAreaLayoutGuide.snp.top).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        containerView.addSubview(separatorLineView)
        separatorLineView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        containerView.addSubview(memoTextView)
        memoTextView.snp.makeConstraints {
            $0.top.equalTo(separatorLineView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(120)
        }
        
        containerView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(memoTextView.snp.bottom).offset(27)
            $0.leading.equalTo(memoTextView.snp.leading)
            $0.width.equalTo(168)
            $0.height.equalTo(50)
        }
        
        containerView.addSubview(acceptButton)
        acceptButton.snp.makeConstraints {
            $0.top.equalTo(memoTextView.snp.bottom).offset(27)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(12)
            $0.trailing.equalTo(memoTextView.snp.trailing)
            $0.height.equalTo(50)
        }
        
    }
    
    fileprivate func setInputBind() {
        acceptButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel?.input.memoTextObserver.accept(self.memoTextView.text)
                self.viewModel?.input.participatedId.accept(self.participatedPolicyId ?? -1)
            }).disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.animateDismissView()
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        viewModel?.output.checkedMemoOutput
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                print("메모 후 종료")
//                self?.dismiss(animated: true)
                self?.animateDismissView()
                self?.viewModel?.input.memoCheckObserver.accept(())
            }).disposed(by: disposeBag)
    }
    
    @objc func animateDismissView() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
        
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            NotificationCenter.default.post(name: NSNotification.Name("DismissDetailView"), object: nil, userInfo: nil)
            self.dismiss(animated: false)
            
        }
    }
    
}

extension MemoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = UIColor(hexString: "494949")
            textView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = UIColor(hexString: "C4C4C5")
            textView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)
        let characterCount = newString.count
        guard characterCount <= 700 else { return false }
        
        return true
    }
}
