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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
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
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        
        //navigation
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        self.navigationItem.title = "필터"
        let rightBarButtonItem = UIBarButtonItem(title: "모두 초기화", style: .plain, target: self, action: #selector(resetFilter))
        rightBarButtonItem.tintColor = UIColor(hexString: "999999")
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 14)!]
        rightBarButtonItem.setTitleTextAttributes(attributes, for: .normal)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "000000")
        
        //collectionview
        regionTagCollectionView.delegate = self
        regionTagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "regionTagCollectionViewCell")
        
        //region 선택 view
        let gesture = UITapGestureRecognizer(target: self, action: #selector(presentFilterView))
        guideForAddRegionView.addGestureRecognizer(gesture)
    }
                                             
    @objc fileprivate func presentFilterView() {
        let vc = FilterRegionViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @objc fileprivate func resetFilter() {
        
    }
    
    fileprivate func setLayout() {
        
        view.addSubview(regionTitleLabel)
        regionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.equalToSuperview().inset(21)
        }
        
        view.addSubview(regionTagCollectionView)
        regionTagCollectionView.snp.makeConstraints {
            $0.top.equalTo(regionTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(regionTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(100)
        }
          
        view.addSubview(guideForAddRegionView)
        guideForAddRegionView.snp.makeConstraints {
            $0.top.equalTo(regionTagCollectionView.snp.bottom).offset(20)
            $0.leading.equalTo(regionTagCollectionView.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.input.isFirstLoadObserver.accept(())
            }).disposed(by: disposeBag)
        
        regionTagCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if self.regionTagCollectionView.visibleCells.count <= 1 {
                    self.createDefaultTag()
                }
                
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

