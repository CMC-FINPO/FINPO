//
//  CommunityMainViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/18.
//

import Foundation
import UIKit

class CommunityMainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var inPreparationLabel: UILabel = {
        let label = UILabel()
        label.text = "커뮤니티는 준비중입니다."
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
        label.textColor = .black
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "커뮤니티는 아직 준비중이랍니다..\n조금만 기다려주세요"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        label.textColor = .black
        return label
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
    }
    
    fileprivate func setLayout() {
        view.addSubview(inPreparationLabel)
        inPreparationLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.centerY).offset(100)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(inPreparationLabel.snp.bottom).offset(21)
            $0.centerX.equalToSuperview()
        }
    }
    
    fileprivate func setInputBind() {
        
    }
    
    fileprivate func setOutputBind() {
        
    }

}
