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
    
    var user = User.instance
    
    let disposeBag = DisposeBag()
    let viewModel = CategoryAlarmViewModel()
    
    var listData = ["내 정보 수정", "광고성 정보 수신", "댓글 알림", "관심 분야 알림 설정", "지역 알림 설정", "커뮤니티 이용 수칙", "신고 이유", "이용 약관", "문의하기", "개인정보 처리 방침", "로그아웃", "회원 탈퇴"]
    
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
            cell.controlSwitch.isHidden = false
            viewModel.output.sendResultCategory
                .subscribe(onNext: { interestModels in
                    let isSubscribed = interestModels.data.adSubscribe ?? false
                    cell.controlSwitch.isOn = isSubscribed
                    
                    if(isSubscribed) {
                        cell.controlSwitch.thumbTintColor = UIColor.P01
                        cell.controlSwitch.onTintColor = UIColor.G08
                    } else {
                        cell.controlSwitch.thumbTintColor = UIColor.G05
                        cell.controlSwitch.onTintColor = UIColor.G08
                    }
                }).disposed(by: self.disposeBag)
            cell.controlSwitch.rx.isOn.changed
                .asDriver()
                .drive(onNext: { boolean in
                    boolean ? FCMAPI.adSubscribe(valid: boolean) : FCMAPI.adSubscribe(valid: boolean)
                    if(boolean) {
                        cell.controlSwitch.thumbTintColor = UIColor.P01
                        cell.controlSwitch.onTintColor = UIColor.G08
                    } else {
                        cell.controlSwitch.thumbTintColor = UIColor.G05
                        cell.controlSwitch.onTintColor = UIColor.G08
                    }
                }).disposed(by: cell.disposeBag)
        }
        //댓글 알림
        if(indexPath.row == 2) {
            cell.controlSwitch.isHidden = false
            viewModel.output.sendResultCategory
                .bind { commentModel in
                    if let isAllowed = commentModel.data.communitySubscribe, isAllowed {
                        cell.controlSwitch.isOn = isAllowed
                        cell.controlSwitch.thumbTintColor = UIColor.P01
                        cell.controlSwitch.onTintColor = UIColor.G08
                    } else {
                        cell.controlSwitch.isOn = false
                        cell.controlSwitch.thumbTintColor = UIColor.G05
                        cell.controlSwitch.onTintColor = UIColor.G08
                    }
                }.disposed(by: cell.disposeBag)
            
            cell.controlSwitch.rx.isOn.changed
                .asDriver()
                .drive(onNext: { willChange in
                    FCMAPI.commentSubscribe(valid: willChange)
                    if(willChange) {
                        cell.controlSwitch.thumbTintColor = UIColor.P01
                        cell.controlSwitch.onTintColor = UIColor.G08
                    } else {
                        cell.controlSwitch.thumbTintColor = UIColor.G05
                        cell.controlSwitch.onTintColor = UIColor.G08
                    }
                }).disposed(by: cell.disposeBag)
                
        }
        if(indexPath.row == 11) {
            cell.settingNameLabel.textColor = UIColor.G03
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //로그아웃
//        let socialType = UserDefaults.standard.string(forKey: "socialType")
        let socialType = KeyChain.read(key: KeyChain.socialType) ?? ""
        print("소셜타입: \(socialType)")
        
        ///내 정보 수정
        if(indexPath.row == 0) {
            let vc = EditUserInfoViewController()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
                
        ///관심분야(카테고리) 알림 설정
        if(indexPath.row == 3) {
            let vc = CategoryAlarmViewController()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if(indexPath.row == 4) {
            let vc = RegionAlarmViewController()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        ///커뮤니티 이용 약관
        if(indexPath.row == 5) {
            let link = BaseURL.communityInfo
            if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        //이용약관
        if(indexPath.row == 6) {
            let link = BaseURL.agreement
            if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        //신고 이유
        if(indexPath.row == 7) {
            
        }
         
        ///문의하기
        if(indexPath.row == 8) {
            let link = BaseURL.ask
            if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        ///개인정보 처리 방침
        if(indexPath.row == 9) {
            let link = BaseURL.personalInfo
            if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        if(indexPath.row == 10) {
            let ac = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if(socialType == "kakao") {
                    UserApi.shared.logout { error in
                        if let error = error { print(error) }
                        else {
                            print("logout() success.")
                            KeyChain.delete(key: KeyChain.accessToken)
                            let vc = LoginViewController()
                            let navVc = UINavigationController(rootViewController: vc)
                            navVc.modalPresentationStyle = .fullScreen
                            self.present(navVc, animated: true)
                        }
                    }
                }
                
                else if(socialType == "google") {
                    KeyChain.delete(key: KeyChain.accessToken)
                    GIDSignIn.sharedInstance.signOut()
                    print("구글 서버 로그아웃 및 로그아웃 성공! ")
                    let vc = LoginViewController()
                    let navVc = UINavigationController(rootViewController: vc)
                    navVc.modalPresentationStyle = .fullScreen
                    self.present(navVc, animated: true)
                }
                else if(socialType == "apple") {
                    KeyChain.delete(key: KeyChain.accessToken)
                    print("애플 서버 로그아웃 및 로그아웃 성공! ")
                    let vc = LoginViewController()
                    let navVc = UINavigationController(rootViewController: vc)
                    navVc.modalPresentationStyle = .fullScreen
                    self.present(navVc, animated: true)
                }
            }))
            ac.addAction(UIAlertAction(title: "취소", style: .destructive))
            //구글,카카오 로그아웃 후 애플 로그인 시 프로필 클리어
            self.user.profileImg = nil
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = ac.popoverPresentationController {
                      // ActionSheet가 표현되는 위치를 저장해줍니다.
                      popoverController.sourceView = self.view
                      popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                      popoverController.permittedArrowDirections = []
                      self.present(ac, animated: true, completion: nil)
                  }
            } else {
                self.present(ac, animated: true, completion: nil)
            }
        }
    
        //회원탈퇴
        if (indexPath.row == 11) {
            let ac = UIAlertController(title: "회원 탈퇴", message: "저장된 정보가 모두 사라집니다", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if(socialType == "kakao") {
                    ///UserDefaults -> keychain
                    let accessToken = KeyChain.read(key: KeyChain.accessToken) ?? ""
                    SignOutAPI.signoutWithAuthKakao(accessToken: accessToken) { valid in
                        switch valid {
                        case .success(let value):
                            if value {
                                KeyChain.delete(key: KeyChain.accessToken)
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
                                KeyChain.delete(key: KeyChain.accessToken)
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
                                KeyChain.delete(key: KeyChain.accessToken)
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
            //구글,카카오 로그아웃 후 애플 로그인 시 프로필 클리어
            self.user.profileImg = nil
            self.present(ac, animated: true, completion: nil)
        }
    }
        
}
