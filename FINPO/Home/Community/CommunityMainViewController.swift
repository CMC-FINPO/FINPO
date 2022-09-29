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
import Kingfisher

class CommunityMainViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = CommunityViewModel()
    
    var isLastPage: Bool = false
    var idList: [Int] = [Int]()
    
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
        postTableView.refreshControl = UIRefreshControl()
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
        let viewController = CommunityWritingViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    fileprivate func setInputBind() {
        
        let reload = postTableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        Observable.merge([firstLoad, reload])
            .bind {
                self.viewModel.input.loadBoardObserver.accept(.latest)
            }
            .disposed(by: disposeBag)
        
        postTableView.rx.reachedBottom(from: -25)
            .map { a -> Bool in return true }
            .subscribe(onNext: { _ in
                if self.isLastPage {
                    return
                } else {
                    self.viewModel.input.loadMoreObserver.accept(())
                }
            }).disposed(by: disposeBag)
        
        sortPolicyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let alertVC = UIAlertController(title: "정렬", message: nil, preferredStyle: .actionSheet)
                alertVC.setTitle(font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 18), color: UIColor(named: "000000"))
                let latestAction = UIAlertAction(title: "최신순", style: .default) { [weak self] action in
                    guard let self = self else { return }
                    //최신순 - 최신순 했을 때 page 0 중복 방지
                    self.viewModel.currentPage = 0
                    self.viewModel.input.loadBoardObserver.accept(.latest)
                    DispatchQueue.main.async {
                        self.sortPolicyButton.setImage(UIImage(named: "chip=chip4"), for: .normal)
                    }
                }
                let popularAction = UIAlertAction(title: "인기순", style: .default) { [weak self] action in
                    guard let self = self else { return }
                    self.viewModel.currentPage = 0
                    self.viewModel.input.loadBoardObserver.accept(.popular)
                    DispatchQueue.main.async {
                        self.sortPolicyButton.setImage(UIImage(named: "chip=chip13"), for: .normal)
                    }
                }
                let cancelAction = UIAlertAction(title: "취소", style: .destructive)
                
                latestAction.setValue(UIColor(hexString: "5B43EF"), forKey: "titleTextColor")
                popularAction.setValue(UIColor(hexString: "5B43EF"), forKey: "titleTextColor")
                alertVC.addAction(latestAction)
                alertVC.addAction(popularAction)
                alertVC.addAction(cancelAction)
                alertVC.view.layer.masksToBounds = true
                alertVC.view.layer.cornerRadius = 5
                self?.present(alertVC, animated: true)
            }).disposed(by: disposeBag)
        
        postTableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                let vc = CommunityDetailViewController()
                vc.initialize(id: self.idList[indexPath.row])
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        self.viewModel.output.loadBoardOutput
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { action in
                switch action {
                case .first(let data):
                    self.sumOfPostLabel.text = "\(data.data.totalElements)개의 글"
                    self.sumOfPostLabel.attributedText = self.attributeText(originalText: self.sumOfPostLabel.text!, range: "\(data.data.totalElements)", color: "5B43EF")
                case .loadMore(let data):
                    self.sumOfPostLabel.text = "\(data.data.totalElements)개의 글"
                    self.sumOfPostLabel.attributedText = self.attributeText(originalText: self.sumOfPostLabel.text!, range: "\(data.data.totalElements)", color: "5B43EF")
                case .edited(_):
                    break
                }
            }).disposed(by: disposeBag)
        
        self.viewModel.output.loadBoardOutput
            .scan(into: [CommunityContentModel]()) { boards, action in
                switch action {
                case .first(let firstData):
                    boards.removeAll()
                    self.idList.removeAll()
                    if firstData.data.last {
                        self.isLastPage = true
                    }
                    for i in 0..<(firstData.data.content.count) {
                        boards.append(firstData.data.content[i])
                        self.idList.append(firstData.data.content[i].id)
                    }
                case .loadMore(let addedData):
                    if addedData.data.last {
                        self.isLastPage = true
                    }
                    for i in 0..<(addedData.data.content.count) {
                        boards.append(addedData.data.content[i])
                        self.idList.append(addedData.data.content[i].id)
                    }
                case .edited(let editedData):
                    boards.append(editedData)
                }
            }
            .debug()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: postTableView.rx.items(cellIdentifier: "postTableViewCell", cellType: BoardTableViewCell.self)) {
                (index, element, cell) in
                cell.selectionStyle = .none
                if let imageStr = element.user?.profileImg {
                    let profileImgURL = URL(string: imageStr)
                    cell.userImageView.kf.setImage(with: profileImgURL)
                } else {
                    cell.userImageView.image = UIImage(named: "profile=Default_72")
                }
                ///익명글
                if element.anonymity {
                    cell.userName.text = "(익명)"
                } else {
                    cell.userName.text = element.user?.nickname ?? "(알 수 없음)"
                }
                ///Date
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                format.locale = Locale(identifier: "ko")
                format.timeZone = TimeZone(abbreviation: "KST")
                var tempDate: Date
                element.isModified ? (tempDate = format.date(from: element.modifiedAt) ?? Date()) : (tempDate = format.date(from: element.createdAt) ?? Date())
                format.dateFormat = "yyyy년 MM월 dd일 a hh:mm"
                format.amSymbol = "오전"
                format.pmSymbol = "오후"
                let str = format.string(from: tempDate)
                cell.dateLabel.text = str
                cell.contentLabel.text = element.content
                
                ///좋아요, 댓글, 북마크 수
                cell.likeCountLabel.text = "좋아요 \(element.likes)"
                cell.viewsCountLabel.text = "・ 댓글 \(element.countOfComment)"
                cell.commentCountLabel.text = "・ 조회수 \(element.hits)"
                
                if(element.isLiked) {
                    cell.likeButton.setImage(UIImage(named: "like_active")?.withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                }
                
                cell.likeButton.rx.tap
                    .subscribe(onNext: { _ in
                        if(element.isLiked) {
                            self.viewModel.input.unlikeObserver.accept(element.id)
                        }
                        else {
                            self.viewModel.input.likeObserver.accept(element.id)
                        }
                    }).disposed(by: cell.cellBag)
                
                if(element.isBookmarked) {
                    cell.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
                } else {
                    cell.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                }
                
                cell.bookMarkButton.rx.tap
                    .subscribe(onNext: { [weak self] _ in
                        if(element.isBookmarked) {
                            self?.viewModel.input.undoBookmarkObserver.accept(element.id)
                        } else {
                            self?.viewModel.input.doBookmarkObserver.accept(element.id)
                        }
                    }).disposed(by: cell.cellBag)
                
            }.disposed(by: disposeBag)
    }
    
    public func attributeText(originalText: String, range: String, color: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: originalText)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "\(color)"), range: (originalText as NSString).range(of: "\(range)"))
        return attributedText
    }

}
