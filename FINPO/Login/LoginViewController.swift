//
//  LoginViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/02.
//

import UIKit
import AuthenticationServices
import Alamofire
import SnapKit
import KakaoSDKUser
import RxSwift
import RxCocoa
import Then

class LoginViewController: UIViewController {
    let user = User.instance
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 20)
        label.textColor = UIColor(hexString: "5B43EF")
        label.text = "내 지원금은 내가 챙기자!"
        return label
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loginlogo")
        return imageView
    }()
    
    private var kakaoSignUpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "button=kakao"), for: .normal)
        return button
    }()
    
    private var appleSignUpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "button=apple"), for: .normal)
        return button
    }()

    private func setAttribute() {
        view.backgroundColor = .white
        appleSignUpButton.addTarget(self, action: #selector(appleSignUpButtonPressed), for: .touchUpInside)

    }
    
    private func setLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(270)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.centerX.equalToSuperview().offset(5) //이미지와 텍스트 중앙안맞음
            $0.width.equalTo(209)
            $0.height.equalTo(47)
        }
        
        view.addSubview(kakaoSignUpButton)
        kakaoSignUpButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(147)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
        
        view.addSubview(appleSignUpButton)
        appleSignUpButton.snp.makeConstraints {
            $0.top.equalTo(kakaoSignUpButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
        
       
    }
    
    private func setInputBind() {
        //TODO: apple Sign in Rx extension
        //appleSignUpButton.rx.tap
        
        //KAKAO
        kakaoSignUpButton.rx.tap
            .bind(to: viewModel.input.kakaoSignUpObserver)
            .disposed(by: disposeBag)
    }
    
    private func setOutputBind() {
        viewModel.output.goKakaoSignUp
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    let accesstoken = UserDefaults.standard.object(forKey: "accessToken") as? String
                    if(accesstoken == self?.user.accessTokenFromKAKAO) {
                        let vc = HomeTapViewController()
                        self?.present(vc, animated: true)
                        return
                    }
                    let vc = LoginDetailViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        //error
        viewModel.output.errorValue.asSignal()
            .emit(onNext: { [weak self] error in
                let ac = UIAlertController(title: "에러", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self?.present(ac, animated: true)
            }).disposed(by: disposeBag)
    }
    
    @objc private func appleSignUpButtonPressed() {
        //TODO: move to nextVC
    }
    
//    private func setUserInfo() {
//        UserApi.shared.me { user, error in
//            if let error = error {
//                print(error)
//            }
//            else {
//                print("me() access")
//                //do something
//                _ = user
//                print("\(user?.kakaoAccount?.profile?.nickname)")
//                if let url = user?.kakaoAccount?.profile?.profileImageUrl,
//                   let data = try? Data(contentsOf: url) {
//                    print(data)
//                }
//            }
//        }
//    }

}

