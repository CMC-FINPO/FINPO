//
//  LoginBasicInfoViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/06.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class LoginBasicInfoViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewDidLayoutSubviews() {
        nameTextField.addBottomBorder(color: UIColor.systemGray.withAlphaComponent(0.3).cgColor)
        nickNameTextField.addBottomBorder(color: UIColor.systemGray.withAlphaComponent(0.3).cgColor)
        birthTextField.addBottomBorder(color: UIColor.systemGray.withAlphaComponent(0.3).cgColor)
//        emailTextField.addBottomBorder(color: UIColor.systemGray.withAlphaComponent(0.3).cgColor)
    }
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.trackTintColor = UIColor(hexString: "C4C4C5", alpha: 1)
        progressBar.progressTintColor = UIColor(hexString: "5B43EF", alpha: 1)
        progressBar.progress = 2/6
        progressBar.clipsToBounds = true
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "2/6"
        label.textAlignment = .center
        label.textColor = UIColor.systemGray.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "기본 정보를 입력해주세요"
        label.textColor = .black
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private var nameTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = .systemFont(ofSize: 20, weight: .bold)
        tf.borderStyle = .none
        tf.textColor = UIColor.black
        tf.becomeFirstResponder()
        return tf
    }()
    
    private var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private var nickNameTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = .systemFont(ofSize: 20, weight: .bold)
        tf.borderStyle = .none
        tf.textColor = UIColor.black
        return tf
    }()
    
    private var nickNameAlertLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    private var birthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "생년월일"
        return label
    }()
    
    private var birthTextField: UITextField = {
        let tf = UITextField()
        tf.setDatePicker(target: self)
        return tf
    }()
    
    private var genderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "성별"
        return label
    }()
    
    private var maleButton: UIButton = {
        let button = UIButton()
        button.setTitle("남성", for: .normal)
        button.setTitleColor(UIColor.systemGray.withAlphaComponent(0.5), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.5).cgColor
        button.layer.borderWidth = 1.5
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private var femaleButton: UIButton = {
        let button = UIButton()
        button.setTitle("여성", for: .normal)
        button.setTitleColor(UIColor.systemGray.withAlphaComponent(0.5), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.5).cgColor
        button.layer.borderWidth = 1.5
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = true
        return button
    }()
    
//    private var emailLabel: UILabel = {
//        let label = UILabel()
//        label.text = "이메일 주소"
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 15, weight: .medium)
//        return label
//    }()
//
//    private var emailTextField: UITextField = {
//        let tf = UITextField()
//        tf.textAlignment = .left
//        tf.borderStyle = .none
//        tf.font = .systemFont(ofSize: 20, weight: .bold)
//        tf.textColor = .black
//        return tf
//    }()
//
//    private var emailAlertLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .red
//        label.font = .systemFont(ofSize: 12, weight: .light)
//        return label
//    }()
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textColor = UIColor(hexString: "616161")
        button.backgroundColor = UIColor(hexString: "F0F0F0")
        button.layer.cornerRadius = 20
        button.isEnabled = false
        button.layer.masksToBounds = true
        return button
    }()
        
    fileprivate func setAttribute() {
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        [nameTextField, nickNameTextField, birthTextField].forEach {
            $0.delegate = self
        }
    }
    
    fileprivate func setLayout() {
        view.backgroundColor = .white
        
        view.addSubview(progressBar)
        progressBar.layer.cornerRadius = 5
        progressBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(10)
        }
        
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
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
        }
        
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        view.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
        }
        
        view.addSubview(nickNameTextField)
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        view.addSubview(nickNameAlertLabel)
        nickNameAlertLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(15)
        }
        
        view.addSubview(birthLabel)
        birthLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
        }
        
        view.addSubview(birthTextField)
        birthTextField.snp.makeConstraints {
            $0.top.equalTo(birthLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        view.addSubview(genderLabel)
        genderLabel.snp.makeConstraints {
            $0.top.equalTo(birthTextField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
        }
        
        let genderStackView = UIStackView(arrangedSubviews: [femaleButton, maleButton])
        genderStackView.axis = .horizontal
        genderStackView.distribution = .fillEqually
        genderStackView.spacing = 28
        
        view.addSubview(genderStackView)
        genderStackView.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
        
//        view.addSubview(emailLabel)
//        emailLabel.snp.makeConstraints {
//            $0.top.equalTo(genderStackView.snp.bottom).offset(30)
//            $0.leading.equalToSuperview().inset(15)
//        }
//
//        view.addSubview(emailTextField)
//        emailTextField.snp.makeConstraints {
//            $0.top.equalTo(emailLabel.snp.bottom).offset(10)
//            $0.leading.trailing.equalToSuperview().inset(15)
//        }
//
//        view.addSubview(emailAlertLabel)
//        emailAlertLabel.snp.makeConstraints {
//            $0.top.equalTo(emailTextField.snp.bottom).offset(5)
//            $0.leading.equalToSuperview().inset(15)
//        }
//
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
        
    }
    
    fileprivate func setInputBind() {
        
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.nameTextField.text = self.viewModel.user.nickname
//                self.viewModel.input.nameObserver.accept(self.viewModel.user.nickname)
            }).disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent([.editingDidEnd])
            .map { self.nameTextField.text ?? "" }
            .bind(to: viewModel.input.nameObserver)
            .disposed(by: disposeBag)
        
        nickNameTextField.rx.controlEvent([.editingDidEnd])
            .map { self.nickNameTextField.text ?? "" }
            .bind(to: viewModel.input.nickNameObserver)
            .disposed(by: disposeBag)
        
        birthTextField.rx.controlEvent([.editingDidEnd])
            .map { self.birthTextField.text ?? "" }
            .bind(to: viewModel.input.birthObserver)
            .disposed(by: disposeBag)
        
        maleButton.rx.tap
            .map { Gender.male }
            .bind(to: viewModel.input.genderObserver)
            .disposed(by: disposeBag)
        
        femaleButton.rx.tap
            .map { Gender.female }
            .bind(to: viewModel.input.genderObserver)
            .disposed(by: disposeBag)
        
//        emailTextField.rx.controlEvent([.editingDidEnd])
//            .map { self.emailTextField.text ?? "" }
//            .bind(to: viewModel.input.emailObserver)
//            .disposed(by: disposeBag)
        
        confirmButton.rx.tap.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                let vc = LoginRegionViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        
//        viewModel.input.nickNameObserver
//            .asDriver(onErrorJustReturn: "")
//            .drive(onNext: { [weak self] str in
//                self?.nameTextField.text = str
//            }).disposed(by: disposeBag)
        
        viewModel.output.isNicknameValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid { //TEST
                    self?.nickNameTextField.setErrorRight()
                    self?.nickNameLabel.textColor = .red
                    self?.nickNameTextField.addBottomBorder(color: UIColor.red.cgColor)
                    self?.nickNameAlertLabel.text = "중복된 닉네임입니다"
                    self?.nickNameAlertLabel.textColor = .red
                } else {
                    self?.nickNameTextField.setRight()
                    self?.nickNameLabel.textColor = .black
                    self?.nickNameTextField.addBottomBorder(color: UIColor.systemGray.withAlphaComponent(0.2).cgColor)
                    self?.nickNameAlertLabel.text = ""
                    self?.nickNameAlertLabel.textColor = .black
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.genderValid
            .drive(onNext: { [weak self] gender in
                switch gender {
                case .male:
                    self?.maleButton.setTitleColor(UIColor.rgb(red: 95, green: 88, blue: 234), for: .normal)
                    self?.maleButton.backgroundColor = UIColor.rgb(red: 247, green: 246, blue: 253)
                    self?.maleButton.layer.borderColor = UIColor.rgb(red: 203, green: 199, blue: 247).cgColor
                    self?.femaleButton.setTitleColor(.systemGray.withAlphaComponent(0.4), for: .normal)
                    self?.femaleButton.backgroundColor = UIColor.white
                    self?.femaleButton.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.5).cgColor
                case .female:
                    self?.femaleButton.setTitleColor(UIColor.rgb(red: 95, green: 88, blue: 234), for: .normal)
                    self?.femaleButton.backgroundColor = UIColor.rgb(red: 247, green: 246, blue: 253)
                    self?.femaleButton.layer.borderColor = UIColor.rgb(red: 203, green: 199, blue: 247).cgColor
                    self?.maleButton.setTitleColor(.systemGray.withAlphaComponent(0.4), for: .normal)
                    self?.maleButton.backgroundColor = UIColor.white
                    self?.maleButton.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.5).cgColor
                case .none:
                    break
                }
            }).disposed(by: disposeBag)
        
