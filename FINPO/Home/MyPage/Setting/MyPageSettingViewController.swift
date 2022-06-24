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

class MyPageSettingViewController: UIViewController {
    
    var listData = ["내 정보 수정", "광고성 정보 수신", "커뮤니티 이용 수칙", "신고 이유", "이용 약관", "문의하기", "개인정보 처리 방침", "오픈 소스 라이브러리", "로그아웃", "회원 탈퇴"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
    }
    
    private var settingTableView: UITableView = {
        let tv = UITableView()
        
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        navigationItem.title = "설정"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .black
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.inputViewController?.hidesBottomBarWhenPushed = true
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //로그아웃
        if (indexPath.row == 8) {
            let ac = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if(LoginViewModel.socialType == "kakao") {
                    UserApi.shared.logout { error in
                        if let error = error { print(error) }
                        else {
                            print("logout() success.")
//                            UserDefaults.standard.setValue(nil, forKey: "accessToken")
//                            UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                            let vc = LoginViewController()
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        }
                    }
                }
                
                else if(LoginViewModel.socialType == "google") {
                    GIDSignIn.sharedInstance.signOut()
                    UserDefaults.standard.setValue(nil, forKey: "accessToken")
                    UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                    print("구글 서버 로그아웃 및 로그아웃 성공! ")
                    let vc = LoginViewController()
                    self.dismiss(animated: true)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }))
            ac.addAction(UIAlertAction(title: "취소", style: .destructive))
            self.present(ac, animated: true, completion: nil)
        }
        
        //회원탈퇴
        if (indexPath.row == 9) {
            let ac = UIAlertController(title: "회원 탈퇴", message: "저장된 정보가 모두 사라집니다", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if(LoginViewModel.socialType == "kakao") {
                    SignOutAPI.signoutWithAuthKakao(accessToken: UserDefaults.standard.string(forKey: "accessToken") ?? "") { valid in
                        switch valid {
                        case .success(let value):
                            if value {
                                UserApi.shared.unlink { error in
                                    if let error = error { print(error) }
                                    else {
                                        print("logout() success.")
                                        UserDefaults.standard.setValue(nil, forKey: "accessToken")
                                        UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                                        let vc = LoginViewController()
                                        vc.modalPresentationStyle = .fullScreen
                                        self.present(vc, animated: true)
                                    }
                                }
                            } else { return }
                        case .failure(let error):
                            print("에러 발생: \(error.localizedDescription)")
                        }
                    }
                }
                else if(LoginViewModel.socialType == "google") {
                    SignOutAPI.signoutWithAuthGoogle(accessToken: UserDefaults.standard.string(forKey: "accessToken") ?? "") { valid in
                        switch valid {
                        case .success(let value):
                            if value {
//                                GIDSignIn.sharedInstance.disconnect()
                                print("구글 서버 탈퇴 및 구글 연동 해지 성공! ")
                                UserDefaults.standard.setValue(nil, forKey: "accessToken")
                                UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                                UserDefaults.standard.setValue(nil, forKey: "googleAccessToken")
                                let vc = LoginViewController()
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true)
                            } else {
                                return
                            }
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
