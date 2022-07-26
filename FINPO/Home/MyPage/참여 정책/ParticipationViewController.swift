//
//  ParticipationViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/07.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ParticipationViewController: UIViewController {
    let viewModel = MyPageViewModel()
    let homeViewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    var indexPath: IndexPath?
    
    ///불러온 정책 아이디 저장
    var selectedId: [Int] = [Int]()
    var participatedId: [Int] = [Int]()
//    var isBookmared: [Bool] = [Bool]()
    
    ///참여 정책 삭제버튼
    private let treshButton = UIButton()
    private var treshBarButton = UIBarButtonItem()
    var isDeleteMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    @objc func keyboardUp(notification:NSNotification) {
//        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//           let keyboardRectangle = keyboardFrame.cgRectValue
//       
//            UIView.animate(
//                withDuration: 0.3
//                , animations: {
//                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
//                }
//            )
//        }
//    }
//    
//    @objc func keyboardDown() {
//        self.view.transform = .identity
//    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "핀포님은\n0개의 정책에 참여했네요!"
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "000000")
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var policyTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.bounces = false
        tv.separatorInset.left = 0
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        tv.layer.masksToBounds = true
        tv.layer.cornerRadius = 5
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = UIColor(hexString: "F9F9F9")
        ///네비게이션
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
     
        ///테이블뷰
        policyTableView.register(ParticipationTableViewCell.self, forCellReuseIdentifier: "ParticipationTableViewCell")
        policyTableView.delegate = self
        
        ///참여 정책 삭제 버튼
        treshButton.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        treshButton.setImage(UIImage(named: "delete"), for: .normal)
        treshBarButton.customView = treshButton
        self.navigationItem.rightBarButtonItem = treshBarButton
    }
    
    fileprivate func setLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.trailing.equalToSuperview().inset(21)
        }
        
        view.addSubview(policyTableView)
        policyTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.asDriver { _ in .never()}
            .drive(onNext: { [weak self] _ in
                ///참여 정책 조회 및 수정
                self?.viewModel.input.getUserParticipatedInfo.accept(())                
            }).disposed(by: disposeBag)
        
        ///테이블뷰 셀 탭할 경우 상세보기 화면으로 넘어감
        policyTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let vc = HomeDetailViewController()
                vc.initialize(id: self?.selectedId[indexPath.row] ?? -1)
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        self.treshButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                if(self.isDeleteMode) {
                    self.treshButton.setImage(nil, for: .normal)
                    self.treshButton.setTitle("완료", for: .normal)
                } else {
                    self.viewModel.input.changeToDeleteMode.accept(())
                    self.treshButton.setImage(UIImage(named: "delete"), for: .normal)
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.sendUserParticipatedInfo
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] participatedData in
                guard let self = self else { return }
                switch participatedData {
                case .searchMode(let element):
                    ///title 라벨
                    self.titleLabel.text = "\(self.viewModel.user.nickname)님은\n\(element.data.count)개의 정책에 참여했네요!"
                    self.setLabelTextColor(sender: self.titleLabel, count: element.data.count)
                    ///save selected Id
                    if (element.data.count > 0) {
    //                    self.isBookmared.removeAll()
                        for i in 0..<(element.data.count) {
                            self.selectedId.append(element.data[i].policy.id)
                            self.participatedId.append(element.data[i].id)
                            ///북마크 조정
    //                        self.isBookmared.append(participatedData.data[i].policy.isInterest)
                            
                        }
                        self.indexPath = IndexPath(row: element.data.count, section: 0)
                    }
    //                print("저장된 북마크 등록정보: \(self.isBookmared)")
                case .deleteMode(let _):
                    break
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.sendUserParticipatedInfo
            .scan(into: [ParticipationModel](), accumulator: { models, data in
                switch data {
                case .searchMode(let searchData):
                    models.removeAll()
                    for i in 0..<searchData.data.count {
                        models.append(searchData.data[i])
                    }
                    self.isDeleteMode = false
                case .deleteMode(let deleteModeData):
                    models.removeAll()
                    for i in 0..<deleteModeData.data.count {
                        models.append(deleteModeData.data[i])
                }
                    self.isDeleteMode = true
                }
            })
            .observe(on: MainScheduler.instance)
            .bind(to: self.policyTableView.rx.items(cellIdentifier: "ParticipationTableViewCell", cellType: ParticipationTableViewCell.self)) {
                (index: Int, element: ParticipationModel, cell) in
                
                cell.regionLabel.text = "\(element.policy.region.parent?.name ?? "")" + " " + "\(element.policy.region.name)"
                cell.policyNameLabel.text = element.policy.title
                cell.organizationLabel.text = element.policy.institution ?? "미정"
                
                if(element.memo == nil) {
                    cell.memoEditButton.setTitle("메모 작성", for: .normal)
                    cell.memoStackView.rx.tapGesture()
                        .observe(on: MainScheduler.instance)
                        .when(.recognized)
                        .bind { [weak self] _ in
                            guard let self = self else { return }
                            let vc = MemoViewController()
                            vc.setupProperty(id: self.selectedId[index], on: self.homeViewModel, participatedId: self.participatedId[index])
                            vc.modalPresentationStyle = .overCurrentContext
                            self.present(vc, animated: false)
                        }.disposed(by: cell.disposeBag)
                } else {
                    cell.memoTextLabel.text = element.memo ?? ""
                    cell.memoEditButton.setTitle("메모 수정", for: .normal)
                    cell.memoStackView.rx.tapGesture()
                        .observe(on: MainScheduler.instance)
                        .when(.recognized)
                        .bind { [weak self] _ in
                            guard let self = self else { return }
                            let vc = MemoViewController()
                            vc.titleLabel.text = "메모 수정"
                            vc.setupProperty(id: self.selectedId[index], on: self.homeViewModel, participatedId: self.participatedId[index])
                            vc.modalPresentationStyle = .overCurrentContext
                            self.present(vc, animated: false)
                        }.disposed(by: cell.disposeBag)
                }
                
                if(self.isDeleteMode) {
                    cell.bookMarkButton.setImage(UIImage(named: "delete"), for: .normal)
                    ///삭제 버튼 클릭 시 알럿 생성 및 정책 id 넘겨주기
                    cell.bookMarkButton.rx.tap
                        .asDriver()
                        .drive(onNext: { [weak self] _ in
                            guard let self = self else { return }
                            let ac = UIAlertController(title: "참여한 정책을 삭제하시겠습니까?", message: nil, preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "취소", style: .destructive))
                            ac.addAction(UIAlertAction(title: "삭제", style: .default, handler: { _ in
                                ///참여 정책 id로 삭제 트리거
                                self.viewModel.input.participatedPolicyDeleteObserver.accept(element.id)
                            }))                            
                            self.present(ac, animated: true)
                        }).disposed(by: cell.disposeBag)
                } else {
                    //서버에서 북마크 상태 체크
                    if(element.policy.isInterest) {
                        cell.bookMarkButton.setImage(UIImage(named: "bookmark_top_active"), for: .normal)
                    } else {
                        cell.bookMarkButton.setImage(UIImage(named: "bookmark_top"), for: .normal)
                    }
                    
                    ///북마크 버튼 선택 시 "관심정책" 유무
                    cell.bookMarkButton.rx.tap
                        .asDriver()
                        .drive(onNext: { [weak self] _ in
                            guard let self = self else { return }
                            if(element.policy.isInterest) {
                                self.homeViewModel.input.bookmarkDeleteObserver.accept(self.selectedId[index])
                                cell.bookMarkButton.setImage(UIImage(named: "bookmark_top"), for: .normal)
                            } else {
                                self.homeViewModel.input.bookmarkObserver.accept(self.selectedId[index])
                                cell.bookMarkButton.setImage(UIImage(named: "bookmark_top_active"), for: .normal)
                            }
                        }).disposed(by: cell.disposeBag)
                }
                
       
            }.disposed(by: disposeBag)
        
        
