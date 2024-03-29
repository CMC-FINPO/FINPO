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

final class LoginBasicInfoViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    var user = User.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewDidLayoutSubviews() {
        nameTextField.addBottomBorder(color: UIColor.G07.cgColor)
        nickNameTextField.addBottomBorder(color: UIColor.G07.cgColor)
        birthTextField.addBottomBorder(color: UIColor.G07.cgColor)
//        emailTextField.addBottomBorder(color: UIColor.systemGray.withAlphaComponent(0.3).cgColor)
    }
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.trackTintColor = UIColor.G05
        progressBar.progressTintColor = UIColor.P01
        progressBar.progress = 2/6
        progressBar.clipsToBounds = true
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.G05
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.text = "2/6"
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        label.textColor = .black
        label.text = "기본 정보를 입력해주세요"
        return label
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor.G01
        label.text = "이름"
        return label
    }()
    
    private var nameTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        tf.borderStyle = .none
        tf.textColor = UIColor.B01
        tf.becomeFirstResponder()
        return tf
    }()
    
    private var nameAlertLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textAlignment = .center
        label.textColor = UIColor.E12
        label.text = "13자 이하만 가능해요"
        return label
    }()
    
    private var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor.G01
        return label
    }()
    
    private var nickNameTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        tf.borderStyle = .none
        tf.textColor = UIColor.black
        return tf
    }()
    
    private var nickNameAlertLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textAlignment = .center
        label.textColor = UIColor.E12
        return label
    }()
    
    private var birthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "생년월일"
        label.textColor = UIColor.G01
        return label
    }()
    
    private var birthTextField: UITextField = {
        let tf = UITextField()
        tf.setDatePicker(target: self)
        return tf
    }()
    
    private var genderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.G01
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.text = "성별"
        return label
    }()
    
    private var maleButton: UIButton = {
        let button = UIButton()
        button.setTitle("남성", for: .normal)
        button.setTitleColor(UIColor.G02, for: .normal)
        button.setTitleColor(UIColor.G02, for: .disabled)
        button.setTitleColor(UIColor.P01, for: .selected)
        button.setBackgroundColor(UIColor.P01.withAlphaComponent(0.1), for: .selected)
        button.setBackgroundColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.G06.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private var femaleButton: UIButton = {
        let button = UIButton()
        button.setTitle("여성", for: .normal)
        button.setTitleColor(UIColor.G02, for: .normal)
        button.setTitleColor(UIColor.G02, for: .disabled)
        button.setTitleColor(UIColor.P01, for: .selected)
        button.setBackgroundColor(UIColor.P01.withAlphaComponent(0.1), for: .selected)
        button.setBackgroundColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.G06.cgColor
        button.layer.borderWidth = 1
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
        button.setTitleColor(UIColor.G02, for: .normal)
        button.backgroundColor = UIColor.G08
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.layer.masksToBounds = true
        return button
    }()
        
    fileprivate func setAttribute() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        [nameTextField, nickNameTextField, birthTextField].forEach {
            $0.delegate = self
        }
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
            $0.leading.equalToSuperview().offset(15)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
        }
        
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        view.addSubview(nameAlertLabel)
        nameAlertLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(5)
            $0.leading.equalTo(nameTextField.snp.leading)
        }
        
        view.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
        }
        
        view.addSubview(nickNameTextField)
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(6)
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
            $0.top.equalTo(birthLabel.snp.bottom).offset(6)
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
        genderStackView.spacing = 15
        
        view.addSubview(genderStackView)
        genderStackView.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(8)
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
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(50)
        }
        
    }
    
    fileprivate func setInputBind() {
        
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let socialType = KeyChain.read(key: KeyChain.socialType)
                print("이름가져오기: \(socialType ?? "ㅋ")")
                print("이름: \(self.viewModel.user.name)")
                if(socialType == "apple") {
                    self.nameTextField.text = self.viewModel.user.name
                } else {
                    self.nickNameTextField.text = self.viewModel.user.nickname
                    self.viewModel.input.nickNameObserver.accept(self.nickNameTextField.text ?? "")
                }
            }).disposed(by: disposeBag)
        
//        nameTextField.rx.text
//            .orEmpty
//            .bind(to: viewModel.input.nameObserver)
//            .disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent([.editingChanged, .editingDidEnd])
            .map { self.nameTextField.text ?? "" }
            .bind(to: viewModel.input.nameObserver)
            .disposed(by: disposeBag)
        
//        nickNameTextField.rx.controlEvent([.editingDidEnd])
//            .map { self.nickNameTextField.text ?? "" }
//            .bind(to: viewModel.input.nickNameObserver)
//            .disposed(by: disposeBag)
        
        nickNameTextField.rx.controlEvent([.editingChanged, .editingDidEnd])
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
//                print("아웃풋 닉네임")
//                self?.nickNameTextField.text = str
//            }).disposed(by: disposeBag)
        
        viewModel.output.isNameValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
//                    self?.nameTextField.setRight()
                    self?.nameAlertLabel.isHidden = true
                    self?.nameLabel.textColor = UIColor.G01
                    self?.nameTextField.addBottomBorder(color: UIColor.G07.cgColor)
                } else { //13자 이상(false)
//                    self?.nameTextField.setErrorRight()
                    self?.nameAlertLabel.isHidden = false
                    self?.nameLabel.textColor = UIColor.E12
                    self?.nameTextField.addBottomBorder(color: UIColor.E12.cgColor)
                    self?.nameTextField.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.isNicknameValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    self?.nickNameAlertLabel.isHidden = false
                    self?.nickNameTextField.setErrorRight()
                    self?.nickNameLabel.textColor = .red
                    self?.nickNameTextField.addBottomBorder(color: UIColor.E12.cgColor)
                    self?.nickNameAlertLabel.text = "중복된 닉네임입니다"
                    self?.nickNameAlertLabel.textColor = UIColor.E12
                } else {
                    if(self?.nickNameTextField.text == "") { return }
                    else {
                        self?.nickNameTextField.setRight()
                        self?.nickNameLabel.textColor = UIColor.G01
                        self?.nickNameTextField.addBottomBorder(color: UIColor.G07.cgColor)
                        self?.nickNameAlertLabel.isHidden = true
                    }
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.genderValid
            .drive(onNext: { [weak self] gender in
                guard let self = self else { return }
                switch gender {
                case .male:
                    self.maleButton.isSelected = true
                    self.maleButton.layer.borderColor = UIColor.P01.cgColor
                    self.femaleButton.isSelected = false
                    self.femaleButton.layer.borderColor = UIColor.G06.cgColor
                case .female:
                    self.femaleButton.isSelected = true
                    self.femaleButton.layer.borderColor = UIColor.P01.cgColor
                    self.maleButton.isSelected = false
                    self.maleButton.layer.borderColor = UIColor.G06.cgColor
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
                    self?.confirmButton.backgroundColor = UIColor.P01
                    self?.confirmButton.setTitleColor(UIColor.W01, for: .normal)
                } else {
                    print("방출 이벤트 false!!!!!!")
                    self?.confirmButton.isEnabled = false
                    self?.confirmButton.backgroundColor = UIColor.G08
                    self?.confirmButton.setTitleColor(UIColor.G02, for: .normal)
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
        if(textField == self.nameTextField) {
            self.nickNameTextField.becomeFirstResponder()
        } else if(textField == self.nickNameTextField) {
            self.birthTextField.becomeFirstResponder()
        }
        return true
    }
}
