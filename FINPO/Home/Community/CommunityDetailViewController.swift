//
//  CommunityDetailViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/08/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

class CommunityDetailViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = CommunityDetailViewModel()
    let favoriteViewModel = CommunityViewModel()
    
    var pageId: Int?
    var isLiked: Bool = false
    var isBookmarked: Bool = false
    
    ///대댓글 개수 체크
    var childCommentCnt = [String:Int]()
    ///대댓글 불러온 적 있는지 체크
    var isAddedChild = [String:[Bool]]()
    ///대댓글작성 시 댓글 Parent Id 저장
    var commentParentId = [Int]()
    ///익명댓글 체크 여부
    var isAnonyBtnClicked: Bool = false

    ///대댓글 작성 시 알럿뷰
    let nestCommentView = NestCommentView()
    ///대댓글 작성 시 유저명 저장(익명 포함)
    var userNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
        
        debugPrint("스크롤뷰 height: \(self.scrollView.bounds.height)")
        debugPrint("컨텐츠뷰 height: \(self.contentView.bounds.height)")
        debugPrint("댓글뷰 height: \(self.commentView.bounds.height)")
    }
    
    func initialize(id: Int) {
        self.pageId = id
        debugPrint("커뮤니티 상세 받은 아이디값: \(String(describing: self.pageId))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugPrint("저장된 유저명: \(self.userNames)")
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
        view.backgroundColor = .white
        return view
    }()
    
    private var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 17.5
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
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
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
    
    private var commentTableView: DynamicHeightTableView = {
        let tv = DynamicHeightTableView()
        tv.backgroundColor = .white
        tv.rowHeight = UITableView.automaticDimension
        tv.bounces = false
        tv.separatorInset.left = 0
        return tv
    }()
    
    private lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.text = "댓글을 입력해주세요"
        textView.backgroundColor = UIColor(hexString: "\(ComponentsManager.CustomColor.G09.toString)")
//        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
        textView.textContainerInset = UIEdgeInsets(top: 17.5, left: 10, bottom: 10, right: 10)
        textView.textColor = .secondaryLabel
        textView.delegate = self
        return textView
    }()
    
    private var btnView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor(hexString: "\(ComponentsManager.CustomColor.G09.toString)")
        view.layer.borderColor = UIColor(hexString: "\(ComponentsManager.CustomColor.G08.toString)").cgColor
        return view
    }()
    
    private var sendCommentBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "sendButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private var anonyBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "anonyUnabled")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    public func attributeText(originalText: String, range: String, color: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: originalText)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "\(color)"), range: (originalText as NSString).range(of: "\(range)"))
        return attributedText
    }
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        
        boardCollectionView.register(CommunityCollectionViewCell.self, forCellWithReuseIdentifier: "CommunityCollectionViewCell")
        boardCollectionView.delegate = self
        
        commentTableView.register(BoardTableViewCell.self, forCellReuseIdentifier: "commentTableViewCell")
        commentTableView.delegate = self
    }
    
    fileprivate func setLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview().inset(150)
        }
  
        scrollView.addSubview(boardStackView)
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
            $0.trailing.equalToSuperview()
            $0.height.equalTo(100)
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

        scrollView.addSubview(commentTableView)
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(boardStackView.snp.bottom).offset(30)
            $0.width.equalToSuperview()
