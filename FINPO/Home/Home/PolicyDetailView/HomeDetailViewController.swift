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

enum addPolicyStep {
    case first
    case second
    case last
}

class HomeDetailViewController: UIViewController {
    
    var addbookmarkButton = UIBarButtonItem()
    var didTapped = false
    
    var acceptedDetailId: Int?
    var participatedId: Int?
    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    
    let customAlert = MyAlert()
    let secondAlert = MyAlert()
//    let memoAlert = MemoAlert()
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.serviceInforVC.serviceInfoCollectionView.invalidateIntrinsicContentSize()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.serviceStringData.removeAll()
    }
    
    private var regionLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "5B43EF")
        label.backgroundColor = UIColor(hexString: "5B43EF").withAlphaComponent(0.1)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        label.topInset = 3
        label.bottomInset = 3
        label.rightInset = 3
        label.leftInset = 3
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
    
    let button = UIButton()
         
    fileprivate func setAttribute() {
        ///NavigationControl
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        var addPolicyImage = UIImage(named: "plus")
        addPolicyImage = addPolicyImage?.withRenderingMode(.alwaysOriginal)
        
        var addBookmarkImage = UIImage(named: "bookmark_top")
        addBookmarkImage = addBookmarkImage?.withRenderingMode(.alwaysOriginal)
    
        button.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        button.setImage(UIImage(named: "bookmark_top"), for: .normal)
        
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                if(self?.didTapped == true) {
                    self?.viewModel.input.bookmarkDeleteObserver.accept(self?.acceptedDetailId ?? -1)
                } else {
                    self?.viewModel.input.bookmarkObserver.accept(self?.acceptedDetailId ?? -1)
                }
            }).disposed(by: disposeBag)
        addbookmarkButton.customView = button
        
        
        let addPolicyButton = UIBarButtonItem(image: addPolicyImage, style: .plain, target: self, action: #selector(didAddPolicyButtonTapped))
        
        self.navigationItem.rightBarButtonItems = [
            addbookmarkButton, addPolicyButton
        ]
        
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
        
        self.serviceInforVC.serviceInfoTableView.register(ServiceTypeTableViewCell.self, forCellReuseIdentifier: "ServiceTypeTableViewCell")
    }
    
    @objc private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
    }
    
    @objc private func didAddPolicyButtonTapped() {
        customAlert.showAlert(with: "이 정책에 참여하셨나요?", message: "마이페이지에서 내가 참여한\n정책들을 편하게 찾아볼 수 있어요", on: self, step: .first)
        customAlert.setupPolicyId(with: acceptedDetailId ?? -1, on: self.viewModel, participaedId: participatedId ?? -1)
    }
    
    @objc func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    @objc private func didAddBookmarkButtonTapped() {
        if addbookmarkButton.isSelected {
            viewModel.input.bookmarkDeleteObserver.accept(self.acceptedDetailId ?? -1)
        }
        else {
            viewModel.input.bookmarkObserver.accept(self.acceptedDetailId ?? -1)
        }
    }
    
    fileprivate func setLayout() {
        view.addSubview(regionLabel)
        regionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
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
                if data.data.isInterest ?? false {
                    self.button.setImage(UIImage(named: "bookmark_top_active")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    self.didTapped = true
                } else {
                    self.button.setImage( UIImage(named: "bookmark_top")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    self.didTapped = false
                }
                
                ///신청 방법
                if(data.data.detailUrl != nil) {
                    self.applyInfoVC.policyOpenURLButton.isHidden = false
                    self.applyInfoVC.policyOpenURLButton.rx.tap
                        .asDriver()
                        .drive(onNext: { _ in
                            if let url = URL(string: data.data.detailUrl!) {
                                UIApplication.shared.open(url, options: [:])
                            }
                        }).disposed(by: self.disposeBag)
                }
                self.applyInfoVC.policyLinkValueLabel.text = data.data.detailUrl ?? "링크를 읽어올 수 없습니다."
                
                self.applyInfoVC.policyProcedureValueLabel.text = data.data.process ?? "자세한 신청 절차는 홈페이지를 참고해주세요"
                self.applyInfoVC.announcementValueLabel.text = data.data.process ?? "자세한 심사 및 발표는 홈페이지를 참고해주세요"
                
                ///사업 내용
                self.serviceInforVC.institutionNameValueLabel.text = data.data.institution ?? ""
                //TODO: 지원규모 없을 때 예외처리 할 것
                self.serviceInforVC.scaleValueLabel.text = "총 \(data.data.supportScale ?? "")"
                ///Date
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                format.locale = Locale(identifier: "ko")
                format.timeZone = TimeZone(abbreviation: "KST")
                guard let srtData = format.date(from: data.data.startDate ?? "") else { return }
                let format2 = DateFormatter()
                format2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                format2.locale = Locale(identifier: "ko")
                format2.timeZone = TimeZone(abbreviation: "KST")
                guard let endData = format2.date(from: data.data.endDate ?? "") else { return }
                format.dateFormat = "yy.MM.dd"
                format2.dateFormat = "MM.dd"
                self.serviceInforVC.supportPeriodValueLabel.text = "\(srtData)" + "-" + "\(endData)"
                

            }).disposed(by: disposeBag)
        
        viewModel.output.serviceInfoOutput
            .scan(into: [CategoryDetail](), accumulator: { categories, Category in
                categories.append(Category.data.category!)
            })
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: self.serviceInforVC.policyTypeCollectionView.rx.items(cellIdentifier: "ServiceTypeCollectionViewCell", cellType: PolicyTypeCollectionViewCell.self)) {
                (index: Int, element: CategoryDetail, cell) in
                cell.tagLabel.text = element.name
            }.disposed(by: disposeBag)
        
