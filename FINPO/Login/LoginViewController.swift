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
        //TODO: 로그아웃 후 재 로그인 했을 때, HomeVC로 이동
                                
        //KAKAO
        kakaoSignUpButton.rx.tap
            .take(1)
            .bind(to: viewModel.input.kakaoSignUpObserver)
            .disposed(by: disposeBag)
        
        googleSignUpButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                GIDSignIn.sharedInstance.signIn(with: self.googleSiginInConfig, presenting: self) { user, error in
                    guard error == nil else { return }
                    guard let user = user else { return }
                    self.viewModel.input.googleSignUpObserver.accept(user)
                }
            }.disposed(by: disposeBag)
        
    }
    
    private func setOutputBind() {
        viewModel.output.goKakaoSignUp
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    if(AuthApi.hasToken()) {
                        let vc = HomeTapViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                    }
                    let vc = LoginDetailViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.goGoogleSignUp
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    let accessToken = UserDefaults.standard.object(forKey: "accessToken") as? String
                    //TODO: 여기 accessToken 비교부분 비교 대상이 이상함(소셜토큰과 유저디폴트 토큰은 다름)
                    if(accessToken == self?.user.accessTokenFromSocial) {
                        let vc = HomeTapViewController()
                        self?.present(vc, animated: true, completion: nil)
                        return
                    }
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
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            //Create an account in system
            let userIdentifier = appleIDCredential.user
            let nickName = appleIDCredential.fullName?.nickname
            let email = appleIDCredential.email
            
            if let authorizationCode = appleIDCredential.authorizationCode,
               let identifyToken = appleIDCredential.identityToken,
               let authString = String(data: authorizationCode, encoding: .utf8),
               let tokenString = String(data: identifyToken, encoding: .utf8) {
                
                print("authorizationCode: \(authorizationCode)")
                print("identifyToken: \(identifyToken)")
                print("authString: \(authString)")
                print("tokenString: \(tokenString)")
                UserDefaults.standard.setValue("apple", forKey: "socialType")
                LoginViewModel.socialType = "apple"
                viewModel.input.nickNameObserver.accept(nickName ?? "")
                viewModel.user.accessTokenFromSocial = tokenString
                if(userIdentifier != "") {
                    viewModel.input.appleSignUpObserver.accept(())
                }
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
