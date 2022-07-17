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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
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
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.sendUserParticipatedInfo
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] participatedData in
                guard let self = self else { return }
                ///title 라벨
                self.titleLabel.text = "\(self.viewModel.user.nickname)님은\n\(participatedData.data.count)개의 정책에 참여했네요!"
                self.setLabelTextColor(sender: self.titleLabel, count: participatedData.data.count)
                ///save selected Id
                if (participatedData.data.count > 0) {
//                    self.isBookmared.removeAll()
                    for i in 0..<(participatedData.data.count) {
                        self.selectedId.append(participatedData.data[i].policy.id)
                        self.participatedId.append(participatedData.data[i].id)
                        ///북마크 조정
//                        self.isBookmared.append(participatedData.data[i].policy.isInterest)
                        
                    }
                    self.indexPath = IndexPath(row: participatedData.data.count, section: 0)
                }
//                print("저장된 북마크 등록정보: \(self.isBookmared)")
            }).disposed(by: disposeBag)
        
        viewModel.output.sendUserParticipatedInfo
            .scan(into: [ParticipationModel](), accumulator: { models, data in
                models.removeAll()
                for i in 0..<data.data.count {
                    models.append(data.data[i])
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
                            self.present(vc, animated: true)
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
                            self.present(vc, animated: true)
                        }.disposed(by: cell.disposeBag)
                }
                
                
                
                
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
    
    func setLabelTextColor(sender: UILabel, count: Int) {
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
