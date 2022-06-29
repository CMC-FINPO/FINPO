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
    
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    let tableViewModel = LoginViewModel()
    
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
        dimmedView.addGestureRecognizer(gesture)
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
        
        containerView.addSubview(regionTitleLabel)
        regionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.safeAreaLayoutGuide.snp.top).offset(15)
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
            $0.height.equalTo(180)
        }
        
        containerView.addSubview(localRegionTableView)
        localRegionTableView.snp.remakeConstraints {
            $0.top.equalTo(mainRegionTableView.snp.top)
            $0.leading.equalTo(mainRegionTableView.snp.trailing)
            $0.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
        
    }
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.input.isFirstLoadObserver.accept(())
                self.tableViewModel.getMainRegionDataToTableView()
                self.tableViewModel.getSubRegionDataToTableView(0)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.input.tagLoadActionObserver
            .scan(into: [DataDetail]()) { DataDetail, action in
                switch action {
                case .isFirstLoad(let datalist):
                    for i in 0..<datalist.count {
                        DataDetail.append(datalist[i])
                    }
                case .delete(let index):
                    break
                case .add(let datalist):
                    break
                }
            }
            .asObservable()
            .bind(to: regionTagCollectionView.rx.items(cellIdentifier: "regionTagCollectionViewCell", cellType: TagCollectionViewCell.self)) {
                (index: Int, element: DataDetail, cell) in
                cell.setLayout()
                cell.tagLabel.text = (element.region.parent?.name ?? "") + ( element.region.name)
                cell.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 3
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
    }
}

extension FilterRegionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let dummyLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 16)
            $0.text = "길이 측정용 "
            $0.sizeToFit()
        }
        let size = dummyLabel.frame.size

        return CGSize(width: size.width+12, height: size.height+15)
    }
}