//            $0.bottom.equalToSuperview()
        }
        
        //댓글작성
        view.addSubview(btnView)
        btnView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
        
        btnView.addSubview(anonyBtn)
        anonyBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(45)
            $0.height.equalTo(18)
        }
        
        btnView.addSubview(commentTextView)
        commentTextView.snp.makeConstraints {
            $0.leading.equalTo(anonyBtn.snp.trailing)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(50)
        }
        
        btnView.addSubview(sendCommentBtn)
        sendCommentBtn.snp.makeConstraints {
            $0.leading.equalTo(commentTextView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(25)
            $0.height.equalTo(27.5)
        }
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let id = self?.pageId else { return }
                self?.viewModel.input.loadDetailBoardObserver.accept(id)
                self?.viewModel.input.loadCommentObserver.accept(id)
                
                //댓글 달 때 미리 pageId 넣어두기
                self?.viewModel.input.isNestedObserver.accept(.comment(id: id))
                self?.viewModel.input.pageIdObserver.accept(id)
                self?.viewModel.input.isAnonyBtnClicked.accept(false)
            }).disposed(by: disposeBag)
        
        likeButton.rx.tap
            .bind { [weak self] _ in
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
        
        //댓글 TextView
        commentTextView.rx.text
            .bind { [weak self] text in
                if let text = text {
                    self?.viewModel.input.commentTextObserver.accept(text)
                }
            }.disposed(by: disposeBag)
        
        //댓글 작성 버튼 클릭
        sendCommentBtn.rx.tap
            .bind { [weak self] _ in                
                self?.viewModel.input.commentBtnObserver.accept(())
            }.disposed(by: disposeBag)
        
        //대댓글 작성
        commentTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let parentId = self?.commentParentId[indexPath.row],
                    let self = self,
                    let pageId = self.pageId {
                    if parentId == -1 { //삭제된 글
                        return
                    } else {
                        if self.userNames[indexPath.row] == "X" {
                            return
                        } else {
                            self.nestCommentView.setProperty(self.userNames[indexPath.row], self.viewModel, pageId: pageId)
                            let size = self.scrollView.frame.size.height + self.boardStackView.frame.size.height/2
                            self.nestCommentView.showView(on: self, size)
                            self.viewModel.input.isNestedObserver.accept(.nested(parentId: parentId))
                        }
                    }
                }
            }).disposed(by: disposeBag)

        commentTableView.rx.itemDeselected
            .subscribe(onNext: { [weak self] _ in
                if let pageId = self?.pageId {
                    //다시 재클릭할 경우 대댓글이 아닌 일반댓글로 작성
                    self?.viewModel.input.isNestedObserver.accept(.comment(id: pageId))
                }
            }).disposed(by: disposeBag)
        
        //익명버튼 체크
        anonyBtn.rx.tap
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.isAnonyBtnClicked.toggle()
                self.viewModel.input.isAnonyBtnClicked.accept(self.isAnonyBtnClicked)
                DispatchQueue.main.async {
                    self.isAnonyBtnClicked ? (self.anonyBtn.setImage(UIImage(named: "anonyAbled")?.withRenderingMode(.alwaysOriginal), for: .normal)) : (self.anonyBtn.setImage(UIImage(named: "anonyUnabled")?.withRenderingMode(.alwaysOriginal), for: .normal))
                }
            }.disposed(by: disposeBag)
        
        //TODO: 게시글 이미지 선택 시 풀스크린
