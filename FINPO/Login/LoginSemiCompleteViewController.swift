//
//  LoginSemiCompleteViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/12.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class LoginSemiCompleteViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .blue
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
        label.textColor = UIColor(hexString: "000000")
        label.text = "가입이 완료되었어요!"
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        label.textColor = UIColor(hexString: "494949")
        label.numberOfLines = 2
        label.text = "현재 상태와 이용 목적\n추가 관심 지역을 선택하러 가볼까요?"
        return label
    }()
    
    private var addInfoButton: UIButton = {
        let button = UIButton()
        button.setTitle("추가 정보 입력하기", for: .normal)
        button.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
        button.backgroundColor = UIColor(hexString: "5B43EF")
        button.layer.cornerRadius = 5
        return button
    }()
    
    private var laterButton: UIButton = {
        let button = UIButton()
        button.setTitle("나중에 할게요", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.backgroundColor = UIColor(hexString: "F0F0F0")
        button.layer.cornerRadius = 5
        return button
    }()
    
    fileprivate func setAttribute() {
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        view.backgroundColor = UIColor(hexString: "FFFFFF")
    }
    
    fileprivate func setLayout() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
            $0.width.equalTo(90)
            $0.height.equalTo(80)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.centerX.equalTo(imageView.snp.centerX)
        }
        
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.centerX.equalTo(imageView.snp.centerX)
        }
        
        view.addSubview(addInfoButton)
        addInfoButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-105)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(55)
        }
        
        view.addSubview(laterButton)
        laterButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(55)
        }
    }
    
    fileprivate func setInputBind() {
        //TODO: API 완성되면 시작
        addInfoButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                
            }).disposed(by: disposeBag)
        
        laterButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        
    }
}
