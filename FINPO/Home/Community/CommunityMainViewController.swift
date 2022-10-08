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
    var checkIsMine: [CommunityContentModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
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
        tv.separatorInset.left = 0
        return tv
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        return view
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
        postTableView.delegate = self
    }
    
    fileprivate func setLayout() {
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
        let vc = CommunitySearchViewController()
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func moveToWritingVC() {
        let viewController = CommunityWritingViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    fileprivate func setInputBind() {
        
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                self?.viewModel.input.loadBoardObserver.accept(.latest)
            }).disposed(by: disposeBag)
        
        let reload = postTableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        Observable.merge([firstLoad, reload])
            .bind { [weak self] _ in
                self?.viewModel.currentPage = 0
                self?.isLastPage = false
                //밑에거 없이 트리거만 작동하면 리프레쉬 되게
//                self?.viewModel.input.loadBoardObserver.accept(.latest)
                self?.viewModel.input.reloadObserver.accept(())
            }
            .disposed(by: disposeBag)
        
        postTableView.rx.reachedBottom(from: -25)
            .map { a -> Bool in return true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
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
                    self.isLastPage = false
                    self.viewModel.input.loadBoardObserver.accept(.latest)
                    DispatchQueue.main.async {
                        self.sortPolicyButton.setImage(UIImage(named: "chip=chip4"), for: .normal)
                    }
                }
                let popularAction = UIAlertAction(title: "인기순", style: .default) { [weak self] action in
                    guard let self = self else { return }
                    self.viewModel.currentPage = 0
                    self.isLastPage = false
                    self.viewModel.input.loadBoardObserver.accept(.popular)
                    DispatchQueue.main.async {
                        self.sortPolicyButton.setImage(UIImage(named: "chip=chip13"), for: .normal)
                    }
                }
                let cancelAction = UIAlertAction(title: "취소", style: .destructive)
                
                latestAction.setValue(UIColor.P01, forKey: "titleTextColor")
                popularAction.setValue(UIColor.P01, forKey: "titleTextColor")
                alertVC.addAction(latestAction)
                alertVC.addAction(popularAction)
                alertVC.addAction(cancelAction)
                alertVC.view.layer.masksToBounds = true
                alertVC.view.layer.cornerRadius = 5
                self?.present(alertVC, animated: true)
            }).disposed(by: disposeBag)
        
        postTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let vc = CommunityDetailViewController()
                guard let self = self else { return }
                vc.initialize(id: self.idList[indexPath.row], boardData: self.checkIsMine[indexPath.row])
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
            .scan(into: [CommunityContentModel]()) { [weak self] boards, action in
                guard let self = self else { return }
                switch action {
                case .first(let firstData):
                    boards.removeAll()
                    self.idList.removeAll()
                    self.checkIsMine.removeAll()
                    if firstData.data.last {
                        self.isLastPage = true
                    }
                    for i in 0..<(firstData.data.content.count) {
                        boards.append(firstData.data.content[i])
                        self.idList.append(firstData.data.content[i].id)
                        self.checkIsMine.append(firstData.data.content[i])
                    }
                case .loadMore(let addedData):
                    if addedData.data.last {
                        self.isLastPage = true
                    }
                    for i in 0..<(addedData.data.content.count) {
                        boards.append(addedData.data.content[i])
                        self.idList.append(addedData.data.content[i].id)
                        self.checkIsMine.append(addedData.data.content[i])
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
                
                cell.likeObserver.onNext(LikeMenu(boardId: element.id, isLike: !element.isLiked))
               
            }.disposed(by: disposeBag)
        
        viewModel.output.errorValue.asSignal()
            .emit(onNext: { [weak self] error in
                let errorMessage = error.message
                let ac = UIAlertController(title: "에러", message: errorMessage, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "확인", style: .cancel))
                self?.present(ac, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.output.activated?
            .map { !$0 }
            .observe(on: MainScheduler.asyncInstance)
            .do(onNext: { [weak self] finished in
                if finished {
                    self?.postTableView.refreshControl?.endRefreshing()
                }})
            .bind(to: activityIndicator.rx.isHidden)
            .disposed(by: disposeBag)
                
            
    }
    
    public func attributeText(originalText: String, range: String, color: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: originalText)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "\(color)"), range: (originalText as NSString).range(of: "\(range)"))
        return attributedText
    }
    
}

extension CommunityMainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell", for: indexPath) as? BoardTableViewCell else { return }
        cell.cellBag = DisposeBag()
    }
}
