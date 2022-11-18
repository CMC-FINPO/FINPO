//
//  ReportViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/04.
//

import Foundation
import UIKit
import RxSwift

enum SortIsBoard {
    case board(Int)
    case comment(Int)
}

class ReportViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let viewModel: EditCommentViewModelType
    let commentId: SortIsBoard
    
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    let reportData = ["낚시/놀람/도배", "정당/정치인 비하 및 선거운동", "유출/사칭/사기", "게시판 성격에 부적절함", "음란물/불건전한 만남 및 대화", "상업적 광고 및 판매", "욕설/비하"]
    var reportOb: Observable<[String]>
    
    let defaultHeight: CGFloat = 500
    let dismissibleHeight: CGFloat = 100
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    
    init(viewModel: EditCommentViewModelType = EditCommentViewModel(), commentId: SortIsBoard) {
        self.viewModel = viewModel
        self.commentId = commentId
        self.reportOb = Observable.of(reportData)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = EditCommentViewModel()
        commentId = SortIsBoard.board(-1)
        reportOb = Observable.of(reportData)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.G09
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    let maxDimmedAlpha: CGFloat = 0.1
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var reportTableView: UITableView = {
        let tv = UITableView()
        tv.bounces = false
        tv.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv.sectionHeaderTopPadding = 0
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.delegate = self
        return tv
    }()
    
    private var cancelBtn: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor.G02, for: .normal)
        button.setBackgroundColor(UIColor.G08, for: .normal)
        return button
    }()
    
    private func setAttribute() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(animateDismissView))
        dimmedView.addGestureRecognizer(gesture)
        
        //신고 종류
        reportOb = Observable.of(reportData)
        
        cancelBtn.addTarget(self, action: #selector(animateDismissView), for: .touchUpInside)
    }
    
    private func setLayout() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // 6. Set container to default height
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        // 7. Set bottom constant to 0 -> defaultHeight
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
        
        containerView.addSubview(reportTableView)
        reportTableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        containerView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(54)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(350)
            $0.height.equalTo(55)
        }
    }
    
    private func setInputBind() {
        reportTableView.rx.itemSelected
            .map { $0.row + 1 }
            .bind { [weak self] index in
                guard let self = self else { return }
                switch self.commentId {
                case .board(let boardId):
                    self.viewModel.commentReportObserver.onNext((commentId: .board(boardId), reportId: index))
                case .comment(let commentId):
                    self.viewModel.commentReportObserver.onNext((commentId: .comment(commentId), reportId: index))
                }
            }
//                self.viewModel.commentReportObserver.onNext((commentId: self.commentId, reportId: index)) }
            .disposed(by: disposeBag)
    }
    
    private func setOutputBind() {
        reportOb
            .bind(to: reportTableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) {
                (index: Int, element: String, cell: UITableViewCell) in
                cell.textLabel?.textAlignment = .center
                cell.selectionStyle = .none
                cell.textLabel?.text = element
            }.disposed(by: disposeBag)
        
        viewModel.reportOutput
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] finished in
                self?.showAlert("신고 완료", "신고가 완료되었습니다")
                self?.animateDismissView()
            }).disposed(by: disposeBag)
    }
    
    @objc func animateDismissView() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
        
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            NotificationCenter.default.post(name: NSNotification.Name("DismissDetailView"), object: nil, userInfo: nil)
            self.dismiss(animated: false)
            
        }
    }
}

extension ReportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let label = UILabel()
        label.text = "신고 사유 선택"
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
        label.textColor = .black
        headerView.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    

}