//        homeViewModel.output.checkedBookmarkOutput
//            .asObservable()
//            .subscribe(onNext: { [weak self] valid in
//                if valid {
//                    self?.policyTableView.reloadRows(at: [self?.indexPath ?? IndexPath()], with: .automatic)
//                    print("인덱스패스: \(self?.indexPath)")
//                }
//            }).disposed(by: disposeBag)
//        
//        homeViewModel.output.checkedBookmarkDeleteOutput
//            .asObservable()
//            .subscribe(onNext: { [weak self] valid in
//                if valid {
//                    self?.policyTableView.reloadRows(at: [self?.indexPath ?? IndexPath()], with: .automatic)
//                }
//            }).disposed(by: disposeBag)
    }
    
    public func setLabelTextColor(sender: UILabel, count: Int) {
        let attributedText = NSMutableAttributedString(string: self.titleLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "5B43EF"), range: (self.titleLabel.text! as NSString).range(of: "\(count)"))
        self.titleLabel.attributedText = attributedText
    }
}

extension ParticipationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = policyTableView.dequeueReusableCell(withIdentifier: "ParticipationTableViewCell", for: indexPath) as? ParticipationTableViewCell else { return }
        
        ///화면 밖에서 사라질 때 subscription을 dispose 하기
        cell.disposeBag = DisposeBag()
    }
}
