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

class BoardTableViewCell: UITableViewCell {

    var cellBag = DisposeBag()
    
    let attributeVC = CommunityDetailViewController()
    let moreView = CommentMoreView()
    
    private var viewModel: CommunityDetailViewModel?
    private var commentId: Int?
    private var viewController: UIViewController?
    
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
        button.setImage(UIImage(named: "scrap_active"), for: .selected)
        return button
    }()
    
    public var likeCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor(hexString: "999999")
        label.text = "좋아요 3"
        return label
    }()
    
    public var commentCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor.G03
        label.text = "댓글 1"
        return label
    }()
    
    public var viewsCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.textColor = UIColor.G03
        label.text = "조회수 30"
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
        moreView.showView(to: self)
    }
    
    @objc func dismissView(_ sender: UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.moreView.moreView.removeFromSuperview()
            self?.moreView.backgroundView.removeFromSuperview()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            $0.leading.equalTo(bookMarkButton.snp.trailing).offset(151)
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
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
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
            $0.top.equalToSuperview().offset(18)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cellBag = DisposeBag()
    }
}
