//
//  LoginSuccessViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/25.
//

import Foundation
import UIKit
import SnapKit

final class LoginSuccessViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
    }
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "iOS_illust")
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "000000")
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "핀포와 함께\n정책을 찾으러 가 볼까요?"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 28)
        return label
    }()
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.setBackgroundColor(UIColor(hexString: "5B43EF"), for: .normal)
        button.setTitle("시작하기", for: .normal)
        button.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "나중에 할게요", style: .plain, target: self, action: #selector(skipThisView))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "999999")
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 14)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        confirmButton.addTarget(self, action: #selector(goToHomeVC), for: .touchUpInside)
    }
    
    @objc fileprivate func skipThisView() {
        
    }
    
    fileprivate func setLayout() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(350)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(46)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.height.equalTo(50)
        }
    }
    
    @objc fileprivate func goToHomeVC() {
        let vc = HomeTapViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}
