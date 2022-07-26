//
//  MyRegionViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/06.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MyRegionViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: MyPageViewModel?
    let tableViewModel = LoginViewModel()
    var isSelected: Bool = true
    
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
        label.text = "핀포님이 현재 거주하고 있는 지역을 선택해주세요"
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "000000")
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var tagCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private var mainRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(50)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.bounces = false
        tv.layer.masksToBounds = true
        tv.separatorInset.left = 0
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        return tv
    }()
    
    private var localRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(50)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.bounces = false
        tv.showsHorizontalScrollIndicator = false
        tv.separatorInset.left = 0
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
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
        
        ///태그 컬렉션 뷰
        tagCollectionView.delegate = self
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "MyRegionCollectionViewCell")
        
        ///지역 테이블뷰
        mainRegionTableView.register(MainRegionTableViewCell.self, forCellReuseIdentifier: "MyRegionMainTVCell")
        localRegionTableView.register(SubRegionTableViewCell.self, forCellReuseIdentifier: "MyReionLocalTVCell")
    }
    
    fileprivate func setLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.trailing.equalToSuperview().inset(21)
        }
        
        view.addSubview(tagCollectionView)
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.width.equalToSuperview().inset(10)
            $0.height.equalTo(85)
        }
        
        view.addSubview(mainRegionTableView)
        mainRegionTableView.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(15)
            $0.width.equalTo(100)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
        }
        
        view.addSubview(localRegionTableView)
        localRegionTableView.snp.makeConstraints {
            $0.top.equalTo(mainRegionTableView.snp.top)
            $0.leading.equalTo(mainRegionTableView.snp.trailing)
            $0.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let viewModel = self.viewModel else { return }
                ///닉네임 설정
                self.titleLabel.text = "\(viewModel.user.nickname)님이 현재 거주하고 있는\n지역을 선택해주세요"
                
                ///거주지역 Trigger
                self.tableViewModel.input.myRegionObserver.accept(())
                
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
//            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                if(self?.isSelected == false) {
                    self?.tableViewModel.input.subRegionTapped.accept(indexPath.row)
                    self?.tagCollectionView.subviews[0].removeFromSuperview()
                    self?.tableViewModel.input.regeionButtonObserver.accept(true)
                    self?.isSelected = true
                } else {
                    self?.isSelected = true
                }
            }).disposed(by: disposeBag)
        
        tagCollectionView.rx.itemSelected
            .subscribe(onNext:{ [weak self] indexPath in
                if(self?.isSelected == true) {
                    let cell = self?.tagCollectionView.cellForItem(at: indexPath)
                    cell?.removeFromSuperview()
                    self?.createDefaultTag()
                    LoginViewModel.isMainRegionSelected = false
                    self?.isSelected = false
                    self?.tableViewModel.input.regeionButtonObserver.accept(false)
                } else {
                    self?.isSelected = false
                }
            }).disposed(by: disposeBag)
        
        ///서버에 저장
        confirmButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableViewModel.input.editMainRegionObserver.accept(self?.tableViewModel.selectedMainRegion ?? -1)
                //add notification (EditRegionVC)
                NotificationCenter.default.post(name: NSNotification.Name("popViewController"), object: nil, userInfo: nil)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        tableViewModel.output.mainRegionUpdate
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: mainRegionTableView.rx.items(cellIdentifier: "MyRegionMainTVCell")) {
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
            .bind(to: localRegionTableView.rx.items(cellIdentifier: "MyReionLocalTVCell")) {
                (index: Int, element: SubRegion, cell: SubRegionTableViewCell) in
                cell.selectionStyle = .none
                cell.subRegionLabel.text = element.name
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
            }.disposed(by: disposeBag)
                
        tableViewModel.output.regionButton
            .scan(into: [UniouRegion]()) { regions, type in
                regions.removeAll()
//                var newRegions = [UniouRegion]()
                switch type {
                case .first(let userData):
                    for i in 0..<userData.data.count {
                        ///거주지역만 골라서 방출
                        if userData.data[i].isDefault {
                            let unionRegion = UniouRegion(unionRegionName: (userData.data[i].region.parent?.name ?? "") + " " + (userData.data[i].region.name))
                            regions.append(unionRegion)
                            ///메인지역 임시 저장
                            self.tableViewModel.selectedMainRegion = userData.data[i].region.id
                        }
                    }
                case .add(let region):
                    regions.append(region)
                case .delete(let index):
                    self.tableViewModel.selectedMainRegion = -1
                    print("임시저장 된 메인지역: \(self.tableViewModel.selectedMainRegion)")
                    regions.remove(at: index)
                }
//                return newRegions
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: tagCollectionView.rx.items(cellIdentifier: "MyRegionCollectionViewCell", cellType: TagCollectionViewCell.self)) {
                (index: Int, element: UniouRegion, cell) in
                cell.setLayout()
                cell.tagLabel.text = element.unionRegionName
                cell.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 3
            }.disposed(by: disposeBag)
        
        tableViewModel.output.regionButtonValid
            .drive(onNext: { valid in
                if valid {
                    self.confirmButton.isEnabled = true
                    self.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                    self.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                } else {
                    self.confirmButton.isEnabled = false
                    self.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .disabled)
                    self.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                }
            }).disposed(by: disposeBag)
        
        tableViewModel.output.editMainRegionCompleted
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
//                self?.navigationController?.popViewController(animated: true)
                //페이징뷰로 구성되어 있으므로 이 뷰컨에서 네비게이션은 안 됨
                self?.viewModel?.input.popViewObserver.accept(true)
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

extension MyRegionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let cellItemForRow: CGFloat = 3
        let minimumSpacing: CGFloat = 18
        
        let width = (collectionViewWidth - (cellItemForRow - 1) * minimumSpacing) / cellItemForRow
        
        return CGSize(width: width, height: width/5 + 7)
    }
}
