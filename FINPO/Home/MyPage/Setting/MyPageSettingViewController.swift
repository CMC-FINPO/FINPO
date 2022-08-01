//
//  MyPageSettingViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/19.
//

import Foundation
import UIKit
import SnapKit
import KakaoSDKUser
import GoogleSignIn
import RxSwift
import RxCocoa

class MyPageSettingViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = CategoryAlarmViewModel()
    
    var listData = ["내 정보 수정", "광고성 정보 수신", "관심 분야 알림 설정", "지역 알림 설정", "이용 약관", "문의하기", "개인정보 처리 방침", "로그아웃", "회원 탈퇴"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setIntputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private var settingTableView: UITableView = {
        let tv = UITableView()
        tv.separatorInset.left = 0
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        navigationItem.title = "설정"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .black
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    fileprivate func setLayout() {
        view.addSubview(settingTableView)
        settingTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setIntputBind() {
        rx.viewWillAppear.asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                self?.viewModel.input.myInterestCategoryObserver.accept(())
            }).disposed(by: disposeBag)
    }
    
}

extension MyPageSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingTableViewCell
        cell.settingNameLabel.text = listData[indexPath.row]
        if(indexPath.row == 1) {
//            cell.controlSwitch.transform = CGAffineTransform(scaleX: 1.1, y: 1)
            cell.controlSwitch.isHidden = false
            viewModel.output.sendResultCategory
                .subscribe(onNext: { interestModels in
                    let isSubscribed = interestModels.data.adSubscribe ?? false
                    cell.controlSwitch.isOn = isSubscribed
                    
                    if(isSubscribed) {
                        cell.controlSwitch.thumbTintColor = UIColor(hexString: "5B43EF")
                        cell.controlSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                    } else {
                        cell.controlSwitch.thumbTintColor = UIColor(hexString: "C4C4C5")
                        cell.controlSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                    }
                }).disposed(by: self.disposeBag)
            cell.controlSwitch.rx.isOn.changed
                .asDriver()
                .drive(onNext: { boolean in
                    boolean ? FCMAPI.adSubscribe(valid: boolean) : FCMAPI.adSubscribe(valid: boolean)
                    if(boolean) {
                        cell.controlSwitch.thumbTintColor = UIColor(hexString: "5B43EF")
                        cell.controlSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                    } else {
                        cell.controlSwitch.thumbTintColor = UIColor(hexString: "C4C4C5")
                        cell.controlSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                    }
                }).disposed(by: cell.disposeBag)
        }
        if(indexPath.row == 8) {
            cell.settingNameLabel.textColor = UIColor(hexString: "999999")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //로그아웃
        let socialType = UserDefaults.standard.string(forKey: "socialType")
        
        ///내 정보 수정
        if(indexPath.row == 0) {
            let vc = EditUserInfoViewController()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        ///관심분야(카테고리) 알림 설정
        if(indexPath.row == 2) {
            let vc = CategoryAlarmViewController()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if(indexPath.row == 3) {
            let vc = RegionAlarmViewController()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        ///이용약관
        if(indexPath.row == 4) {
            let link = BaseURL.agreement
            if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        ///문의하기
        if(indexPath.row == 5) {
            let link = BaseURL.ask
            if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        ///개인정보 처리 방침
        if(indexPath.row == 6) {
            let link = BaseURL.personalInfo
            if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        ///오픈 소스 라이브러리
//        if(indexPath.row == 7) {
//            
//        }
        
        if(indexPath.row == 7) {
            let ac = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if(socialType == "kakao") {
//                    UserApi.shared.logout { error in
//                        if let error = error { print(error) }
//                        else {
                            print("logout() success.")
                            UserDefaults.standard.setValue(nil, forKey: "accessToken")
                            UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                            let vc = LoginViewController()
                            let navVc = UINavigationController(rootViewController: vc)
                            navVc.modalPresentationStyle = .fullScreen
                            self.present(navVc, animated: true)
//                        }
//                    }
                }
                
                else if(socialType == "google") {
//                    GIDSignIn.sharedInstance.signOut()
                    UserDefaults.standard.setValue(nil, forKey: "accessToken")
                    UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                    print("구글 서버 로그아웃 및 로그아웃 성공! ")
                    let vc = LoginViewController()
                    let navVc = UINavigationController(rootViewController: vc)
                    navVc.modalPresentationStyle = .fullScreen
                    self.present(navVc, animated: true)
                }
                else if(socialType == "apple") {
                    UserDefaults.standard.setValue(nil, forKey: "accessToken")
                    UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                    print("애플 서버 로그아웃 및 로그아웃 성공! ")
                    let vc = LoginViewController()
                    let navVc = UINavigationController(rootViewController: vc)
                    navVc.modalPresentationStyle = .fullScreen
                    self.present(navVc, animated: true)
                }
            }))
            ac.addAction(UIAlertAction(title: "취소", style: .destructive))
            self.present(ac, animated: true, completion: nil)
        }
    
        //회원탈퇴
        if (indexPath.row == 8) {
            let ac = UIAlertController(title: "회원 탈퇴", message: "저장된 정보가 모두 사라집니다", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if(socialType == "kakao") {
                    ///UserDefaults -> keychain
                    let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
                    SignOutAPI.signoutWithAuthKakao(accessToken: accessToken) { valid in
                        switch valid {
                        case .success(let value):
                            if value {
                                print("logout() success.")
                                UserDefaults.standard.setValue(nil, forKey: "accessToken")
                                UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                                let vc = LoginViewController()
                                let navVc = UINavigationController(rootViewController: vc)
                                navVc.modalPresentationStyle = .fullScreen
                                self.present(navVc, animated: true)
                            } else { return }
                        case .failure(let error):
                            print("에러 발생: \(error.localizedDescription)")
                        }
                    }
                }
                else if(socialType == "google") {
                    ///UserDefaults -> keychain
                    let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
                    SignOutAPI.signoutWithAuthGoogle(accessToken: accessToken) { valid in
                        switch valid {
                        case .success(let value):
                            if value {
                                print("구글 서버 탈퇴 및 구글 연동 해지 성공! ")
                                UserDefaults.standard.setValue(nil, forKey: "accessToken")
                                UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                                UserDefaults.standard.setValue(nil, forKey: "SocialAccessToken")
                                let vc = LoginViewController()
                                let navVc = UINavigationController(rootViewController: vc)
                                navVc.modalPresentationStyle = .fullScreen
                                self.present(navVc, animated: true)
                            } else {
                                return
                            }
                        case .failure(let error):
                            print("에러 발생: \(error.localizedDescription)")
                        }
                    }
                }
                else if(socialType == "apple") {
                    ///UserDefaults -> keychain
                    let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
                    SignOutAPI.signoutWithAuthApple(accessToken: accessToken) { valid in
                        switch valid {
                        case .success(let value):
                            if value {
                                print("애플 서버 탈퇴 및 애플 연동 해지 성공!")
                                UserDefaults.standard.setValue(nil, forKey: "accessToken")
                                UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                                UserDefaults.standard.setValue(nil, forKey: "SocialAccessToken")
                                let vc = LoginViewController()
                                let navVC = UINavigationController(rootViewController: vc)
                                navVC.modalPresentationStyle = .fullScreen
                                self.present(navVC, animated: true)
                            } else { return }
                        case .failure(let error):
                            print("에러 발생: \(error.localizedDescription)")
                        }
                    }
                }
            }))
            ac.addAction(UIAlertAction(title: "취소", style: .destructive))
            self.present(ac, animated: true, completion: nil)
        }
    }
        
}