//        viewModel.output.isEmailValid
//            .asDriver(onErrorJustReturn: false)
//            .drive(onNext: { [weak self] valid in
//                if !valid { //TEST
//                    self?.emailTextField.setRight()
//                    self?.emailLabel.textColor = .red
//                    self?.emailTextField.addBottomBorder(color: UIColor.red.cgColor)
//                    self?.emailAlertLabel.text = "중복된 이메일입니다"
//                    self?.emailAlertLabel.textColor = .red
//                } else {
//                    self?.emailTextField.setErrorRight()
//                    self?.emailLabel.textColor = .black
//                    self?.emailTextField.addBottomBorder(color: UIColor.systemGray.withAlphaComponent(0.2).cgColor)
//                    self?.emailAlertLabel.text = ""
//                    self?.emailAlertLabel.textColor = .black
//                }
//            }).disposed(by: disposeBag)
        
//        viewModel.input.nameObserver
//            .asObservable()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] str in
//                guard let self = self else { return }
//                self.nameTextField.text = str
//            })
//            .disposed(by: disposeBag)
        
        viewModel.output.buttonValid
            .drive(onNext: { [weak self] valid in
                if valid {
                    print("방출된 이벤트 받음 -> 버튼 색상 변경 됨")
                    self?.confirmButton.isEnabled = true
                    self?.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                    self?.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                } else {
                    print("방출 이벤트 false!!!!!!")
                    self?.confirmButton.isEnabled = false
                    self?.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                    self?.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .normal)
                }
            }).disposed(by: disposeBag)
        
    }
        
}

extension LoginBasicInfoViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
