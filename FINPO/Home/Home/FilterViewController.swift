//
//  FilterViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/28.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class FilterViewController: UIViewController, UIViewControllerTransitioningDelegate {

    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    
    var selectedCategory = [Int]()
    var selectedRegion = [Int]()
    
    static var isFirstLoad = true
    static var isEdited = false
    static var selectedCategories: [Int] = [Int]()
    static var selectedRegions: [Int] = [Int]()
    
    ///참여 공간 라벨 레이아웃 조정용
    static var participationTagStr = [String]()
    
    ///생활 안정 라벨 레이아웃 조정용
    static var livingTagStr = [String]()
    
    ///필터 리셋 시 FilterRegionVC에 전달
    static var isFilterResetBtnTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didDismissDetailNotification(_:)),
            name: NSNotification.Name("DismissDetailView"),
            object: nil
        )
        
    }
    
    @objc func didDismissDetailNotification(_ notification: Notification) {
        self.viewModel.input.tagLoadActionObserver.accept(.isFirstLoad(FilterRegionViewController.filteredDataList))
        self.viewModel.input.categoryObserver.accept(())
}
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false

//        FilterViewController.isEdited = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        FilterViewController.isFirstLoad = true
    }
    
    private var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    
    private var regionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "지역 선택"
        label.textColor = UIColor(hexString: "494949")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        return label
    }()
    
    private var regionTagCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
//        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = 3
        flow.minimumInteritemSpacing = 3
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.layer.masksToBounds = true
        cv.layer.cornerRadius = 3
        return cv
    }()
    
    private var guideForAddRegionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F0F0F0")
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        titleLabel.textColor = UIColor(hexString: "C4C4C5")
        titleLabel.text = "추가 할 지역 선택하기"
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        let imageView = UIImageView(image: UIImage(named: "down"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(298)
        }
        return view
    }()
    
    private var separatorLineView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        return separator
    }()
    
    private var jobTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "일자리"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var jobCategoryCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.minimumLineSpacing = 3
        flow.minimumInteritemSpacing = 10
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)        
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = true
        cv.isScrollEnabled = false
        return cv
    }()
    
    private var livingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "생활안정"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var livingCategoryCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.minimumLineSpacing = 3
        flow.minimumInteritemSpacing = 20
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = true
        cv.isScrollEnabled = false
        return cv
    }()
    
    private var educationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "교육 문화"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var educationCategoryCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.minimumLineSpacing = 3
        flow.minimumInteritemSpacing = 10
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = true
        cv.isScrollEnabled = false
        return cv
    }()
    
    private var participationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "참여 공간"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var participationCategoryCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