//        boardCollectionView.rx.itemSelected
//            .subscribe(onNext: { [weak self] indexPath in
//                let cell = self?.boardCollectionView.dequeueReusableCell(withReuseIdentifier: "CommunityCollectionViewCell", for: indexPath) as! CommunityCollectionViewCell
//
//            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.loadDetailBoardOutput
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] boardDetail in
                guard let self = self else { return }
                if let profileImgStr = boardDetail.data.user?.profileImg {
                    let imgUrl = URL(string: profileImgStr)
                    self.userImageView.kf.setImage(with: imgUrl)
                }
                if(boardDetail.data.anonymity) {
                    self.userName.text = "(익명)"
                } else {
                    self.userName.text = boardDetail.data.user?.nickname ?? "(알 수 없음)"
                }
                ///Date
                let date = self.currentDate(boardDetail.data.isModified, boardDetail.data.modifiedAt, boardDetail.data.createdAt)
                self.dateLabel.text = date
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
                    DispatchQueue.main.async {
                        self.likeButton.snp.remakeConstraints({
                            $0.top.equalTo(self.boardCollectionView.snp.bottom).offset(15)
                            $0.leading.equalTo(self.boardCollectionView.snp.leading)
                        })
                        self.likeButton.layoutIfNeeded()
                        self.commentTableView.snp.remakeConstraints {
                            $0.top.equalTo(self.likeButton.snp.bottom).offset(15)
                        }
                        self.commentTableView.layoutIfNeeded()
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
            .bind(to: boardCollectionView.rx.items(cellIdentifier: "CommunityCollectionViewCell", cellType: CommunityCollectionViewCell.self)) { [weak self]
                (index: Int, element: BoardImgDetail, cell) in
                guard let self = self else { return }
                cell.checkImageBtn.isHidden = true
                DispatchQueue.global().async {
                    //캐시에 있는지 확인 후 없다면 메모리 캐시에 저장
                    let imgUrl: String = String(element.img)
                    debugPrint("저장될 이미지 url: \(imgUrl)") //54509b55-10ea-4886-a001-7d75795ed5df.jpeg
                    //가져오기
                    if let cachedImg = CacheManager.shared.object(forKey: NSString(string: imgUrl).lastPathComponent as NSString) {
                        DispatchQueue.main.async {
                            cell.imageView.image = cachedImg
                        }
                    } else { //없다면 메모리 캐시 저장 후 적용
                        if let url = URL(string: imgUrl) {
                            if let data = try? Data(contentsOf: url) {
                                guard let img = UIImage(data: data) else { return }
                                CacheManager.shared.setObject(img, forKey: NSString(string: imgUrl).lastPathComponent as NSString)
                                DispatchQueue.main.async {
                                    cell.imageView.image = img
                                }
                            }
                        }
                    }
                }
            }.disposed(by: disposeBag)
            
        viewModel.output.loadCommentOutput
            .scan(into: [CommentContentDetail]()) { [weak self] comments, response in
                guard let self = self else { return }
                //댓글*대댓글 추가 시 리로드
                comments.removeAll()
                self.childCommentCnt.removeAll()
                self.isAddedChild.removeAll()
                self.commentParentId.removeAll()
                self.userNames.removeAll()
                
                for i in 0..<(response.data.content.count) {
                    if let childs = response.data.content[i].childs {
                        comments.append(response.data.content[i])
                        self.childCommentCnt["\(response.data.content[i].id)", default: 0] += 1
                        self.isAddedChild["\(response.data.content[i].id)", default: [Bool]()].append(false)
                        for _ in 0..<(childs.count) {
                            comments.append(response.data.content[i])
                            self.childCommentCnt["\(response.data.content[i].id)", default: 0] += 1
                            self.isAddedChild["\(response.data.content[i].id)", default: [false]].append(false)
                            print("읽어들인 대댓글 체크용: \(self.isAddedChild)")
                        }
                    } else {
                        comments.append(response.data.content[i])
                    }
                }
            }
            .bind(to: commentTableView.rx.items(cellIdentifier: "commentTableViewCell", cellType: BoardTableViewCell.self)) { [weak self]
                (index: Int, element: CommentContentDetail, cell) in
                guard let self = self else { return }
                cell.selectionStyle = .none
                ///대댓글이 있는 경우
                if let child = element.childs {
                    //check child count
                    let total = self.childCommentCnt["\(element.id)", default: 0]
                    if((total - (child.count)) > 0) { //댓글
                        self.childCommentCnt["\(element.id)", default: 0] -= 1
                        if(element.status) { //댓글 삭제 분기
                            cell.contentLabel.text = element.content ?? "댓글없음"
                            //익명 여부 체크
                            if let isAnnoymity = element.anonymity {
                                if(isAnnoymity) {
                                    cell.userName.text = "(익명)"
                                    //대댓글 달 때 유저이름 저장
                                    self.userNames.append("(익명)")
                                    //more view 데이터 삽입
                                    cell.propertyInjection(on: self.viewModel, commentId: element.id, viewController: self)
                                } else if(!isAnnoymity) {
                                    if let isWriter = element.isWriter {
                                        if isWriter {
                                            cell.userName.text = (element.user?.nickname ?? "") + "(글쓴이)"
                                            cell.hiddenProperty()
                                        }
                                    }
                                    if let isMine = element.isMine {
                                        if isMine {
                                            cell.userName.text = element.user?.nickname ?? "본인이름없음" + "(본인)"
                                            cell.hiddenProperty()
                                        }
                                    }
                                    //Profile Img
                                    if let imgUrl = element.user?.profileImg {
                                        cell.userImageView.kf.setImage(with: URL(string: imgUrl))
                                    }
                                    //대댓글 달 때 유저이름 저장
                                    self.userNames.append(element.user?.nickname ?? "")
                                    //more view 데이터 삽입
                                    cell.propertyInjection(on: self.viewModel, commentId: element.id, viewController: self)
                                }
                            }
                            //댓글 Date
                            guard let isModified = element.isModified,
                                  let modifiedAt = element.modifiedAt,
                                  let createdAt  = element.createdAt
                            else { return }
                            let date = self.currentDate(isModified, modifiedAt, createdAt)
                            cell.dateLabel.text = date
                            
                            cell.hiddenProperty()
                            self.commentParentId.append(element.id)
                            print("대댓글이 있는 경우 댓글 ParentId 추가: \(self.commentParentId)")
                        } else { //삭제된 댓글
                            cell.setDeleteComment()
                            self.commentParentId.append(-1)
                            print("삭제된 글 && 대댓글이 있는 경우 댓글 parentId 추가: \(self.commentParentId)")
                            //대댓글 달 때 유저이름 저장
                            self.userNames.append("X")
                        }
                    } else { //대댓글
                        if let isAdded = (self.isAddedChild["\(element.id)"]) {
                            for i in 0..<(isAdded.count-1) {
                                if (!isAdded[i]) {
                                    self.isAddedChild["\(element.id)"]?[i] = true
                                    if let isCommentAlive = element.childs?[i].status { //댓글 삭제 분기
                                        isCommentAlive ? (cell.contentLabel.text = element.childs?[i].content ?? "에러") : (cell.setDeleteComment())
                                        if(isCommentAlive) {
                                            //익명분기
                                            if let isAnnonymity = element.childs?[i].anonymity {
                                                if(isAnnonymity) {
                                                    cell.userName.text = "(익명)"
                                                    self.userNames.append("(익명)")
                                                    //more view 데이터 삽입
                                                    guard let childId = element.childs?[i].id else { return }
                                                    cell.propertyInjection(on: self.viewModel, commentId: childId, viewController: self)
                                                } else if(!isAnnonymity) {
                                                    if let isWriter = element.childs?[i].isWriter { //글쓴이 분기
                                                        if isWriter { (cell.userName.text = (element.childs?[i].user?.nickname ?? "") + "(글쓴이)") }
                                                    }
                                                    if let isMine = element.childs?[i].isMine {
                                                        if isMine { cell.userName.text = (element.childs?[i].user?.nickname ?? "") + "(본인)" }
                                                    }
                                                    //Profile Img
                                                    if let imgUrl = element.childs?[i].user?.profileImg {
                                                        cell.userImageView.kf.setImage(with: URL(string: imgUrl))
                                                    }
                                                    self.userNames.append(element.childs?[i].user?.nickname ?? "")
                                                    //more view 데이터 삽입
                                                    guard let childId = element.childs?[i].id else { return }
                                                    cell.propertyInjection(on: self.viewModel, commentId: childId, viewController: self)
                                                }
                                            }
                                            //대댓글 Date
                                            guard let isModified = element.childs?[i].isModified,
                                                  let modifiedAt = element.childs?[i].modifiedAt,
                                                  let createdAt  = element.childs?[i].createdAt
                                            else { return }
                                            let date = self.currentDate(isModified, modifiedAt, createdAt)
                                            cell.dateLabel.text = date

                                            cell.childCommentProperty()
                                            self.commentParentId.append(element.childs?[i].parent?.id ?? -1)
                                            print("대댓글 ParentId 추가: \(self.commentParentId)")
                                        } else { //삭제된 대댓글
                                            self.commentParentId.append(-1)
                                            print("삭제된 대댓글 && 대댓글이 있는 경우 parentId 추가: \(self.commentParentId)")
                                            //대댓글 달 때 유저이름 저장
                                            self.userNames.append("X")
                                        }
                                    }
                                    return
                                }
                            }
                        }
                    }
                }
                ///대댓글이 없는 경우
                else {
                    //삭제된 글인지 분기
                    if(element.status) {
                        cell.contentLabel.text = element.content ?? "댓글이 삭제 안된 글(에러)"
                        cell.hiddenProperty()
                        //삭제된 글이 아니라면 익명성 체크
                        if let isAnnoymity = element.anonymity {
                            if(isAnnoymity) {
                                cell.userName.text = "(익명)"
                                //대댓글 달 때 유저이름 저장
                                self.userNames.append("(익명)")
                            } else if(!isAnnoymity) {
                                if let isWriter = element.isWriter {
                                    if isWriter { cell.userName.text = (element.user?.nickname ?? "") + "(글쓴이)" }
                                }
                                if let isMine = element.isMine {
                                    if isMine {
                                        cell.userName.text = element.user?.nickname ?? "본인이름없음" + "(본인)"
                                        cell.hiddenProperty()
                                    }
                                }
                                //Profile Img
                                if let imgUrl = element.user?.profileImg {
                                    cell.userImageView.kf.setImage(with: URL(string: imgUrl))
                                }
                                //대댓글 달 때 유저이름 저장
                                self.userNames.append(element.user?.nickname ?? "")
                            }
                        } else {
                            cell.userName.text = element.user?.nickname ?? "닉네임 불러오기 에러"
                        }
                        self.commentParentId.append(element.id)
                        print("대댓글이 없는경우 댓글 ParentId 추가: \(self.commentParentId)")
                        //Date
                        guard let isModified = element.isModified,
                              let modifiedAt = element.modifiedAt,
                              let createdAt  = element.createdAt
                        else { return }
                        let date = self.currentDate(isModified, modifiedAt, createdAt)
                        cell.dateLabel.text = date
                    } else { //삭제된 글인 경우
                        cell.setDeleteComment()
                        self.commentParentId.append(-1)
                        print("삭제된 글 && 대댓글이 없는 경우 parentId 추가: \(self.commentParentId)")
                        //대댓글 달 때 유저이름 저장
                        self.userNames.append("X")
                    }
                }
                self.scrollView.updateContentSize()
            }.disposed(by: disposeBag)
    }
    
    func currentDate(_ isModified: Bool, _ modifiedAt: String, _ createdAt: String) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        format.locale = Locale(identifier: "ko")
        format.timeZone = TimeZone(abbreviation: "KST")
        var tempDate: Date
        isModified ? (tempDate = format.date(from: modifiedAt) ?? Date()) : (tempDate = format.date(from: createdAt) ?? Date())
        format.dateFormat = "yyyy년 MM월 dd일 a hh:mm"
        format.amSymbol = "오전"
        format.pmSymbol = "오후"
        var str = format.string(from: tempDate)
        isModified ? (str = str + "(수정됨)") : (str = str)
        return str
    }
}

