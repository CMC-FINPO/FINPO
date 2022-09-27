//
//  CommunityWritingViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/27.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CommunityWritingViewController: UIViewController {
    
    private var addWritingBoardButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private lazy var boardTextView: UITextView = {
        let textView = UITextView()
        textView.text = "글자 수는 최대 1000자입니다."
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        textView.textColor = .secondaryLabel
        textView.delegate = self
        return textView
    }()
    
    private var barButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
    
    private var imageCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .init(), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private var bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var albumButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        button.backgroundColor = .green
        return button
    }()
    
    private func setAttribute() {
        view.backgroundColor = .white
        barButton.setTitle("작성하기", for: .normal)
        barButton.setTitleColor(UIColor.P01, for: .normal)
        barButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        addWritingBoardButton.customView = barButton
        self.navigationItem.rightBarButtonItem = addWritingBoardButton
    }
    
    private func setLayout() {
        view.addSubview(boardTextView)
        boardTextView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        bottomView.addSubview(albumButton)
        albumButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(45)
            $0.width.height.equalTo(25)
        }
        
        view.addSubview(imageCollectionView)
        imageCollectionView.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(105)
        }
    }
    
    private func setInputBind() {

    }
    
    private func setOutputBind() {
        
    }
}

extension CommunityWritingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .secondaryLabel else { return }
        textView.text = nil
        textView.textColor = .label
    }
}
