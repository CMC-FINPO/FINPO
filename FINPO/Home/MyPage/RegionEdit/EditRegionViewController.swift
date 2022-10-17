//
//  EditRegionViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/06.
//

import Foundation
import UIKit
import RxSwift

class EditRegionViewController: UIViewController {
    
    var viewModel: MyPageViewModel?
    let interestRegionVC = InterestRegionViewController()
    let myRegionVC = MyRegionViewController()
    let disposeBag = DisposeBag()
    
    func setViewModel(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///네비게이션
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "000000")
        
        interestRegionVC.setViewModel(viewModel: self.viewModel ?? MyPageViewModel())
        myRegionVC.setViewModel(viewModel: self.viewModel ?? MyPageViewModel())
        setAttribute()
        setLayout()
        setOutputBind()
        setObserver()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //지역 뷰컨 추가
    var dataViewControllers: [UIViewController] {
        [self.interestRegionVC, self.myRegionVC]
    }
    
    var currentPage: Int = 0 {
        didSet {
            ///from segmentedControl -> pageViewController update
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            self.pageViewController.setViewControllers(
                [dataViewControllers[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
        }
    }
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UnderlineSegmentedControl(items: ["관심 지역", "거주 지역"])
        return segmentedControl
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
        view.backgroundColor = .white
        
        ///세그먼트 컨트롤 세팅
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "000000")], for: .normal)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "000000"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .normal)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "5B43EF"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .selected)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "5B43EF"), .font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)],for: .highlighted)
        
        self.segmentedControl.addTarget(self, action: #selector(self.changeValue(control:)), for: .valueChanged)
        self.segmentedControl.selectedSegmentIndex = 0
        
        //segmentedControl 값이 변경될 때, pageVC에도 적용시켜주기 위해 selector 추가
        self.changeValue(control: self.segmentedControl)
        
        
    }
    
    fileprivate func setLayout() {
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(45)
        }
        
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(1)
            $0.top.equalTo(segmentedControl.snp.bottom).offset(1)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
    
    fileprivate func setOutputBind() {
        self.viewModel?.output.popViewOutput
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.popViewController),
            name: NSNotification.Name("popViewController"),
            object: nil
        )
    }
    
    @objc fileprivate func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
    }
 
}

extension EditRegionViewController: UIPageViewControllerDataSource {
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
/*
 pageViewController에서 값이 변경될 때 segmentedControl에도 적용하기 위해, delegate 처리
 위 dataSource에서 처리하면 캐싱이 되어 index값이 모두 불리지 않으므로, delegate에서 따로 처리가 필요
 */
extension EditRegionViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?[0],
              let index = self.dataViewControllers.firstIndex(of: viewController) else { return }
        self.currentPage = index
        self.segmentedControl.selectedSegmentIndex = index
    }
}

