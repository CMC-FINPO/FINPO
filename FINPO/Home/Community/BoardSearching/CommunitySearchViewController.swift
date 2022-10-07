//
//  CommunitySearchViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/02.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CommunitySearchViewController: UIViewController {
    
    let viewModel: CommunitySearchViewModelType
    let disposeBag = DisposeBag()
    
    init(viewModel: CommunitySearchViewModelType = CommunitySearchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = CommunitySearchViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private lazy var searchBar: UISearchBar = {
        var bounds = UIScreen.main.bounds
        var width = bounds.size.width
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: width-28, height: 0))
        searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "제목이나 내용을 검색해주세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.G05])
        searchBar.searchTextField.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        searchBar.searchTextField.backgroundColor = UIColor.G08
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.layer.cornerRadius = 7
        searchBar.searchTextField.layer.borderColor = UIColor.G06.cgColor
        searchBar.searchTextField.layer.borderWidth = 1
        return searchBar
    }()
    
    private lazy var resultTableView: UITableView = {
        let resultTableView = UITableView()
        resultTableView.backgroundColor = UIColor.G09
        resultTableView.rowHeight = CGFloat(150)
        resultTableView.separatorInset.left = 0
        resultTableView.register(BoardTableViewCell.self, forCellReuseIdentifier: "BoardTableViewCell")
        return resultTableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.center = self.view.center
        view.hidesWhenStopped = true
        view.style = UIActivityIndicatorView.Style.medium
        return view
    }()
    
    private func setAttribute() {
        view.backgroundColor = UIColor.G09
        //textfield in NavigationItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
    }
    
    private func setLayout() {
        view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        view.addSubview(activityIndicator)
    }
    
    private func setInputBind() {
        //SearchBar의 검색 버튼 or TableView LoadMore 이벤트 시 불러오기
//        Observable.merge(
//            searchBar.rx.searchButtonClicked.asObservable(),
//            resultTableView.rx.reachedBottom(from: -25).asObservable()
//        )
        
        //Tap이 되었을 때 Text를 ViewModel로 보내기
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text) { $1 ?? "" }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in self?.viewModel.contentText.onNext(text) })
            .disposed(by: disposeBag)
        
        //테이블 더 불러오기
        resultTableView.rx.reachedBottom(from: -25)
            .bind(to: viewModel.increasePage)
            .disposed(by: disposeBag)
        
        //게시글 상세이동
        resultTableView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.DetailObserver)
            .disposed(by: disposeBag)
    }
    
    private func setOutputBind() {
        viewModel.fetchBoard
            .scan(into: [CommunityContentModel]()) { boards, response in
                boards.removeAll()
                for board in response.data.content {
                    boards.append(board)
                }
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: resultTableView.rx.items(cellIdentifier: "BoardTableViewCell", cellType: BoardTableViewCell.self)) {
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
                
//                cell.likeButton.rx.tap
//                    .subscribe(onNext: { _ in
//                        if(element.isLiked) {
//                            self.viewModel.input.unlikeObserver.accept(element.id)
//                        }
//                        else {
//                            self.viewModel.input.likeObserver.accept(element.id)
//                        }
//                    }).disposed(by: cell.cellBag)
                
                if(element.isBookmarked) {
                    cell.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
                } else {
                    cell.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                }
                
//                cell.bookMarkButton.rx.tap
//                    .subscribe(onNext: { [weak self] _ in
//                        if(element.isBookmarked) {
//                            self?.viewModel.input.undoBookmarkObserver.accept(element.id)
//                        } else {
//                            self?.viewModel.input.doBookmarkObserver.accept(element.id)
//                        }
//                    }).disposed(by: cell.cellBag)
            }
            .disposed(by: disposeBag)
        
        viewModel.activated
            .map { !$0 }
            .bind { [weak self] finished in
                finished ? (self?.activityIndicator.stopAnimating()) : (self?.activityIndicator.startAnimating())
            }.disposed(by: disposeBag)
                
        viewModel.moveToDetail
            .map { $0 }
            .bind { [weak self] boardData in
                let vc = CommunityDetailViewController()
                vc.initialize(id: boardData.id , boardData: boardData)
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
    }
}

extension CommunitySearchViewController: UITextFieldDelegate {
    
}