//        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = 3
        flow.minimumInteritemSpacing = 20
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 20)
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = true
        cv.isScrollEnabled = false
        return cv
    }()
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
        button.setTitle("선택 완료", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.backgroundColor = UIColor(hexString: "F0F0F0")
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        ///navigation
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        self.navigationItem.title = "필터"
        let rightBarButtonItem = UIBarButtonItem(title: "모두 초기화", style: .plain, target: self, action: #selector(resetFilter))
        rightBarButtonItem.tintColor = UIColor(hexString: "999999")
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 14)!]
        rightBarButtonItem.setTitleTextAttributes(attributes, for: .normal)
        rightBarButtonItem.setTitleTextAttributes(attributes, for: .selected)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "000000")
        
        ///collectionview
        regionTagCollectionView.delegate = self
        regionTagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "regionTagCollectionViewCell")
        
        ///region 선택 view
        let gesture = UITapGestureRecognizer(target: self, action: #selector(presentFilterView))
        guideForAddRegionView.addGestureRecognizer(gesture)
        
        ///카테고리 Collection view
        jobCategoryCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "jobCategoryCollectionView")
        
        livingCategoryCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "livingCategoryCollectionView")
        livingCategoryCollectionView.delegate = self
        
        educationCategoryCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "educationCategoryCollectionView")

        participationCategoryCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "participationCategoryCollectionView")
        participationCategoryCollectionView.delegate = self
    }
                                             
    @objc fileprivate func presentFilterView() {
        let vc = FilterRegionViewController()
//        vc.hidesBottomBarWhenPushed = true
        vc.modalPresentationStyle = .overCurrentContext
//        FilterViewController.isEdited = true
        self.present(vc, animated: false)
    }
    
    @objc fileprivate func resetFilter() {
        FilterViewController.isFilterResetBtnTapped = true
        self.viewModel.input.filterResetTriggerObserver.accept(())
        self.viewModel.input.categoryObserver.accept(())
    }
    
    fileprivate func setLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            $0.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            $0.height.equalTo(view.bounds.height+50)
        }
        
        contentView.addSubview(regionTitleLabel)
        regionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(15)
            $0.height.equalTo(15)
            $0.leading.equalToSuperview().inset(21)
        }
        
        contentView.addSubview(regionTagCollectionView)
        regionTagCollectionView.snp.makeConstraints {
            $0.top.equalTo(regionTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(regionTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(100)
        }
          
        contentView.addSubview(guideForAddRegionView)
        guideForAddRegionView.snp.makeConstraints {
            $0.top.equalTo(regionTagCollectionView.snp.bottom).offset(20)
            $0.leading.equalTo(regionTagCollectionView.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
        
        contentView.addSubview(separatorLineView)
        separatorLineView.snp.makeConstraints {
            $0.top.equalTo(guideForAddRegionView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        ///일자리
        contentView.addSubview(jobTitleLabel)
        jobTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLineView.snp.bottom).offset(15)
            $0.height.equalTo(15)
            $0.leading.equalTo(guideForAddRegionView.snp.leading)
        }
        
        contentView.addSubview(jobCategoryCollectionView)
        jobCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(jobTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        ///생활안정
        contentView.addSubview(livingTitleLabel)
        livingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(jobCategoryCollectionView.snp.bottom).offset(15)
            $0.height.equalTo(15)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
        }
        
        contentView.addSubview(livingCategoryCollectionView)
        livingCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(livingTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(livingTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(50)
        }
        
        ///교육문화
        contentView.addSubview(educationTitleLabel)
        educationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(livingCategoryCollectionView.snp.bottom).offset(15)
            $0.height.equalTo(15)
            $0.leading.equalTo(livingTitleLabel.snp.leading)
        }
        
        contentView.addSubview(educationCategoryCollectionView)
        educationCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(educationTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(educationTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(50)
        }
        
        ///참여공간
        contentView.addSubview(participationTitleLabel)
        participationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(educationCategoryCollectionView.snp.bottom).offset(15)
            $0.height.equalTo(15)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
        }
        
        contentView.addSubview(participationCategoryCollectionView)
        participationCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(participationTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.top.equalTo(participationCategoryCollectionView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                if FilterViewController.isFirstLoad { //맨처음 True
                    self.viewModel.input.isFirstLoadObserver.accept(())
                } else {
                    //두번째부턴 FilterRegionVC의 filteredDataList로만 관리
                    print("다시 로드될 때 !!!")
                    self.viewModel.input.tagLoadActionObserver.accept(.isFirstLoad(FilterRegionViewController.filteredDataList))
                }
                
                self.viewModel.input.categoryObserver.accept(())
            }).disposed(by: disposeBag)
        
        regionTagCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if self.regionTagCollectionView.visibleCells.count <= 1 {
                    //self.createDefaultTag()
                    self.viewModel.input.confirmButtonValid.accept(false)
                }
                self.viewModel.input.deleteTagObserver.accept(indexPath.row)
            }).disposed(by: disposeBag)
        
        
        ///일자리 - idx 0,1,2 -> 5,6,7
        jobCategoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                ///눌리는 순간 필터 버튼 효과 없애기
                FilterViewController.isFilterResetBtnTapped = false
                ///선택완료 버튼은 카테고리 중 하나라도 선택되면 트루
                self.viewModel.input.confirmButtonValid.accept(true)
                if indexPath.row == 0 {
                    self.selectedCategory.append(5)
                } else if indexPath.row == 1 {
                    self.selectedCategory.append(6)
                } else {
                    self.selectedCategory.append(7)
                }
            }).disposed(by: disposeBag)
        
        jobCategoryCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if indexPath.row == 0 {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 5}
                } else if indexPath.row == 1 {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 6}
                } else {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 7}
                }
            }).disposed(by: disposeBag)
        
        ///생활안정
        livingCategoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                FilterViewController.isFilterResetBtnTapped = false
                self.viewModel.input.confirmButtonValid.accept(true)
                if indexPath.row == 0 {
                    self.selectedCategory.append(8)
                } else {
                    self.selectedCategory.append(9)
                }
            }).disposed(by: disposeBag)
        
        livingCategoryCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if indexPath.row == 0 {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 8}
                } else {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 9}
                }
            }).disposed(by: disposeBag)
        
        ///교육 문화
        educationCategoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                FilterViewController.isFilterResetBtnTapped = false
                self.viewModel.input.confirmButtonValid.accept(true)
                if indexPath.row == 0 {
                    self.selectedCategory.append(10)
                } else {
                    self.selectedCategory.append(11)
                }
            }).disposed(by: disposeBag)
        
        educationCategoryCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                FilterViewController.isFilterResetBtnTapped = false
                if indexPath.row == 0 {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 10}
                } else {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 11 }
                }
            }).disposed(by: disposeBag)
        
        ///참여 공간
        participationCategoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.input.confirmButtonValid.accept(true)
                if indexPath.row == 0 {
                    self.selectedCategory.append(12)
                } else if indexPath.row == 1 {
                    self.selectedCategory.append(13)
                } else {
                    self.selectedCategory.append(14)
                }
            }).disposed(by: disposeBag)
        
        participationCategoryCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if indexPath.row == 0 {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 12}
                } else if indexPath.row == 1 {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 13}
                } else {
                    self.selectedCategory = self.selectedCategory.filter { $0 != 14}
                }
            }).disposed(by: disposeBag)
        
        ///필터 완료 버튼
        confirmButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.selectedCategory.count > 0 {
                    print("넘기는 카테고리: \(self.selectedCategory)")
                    print("넘기는 카테고리: \(self.selectedRegion)")
                    
                    FilterViewController.selectedCategories = self.selectedCategory
                    FilterViewController.selectedRegions = self.selectedRegion
                    
                    NotificationCenter.default.post(name: NSNotification.Name("sendFilteredInfo"), object: nil, userInfo: nil)
                }
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.input.tagLoadActionObserver
            .scan(into: [DataDetail]()) { DataDetail, action in
                switch action {
                case .isFirstLoad(let datalist):
                    self.selectedRegion.removeAll()
                    if(FilterViewController.isFilterResetBtnTapped) {
                        self.selectedRegion.removeAll()
                        DataDetail.removeAll()
                        break
                    }
                    for i in 0..<datalist.count {
                        let list = datalist
//                        DataDetail.append(datalist[i])
                        DataDetail = list
                        self.selectedRegion.append(datalist[i].region.id)
                        print("첫 로드 시 선택된 지역: \(self.selectedRegion)")
                        print("필터된 데이터 리스트 \(FilterRegionViewController.filteredDataList)")
                    }
                    FilterViewController.isFirstLoad = false
                    
                case .delete(let index):
                    DataDetail.remove(at: index)
                    self.selectedRegion.remove(at: index)
                    print("삭제된 후 선택된 지역: \(self.selectedRegion)")

                case .add(let datalist):
                    print("추가된 후 선택된 지역: \(self.selectedRegion)")
                    
                case .deleteAll:
                    self.selectedRegion.removeAll()
                    DataDetail.removeAll()
                }
            }
            .asObservable()
            .bind(to: regionTagCollectionView.rx.items(cellIdentifier: "regionTagCollectionViewCell", cellType: TagCollectionViewCell.self)) {
                (index: Int, element: DataDetail, cell) in
                cell.setLayout()
                if (element.region.id == 0 || element.region.id == 100 || element.region.id == 200) {
                    cell.tagLabel.text = (element.region.name)
                } else {
                    cell.tagLabel.text = (element.region.parent?.name ?? "") + ( element.region.name)
                }
                cell.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 3
 
                //여기서 추가한 횟수만큼 들어감
//                FilterRegionViewController.filteredDataList.append(element)
            }.disposed(by: disposeBag)
        
        viewModel.output.getJobData
            .scan(into: [ChildDetail](), accumulator: { childDatail, arrays in
                childDatail.removeAll()
                print("일자리 태그 개수: \(arrays.data[0].childs.count)")
                for i in 0..<arrays.data[0].childs.count {
                    childDatail.append(arrays.data[0].childs[i])
                }
            })
            .debug()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: jobCategoryCollectionView.rx.items(cellIdentifier: "jobCategoryCollectionView", cellType: FilterCollectionViewCell.self)) { (index: Int, element: ChildDetail, cell) in
                
                if(FilterViewController.isFilterResetBtnTapped) {
                    self.selectedCategory.removeAll()
                    cell.isSelected = false
                }
                cell.tagLabel.text = element.name
                cell.tagLabel.sizeToFit()
                cell.frame.size = CGSize(width: cell.tagLabel.frame.width+20, height: 40)
            }.disposed(by: disposeBag)
        
        viewModel.output.getJobData
            .scan(into: [ChildDetail](), accumulator: { childDatail, arrays in
                childDatail.removeAll()
                print("생활안정 태그 개수: \(arrays.data[1].childs.count)")
                for i in 0..<arrays.data[1].childs.count {
                    childDatail.append(arrays.data[1].childs[i])
                }
            })
            .debug()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: livingCategoryCollectionView.rx.items(cellIdentifier: "livingCategoryCollectionView", cellType: FilterCollectionViewCell.self)) { (index: Int, element: ChildDetail, cell) in
                if(FilterViewController.isFilterResetBtnTapped) {
                    self.selectedCategory.removeAll()
                    cell.isSelected = false
                }
                cell.tagLabel.text = element.name
                cell.tagLabel.sizeToFit()
                cell.frame.size = CGSize(width: cell.tagLabel.frame.width+20, height: 40)
            }.disposed(by: disposeBag)
        
        viewModel.output.getJobData
            .scan(into: [ChildDetail](), accumulator: { childDatail, arrays in
                childDatail.removeAll()
                for i in 0..<arrays.data[2].childs.count {
                    childDatail.append(arrays.data[2].childs[i])
                }
            })
            .debug()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: educationCategoryCollectionView.rx.items(cellIdentifier: "educationCategoryCollectionView", cellType: FilterCollectionViewCell.self)) {
                (index: Int, element: ChildDetail, cell) in
                if(FilterViewController.isFilterResetBtnTapped) {
                    self.selectedCategory.removeAll()
                    cell.isSelected = false
                }
                cell.tagLabel.text = element.name
                cell.tagLabel.sizeToFit()
                cell.frame.size = CGSize(width: cell.tagLabel.frame.width+20, height: 40)
            }.disposed(by: disposeBag)

        viewModel.output.getJobData
            .scan(into: [ChildDetail](), accumulator: { childDatail, arrays in
                childDatail.removeAll()
                for i in 0..<arrays.data[3].childs.count {
                    childDatail.append(arrays.data[3].childs[i])
                }
            })
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: participationCategoryCollectionView.rx.items(cellIdentifier: "participationCategoryCollectionView", cellType: FilterCollectionViewCell.self)) {
                (index: Int, element: ChildDetail, cell) in
                if(FilterViewController.isFilterResetBtnTapped) {
                    self.selectedCategory.removeAll()
                    cell.isSelected = false
                }
                cell.tagLabel.text = element.name
                cell.tagLabel.sizeToFit()
                cell.frame.size = CGSize(width: cell.tagLabel.frame.width+20, height: 40)
            }.disposed(by: disposeBag)
        
        viewModel.output.confirmButtonValidOutput
            .drive(onNext: { valid in
                if valid {
                    self.confirmButton.isEnabled = true
                    self.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                    self.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                } else {
                    self.confirmButton.isEnabled = false
                    self.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                    self.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .normal)
                }
            }).disposed(by: disposeBag)
        
        
    }
    
    fileprivate func createDefaultTag() {
        let dummyLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
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
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 14)
        titleLabel.textColor = UIColor(hexString: "A2A2A2")
        titleLabel.text = "선택한 곳이 없어요..😅"

        self.regionTagCollectionView.addSubview(views)
        views.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(size.height)
            $0.width.equalTo(size.width)
        }
    }

}

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 10)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == participationCategoryCollectionView {
            return 15
        } else { return 15 }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == regionTagCollectionView {
            let dummyLabel = UILabel().then {
                $0.font = .systemFont(ofSize: 16)
                $0.text = "길이 측정용   "
                $0.sizeToFit()
            }
            let size = dummyLabel.frame.size

            return CGSize(width: size.width+12, height: size.height+15)
        }
