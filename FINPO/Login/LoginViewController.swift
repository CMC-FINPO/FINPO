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
import GoogleSignIn
import KakaoSDKAuth


class LoginViewController: UIViewController {
    let user = User.instance
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    
    let googleSiginInConfig = GIDConfiguration.init(clientID: "845892149030-nb47tiirkmtqmgs34f7klha903pip0g2.apps.googleusercontent.com")
    
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
    
    private var googleSignUpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "button=google"), for: .normal)
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
            $0.top.equalTo(imageView.snp.bottom).offset(100)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
        
        view.addSubview(appleSignUpButton)
        appleSignUpButton.snp.makeConstraints {
            $0.top.equalTo(kakaoSignUpButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
        
        view.addSubview(googleSignUpButton)
        googleSignUpButton.snp.makeConstraints {
            $0.top.equalTo(appleSignUpButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
       
    }
    
    private func setInputBind() {
        ///카카오 리팩
        kakaoSignUpButton.rx.tap
            .take(1)
            .bind { [weak self] _ in
                self?.viewModel.input.finalSocialSignupCheckObserver.accept(.kakao)
            }
            .disposed(by: disposeBag)
                
        ///구글 리팩 완료
        googleSignUpButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                ///소셜 로그인, 회원가입 리팩토링
                GIDSignIn.sharedInstance.signIn(with: self.googleSiginInConfig, presenting: self) { user, error in
                    guard error == nil else { return }
                    guard let user = user else { return }
                    self.viewModel.input.finalSocialSignupCheckObserver.accept(.google(user))
                }
            }.disposed(by: disposeBag)
        
    }
    
    private func setOutputBind() {
        ///회원가입
        viewModel.output.goKakaoSignUp
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    let vc = LoginDetailViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.goGoogleSignUp
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    let vc = LoginDetailViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.goAppleSignUp
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid {
                    let vc = LoginDetailViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        
        ///재로그인
        viewModel.output.goKakaoLogin
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    print("카카오로그인 -> 토큰 확인 -> 홈 이동")
                    let vc = HomeTapViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.goGoogleLogin
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    let vc = HomeTapViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.goAppleLogin
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    let vc = HomeTapViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        
        //error
        viewModel.output.errorValue.asSignal()
            .emit(onNext: { [weak self] error in
                let ac = UIAlertController(title: "에러", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self?.present(ac, animated: true)
            }).disposed(by: disposeBag)
    }
    
    @objc private func appleSignUpButtonPressed() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        //회원가입 시 리퀘스트 요청?
        authorizationController.performRequests() //요청 보냄
    }

}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    ///현재 화면에서 애플 로그인 화면 띄우기
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            ///Create an account in system
            let userIdentifier = appleIDCredential.user
            
            ///ver1.0.2 애플 재로그인 시 유저정보가 제공되지 않음 -> guard 통과 못함
            let givenName = appleIDCredential.fullName?.givenName ?? ""
            let familyName = appleIDCredential.fullName?.familyName ?? ""
//            viewModel.user.nickname = familyName + givenName
            viewModel.user.name = familyName + givenName
            print("애플로그인 시 저장된 이름: \(viewModel.user.name)")
            
            if let authorizationCode = appleIDCredential.authorizationCode,
               let identifyToken = appleIDCredential.identityToken,
               let authString = String(data: authorizationCode, encoding: .utf8),
               let tokenString = String(data: identifyToken, encoding: .utf8) {
                UserDefaults.standard.setValue(tokenString, forKey: "appleAccessToken")
                UserDefaults.standard.setValue("apple", forKey: "socialType")
                KeyChain.create(key: KeyChain.socialType, token: "apple")
                UserDefaults.standard.setValue(authString, forKey: "authorizationCode")
                
                ///performRequests()시 여기로 들어옴
                self.viewModel.input.finalSocialSignupCheckObserver.accept(.apple(tokenString))
            }
        case let passwordCredential as ASPasswordCredential:
            let userName = passwordCredential.user
            let password = passwordCredential.password
            
            print("username: \(userName)")
            print("password: \(password)")
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("애플 로그인 실패: \(error.localizedDescription)")
    }
}


