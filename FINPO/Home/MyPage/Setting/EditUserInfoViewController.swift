//
//  EditUserInfoViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/15.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class EditUserInfoViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = EditUserInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameTextField.addBottomBorder(color: UIColor(hexString: "EBEBEB").cgColor)
        nickNameTextField.addBottomBorder(color: UIColor(hexString: "EBEBEB").cgColor)
        birthTextField.addBottomBorder(color: UIColor(hexString: "EBEBEB").cgColor)
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "수정할 회원 정보를\n입력해주세요"
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "494949")
        label.text = "이름"
        return label
    }()
    
    private var nameTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        tf.borderStyle = .none
        tf.becomeFirstResponder()
        tf.textColor = UIColor(hexString: "000000")
        return tf
    }()
    
    private var nameAlertLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "FF3C00")
        label.text = "13자 이하만 가능해요"
        return label
    }()
    
    private var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "494949")
        return label
    }()
    
    private var nickNameTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        tf.borderStyle = .none
        tf.textColor = UIColor(hexString: "000000")
        return tf
    }()
    
    private var nickNameAlertLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "FF3C00")
        return label
    }()
    
    private var birthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "494949")
        label.text = "생년월일"
        return label
    }()
    
    private var birthTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        tf.placeholder = "예)2022.07.15"
        tf.textColor = UIColor(hexString: "000000")
        tf.setDatePicker(target: self)
        return tf
    }()
    
    private var genderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "494949")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.text = "성별"
        return label
    }()
    
    private var maleButton: UIButton = {
        let button = UIButton()
        button.setTitle("남성", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .disabled)
        button.setTitleColor(UIColor(hexString: "5B43EF"), for: .selected)
        button.setBackgroundColor(UIColor(hexString: "5B43EF").withAlphaComponent(0.1), for: .selected)
        button.setBackgroundColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private var femaleButton: UIButton = {
        let button = UIButton()
        button.setTitle("여성", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .disabled)
        button.setTitleColor(UIColor(hexString: "5B43EF"), for: .selected)
        button.setBackgroundColor(UIColor(hexString: "5B43EF").withAlphaComponent(0.1), for: .selected)
        button.setBackgroundColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정하기", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.backgroundColor = UIColor(hexString: "F0F0F0")
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        
        ///navigation
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        ///TextField 편의성
        [nameTextField, nickNameTextField, birthTextField].forEach {
            $0.delegate = self
        }
    }
    
    fileprivate func setLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.equalToSuperview().inset(21)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(21)
        }
        
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(21)
        }
        
        view.addSubview(nameAlertLabel)
        nameAlertLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(5)
            $0.leading.equalTo(nameTextField.snp.leading)
        }
        
        view.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(21)
        }
        
        view.addSubview(nickNameTextField)
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(21)
        }
        
        view.addSubview(nickNameAlertLabel)
        nickNameAlertLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(21)
        }
        
        view.addSubview(birthLabel)
        birthLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(21)
        }
        
        view.addSubview(birthTextField)
        birthTextField.snp.makeConstraints {
            $0.top.equalTo(birthLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(21)
        }
        
        view.addSubview(genderLabel)
        genderLabel.snp.makeConstraints {
            $0.top.equalTo(birthTextField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(21)
        }
        
        let genderStackView = UIStackView(arrangedSubviews: [femaleButton, maleButton])
        genderStackView.axis = .horizontal
        genderStackView.distribution = .fillEqually
        genderStackView.spacing = 15
        
        view.addSubview(genderStackView)
        genderStackView.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(50)
        }
        
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
                self.viewModel.input.userInfoObserver.accept(())
                
            }).disposed(by: disposeBag)
        
        nameTextField.rx.text
            .orEmpty
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
        
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.input.didTappedConfirmButton.accept(())
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        ///최초 진입 시 유저 정보 가져오기
        viewModel.output.sendUserInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] userInfo in
                guard let self = self else { return }
                self.nameTextField.text = userInfo.data.name
                
                self.nickNameTextField.text = userInfo.data.nickname
                self.birthTextField.text = userInfo.data.birth
                if(userInfo.data.gender.contains("MALE")) {
                    self.maleButton.isSelected = true
                    self.maleButton.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                    //버튼 활성화
                    self.viewModel.input.genderObserver.accept(.male)
                } else {
                    self.femaleButton.isSelected = true
                    self.femaleButton.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                    //버튼 활성화
                    self.viewModel.input.genderObserver.accept(.female)
                }
                //버튼 활성화
                self.viewModel.output.isNameValid.accept(true)
                self.viewModel.output.isNicknameValid.accept(false)
                self.viewModel.input.birthObserver.accept(userInfo.data.birth)
                
            }).disposed(by: disposeBag)
        
        ///이름
        viewModel.output.isNameValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    self?.nameAlertLabel.isHidden = true
                    self?.nameLabel.textColor = UIColor(hexString: "494949")
                    self?.nameTextField.addBottomBorder(color: UIColor(hexString: "EBEBEB").cgColor)
                } else { //13자 이상(false)
                    self?.nameAlertLabel.isHidden = false
                    self?.nameLabel.textColor = UIColor(hexString: "FF3C00")
                    self?.nameTextField.addBottomBorder(color: UIColor(hexString: "FF3C00", alpha: 1.0).cgColor)
                    self?.nameTextField.layoutIfNeeded()
                    
                }
            }).disposed(by: disposeBag)
        
        ///닉네임
        viewModel.output.isNicknameValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    self?.nickNameAlertLabel.isHidden = false
                    self?.nickNameTextField.setErrorRight()
                    self?.nickNameLabel.textColor = .red
                    self?.nickNameTextField.addBottomBorder(color: UIColor(hexString: "FF3C00", alpha: 1.0).cgColor)
                    self?.nickNameAlertLabel.text = "중복된 닉네임입니다"
                    self?.nickNameAlertLabel.textColor = .red
                } else {
                    if(self?.nickNameTextField.text == "") { return }
                    else {
                        self?.nickNameTextField.setRight()
                        self?.nickNameLabel.textColor = UIColor(hexString: "494949")
                        self?.nickNameTextField.addBottomBorder(color: UIColor(hexString: "EBEBEB").cgColor)
                        self?.nickNameAlertLabel.isHidden = true
                    }
                }
            }).disposed(by: disposeBag)
        

        
        ///성별
        viewModel.output.genderValid
            .drive(onNext: { [weak self] gender in
                guard let self = self else { return }
                switch gender {
                case .male:
                    self.maleButton.isSelected = true
                    self.maleButton.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                    self.femaleButton.isSelected = false
                    self.femaleButton.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
                case .female:
                    self.femaleButton.isSelected = true
                    self.femaleButton.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                    self.maleButton.isSelected = false
                    self.maleButton.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
                case .none:
                    break
                }
            }).disposed(by: disposeBag)
        
        ///버튼 정합성
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
        
        ///서버 송신 후 뷰 pop
        viewModel.output.isCompltedEdit
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid { self.navigationController?.popViewController(animated: true) }
            }).disposed(by: disposeBag)
    }
}

extension EditUserInfoViewController: UITextFieldDelegate {
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
