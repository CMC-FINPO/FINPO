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
//        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var boardStackView: UIView = {
        let view = UIView()
//        view.axis = .vertical
//        view.distribution = .fillEqually
//        view.isUserInteractionEnabled = true
        view.backgroundColor = .white
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
        label.text = "dummy time"
        return label
    }()
    
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
//        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.text = ""
        return label
    }()
    
    private var boardCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
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
        label.text = "좋아요"
        return label
    }()
    
    private var commentCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.text = "댓글"
        return label
    }()
    
    private var viewsCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.text = "조회수"
        return label
    }()
    
    private var commentView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    private var commentTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
//        tv.rowHeight = CGFloat(100)
        tv.rowHeight = UITableView.automaticDimension
//        tv.estimatedRowHeight = 100
        tv.bounces = false
        tv.separatorInset.left = 0
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        
        boardCollectionView.register(CommunityCollectionViewCell.self, forCellWithReuseIdentifier: "CommunityCollectionViewCell")
        
        commentTableView.register(BoardTableViewCell.self, forCellReuseIdentifier: "commentTableViewCell")
    }
    
    fileprivate func setLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.greaterThanOrEqualToSuperview().offset(500)
        }
        
        contentView.addSubview(boardStackView)
        boardStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(150)
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
        
        contentView.addSubview(commentView)
        commentView.snp.makeConstraints {
            $0.top.equalTo(boardStackView.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(self.view.bounds.height)
        }
        
        commentView.addSubview(commentTableView)
        commentTableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
//            $0.bottom.equalTo(self.scrollView.safeAreaLayoutGuide.snp.bottom)
            $0.bottom.equalTo(commentView)
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
                self?.viewModel.input.loadCommentObserver.accept(id)
            }).disposed(by: disposeBag)
        
        likeButton.rx.tap
            .bind { [weak self] _ in
                print("aksdjlaksjdlaksjdla")
                guard let self = self else { return }
                if self.isLiked {
                    self.viewModel.input.likeObserver.accept(.undoLike(id: self.pageId ?? -1))
                    self.isLiked.toggle()
                    self.likeButton.setImage(UIImage(named: "like"), for: .normal)
                } else {
                    self.viewModel.input.likeObserver.accept(.doLike(id: self.pageId ?? -1))
                    self.isLiked.toggle()
                    self.likeButton.setImage(UIImage(named: "like_active"), for: .normal)
                }
            }.disposed(by: disposeBag)
        
        bookMarkButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self else { return }
                if self.isBookmarked {
                    self.viewModel.input.bookmarkObserver.accept(.undoBook(id: self.pageId ?? -1))
                    self.isBookmarked.toggle()
                    self.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                } else {
                    self.viewModel.input.bookmarkObserver.accept(.doBook(id: self.pageId ?? -1))
                    self.isBookmarked.toggle()
                    self.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
                }
            }.disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.loadDetailBoardOutput
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
                    self.isBookmarked = true
                } else {
                    self.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                    self.isBookmarked = false
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.loadDetailBoardOutput
            .scan(into: [BoardImgDetail]()) { [weak self] imgs, data in
                guard let self = self else { return }
                if let imagsCnt = data.data.imgs {
                    for i in 0..<(imagsCnt.count) {
                        imgs.append(imagsCnt[i])
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.boardCollectionView.isHidden = true
                        self.likeButton.snp.remakeConstraints({
                            $0.top.equalTo(self.contentLabel.snp.bottom).offset(15)
                            $0.leading.equalTo(self.contentLabel.snp.leading)
                        })
                        self.likeButton.layoutIfNeeded()
                    }
                    return
                }
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: boardCollectionView.rx.items(cellIdentifier: "CommunityCollectionViewCell", cellType: CommunityCollectionViewCell.self)) {
                (index: Int, element: BoardImgDetail, cell) in
                if let url = URL(string: element.img) {
                    cell.imageView.kf.setImage(with: url)
                } else {
                    cell.imageView.image = UIImage(named: "MainInterest1")
                }
            }.disposed(by: disposeBag)
            
        viewModel.output.loadCommentOutput
            .scan(into: [CommentContentDetail]()) { comments, response in
                for i in 0..<(response.data.content.count) {
                    comments.append(response.data.content[i])
                }
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: commentTableView.rx.items(cellIdentifier: "commentTableViewCell", cellType: BoardTableViewCell.self)) {
                (index: Int, element: CommentContentDetail, cell) in
                if(element.status) {
                    cell.contentLabel.text = element.content ?? "댓글없음"
                    cell.hiddenProperty() //댓글전용 셀로 만들기
                } else { //삭제된 글일경우
                    cell.setDeleteComment()
                    cell.contentLabel.text = "(삭제된 댓글입니다)"
                }
                
                //댓글 작성자 익명 확인
//                if(element.user != nil) {
//                    if let imgurl = element.user?.profileImg,
//                       let nickname = element.user?.nickname,
//                       let isMine = element.isMine,
//                       let isWriter = element.isWriter,
//                       let anonymity = element.anonymity
//                    {
//                        cell.userImageView.kf.setImage(with: URL(string: imgurl))
//                        if(isMine) {
//                            cell.userName.text = nickname + "(본인)"
//                        } else if(isWriter){
//                            cell.userName.text = nickname + "(글쓴이)"
//                        } else if(anonymity){
//                            cell.userName.text = "(익명)"
//                        } else if(element.status){
//                            cell.userName.text = "(알 수 없음)"
//                        }
//                    }
//                } else {
//                    guard let nickname = element.user?.nickname else { return }
//                    cell.userName.text = nickname
//                }
                
                
            }.disposed(by: disposeBag)
    }
}
