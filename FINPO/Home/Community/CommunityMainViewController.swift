//
//  CommunityMainViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/18.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CommunityMainViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = CommunityViewModel()
    
    ///test
    let dummyItems = Observable.just([
        " Usage of text input box ",
        " Usage of switch button ",
        " Usage of progress bar ",
        " Usage of text labels ",
        ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    ///커뮤니티 준비중 내용
//    private var inPreparationLabel: UILabel = {
//        let label = UILabel()
//        label.text = "커뮤니티는 준비중입니다."
//        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 32)
//        label.textColor = .black
//        return label
//    }()
//
//    private var descriptionLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.text = "커뮤니티는 아직 준비중이랍니다..\n조금만 기다려주세요"
//        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
//        label.textColor = .black
//        return label
//    }()
    
    private var sumOfPostLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "000000")
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        label.text = "***개의 글"
        return label
    }()
    
    private var sortPolicyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(named: "chip=chip4"), for: .normal)
        return button
    }()
    
    private var postTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.rowHeight = CGFloat(150)
        tv.bounces = false
        tv.separatorInset.left = 0
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        
        ///네비게이션 버튼
        navigationItem.title = ""
        let writingButton = UIBarButtonItem(image: UIImage(named: "write")?.withRenderingMode(.alwaysOriginal)
                                              , style: .plain,
                                              target: self,
                                              action: #selector(moveToWritingVC))
        let searchButton = UIBarButtonItem(
            image: UIImage(named: "search_1.5")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(moveToSearchVC)
        )
        self.navigationItem.rightBarButtonItems = [writingButton, searchButton]
        
        ///게시글 테이블뷰
        postTableView.register(BoardTableViewCell.self, forCellReuseIdentifier: "postTableViewCell")
    }
    
    fileprivate func setLayout() {
        ///커뮤니티 준비중 내용
//        view.addSubview(inPreparationLabel)
//        inPreparationLabel.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.top.equalTo(view.snp.centerY).offset(100)
//        }
//
//        view.addSubview(descriptionLabel)
//        descriptionLabel.snp.makeConstraints {
//            $0.top.equalTo(inPreparationLabel.snp.bottom).offset(21)
//            $0.centerX.equalToSuperview()
//        }
                
        view.addSubview(sumOfPostLabel)
        sumOfPostLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.equalToSuperview().inset(21)
            
        }
        
        view.addSubview(sortPolicyButton)
        sortPolicyButton.snp.makeConstraints {
            $0.centerY.equalTo(sumOfPostLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(26)
            $0.width.equalTo(75)
            $0.height.equalTo(35)
        }
        
        view.addSubview(postTableView)
        postTableView.snp.makeConstraints {
            $0.top.equalTo(sortPolicyButton.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        
    }
    
    @objc private func moveToSearchVC() {
        
    }
    
    @objc private func moveToWritingVC() {
        
    }
    
    fileprivate func setInputBind() {
        
    }
    
    fileprivate func setOutputBind() {
        dummyItems
            .observe(on: MainScheduler.instance)
            .bind(to: postTableView.rx.items(cellIdentifier: "postTableViewCell", cellType: BoardTableViewCell.self)) { (index, element, cell) in
                cell.selectionStyle = .none
                cell.contentView.backgroundColor = .white
            }.disposed(by: disposeBag)
    }

}
