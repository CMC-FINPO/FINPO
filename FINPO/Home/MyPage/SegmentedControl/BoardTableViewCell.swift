//
//  BoardTableViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/19.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Alamofire

class BoardTableViewCell: UITableViewCell {
    
    enum likeCheckAction {
        case isLike(id: Int)
        case notLike(id: Int)
        
        var sortingURL: String {
            switch self {
            case .isLike(let id), .notLike(let id):
                return "post/\(id)/like"
            }
        }
    }
    // INPUT
    let likeObserver: AnyObserver<LikeMenu>
    let likeBtnTapped: AnyObserver<Void>
    
    let bookObserver: AnyObserver<BookmarkMenu>
    let bookBtnTapped: AnyObserver<Void>
    
    // OUTPUT
    let likeResult: PublishSubject<LikeMenu>
    let bookResult: PublishSubject<BookmarkMenu>
    
    var cellBag = DisposeBag()
    
    let attributeVC = CommunityDetailViewController()
    let moreView = CommentMoreView()
    
    private var viewModel: CommunityDetailViewModel?
    private var commentId: Int?
    private var viewController: UIViewController?
    
    var commentData: AnyObserver<CommentContentDetail>
    var nestCommentData: AnyObserver<CommentChildDetail>
    
    public var commentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "comment")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 17.5
        return imageView
    }()
    
    public var userName: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.text = "사용자"
        return label
    }()
    
    public var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor.G03
        label.text = "dummy time 2022/06/20"
        return label
    }()
    
    public var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        label.textColor = UIColor(hexString: "000000")
        label.text = ""
        return label
    }()
    
    public var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like"), for: .normal)
        button.setImage(UIImage(named: "like"), for: .selected)
        return button
    }()
    
    public var bookMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "scrap_inactive"), for: .normal)
        button.setImage(UIImage(named: "scrap_inactive"), for: .selected)
        return button
    }()
    
    public var likeCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.text = "좋아요"
        return label
    }()
    
    public var commentCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor.G03
        label.text = "댓글"
        return label
    }()
    
    public var viewsCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor.G03
        label.text = "조회수"
        return label
    }()
    
    public var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "more"), for: .normal)
        return button
    }()
    
    @objc func showMoreView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        moreView.backgroundView.addGestureRecognizer(gesture)
        DispatchQueue.main.async {
            self.moreView.showView(to: self, on: self.viewController ?? UIViewController(), option: .comment, pageId: nil, boardData: nil)
        }
    }
    
    @objc func dismissView(_ sender: UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.moreView.moreView.removeFromSuperview()
            self?.moreView.backgroundView.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        let data = PublishSubject<CommentContentDetail>()
        commentData = data.asObserver()
        let nestData = PublishSubject<CommentChildDetail>()
        nestCommentData = nestData.asObserver()
        
        //좋아요, 북마크
        let liking = PublishSubject<LikeMenu>()
        let likingTapEvent = PublishSubject<Void>()
        let booking = PublishSubject<BookmarkMenu>()
        let bookingTapEvent = PublishSubject<Void>()
        
        let likingResult = PublishSubject<LikeMenu>()
        let bookingResult = PublishSubject<BookmarkMenu>()
        
        likeObserver  = liking.asObserver()
        likeBtnTapped = likingTapEvent.asObserver()
        bookObserver  = booking.asObserver()
        bookBtnTapped = bookingTapEvent.asObserver()
        
        
        likeResult = likingResult
        bookResult = bookingResult
        
        debugPrint("셀 데이터: \(commentData)") //okay
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        data
            .map { $0 }
            .debug()
            .bind { [weak self] data in self?.moreView.onData.onNext(data) }
            .disposed(by: cellBag)
                
        nestData
            .map { $0 }
            .debug()
            .bind { [weak self] data in self?.moreView.nestOnData.onNext(data)}
            .disposed(by: cellBag)
        
        //좋아요, 북마크
        
        //트리거가 되면 상세조회로 가져오기
        liking
            .map { data -> Observable<CommunityDetailBoardResponseModel> in
                ApiManager.getData(from: BaseURL.url.appending("post/\(data.boardId)"), to: CommunityDetailBoardResponseModel.self, encoding: URLEncoding.default)
            }
            .flatMap { $0 }
            .map { LikeMenu(boardId: $0.data.id, isLike: !$0.data.isLiked) }
            .bind(to: likingResult)
            .disposed(by: cellBag)
        
        likingResult
            .debug()
            .map { !$0.isLike }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLike in
                if isLike { self?.likeButton.setImage(UIImage(named: "like_active"), for: .normal) }
                else { self?.likeButton.setImage(UIImage(named: "like"), for: .normal)}
            }.disposed(by: cellBag)
        
        likeButton.rx.tap.withLatestFrom(likingResult.asObservable())
            .map { LikeMenu(boardId: $0.boardId, isLike: !$0.isLike) }
            .do(onNext: { [weak self] data in self?.likeResult.onNext(data) })
            .bind { likeData in
                if likeData.isLike { ApiManager.deleteDataWithoutRx(from: BaseURL.url.appending("post/\(likeData.boardId)/like"), to: CommunityLikeResponseModel.self, encoding: URLEncoding.default) }
                else { ApiManager.postDataWithoutRx(from: BaseURL.url.appending("post/\(likeData.boardId)/like"), to: CommunityLikeResponseModel.self, encoding: URLEncoding.default) }
            }.disposed(by: cellBag)
        
        booking
            .map { data -> Observable<CommunityLikeResponseModel> in
                ApiManager.getData(from: BaseURL.url.appending("post/\(data.boardId)"), to: CommunityLikeResponseModel.self, encoding: URLEncoding.default)
            }
            .flatMap { $0 }
            .map { BookmarkMenu(boardId: $0.data.id, isBooked: !$0.data.isBookmarked) }
            .bind(to: bookingResult)
            .disposed(by: cellBag)
        
        bookingResult
            .map { !$0.isBooked }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isBooked in
                if isBooked { self?.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal) }
                else { self?.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal) }
            }.disposed(by: cellBag)
        
        bookMarkButton.rx.tap.withLatestFrom(bookingResult.asObservable())
            .map { BookmarkMenu(boardId: $0.boardId, isBooked: !$0.isBooked) }
            .do(onNext: { [weak self] data in self?.bookResult.onNext(data) })
            .debug()
            .bind { bookData in
                if bookData.isBooked { ApiManager.deleteDataWithoutRx(from: BaseURL.url.appending("post/\(bookData.boardId)/bookmark"), to: CommunityLikeResponseModel.self, encoding: URLEncoding.default) }
                else { ApiManager.postDataWithoutRx(from: BaseURL.url.appending("post/\(bookData.boardId)/bookmark"), to: CommunityLikeResponseModel.self, encoding: URLEncoding.default) }
            }.disposed(by: cellBag)
            
        viewModel = nil
        commentId = nil
        viewController = nil
        contentView.backgroundColor = UIColor.white
        contentView.isUserInteractionEnabled = true
        
        moreButton.addTarget(self, action: #selector(showMoreView), for: .touchUpInside)
        
        [userImageView, userName, dateLabel, contentLabel, likeButton, bookMarkButton, likeCountLabel, commentCountLabel, viewsCountLabel, moreButton].forEach {
            contentView.addSubview($0)
        }
        contentView.addSubview(commentImageView)

        userImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).inset(21)
            $0.top.equalTo(contentView.snp.top).inset(10)
            $0.height.width.equalTo(35)
        }
        
        userName.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.top).offset(3)
            $0.leading.equalTo(userImageView.snp.trailing).offset(9)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(userName.snp.bottom).offset(2)
            $0.leading.equalTo(userName.snp.leading)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.bottom).offset(21)
            $0.leading.equalTo(userImageView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
        }
        
        likeButton.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.bottom).inset(10)
            $0.leading.equalTo(contentLabel.snp.leading)
            $0.height.width.equalTo(25)
        }
        
        bookMarkButton.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.top)
            $0.leading.equalTo(likeButton.snp.trailing).offset(10)
            $0.width.height.equalTo(25)
        }
        
        likeCountLabel.snp.makeConstraints {
            $0.leading.equalTo(bookMarkButton.snp.trailing).offset(140)
            $0.bottom.equalTo(bookMarkButton.snp.bottom)
        }
        
        viewsCountLabel.snp.makeConstraints {
            $0.bottom.equalTo(likeCountLabel.snp.bottom)
            $0.leading.equalTo(likeCountLabel.snp.trailing).offset(2.5)
        }
        
        commentCountLabel.snp.makeConstraints {
            $0.bottom.equalTo(likeCountLabel.snp.bottom)
            $0.leading.equalTo(viewsCountLabel.snp.trailing).offset(2.5)
        }
    }
    
    required init?(coder: NSCoder) {
        let data = PublishSubject<CommentContentDetail>()
        commentData = data.asObserver()
        let nestData = PublishSubject<CommentChildDetail>()
        nestCommentData = nestData.asObserver()
        //좋아요
        likeObserver  = PublishSubject<LikeMenu>().asObserver()
        likeBtnTapped = PublishSubject<Void>().asObserver()
        //북마크
        bookObserver = PublishSubject<BookmarkMenu>().asObserver()
        bookBtnTapped = PublishSubject<Void>().asObserver()
        
        likeResult    = PublishSubject<LikeMenu>()
        bookResult    = PublishSubject<BookmarkMenu>()
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func hiddenProperty() {
        [self.likeButton, self.bookMarkButton, self.likeCountLabel, self.viewsCountLabel, self.commentCountLabel].forEach {
            $0.isHidden = true
        }
        self.contentView.layoutIfNeeded()
        
        self.contentLabel.snp.remakeConstraints {
            $0.leading.equalTo(userImageView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.top.equalTo(userImageView.snp.bottom).offset(15)
            $0.bottom.equalTo(contentView.snp.bottom).inset(15)
        }
        self.contentLabel.layoutIfNeeded()
        
        self.moreButton.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.top)
            $0.trailing.equalToSuperview().inset(15)
            $0.width.height.equalTo(25)
        }
        self.moreButton.layoutIfNeeded()
    }
    
    public func setDeleteComment() {
        [self.likeButton, self.bookMarkButton, self.likeCountLabel, self.viewsCountLabel, self.commentCountLabel, self.userImageView, self.userName, self.dateLabel, self.moreButton].forEach {
            $0.isHidden = true
            self.contentView.layoutIfNeeded()
        }
        self.contentLabel.snp.remakeConstraints {
            $0.edges.equalTo(contentView).inset(21)
        }
        self.contentLabel.text = "(삭제된 댓글입니다)"
        self.contentLabel.attributedText =  self.attributeVC.attributeText(
            originalText: self.contentLabel.text ?? "",
            range: "\(self.contentLabel.text ?? "")",
            color: ComponentsManager.CustomColor.G04.toString
        )
        self.contentLabel.layoutIfNeeded()
    }
    
    //대댓글용
    public func childCommentProperty() {
        [self.likeButton, self.bookMarkButton, self.likeCountLabel, self.viewsCountLabel, self.commentCountLabel].forEach {
            $0.isHidden = true
        }
        self.contentView.backgroundColor = UIColor(hexString: "F9F9F9")
        self.contentView.layoutIfNeeded()
        
        self.commentImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(10)
            $0.width.height.equalTo(25)
        }
        self.commentImageView.layoutIfNeeded()
        
        self.userImageView.snp.remakeConstraints {
            $0.leading.equalTo(commentImageView.snp.trailing)
            $0.top.equalTo(commentImageView.snp.top)
            $0.width.height.equalTo(35)
        }
        self.userImageView.layoutIfNeeded()
        
        self.contentLabel.snp.remakeConstraints {
            $0.leading.equalTo(userImageView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.top.equalTo(userImageView.snp.bottom).offset(15)
            $0.bottom.equalTo(contentView.snp.bottom).inset(15)
        }
        self.contentLabel.layoutIfNeeded()
        
        self.moreButton.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.top)
            $0.trailing.equalToSuperview().inset(15)
            $0.width.height.equalTo(25)
        }
        self.moreButton.layoutIfNeeded()
    }
    
    public func addToDynamicContent() {
        let uiv = UIView()
        contentView.addSubview(uiv)
        uiv.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(80)
        }
        uiv.backgroundColor = .systemRed
        
        self.contentView.layoutIfNeeded()
    }
    
    public func propertyInjection(on viewModel: CommunityDetailViewModel, commentId: Int, viewController: UIViewController) {
        self.viewModel = viewModel
        self.commentId = commentId
        self.viewController = viewController
    }
}