//        viewModel.output.serviceInfoOutput
//            .scan(into: [PolicyDetailInformation]()) { willAddedSupportInfo, data  in
//                self.serviceStringData.removeAll()
//                //TODO: 나눌 Str 없을 때 에러처리
////                guard let str = data.data.support else { return }
////                self.serviceStringData = (str.components(separatedBy: ["n", "ㅇ", "\n"]))
////                for _ in 0..<(self.serviceStringData.count) {
////                    willAddedSupportInfo.append(data.data)
////                }
////                print("들어온 지원내용: \(willAddedSupportInfo[0].support ?? "")")
//                for _ in 0..<(HomeViewModel.serviceString.count) {
//                    willAddedSupportInfo.append(data.data)
//                }
//            }
//            .debug()
//            .observe(on: MainScheduler.instance)
//            .bind(to: self.serviceInforVC.serviceInfoCollectionView.rx.items(cellIdentifier: "ServiceTypeCollectionViewCell", cellType: ServiceTypeCollectionViewCell.self)) { (index: Int, element: PolicyDetailInformation, cell) in
//                cell.tagLabel.text = HomeViewModel.serviceString[index]
//                print("splited 된 지원내용: \(HomeViewModel.serviceString[index])")
//                
////                cell.configureLabels()
//            }.disposed(by: disposeBag)
        
        viewModel.output.serviceInfoOutput
            .scan(into: [PolicyDetailInformation]()) { willAddedSupportInfo, data in
                self.serviceStringData.removeAll()
                willAddedSupportInfo.append(data.data)
            }
            .observe(on: MainScheduler.instance)
            .bind(to: self.serviceInforVC.serviceInfoTableView.rx.items(cellIdentifier: "ServiceTypeTableViewCell", cellType: ServiceTypeTableViewCell.self)) {
                (index: Int, element: PolicyDetailInformation, cell) in

                cell.tagLabel.text = HomeViewModel.serviceString[index]
                cell.selectionStyle = .none
                print("splited 된 지원내용: \(HomeViewModel.serviceString[index])")
            }
            .disposed(by: disposeBag)
            
        viewModel.output.mypolicyAddOutput
