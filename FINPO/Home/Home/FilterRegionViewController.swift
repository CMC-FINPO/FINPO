//
//  FilterRegionViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/29.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class FilterRegionViewController: UIViewController {
    let vc = FilterViewController()
    
    let disposeBag = DisposeBag()
//    let viewModel = HomeViewModel.instance
    var viewModel = HomeViewModel()
    let tableViewModel = LoginViewModel()
    var isSelected: Bool = true
    static var isFirstLoad = true
    static var filteredDataList = [DataDetail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
        setupPanGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")

        // get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            //드래그 멈출 때 -> container view의 마지막 heignt를 얻기
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
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
    
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimmedAlpha: CGFloat = 0.6
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    private var regionCenterLabel: UILabel = {
        let label = UILabel()
        label.text = "지역 선택"
        label.textColor = UIColor(hexString: "000000")
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        return label
    }()
    
    private var separatorLineView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        return separator
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
    
    private var mainRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(60)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.bounces = false
        tv.layer.masksToBounds = true
        tv.separatorInset.left = 0
        return tv
    }()
    
    private var localRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(40)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.bounces = false
        tv.showsHorizontalScrollIndicator = false
        tv.layoutIfNeeded()
        tv.separatorInset.left = 0
        return tv
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

    let defaultHeight: CGFloat = 600
    let dismissibleHeight: CGFloat = 300
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // keep updated with new height
    var currentContainerHeight: CGFloat = 600
    
    fileprivate func setAttribute() {
        
        regionTagCollectionView.delegate = self
        regionTagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "regionTagCollectionViewCell")
        
        mainRegionTableView.register(MainRegionTableViewCell.self, forCellReuseIdentifier: "cell")
        localRegionTableView.register(SubRegionTableViewCell.self, forCellReuseIdentifier: "cell")
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(animateDismissView))
        //수정 안하고 바깥 클릭종료 막기
//        dimmedView.addGestureRecognizer(gesture) 
    }
    
    fileprivate func setLayout() {
        
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
        
        containerView.addSubview(regionCenterLabel)
        regionCenterLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.safeAreaLayoutGuide.snp.top).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        containerView.addSubview(separatorLineView)
        separatorLineView.snp.makeConstraints {
            $0.top.equalTo(regionCenterLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        containerView.addSubview(regionTitleLabel)
        regionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLineView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(21)
        }
        
        containerView.addSubview(regionTagCollectionView)
        regionTagCollectionView.snp.makeConstraints {
            $0.top.equalTo(regionTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(regionTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(100)
        }
        
        containerView.addSubview(mainRegionTableView)
        mainRegionTableView.snp.makeConstraints {
            $0.top.equalTo(regionTagCollectionView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(15)
            $0.width.equalTo(100)
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-90)
//            $0.height.equalTo(180)
        }
        
        containerView.addSubview(localRegionTableView)
        localRegionTableView.snp.remakeConstraints {
            $0.top.equalTo(mainRegionTableView.snp.top)
            $0.leading.equalTo(mainRegionTableView.snp.trailing)
            $0.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-90)
        }
        
        containerView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
        
    }
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                if FilterRegionViewController.isFirstLoad {
                    self.viewModel.input.isFirstLoadObserver.accept(())
                } else {
                    self.viewModel.input.tagLoadActionObserver.accept(.isFirstLoad(FilterRegionViewController.filteredDataList))
                }
                self.tableViewModel.getMainRegionDataToTableView()
                self.tableViewModel.getSubRegionDataToTableView(0)
                self.viewModel.input.addMainRegionIndexObserver.accept(0)
            }).disposed(by: disposeBag)
        
        mainRegionTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableViewModel.getSubRegionDataToTableView(indexPath.row)
                self?.viewModel.input.addMainRegionIndexObserver.accept(indexPath.row)
                print("메인 지역 인덱스 방출: \(indexPath.row)")
            }).disposed(by: disposeBag)
        
        localRegionTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                FilterViewController.isFilterResetBtnTapped = false
                if self.isSelected == false {
                    self.regionTagCollectionView.subviews[(self.regionTagCollectionView.subviews.count)-1].removeFromSuperview()
                    self.isSelected = true
                }
                print("localRegion 이벤트 방출")
                FilterViewController.isEdited = true
                self.viewModel.input.confirmButtonValid.accept(true)
                self.viewModel.input.addTagObserver.accept(indexPath.row)

            }).disposed(by: disposeBag)
        
        regionTagCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if self.regionTagCollectionView.visibleCells.count <= 1 {
                    self.createDefaultTag()
                    self.isSelected = false
                    self.viewModel.input.confirmButtonValid.accept(false)
                } else {
                    self.viewModel.input.confirmButtonValid.accept(true)
                }                
                self.viewModel.input.deleteTagObserver.accept(indexPath.row)
            }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.animateDismissView()
