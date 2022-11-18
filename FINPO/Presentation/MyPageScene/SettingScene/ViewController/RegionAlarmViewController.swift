//
//  RegionAlarmViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/15.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class RegionAlarmViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = CategoryAlarmViewModel()
    
    //header switch
    let alarmSwitch = UISwitch()
    
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
    
    private var AlarmTableView: UITableView = {
        let tv = UITableView()
        tv.bounces = false
        tv.separatorInset.left = 0
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        
        ///navigation
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        self.navigationItem.title = "지역 알림 설정"
        
        ///테이블뷰
        self.AlarmTableView.delegate = self
        self.AlarmTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "InterestRegionTableViewCell")
    }
    
    fileprivate func setLayout() {
        view.addSubview(AlarmTableView)
        AlarmTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.input.myInterestRegionObserver.accept(())
                
            }).disposed(by: disposeBag)
        
        self.alarmSwitch.rx.isOn.changed
            .asDriver()
            .drive(onNext: { [weak self] boolean in
                guard let self = self else { return }
                self.viewModel.input.didTappedWholeSwitchObserver.accept(boolean)
                if(self.alarmSwitch.isOn) {
                    self.alarmSwitch.thumbTintColor = UIColor(hexString: "5B43EF")
                    self.alarmSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                } else {
                    self.alarmSwitch.thumbTintColor = UIColor(hexString: "C4C4C5")
                    self.alarmSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.sendResultRegion
            .scan(into: [MyAlarmInterestRegion]()) { willAdded, dataFromAPI in
                willAdded.removeAll()
                for i in 0..<(dataFromAPI.data.interestRegions.count) {
                    willAdded.append(dataFromAPI.data.interestRegions[i])
                }
            }
            .debug()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: self.AlarmTableView.rx.items(cellIdentifier: "InterestRegionTableViewCell", cellType: SettingTableViewCell.self)) {
                (index: Int, element: MyAlarmInterestRegion, cell) in
                cell.selectionStyle = .none
                cell.settingNameLabel.text = element.region.name
                cell.controlSwitch.isHidden = false
                cell.controlSwitch.isOn = element.subscribe
                
                if(cell.controlSwitch.isOn) {
                    cell.controlSwitch.thumbTintColor = UIColor(hexString: "5B43EF")
                    cell.controlSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                } else if(!cell.controlSwitch.isOn) {
                    cell.controlSwitch.thumbTintColor = UIColor(hexString: "C4C4C5")
                    cell.controlSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                }
                
                cell.controlSwitch.rx.isOn.changed
                    .asDriver()
                    .drive(onNext: { [weak self] boolean in
                        guard let self = self else { return }
                        self.viewModel.input.didTappedRegionCellSwtichIdObserver.accept(element.id ?? -1)
                        self.viewModel.input.didTappedRegionCellSwitchSubsObserver.accept(boolean)
                    }).disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
    }
}

extension RegionAlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "전체 알림"
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        label.textColor = .black
        
        DispatchQueue.main.async {
            self.alarmSwitch.isHidden = false
            self.alarmSwitch.layer.masksToBounds = true
            self.alarmSwitch.layer.cornerRadius = 15
            self.alarmSwitch.layer.borderWidth = 1
            self.alarmSwitch.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
        }
        
        self.viewModel.output.sendResultRegion
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.alarmSwitch.isOn = data.data.subscribe
                if(data.data.subscribe) {
                    self.alarmSwitch.isOn = true
                    self.alarmSwitch.thumbTintColor = UIColor(hexString: "5B43EF")
                    self.alarmSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                } else {
                    self.alarmSwitch.isOn = false
                    self.alarmSwitch.thumbTintColor = UIColor(hexString: "C4C4C5")
                    self.alarmSwitch.onTintColor = UIColor(hexString: "F0F0F0")
                }
            }).disposed(by: disposeBag)
        
        headerView.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(21)
            $0.centerY.equalToSuperview()
        }
        headerView.addSubview(alarmSwitch)
        alarmSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(21)
            $0.centerY.equalToSuperview()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = AlarmTableView.dequeueReusableCell(withIdentifier: "InterestRegionTableViewCell", for: indexPath) as? SettingTableViewCell else { return }
        
        cell.disposeBag = DisposeBag()
    }
}