//            .distinctUntilChanged()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid {
                    self.secondAlert.setupPolicyId(with: self.acceptedDetailId ?? -1, on: self.viewModel, participaedId: self.participatedId ?? -1)
                    self.secondAlert.showAlert(with: "참여 정책 목록에 추가했어요", message: "추가한 참여 정책은\n마이페이지에서 확인할 수 있어요", on: self, step: .second)
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.goToMemoAlert
            .subscribe(onNext: { [weak self] valid in
                guard let self = self else { return }
                let vc = MemoViewController()
                vc.modalPresentationStyle = .overCurrentContext
                vc.setupProperty(id: self.acceptedDetailId ?? 10000, on: self.viewModel, participatedId: self.participatedId ?? -1)

                self.present(vc, animated: false)
            }).disposed(by: disposeBag)
        
        viewModel.output.checkedMemoOutput
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid {
                    let ac = UIAlertController(title: nil, message: "메모가 등록되었습니다", preferredStyle: .alert)
                    ac.setTitle(font: UIFont(name: "AppleSDGothicNeo-Medium", size: 18), color: UIColor(hexString: "000000"))
                    let action = UIAlertAction(title: "확인", style: .default)
                    action.setValue(UIColor(hexString: "5B43EF"), forKey: "titleTextColor")
                    ac.addAction(action)
                    self.present(ac, animated: true)
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.checkedBookmarkOutput
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid { //성공
                    self.button.setImage(UIImage(named: "bookmark_top_active")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    self.didTapped = true
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.checkedBookmarkDeleteOutput
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid { //삭제성공
                    self.button.setImage(UIImage(named: "bookmark_top")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    self.didTapped = false
                }
            }).disposed(by: disposeBag)
    }
}