//        else if collectionView == jobCategoryCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "jobCategoryCollectionView", for: indexPath) as! FilterCollectionViewCell
//            return CGSize(width: cell.tagLabel.frame.width, height: 40)
//        } else if collectionView == educationCategoryCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "educationCategoryCollectionView", for: indexPath) as! FilterCollectionViewCell
//            return CGSize(width: cell.tagLabel.frame.width, height: 40)
//        } else if collectionView == participationCategoryCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "participationCategoryCollectionView", for: indexPath) as! FilterCollectionViewCell
//            cell.tagLabel.sizeToFit()
//            return CGSize(width: cell.tagLabel.frame.width, height: 40)
//        }
        else if(collectionView == participationCategoryCollectionView) {
            let dummyLabel = UILabel().then {
                $0.font = .systemFont(ofSize: 16)
                $0.text = FilterViewController.participationTagStr[indexPath.row]
                $0.sizeToFit()
            }
            let size = dummyLabel.frame.size
            return CGSize(width: size.width+10, height: size.height+5)
        }
        
        else if(collectionView == livingCategoryCollectionView) {
            let dummyLabel = UILabel().then {
                $0.font = .systemFont(ofSize: 16)
                $0.text = FilterViewController.livingTagStr[indexPath.row]
                $0.sizeToFit()
            }
            let size = dummyLabel.frame.size
            return CGSize(width: size.width+10, height: size.height+5)
        }
        else {
            return CGSize(width: 10, height: 10)
        }
    }
}

