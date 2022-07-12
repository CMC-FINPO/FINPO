//
//  AlarmViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/11.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class AlarmViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let viewModel = AlarmViewModel()
    
    //네비게이션 Bar 버튼
    var refreshBarButton = UIBarButtonItem()
    var treshBarButton = UIBarButtonItem()
    var completeBarButton = UIBarButtonItem()
    
    let refreshButton = UIButton()
    let treshButton = UIButton()
    let completeButton = UIButton()
    
    var isDelete: Bool = false
    
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
    
    private var alarmTableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.estimatedRowHeight = 80
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = UIColor(hexString: "F9F9F9")
        ///네비게이션
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        ///네비게이션 버튼 생성(새로고침, 휴지통)
 
        refreshButton.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        refreshButton.setImage(UIImage(named: "Group 39"), for: .normal)
        refreshBarButton.customView = refreshButton
                
        treshButton.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        treshButton.setImage(UIImage(named: "delete"), for: .normal)
        treshBarButton.customView = treshButton
        
        completeButton.setTitle("완료", for: .normal)
        completeButton.setTitleColor(UIColor(hexString: "5B43EF"), for: .normal)
        completeButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        completeButton.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        completeBarButton.customView = completeButton
        
        self.navigationItem.rightBarButtonItems = [treshBarButton, refreshBarButton]
        
        //테이블뷰
        alarmTableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: "AlarmTableViewCell")
        alarmTableView.delegate = self
    }
    
    fileprivate func setLayout() {
        view.addSubview(alarmTableView)
        alarmTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.trailing.leading.equalToSuperview().inset(21)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                self?.viewModel.input.getMyAlarmList.accept(())
            }).disposed(by: disposeBag)
        
        self.refreshButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.viewModel.input.getMyAlarmList.accept(())
            }).disposed(by: disposeBag)
        
        self.treshButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.navigationItem.rightBarButtonItems = nil
                self?.navigationItem.rightBarButtonItem = self?.completeBarButton
                self?.viewModel.input.getMyDeleteAlarmList.accept(())
            }).disposed(by: disposeBag)
        
        self.completeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationItem.rightBarButtonItems = nil
                self.navigationItem.rightBarButtonItems = [self.treshBarButton, self.refreshBarButton]
                self.viewModel.input.getMyAlarmList.accept(())
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.sendAlarmList
            .scan(into: [AlarmContentDetail]()) { alarmDatas, alarmModel in
                alarmDatas.removeAll()
                switch alarmModel {
                case .first(let data):
                    for i in 0..<(data.data.content.count) {
                        alarmDatas.append(data.data.content[i])
                    }
                    self.isDelete = false
                case .delete(let data):
                    for i in 0..<(data.data.content.count) {
                        alarmDatas.append(data.data.content[i])
                    }
                    self.isDelete = true
                }
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: alarmTableView.rx.items(cellIdentifier: "AlarmTableViewCell", cellType: AlarmTableViewCell.self)) {
                (index: Int, element: AlarmContentDetail, cell) in
                if(self.isDelete) {
                    cell.alarmButton.setImage(UIImage(named: "delete_small"), for: .normal)
                    cell.remakeImage()
                    cell.alarmButton.rx.tap
                        .asDriver()
                        .drive(onNext: { [weak self] _ in
                            self?.viewModel.input.didTappedDeleteButtonObserver.accept(element.id)
                        }).disposed(by: cell.disposeBag)
                } else {
                    cell.alarmButton.setImage(UIImage(named: "alarm_active"), for: .normal)
                }
                ///정책명 라벨
                cell.alarmInfoLabel.text = element.policy.title
                ///Date
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                format.locale = Locale(identifier: "ko")
                format.timeZone = TimeZone(abbreviation: "KST")
                guard let tempDate = format.date(from: element.policy.modifiedAt!) else { return }
                format.dateFormat = "yyyy년 MM월 dd일 a hh:mm"
                format.amSymbol = "오전"
                format.pmSymbol = "오후"
                let str = format.string(from: tempDate)
                cell.alarmDateLabel.text = str
            }.disposed(by: disposeBag)
        
        viewModel.output.didCompletedDelete
            .subscribe(onNext: { valid in
                self.viewModel.input.getMyDeleteAlarmList.accept(())
            }).disposed(by: disposeBag)
        
        
    }
    
    
}

extension AlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}
