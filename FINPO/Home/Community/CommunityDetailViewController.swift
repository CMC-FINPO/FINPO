//
//  CommunityDetailViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/23.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import Kingfisher

class CommunityDetailViewController: UIViewController {
    
    var pageId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    func initialize(id: Int) {
        self.pageId = id
        print("커뮤니티 상세 받은 아이디값: \(String(describing: self.pageId))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private var contentView: UIView = { //dynamicSizeContent
        let view = UIView()
        
        return view
    }()
    
    private var boardStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
//        view.distribution = .fillEqually
        view.spacing = 5
        return view
    }()
    
    private var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal)
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var userName: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.text = "사용자"
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.text = "dummy time 2022/06/20"
        return label
    }()
    
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
//        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.text = "여기에는 여기에는 컨텐츠가 들어갑니다\n여기에는 늘어납니다\n여기에는 늘어납니다\n늘어났니?\n늘어난거맞니?\n동적으로다이내믹하게늘어낫니?\n정말이니?"
        return label
    }()
    
    private var boardCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        return cv
    }()
    
    private var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like"), for: .normal)
        button.setImage(UIImage(named: "like"), for: .selected)
        return button
    }()
    
    private var bookMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "scrap_inactive"), for: .normal)
        button.setImage(UIImage(named: "scrap_active"), for: .selected)
        return button
    }()
    
    private var likeCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.text = "좋아요 3"
        return label
    }()
    
    private var commentCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.text = "댓글 1"
        return label
    }()
    
    private var viewsCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.text = "조회수 30"
        return label
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
    }
    
    fileprivate func setLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        contentView.addSubview(boardStackView)
        boardStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        boardStackView.addSubview(userImageView)
        userImageView.snp.makeConstraints {
            $0.leading.equalTo(boardStackView.snp.leading).inset(10)
            $0.top.equalTo(boardStackView.snp.top).inset(10)
            $0.height.width.equalTo(35)
        }
        
        boardStackView.addSubview(userName)
        userName.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.top).offset(3)
            $0.leading.equalTo(userImageView.snp.trailing).offset(9)
        }
        
        boardStackView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(userName.snp.bottom).offset(2)
            $0.leading.equalTo(userName.snp.leading)
        }
        
        boardStackView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.leading)
            $0.trailing.equalTo(boardStackView.snp.trailing)
            $0.top.equalTo(userImageView.snp.bottom).offset(15)
        }
        
        boardStackView.addSubview(boardCollectionView)
        boardCollectionView.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(10)
            $0.leading.equalTo(contentLabel.snp.leading)
            $0.height.equalTo(90)
        }
        
        boardStackView.addSubview(likeButton)
        likeButton.snp.makeConstraints {
            $0.top.equalTo(boardCollectionView.snp.bottom).offset(15)
            $0.leading.equalTo(boardCollectionView.snp.leading)
            $0.height.width.equalTo(25)
        }
        
        boardStackView.addSubview(bookMarkButton)
        bookMarkButton.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.top)
            $0.leading.equalTo(likeButton.snp.trailing).offset(10)
            $0.height.width.equalTo(25)
        }
        
        boardStackView.addSubview(likeCountLabel)
        likeCountLabel.snp.makeConstraints {
            $0.leading.equalTo(bookMarkButton.snp.trailing).offset(151)
            $0.bottom.equalTo(bookMarkButton.snp.bottom)
        }
        
        boardStackView.addSubview(viewsCountLabel)
        viewsCountLabel.snp.makeConstraints {
            $0.bottom.equalTo(likeCountLabel.snp.bottom)
            $0.leading.equalTo(likeCountLabel.snp.trailing).offset(2.5)
        }
        
        boardStackView.addSubview(commentCountLabel)
        commentCountLabel.snp.makeConstraints {
            $0.bottom.equalTo(likeCountLabel.snp.bottom)
            $0.leading.equalTo(viewsCountLabel.snp.trailing).offset(2.5)
        }
    }
    
    fileprivate func addToDynamicContent() {
      let uiv = UIView()
      uiv.heightAnchor.constraint(equalToConstant: 40).isActive = true
      uiv.backgroundColor = .systemRed

      contentView.addSubview(uiv)
    }
    
    fileprivate func setInputBind() {
        
    }
    
    fileprivate func setOutputBind() {
        
    }
}