class MyAlert {
    
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .white
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        return alert
    }()
    
    private var mytargetView: UIView?
    private var selectedPolicyId: Int?
    private var viewModel: HomeViewModel?
    
    func setupPolicyId(with id: Int, on viewModel: HomeViewModel, participaedId: Int) {
        self.viewModel = viewModel
        self.selectedPolicyId = id
        print("커스텀 알럿에 들어온 Id 값: \(self.selectedPolicyId ?? 10000)")
    }
    
    func showAlert(with title: String, message: String, on viewController: UIViewController, step: addPolicyStep) {
        guard let targetView = viewController.view else { return }
        
        mytargetView = targetView
        
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        backgroundView.addGestureRecognizer(gesture)

        
        switch step {
        case .first:
            targetView.addSubview(alertView)
            alertView.frame = CGRect(x: 0, y: targetView.frame.height/2, width: targetView.frame.size.width, height: targetView.frame.height/2)
            
            let imageView = UIImageView(frame: CGRect(x: targetView.bounds.midX - 50, y: 58, width: 100, height: 100))
            imageView.image = UIImage(named: "participate")
            alertView.addSubview(imageView)
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY+10, width: alertView.frame.size.width, height: 30))
            titleLabel.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 27)
            titleLabel.text = title
            titleLabel.textAlignment = .center
            alertView.addSubview(titleLabel)
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.maxY+10, width: alertView.frame.size.width, height: 50))
            messageLabel.numberOfLines = 0
            messageLabel.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
            messageLabel.text = message
            let attributedText = NSMutableAttributedString(string: messageLabel.text!)
            attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "5B43EF"), range: (messageLabel.text! as NSString).range(of: "마이페이지"))
            messageLabel.attributedText = attributedText
            messageLabel.textAlignment = .center
            alertView.addSubview(messageLabel)

            let button = UIButton(frame: CGRect(x: 20, y: messageLabel.frame.maxY+15, width: alertView.frame.size.width-40, height: 55))
            button.setTitle("참여했어요", for: .normal)
            button.addTarget(self, action: #selector(setInputBind), for: .touchUpInside)
            button.backgroundColor = UIColor(hexString: "5B43EF")
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 5
            alertView.addSubview(button)
            
        case .second:
            targetView.addSubview(alertView)
            alertView.frame = CGRect(x: 0, y: targetView.frame.height/2, width: targetView.frame.size.width, height: targetView.frame.height/2)
            
            let imageView = UIImageView(frame: CGRect(x: targetView.bounds.midX - 40, y: 50, width: 80, height: 80))
            imageView.image = UIImage(named: "add_confirm")
            alertView.addSubview(imageView)
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY+10, width: alertView.frame.size.width, height: 30))
            titleLabel.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 27)
            titleLabel.text = title
            titleLabel.textAlignment = .center
            alertView.addSubview(titleLabel)
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.maxY+10, width: alertView.frame.size.width, height: 50))
            messageLabel.numberOfLines = 0
            messageLabel.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
            messageLabel.text = message
            
            let attributedText = NSMutableAttributedString(string: messageLabel.text!)
            attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "5B43EF"), range: (messageLabel.text! as NSString).range(of: "마이페이지"))
            messageLabel.attributedText = attributedText
            messageLabel.textAlignment = .center
            alertView.addSubview(messageLabel)
            
            let cancelButton = UIButton(frame: CGRect(x: 20, y: messageLabel.frame.maxY+25, width: alertView.frame.size.width/2 - 30, height: 55))
            cancelButton.setTitle("닫기", for: .normal)
            cancelButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
            cancelButton.backgroundColor = UIColor(hexString: "F0F0F0")
            cancelButton.setTitleColor(UIColor(hexString: "616161"), for: .normal)
            cancelButton.layer.masksToBounds = true
            cancelButton.layer.cornerRadius = 5
            alertView.addSubview(cancelButton)
            
            let memoButton = UIButton(frame: CGRect(x: alertView.frame.size.width/2 + 10, y: messageLabel.frame.maxY+25, width: alertView.frame.size.width/2 - 30, height: 55))
            memoButton.setTitle("메모 작성하기", for: .normal)
            memoButton.addTarget(self, action: #selector(presentMemoAlert), for: .touchUpInside)
            memoButton.backgroundColor = UIColor(hexString: "5B43EF")
            memoButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
            memoButton.layer.masksToBounds = true
            memoButton.layer.cornerRadius = 5
            alertView.addSubview(memoButton)
            
        case .last:
            targetView.addSubview(alertView)
            alertView.frame = CGRect(x: 0, y: targetView.frame.height - targetView.frame.height/3, width: targetView.frame.size.width, height: targetView.frame.height/3)
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: alertView.frame.size.width, height: 50))
            titleLabel.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 27)
            titleLabel.text = title
            titleLabel.textAlignment = .center
            alertView.addSubview(titleLabel)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = Constants.backgroundAlphaTo
        }, completion: { done in
//            if done {
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.alertView.center = targetView.center
//                })
//            }
        })
    }
    
    @objc func setInputBind() {
        guard let viewModel = viewModel else { return }
        dismissAlert()
        viewModel.input.mypolicyAddObserver.accept(self.selectedPolicyId ?? 10000)
    }
    
    @objc fileprivate func dismissAlert() {
        guard let targetView = mytargetView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.frame = CGRect(x: 0,
                                          y: targetView.frame.size.height,
                                          width: targetView.frame.size.width,
                                          height: 300)
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.backgroundView.alpha = 0
                }, completion: { done in
                    if done {
                        print("알럿뷰 삭제됨")
                        self.alertView.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                })
            }
        })
    }
    
    @objc func presentMemoAlert() {
        print("tapped")
        guard let viewModel = viewModel else { return }
        dismissAlert()
        viewModel.input.presentMemoAlertObserver.accept(())
        print("메모알럿 트리거 발동")
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
//        guard let cell = self.serviceInforVC.serviceInfoCollectionView.dequeueReusableCell(withReuseIdentifier: "ServiceTypeCollectionViewCell", for: indexPath) as? ServiceTypeCollectionViewCell else { return .zero }
//
        let text = HomeViewModel.serviceString[0]
        let width = UILabel.textWidth(font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 14) ?? UIFont(), text: text)
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.sizeToFit()
        
        return CGSize(width: textLabel.frame.width, height: textLabel.frame.height)
    }
}

extension HomeDetailViewController: UITableViewDelegate {
    
}