//                FilterRegionViewController.filteredDataList.removeAll()
                ///여기서 필터링 된 지역id, 카테고리id 가지고 이벤트 주기 -> 홈 테이블뷰 갱신되게
                
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.input.tagLoadActionObserver
            .scan(into: [DataDetail]()) { DataDetail, action in
                switch action {
                case .isFirstLoad(let datalist) :
                    if FilterViewController.isFilterResetBtnTapped {
                        DataDetail.removeAll()
                        FilterRegionViewController.filteredDataList.removeAll()
                        break
                    } 
                    if FilterRegionViewController.isFirstLoad {
                        for i in 0..<datalist.count {
                            DataDetail.append(datalist[i])
                        }
                        FilterRegionViewController.isFirstLoad = false
                    } else {
                        for i in 0..<datalist.count {
                            DataDetail.append(datalist[i])
                        }
                    }
                case .delete(let index):
                    DataDetail.remove(at: index)
                case .add(let datalist):
                    print("이벤트 받음: \(datalist.region.name)")
                    DataDetail.append(datalist)
                    
                case .deleteAll:
                    DataDetail.removeAll()
                }
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: regionTagCollectionView.rx.items(cellIdentifier: "regionTagCollectionViewCell", cellType: TagCollectionViewCell.self)) {
                (index: Int, element: DataDetail, cell) in
                cell.setLayout()
//                cell.tagLabel.text = (element.region.parent?.name ?? "") + ( element.region.name)
                if (element.region.id == 0 || element.region.id == 100 || element.region.id == 200) {
                    cell.tagLabel.text = (element.region.name)
                } else {
                    cell.tagLabel.text = (element.region.parent?.name ?? "") + ( element.region.name)
                }
                cell.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 3
                //여기서 최근 regionId, subregion title 저장
                
            }.disposed(by: disposeBag)
        
        tableViewModel.output.mainRegionUpdate
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: mainRegionTableView.rx.items(cellIdentifier: "cell")) {
                (index: Int, element: MainRegion, cell: MainRegionTableViewCell) in
                cell.selectionStyle = .none
                cell.mainRegionLabel.text = element.name
            }.disposed(by: disposeBag)
        
        tableViewModel.output.subRegionUpdate
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: localRegionTableView.rx.items(cellIdentifier: "cell")) {
                (index: Int, element: SubRegion, cell: SubRegionTableViewCell) in
                cell.selectionStyle = .none
                cell.subRegionLabel.text = element.name
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
            }.disposed(by: disposeBag)
        
        viewModel.output.confirmButtonValidOutput
            .drive(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid {
                    self.confirmButton.isEnabled = valid
                    self.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                    self.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                } else {
                    self.confirmButton.isEnabled = valid
                    self.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                    self.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .normal)
                }
            }).disposed(by: disposeBag)
    }
}

extension FilterRegionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let dummyLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 16)
            $0.text = "길이 측정용   "
            $0.sizeToFit()
        }
        let size = dummyLabel.frame.size

        return CGSize(width: size.width+12, height: size.height+15)
    }
}