extension CommunityDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 10))
        
        tableView.sectionHeaderTopPadding = 0
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "정보를 불러오는 중입니다."
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = .black
        
        self.viewModel.output.commentCntOutput
            .drive(onNext: { cnt in
                label.text = ("\(cnt)개의 댓글")
                label.attributedText = self.attributeText(originalText: label.text ?? "", range: "\(cnt)", color: "5B43EF")
            }).disposed(by: disposeBag)
        
        headerView.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(21)
            $0.centerY.equalToSuperview()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

extension CommunityDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
            guard textView.textColor == .secondaryLabel else { return }
            textView.text = nil
            textView.textColor = .label
        }
}

extension UIScrollView {
    //not use
   func updateContentView() {
      contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
   }
}

extension UIScrollView {
    func updateContentSize() {
        let unionCalculatedTotalRect = recursiveUnionInDepthFor(view: self)
        
        // 계산된 크기로 컨텐츠 사이즈 설정
        self.contentSize = CGSize(width: self.frame.width, height: unionCalculatedTotalRect.height+75)
    }
    
    private func recursiveUnionInDepthFor(view: UIView) -> CGRect {
        var totalRect: CGRect = .zero
        
        // 모든 자식 View의 컨트롤의 크기를 재귀적으로 호출하며 최종 영역의 크기를 설정
        for subView in view.subviews {
            totalRect = totalRect.union(recursiveUnionInDepthFor(view: subView))
        }
        
        // 최종 계산 영역의 크기를 반환
        return totalRect.union(view.frame)
    }
}

extension CommunityDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}
