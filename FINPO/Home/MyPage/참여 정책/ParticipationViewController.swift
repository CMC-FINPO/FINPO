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

class ParticipationViewController: UIViewController {
    let viewModel = MyPageViewModel()
    let disposeBag = DisposeBag()
    
    ///불러온 정책 아이디 저장
    var selectedId: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "핀포님은\n2개의 정책에 참여했네요!"
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
//        tv.rowHeight = 150
        tv.separatorInset.left = 0
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = UIColor(hexString: "F9F9F9")
        ///네비게이션
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
     
        ///테이블뷰
//        policyTableView.delegate = self
        policyTableView.register(ParticipationTableViewCell.self, forCellReuseIdentifier: "ParticipationTableViewCell")
//        policyTableView.estimatedRowHeight = 150
//        policyTableView.rowHeight = UITableView.automaticDimension
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
        rx.viewWillAppear.take(1).asDriver { _ in .never()}
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
                    for i in 0..<(participatedData.data.count) {
                        self.selectedId.append(participatedData.data[i].policy.id)
                    }
                }
                print("불러온 참여정책 id 값: \(self.selectedId)")
            }).disposed(by: disposeBag)
        
        viewModel.output.sendUserParticipatedInfo
            .scan(into: [ParticipationModel](), accumulator: { models, data in
                for i in 0..<data.data.count {
                    models.append(data.data[i])
                }
            })
            .bind(to: self.policyTableView.rx.items(cellIdentifier: "ParticipationTableViewCell", cellType: ParticipationTableViewCell.self)) {
                (index: Int, element: ParticipationModel, cell) in
                cell.regionLabel.text = "\(element.policy.region.parent?.name ?? "")" + " " + "\(element.policy.region.name)"
                cell.policyNameLabel.text = element.policy.title
                cell.organizationLabel.text = element.policy.institution ?? "미정"
                print("가져온 메모: \(element.memo ?? "메모없음")")
                if(element.memo == nil) {
                    cell.memoEditButton.setTitle("메모 작성", for: .normal)
                } else {
                    cell.memoTextLabel.text = element.memo ?? ""
                    cell.memoEditButton.setTitle("메모 수정", for: .normal)
                }
            }.disposed(by: disposeBag)
        
        
    }
    
    func setLabelTextColor(sender: UILabel, count: Int) {
        let attributedText = NSMutableAttributedString(string: self.titleLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "5B43EF"), range: (self.titleLabel.text! as NSString).range(of: "\(count)"))
        self.titleLabel.attributedText = attributedText
    }
}

