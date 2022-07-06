//
//  InterestRegionViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/06.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class InterestRegionViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: MyPageViewModel?
    let tableViewModel = LoginViewModel()
    var isSelected: Bool = false
    
    func setViewModel(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "핀포님이\n관심 지역을 선택해주세요?"
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "000000")
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var tagCollectionView: UICollectionView = {
//        let flow = UICollectionViewFlowLayout()
        let flow = LeftAlignedCollectionViewFlowLayout() //셀 왼쪽 정렬
        flow.scrollDirection = .vertical
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private var mainRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(60)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.bounces = false
        tv.layer.masksToBounds = true
        return tv
    }()
    
    private var localRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(40)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.bounces = false
        tv.showsHorizontalScrollIndicator = false
        tv.layoutIfNeeded()
        return tv
    }()
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
        button.setTitle("선택 완료", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.backgroundColor = UIColor(hexString: "F0F0F0")
        button.layer.cornerRadius = 5
        button.isEnabled = true
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate func setAttribute() {
        ///네비게이션
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        ///태그 컬렉션뷰
        tagCollectionView.delegate = self
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "InterestColltionViewCell")
        
        ///지역 테이블뷰
        mainRegionTableView.register(MainRegionTableViewCell.self, forCellReuseIdentifier: "InterestMainTVCell")
        localRegionTableView.register(SubRegionTableViewCell.self, forCellReuseIdentifier: "InterestLocalTVCell")
    }
    
    fileprivate func setLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.trailing.equalToSuperview().inset(21)
        }
        
        view.addSubview(tagCollectionView)
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(100)
        }
        
        view.addSubview(mainRegionTableView)
        mainRegionTableView.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(15)
            $0.width.equalTo(100)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-150)
        }
        
        view.addSubview(localRegionTableView)
        localRegionTableView.snp.makeConstraints {
            $0.top.equalTo(mainRegionTableView.snp.top)
            $0.leading.equalTo(mainRegionTableView.snp.trailing)
            $0.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-150)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let viewModel = self.viewModel else { return }
                self.titleLabel.text = "\(viewModel.user.nickname)님의\n관심 지역을 선택해 주세요"
                ///관심지역 Trigger
                self.tableViewModel.input.interestRegionObserver.accept(())
                
                ///테이블뷰 데이터 Trigger
                self.tableViewModel.getMainRegionDataToTableView()
                self.tableViewModel.getSubRegionDataToTableView(0) //default: Seoul
                
            }).disposed(by: disposeBag)
        
        mainRegionTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableViewModel.getSubRegionDataToTableView(indexPath.row)
            }).disposed(by: disposeBag)
        
        localRegionTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if(self.isSelected == false) {
                    self.tagCollectionView.subviews[(self.tagCollectionView.subviews.count)-1].removeFromSuperview()
                    self.isSelected = true
                    self.tableViewModel.input.regeionButtonObserver.accept(true)
                }
                self.tableViewModel.input.subRegionTapped.accept(indexPath.row)
                ///확인 버튼 정합성
                self.tableViewModel.input.regeionButtonObserver.accept(true)
            }).disposed(by: disposeBag)
        
        tagCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if self.tagCollectionView.visibleCells.count <= 1 {
                    self.createDefaultTag()
                    self.isSelected = false
                    ///확인 버튼 정합성
                    self.tableViewModel.input.regeionButtonObserver.accept(false)
                } else {
                    self.isSelected = true
                }
                print("선택된 관심 지역 리스트 \(self.tableViewModel.user.interestRegion)")
                self.tableViewModel.selectedInterestRegion = self.viewModel?.user.interestRegion ?? [Int]()
                self.tableViewModel.input.deleteTagObserver.accept(indexPath.row)
            }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableViewModel.input.editInterestRegionObserver.accept(self?.tableViewModel.selectedInterestRegion ?? [Int]())
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        tableViewModel.output.mainRegionUpdate
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: mainRegionTableView.rx.items(cellIdentifier: "InterestMainTVCell")) {
                (index: Int, element: MainRegion, cell: MainRegionTableViewCell) in
                if index > 2 {
                    cell.setLayout()
                }
                if index == 0 || index == 1 || index == 2 {
                    cell.setRegionLayout()
                    cell.notReadyRegionLabel.isHidden = true
                }
                cell.selectionStyle = .none
                cell.mainRegionLabel.text = element.name
            }.disposed(by: disposeBag)
        
        tableViewModel.output.subRegionUpdate
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: localRegionTableView.rx.items(cellIdentifier: "InterestLocalTVCell")) {
                (index: Int, element: SubRegion, cell: SubRegionTableViewCell) in
                cell.selectionStyle = .none
                cell.subRegionLabel.text = element.name
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
            }.disposed(by: disposeBag)
        
        tableViewModel.output.regionButton
            .scan([UniouRegion]()) { regions, type in
                var newRegions = regions
                switch type {
                case .add(let region):
                    newRegions.append(region)
                case .delete(let index):
                    newRegions.remove(at: index)
                case .first(let userData):
                    for i in 0..<userData.data.count {
                        ///관심지역만 골라서 방출하기
                        if !userData.data[i].isDefault {
                            let unionRegion = UniouRegion(unionRegionName: (userData.data[i].region.parent?.name ?? "") + " " + (userData.data[i].region.name))
                            newRegions.append(unionRegion)
                            ///처음 로드 시 관심지역도 임시저장
                            self.tableViewModel.selectedInterestRegion.append(userData.data[i].region.id)
                        }

                    }
                }
                return newRegions
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: tagCollectionView.rx.items(cellIdentifier: "InterestColltionViewCell", cellType: TagCollectionViewCell.self)) {
                (index: Int, element: UniouRegion, cell) in
                print("들어옴")
                cell.setLayout()
                cell.tagLabel.text = element.unionRegionName
                cell.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 3
                print("tagCollectionview 인덱스 \(index)")
            }.disposed(by: disposeBag)
        
        tableViewModel.output.editInterestRegionCompleted
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    self?.navigationController?.popViewController(animated: true)
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func createDefaultTag() {
        let dummyLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 16)
            $0.text = "선택한 곳이 없어요..😅"
            $0.sizeToFit()
        }
        let size = dummyLabel.frame.size
        
        let views = UIView(frame: CGRect(x: 5, y: 5, width: size.width, height: size.height))
        views.layer.borderWidth = 1
        views.layer.borderColor = UIColor(hexString: "A2A2A2").cgColor
        views.bounds = views.frame.insetBy(dx: -5, dy: -5)
        views.layer.cornerRadius = 3
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        titleLabel.textColor = UIColor(hexString: "A2A2A2")
        titleLabel.text = "선택한 곳이 없어요..😅"
        self.tagCollectionView.addSubview(views)
        views.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(size.height)
            $0.width.equalTo(size.width)
        }
    }
}
extension InterestRegionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let cellItemForRow: CGFloat = 3
        let minimumSpacing: CGFloat = 2
        
        let width = (collectionViewWidth - (cellItemForRow - 1) * minimumSpacing) / cellItemForRow
        
        return CGSize(width: width, height: width/5)
    }
}

