//
//  WriteMySelfViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/14.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

final class WriteMySelfViewController: UIViewController {
    
    let viewModel: SegmentedViewModelType
    let disposeBag = DisposeBag()
    
    init(viewModel: SegmentedViewModelType = SegmentedViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = SegmentedViewModel()
        super.init(coder: coder)
    }
    
    let dummyItems = Observable.just([
        " Usage of text input box ",
        " Usage of switch button ",
        " Usage of progress bar ",
        " Usage of text labels ",
        ])
    
    private lazy var boardTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(150)
        tv.bounces = true
        tv.refreshControl = UIRefreshControl()
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        tv.register(BoardTableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
        
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        

    }
    
    fileprivate func setLayout() {
        view.addSubview(boardTableView)
        boardTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    fileprivate func setInputBind() {
        let firstLoad = rx.viewWillAppear
            .map { _ in () }
        
        let reload = boardTableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        Observable.merge([firstLoad, reload])
            .bind(to: viewModel.fetchMyWriting)
            .disposed(by: disposeBag)
        
        boardTableView.rx.reachedBottom(from: -25)
            .bind(to: viewModel.loadMore)
            .disposed(by: disposeBag)
            
    }
    
    fileprivate func setOutputBind() {
        
        viewModel.mywritingResult
            .scan(into: [CommunityContentModel]()) { data, from in
                switch from {
                case .first(let firstModel):
                    data.removeAll()
                    for i in 0..<firstModel.data.content.count {
                        data.append(firstModel.data.content[i])
                    }
                case .loadMore(let moreModel):
                    for i in 0..<moreModel.data.content.count {
                        data.append(moreModel.data.content[i])
                    }
                }
            }
            .do(onNext: { [weak self] _ in self?.boardTableView.refreshControl?.endRefreshing()} )
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: boardTableView.rx.items(cellIdentifier: "cell", cellType: BoardTableViewCell.self)) {
                (index, element, cell) in
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
            }.disposed(by: disposeBag)
    }
    
}
