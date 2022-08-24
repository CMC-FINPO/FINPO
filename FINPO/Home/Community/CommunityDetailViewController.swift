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
    
    let disposeBag = DisposeBag()
    let viewModel = CommunityDetailViewModel()
    let favoriteViewModel = CommunityViewModel()
    
    var pageId: Int?
    var isLiked: Bool = false
    var isBookmarked: Bool = false
    
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
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let id = self?.pageId else { return }
                self?.viewModel.input.loadDetailBoardObserver.accept(id)
            }).disposed(by: disposeBag)
        
        likeButton.rx.tap
            .bind { [weak self] _ in
                print("aksdjlaksjdlaksjdla")
                guard let self = self else { return }
                if self.isLiked {
                    self.viewModel.input.undoLikeObserver.accept(self.pageId ?? -1)
                    self.isLiked.toggle()
                    self.likeButton.setImage(UIImage(named: "like"), for: .normal)
                } else {
                    self.viewModel.input.doLikeObserver.accept(self.pageId ?? -1)
                    self.isLiked.toggle()
                    self.likeButton.setImage(UIImage(named: "like_active"), for: .normal)
                }
            }.disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        self.viewModel.output.loadDetailBoardOutput
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] boardDetail in
                guard let self = self else { return }
                if let profileImgStr = boardDetail.data.user.profileImg {
                    let imgUrl = URL(string: profileImgStr)
                    self.userImageView.kf.setImage(with: imgUrl)
                }
                if(boardDetail.data.anonymity) {
                    self.userName.text = "(익명)"
                } else {
                    self.userName.text = boardDetail.data.user.nickname ?? "(알 수 없음)"
                }
                ///Date
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                format.locale = Locale(identifier: "ko")
                format.timeZone = TimeZone(abbreviation: "KST")
                var tempDate: Date
                boardDetail.data.isModified ? (tempDate = format.date(from: boardDetail.data.modifiedAt) ?? Date()) : (tempDate = format.date(from: boardDetail.data.createdAt) ?? Date())
                format.dateFormat = "yyyy년 MM월 dd일 a hh:mm"
                format.amSymbol = "오전"
                format.pmSymbol = "오후"
                let str = format.string(from: tempDate)
                boardDetail.data.isModified ? (self.dateLabel.text = str + "(수정됨)") : (self.dateLabel.text = str)
                ///Content
                self.contentLabel.text = boardDetail.data.content
                
                ///좋아요, 댓글, 북마크 수
                self.likeCountLabel.text = "좋아요 \(boardDetail.data.likes)"
                self.viewsCountLabel.text = "・ 댓글 \(boardDetail.data.countOfComment)"
                self.commentCountLabel.text = "・ 조회수 \(boardDetail.data.hits)"
                
                if(boardDetail.data.isLiked) {
                    self.likeButton.setImage(UIImage(named: "like_active"), for: .normal)
                    self.isLiked = true
                } else {
                    self.likeButton.setImage(UIImage(named: "like")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    self.isLiked = false
                }
                
                if(boardDetail.data.isBookmarked) {
                    self.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
                } else {
                    self.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                }
            }).disposed(by: disposeBag)
    }
}
