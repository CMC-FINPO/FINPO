//
//  HomeDetailViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/01.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class HomeDetailViewController: UIViewController {
    
    var acceptedDetailId: Int?
    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    
    var serviceStringData = [String]()
    
    var serviceInforVC = ServiceInfoViewController()
    let applyInfoVC = ApplyInfoViewController()
    var dataViewControllers: [UIViewController] {
        [self.serviceInforVC, self.applyInfoVC]
    }
        
    func initialize(id: Int) {
        self.acceptedDetailId = id
        print("홈디테일뷰 받은 아이디값: \(self.acceptedDetailId)")
    }
    
    var currentPage: Int = 0 {
        didSet {
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            self.pageViewController.setViewControllers(
                [dataViewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "F0F0F0")

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
        self.serviceStringData.removeAll()
    }
    private var regionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "5B43EF")
        label.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.1)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        return label
    }()
    
    private var policyNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "000000")
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 27)
        label.numberOfLines = 0
        return label
    }()
    
    private var policySubscriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "000000")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private var scrapCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "999999")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.text = "스크랩수"
        return label
    }()
    
    private var viewCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "999999")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.text = "조회수"
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UnderlineSegmentedControl(items: ["사업 내용", "신청 방법"])
        return segmentedControl
    }()
    
    private let separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "C4C4C5")
        return view
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.setViewControllers([self.dataViewControllers[0]], direction: .forward, animated: true)
        vc.delegate = self
        vc.dataSource = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
 
    fileprivate func setAttribute() {
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        ///segmentedControl
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "000000")], for: .normal)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "000000"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .normal)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "5B43EF"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .selected)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "5B43EF"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .highlighted)
        self.segmentedControl.addTarget(self, action: #selector(self.changeValue(control:)), for: .valueChanged)
        self.segmentedControl.selectedSegmentIndex = 0
        //segmentedControl 값이 변경될 때, pageVC에도 적용시켜주기 위해 selector 추가
        self.changeValue(control: self.segmentedControl)
        
        
        ///사업 내용
        self.serviceInforVC.policyTypeCollectionView.register(PolicyTypeCollectionViewCell.self, forCellWithReuseIdentifier: "ServiceTypeCollectionViewCell")
        self.serviceInforVC.serviceInfoCollectionView.register(ServiceTypeCollectionViewCell.self, forCellWithReuseIdentifier: "ServiceTypeCollectionViewCell")
        
        self.serviceInforVC.serviceInfoCollectionView.delegate = self
    }
    
    @objc private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
    }
    
    fileprivate func setLayout() {
        view.addSubview(regionLabel)
        regionLabel.snp.makeConstraints {             $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            $0.leading.equalToSuperview().inset(21)
        }
        
        view.addSubview(policyNameLabel)
        policyNameLabel.snp.makeConstraints {
            $0.top.equalTo(regionLabel.snp.bottom).offset(20)
            $0.leading.equalTo(regionLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(22)
        }
        
        view.addSubview(policySubscriptionLabel)
        policySubscriptionLabel.snp.makeConstraints {
            $0.top.equalTo(policyNameLabel.snp.bottom).offset(6)
            $0.leading.equalTo(regionLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(22)
        }
        
        let countStackView = UIStackView(arrangedSubviews: [scrapCountLabel, viewCountLabel]).then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 14
        }
        
        view.addSubview(countStackView)
        countStackView.snp.makeConstraints {
            $0.top.equalTo(policySubscriptionLabel.snp.bottom).offset(9)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(countStackView.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(21)
            $0.trailing.equalToSuperview().inset(190)
            $0.height.equalTo(50)
        }
        
        view.addSubview(separatorLineView)
        separatorLineView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.leading.equalTo(segmentedControl)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(0.5)
        }
        
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
    
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in .never()}
            .drive(onNext: { [weak self] _ in
                self?.viewModel.input.serviceInfoObserver.accept(self?.acceptedDetailId ?? 1000)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.serviceInfoOutput
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.regionLabel.text = (data.data.region?.parent?.name ?? "") + ( data.data.region?.name ?? "")
                self.policyNameLabel.text = data.data.title ?? "공고명 없음"
                self.policySubscriptionLabel.text = data.data.content ?? "표시할 내용이 없습니다."
                self.scrapCountLabel.text = "스크랩수 \(data.data.countOfInterest ?? 0)"
                self.viewCountLabel.text = "조회수 \(data.data.hits)"
                
                //사업 내용
                self.serviceInforVC.institutionNameValueLabel.text = data.data.institution ?? ""
                //TODO: 지원규모 없을 때 예외처리 할 것
                self.serviceInforVC.scaleValueLabel.text = "총 \(data.data.supportScale ?? "")"
                self.serviceInforVC.supportPeriodValueLabel.text = "\(data.data.startDate ?? "" )" + "\(data.data.endDate ?? "")"
//                self.serviceInforVC.supportPeriodValueLabel.text = data.data.modifiedAt ?? "123123"
                
                
                //신청 방법
                self.applyInfoVC.policyLinkValueLabel.text = data.data.detailUrl ?? "링크를 읽어올 수 없습니다."
                self.applyInfoVC.policyProcedureValueLabel.text = data.data.process ?? "자세한 신청 절차는 홈페이지를 참고해주세요"
                self.applyInfoVC.announcementValueLabel.text = data.data.process ?? "자세한 심사 및 발표는 홈페이지를 참고해주세요"
            }).disposed(by: disposeBag)
        
        viewModel.output.serviceInfoOutput
            .scan(into: [CategoryDetail](), accumulator: { categories, Category in
//                var category = categories
                categories.append(Category.data.category!)
            })
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to:                 self.serviceInforVC.policyTypeCollectionView.rx.items(cellIdentifier: "ServiceTypeCollectionViewCell", cellType: PolicyTypeCollectionViewCell.self)) {
                (index: Int, element: CategoryDetail, cell) in
                cell.tagLabel.text = element.name
                cell.tagLabel.sizeToFit()
                let cellWidth = cell.tagLabel.frame.width
                cell.layer.frame.size = CGSize(width: cellWidth, height: 23)
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 3
            }.disposed(by: disposeBag)
        
        viewModel.output.serviceInfoOutput
            .scan(into: [PolicyDetailInformation]()) { willAddedSupportInfo, data  in
                self.serviceStringData.removeAll()
                //TODO: 나눌 Str 없을 때 에러처리
//                guard let str = data.data.support else { return }
//                self.serviceStringData = (str.components(separatedBy: ["n", "ㅇ", "\n"]))
//                for _ in 0..<(self.serviceStringData.count) {
//                    willAddedSupportInfo.append(data.data)
//                }
                for _ in 0..<(HomeViewModel.serviceString.count) {
                    willAddedSupportInfo.append(data.data)
                }
            }
            .debug()
            .observe(on: MainScheduler.instance)
            .bind(to: self.serviceInforVC.serviceInfoCollectionView.rx.items(cellIdentifier: "ServiceTypeCollectionViewCell", cellType: ServiceTypeCollectionViewCell.self)) { [weak self] (index: Int, element: PolicyDetailInformation, cell) in
                guard let self = self else { return }
//                cell.tagLabel.text = self.serviceStringData[index]
                cell.tagLabel.text = HomeViewModel.serviceString[index]
//                print("splited 된 지원내용: \(self.serviceStringData[index])")
                
                print("splited 된 지원내용: \(HomeViewModel.serviceString[index])")
                
                cell.configureLabels()
            }.disposed(by: disposeBag)
            
    
    }
}

extension HomeDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.dataViewControllers.firstIndex(of: viewController),
              index - 1 >= 0 else { return nil }
        return self.dataViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.dataViewControllers.firstIndex(of: viewController),
              index + 1 < self.dataViewControllers.count else { return nil }
        return self.dataViewControllers[index + 1]
    }
}

extension HomeDetailViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?[0],
              let index = self.dataViewControllers.firstIndex(of: viewController) else { return }
        self.currentPage = index
        self.segmentedControl.selectedSegmentIndex = index
    }
}

extension HomeDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = self.serviceInforVC.serviceInfoCollectionView.dequeueReusableCell(withReuseIdentifier: "ServiceTypeCollectionViewCell", for: indexPath) as? ServiceTypeCollectionViewCell else { return .zero }
//        let cellHeight: CGFloat = 30
//        let cellsize = cell.sizeFittingWith(cellHeight: cellHeight, text: HomeViewModel.serviceString[indexPath.row])
//        return cellsize
        let cellSize = NSString(string: HomeViewModel.serviceString[indexPath.row])
            .boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                          options: .usesLineFragmentOrigin,
                          attributes: [
                            NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)
                          ],
                          context: nil
            )
        return CGSize(width: cellSize.width/3, height: cellSize.height)
    }
}



