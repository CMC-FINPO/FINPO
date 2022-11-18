//
//  InterestCategoryViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/13.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxDataSources

class InterestCategoryViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    
    //RxDataSources refactoring
    typealias Section = SectionModel<MyInterestSectionType, MyInterestMenuType>
    private var dataSource: RxCollectionViewSectionedReloadDataSource<CategoryDataSection>!
    let categoryViewModel = InterestCategoryViewModel()

    
    var checkIsInterest = [Bool]() //일자리
    var check1 = [Bool]()
    var check2 = [Bool]()
    var check3 = [Bool]() //생활안정
    var forWhatCheck = [Bool]()

    //불러온 id 값 전체 저장
    var jobCVSelectedId = [Int]()
    var livingCVSelectedId = [Int]()
    var eduCVSelectedId = [Int]()
    var particiCVSelectedId = [Int]()
    var forWhatCVSelectedId = [Int]()
    
    //선택된 id 값 각개 저장
    var jobDidSelectedId = [Int]()
    var livingDidSelectedId = [Int]()
    var eduDidSelectedId = [Int]()
    var particiDidSelectedId = [Int]()
    var forWhatDidSelectedId = [Int]()
    
    //카테고리 셀 사이즈
    static var confirmJobLabelSize = [String]()
    static var confirmLivingLabelSize = [String]()
    static var confirmEduLabelSize = [String]()
    static var confirmParticiLabelSize = [String]()
    
    //이용목적 셀 사이즈
    static var confirmIsForWhatLabelSize = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        dataSource = configureDataSource()
        setOutputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
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
//        flow.minimumInteritemSpacing = 20
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = true
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
        return cv
    }()
    
    private var participationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "참여 공간"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var separatorLineView: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(hexString: "D9D9D9")
        return separator
    }()
    
    private var participationCategoryCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.minimumLineSpacing = 3
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = true
        return cv
    }()
    
    private var forWhatLabel: UILabel = {
        let label = UILabel()
        label.text = "이용 목적"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "000000")
        return label
    }()
    
    private var forWhatCollectionView: UICollectionView = {
        let flow = LeftAlignedCollectionViewFlowLayout()
        flow.minimumLineSpacing = 3
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = true
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
        self.navigationItem.title = "관심 설정"
        let rightBarButtonItem = UIBarButtonItem(title: "모두 초기화", style: .plain, target: self, action: #selector(resetFilter))
        rightBarButtonItem.tintColor = UIColor(hexString: "999999")
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 14)!]
        rightBarButtonItem.setTitleTextAttributes(attributes, for: .normal)
        rightBarButtonItem.setTitleTextAttributes(attributes, for: .selected)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "000000")
        
        ///컬렉션 뷰
        jobCategoryCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "jobInterestCollectionView")
        jobCategoryCollectionView.tag = 1
        jobCategoryCollectionView.delegate = self
        
        livingCategoryCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "livingCollectionView")
        livingCategoryCollectionView.tag = 5
        livingCategoryCollectionView.delegate = self
        
        educationCategoryCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "educationCategoryCollectionView")
        educationCategoryCollectionView.tag = 2
        educationCategoryCollectionView.delegate = self
        
        participationCategoryCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "participationCollectionView")
        participationCategoryCollectionView.tag = 3
        participationCategoryCollectionView.delegate = self
        
        //이용목적
        forWhatCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "forWhatCollectionView")
        forWhatCollectionView.tag = 4
        forWhatCollectionView.delegate = self
    }
    
    @objc fileprivate func resetFilter() {
        //리셋 트리거 -> zip
        viewModel.input.resetTrigger.accept(())
        
        //전체 관심설정
        viewModel.input.lowCategoryObserver.accept(())
        //전체 이용목적
        viewModel.input.forWhatObserver.accept(())
        
        //버튼
        viewModel.input.confirmButtonValid.accept(false)
        
        //선택된 값 제거
        self.jobDidSelectedId.removeAll()
        self.livingDidSelectedId.removeAll()
        self.eduDidSelectedId.removeAll()
        self.particiDidSelectedId.removeAll()
        self.forWhatDidSelectedId.removeAll()
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
        
        //일자리
        contentView.addSubview(jobTitleLabel)
        jobTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(15)
            $0.height.equalTo(14)
            $0.leading.equalToSuperview().inset(21)
        }
        
        contentView.addSubview(jobCategoryCollectionView)
        jobCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(jobTitleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(50)
        }
        
        //생활안정
        contentView.addSubview(livingTitleLabel)
        livingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(jobCategoryCollectionView.snp.bottom).offset(20)
            $0.height.equalTo(14)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
        }
        
        contentView.addSubview(livingCategoryCollectionView)
        livingCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(livingTitleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(livingTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(186)
            $0.height.equalTo(50)
        }
        
        //교육문화
        contentView.addSubview(educationTitleLabel)
        educationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(livingCategoryCollectionView.snp.bottom).offset(20)
            $0.height.equalTo(14)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
        }
        
        contentView.addSubview(educationCategoryCollectionView)
        educationCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(educationTitleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(educationTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(186)
            $0.height.equalTo(50)
        }
        
        //참여공간
        contentView.addSubview(participationTitleLabel)
        participationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(educationCategoryCollectionView.snp.bottom).offset(20)
            $0.height.equalTo(14)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
        }
    
        contentView.addSubview(participationCategoryCollectionView)
        participationCategoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(participationTitleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(jobTitleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(80)
            $0.height.equalTo(50)
        }
        
        contentView.addSubview(separatorLineView)
        separatorLineView.snp.makeConstraints {
            $0.top.equalTo(participationCategoryCollectionView.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(1)
        }
        
        contentView.addSubview(forWhatLabel)
        forWhatLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLineView.snp.bottom).offset(25)
            $0.height.equalTo(14)
            $0.leading.equalTo(separatorLineView.snp.leading)
        }
        
        contentView.addSubview(forWhatCollectionView)
        forWhatCollectionView.snp.makeConstraints {
            $0.top.equalTo(forWhatLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(155)
        }
        
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.top.equalTo(forWhatCollectionView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(15)
//            $0.bottom.equalTo(contentView.snp.bottom)
            $0.height.equalTo(50)
        }
        
    }
    
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<CategoryDataSection> {
        lazy var categoryDataSection = RxCollectionViewSectionedReloadDataSource<CategoryDataSection> { dataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "jobInterestCollectionView", for: indexPath) as! FilterCollectionViewCell
            cell.configureCell(data: item)
            return cell
        }
        return categoryDataSection
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                ///카테고리 전체 텍스트 트리거
                self.viewModel.input.lowCategoryObserver.accept(())
                ///관심카테고리 트리거
                self.viewModel.input.interestCategoryObserver.accept(())
                ///이용 목적 트리거
                self.viewModel.input.forWhatObserver.accept(())
                ///내 이용목적 조회
                self.viewModel.input.myForWhatObserver.accept(())

            }).disposed(by: disposeBag)
        
//        rx.viewWillAppear.asDriver { _ in return .never()}
//            .map { _ in }
//            .drive(categoryViewModel.firstLoad)
//            .disposed(by: disposeBag)
        
        ///일자리 컬렉션뷰 선택
        jobCategoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.jobDidSelectedId.append(self.jobCVSelectedId[indexPath.row])
                self.viewModel.input.confirmButtonValid.accept(true)
                print("선택된 일자리 id: \(self.jobDidSelectedId)")
            }).disposed(by: disposeBag)
        
        jobCategoryCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.jobDidSelectedId = self.jobDidSelectedId.filter { $0 != self.jobCVSelectedId[indexPath.row] }
                print("삭제된 후 일자리 id: \(self.jobDidSelectedId)")
            }).disposed(by: disposeBag)
        
        ///생활안정 컬렉션뷰 선택
        livingCategoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.livingDidSelectedId.append(self.livingCVSelectedId[indexPath.row])
                self.viewModel.input.confirmButtonValid.accept(true)
                print("선택된 생활안정 id: \(self.livingDidSelectedId)")
            }).disposed(by: disposeBag)
        
        livingCategoryCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.livingDidSelectedId = self.livingDidSelectedId.filter { $0 != self.livingCVSelectedId[indexPath.row] }
                print("삭제된 후 생활안정 id: \(self.livingDidSelectedId)")
            }).disposed(by: disposeBag)
        
        //교육문화 컬렉션뷰 선택
        educationCategoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.eduDidSelectedId.append(self.eduCVSelectedId[indexPath.row])
                self.viewModel.input.confirmButtonValid.accept(true)
                print("선택된 교육문화 id: \(self.eduDidSelectedId)")
            }).disposed(by: disposeBag)
        
        educationCategoryCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.eduDidSelectedId = self.eduDidSelectedId.filter { $0 != self.eduCVSelectedId[indexPath.row] }
                print("삭제된 후 교육문화 id: \(self.eduDidSelectedId)")
            }).disposed(by: disposeBag)
        
        //참여 공간 컬렉션뷰 선택
        participationCategoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.particiDidSelectedId.append(self.particiCVSelectedId[indexPath.row])
                self.viewModel.input.confirmButtonValid.accept(true)
                print("선택된 참여공간 id: \(self.particiDidSelectedId)")
            }).disposed(by: disposeBag)
        
        participationCategoryCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.particiDidSelectedId = self.particiDidSelectedId.filter { $0 != self.particiCVSelectedId[indexPath.row] }
                print("삭제된 후 참여공간 id: \(self.particiDidSelectedId)")
            }).disposed(by: disposeBag)
        
        //이용 목적 컬렉션뷰 선택
        forWhatCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.forWhatDidSelectedId.append(self.forWhatCVSelectedId[indexPath.row])
                self.viewModel.input.confirmButtonValid.accept(true)
                print("선택된 이용목적 id: \(self.forWhatDidSelectedId)")
            }).disposed(by: disposeBag)
        
        forWhatCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.forWhatDidSelectedId = self.forWhatDidSelectedId.filter { $0 != self.forWhatCVSelectedId[indexPath.row] }
                print("삭제된 후 이용목적 id: \(self.forWhatDidSelectedId)")
            }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                var unionedId = [Int]()
                unionedId += self.jobDidSelectedId
                unionedId += self.livingDidSelectedId
                unionedId += self.eduDidSelectedId
                unionedId += self.particiDidSelectedId
                var unionedForWhatId = [Int]()
                unionedForWhatId += self.forWhatDidSelectedId
                
                self.viewModel.input.interestEditCompleteObserver.accept(unionedId)
                self.viewModel.input.forWhatEditCompleteObserver.accept(unionedForWhatId)
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.interestCategoryOutput
            .scan(into: [ChildDetail]()) { details, action in
                switch action {
                case .right(let interest):
                    self.checkIsInterest.append(true)
                    self.viewModel.input.confirmButtonValid.accept(true)
                    details.append(interest)
                    self.jobCVSelectedId.append(interest.id)
                    self.jobCVSelectedId.sort()
                    //선택 id 저장 (처음에 right일 경우)
                    self.jobDidSelectedId.append(interest.id)
                case .notYet(let normal):
                    self.checkIsInterest.append(false)
                    details.append(normal)
                    self.jobCVSelectedId.append(normal.id)
                    self.jobCVSelectedId.sort()
                case .clear(_):
                    for i in 0..<(self.checkIsInterest.count) { self.checkIsInterest[i] = false }
                }
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: self.jobCategoryCollectionView.rx.items(cellIdentifier: "jobInterestCollectionView", cellType: FilterCollectionViewCell.self)) {
                (index: Int, element: ChildDetail, cell) in
                if(self.checkIsInterest[index]) {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "5B43EF")
                    cell.tagLabel.textColor = .white
                } else {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "F0F0F0")
                    cell.tagLabel.textColor = .black
                }
            }.disposed(by: disposeBag)

        ///생활안정
        viewModel.output.interestLivingOutput
            .scan(into: [ChildDetail]()) { details, action in
                switch action {
                case .right(let interest):
                    self.check3.append(true)
                    self.viewModel.input.confirmButtonValid.accept(true)
                    details.append(interest)
                    self.livingCVSelectedId.append(interest.id)
                    self.livingCVSelectedId.sort()
                    //선택 id 저장 (처음에 right일 경우)
                    self.livingDidSelectedId.append(interest.id)
                case .notYet(let normal):
                    self.check3.append(false)
                    details.append(normal)
                    self.livingCVSelectedId.append(normal.id)
                    self.livingCVSelectedId.sort()
                case .clear(_):
                    for i in 0..<(self.check3.count) { self.check3[i] = false }
                }
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: self.livingCategoryCollectionView.rx.items(cellIdentifier: "livingCollectionView", cellType: FilterCollectionViewCell.self)) {
                (index: Int, element: ChildDetail, cell) in
                if(self.check3[index]) {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "5B43EF")
                    cell.tagLabel.textColor = .white
                } else {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "F0F0F0")
                    cell.tagLabel.textColor = .black
                }
            }.disposed(by: disposeBag)

        viewModel.output.interestEducationCategoryOutput
            .scan(into: [ChildDetail]()) { details, action in
                switch action {
                case .right(let interest):
                    self.check1.append(true)
                    details.append(interest)
                    self.viewModel.input.confirmButtonValid.accept(true)
                    self.eduCVSelectedId.append(interest.id)
                    self.eduCVSelectedId.sort()
                    //선택 id 저장 (처음에 right일 경우)
                    self.eduDidSelectedId.append(interest.id)
                case .notYet(let normal):
                    self.check1.append(false)
                    details.append(normal)
                    self.eduCVSelectedId.append(normal.id)
                    self.eduCVSelectedId.sort()
                case .clear(_):
                    for i in 0..<(self.check1.count) { self.check1[i] = false }
                }
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: self.educationCategoryCollectionView.rx.items(cellIdentifier: "educationCategoryCollectionView", cellType: FilterCollectionViewCell.self)) {
                (index: Int, element: ChildDetail, cell) in
                if(self.check1[index]) {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "5B43EF")
                    cell.tagLabel.textColor = .white
                } else {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "F0F0F0")
                    cell.tagLabel.textColor = .black
                }
            }.disposed(by: disposeBag)

        viewModel.output.participationCategoryOutput
            .scan(into: [ChildDetail]()) { details, action in
                switch action {
                case .right(let interest):
                    self.check2.append(true)
                    details.append(interest)
                    self.viewModel.input.confirmButtonValid.accept(true)
                    self.particiCVSelectedId.append(interest.id)
                    self.particiCVSelectedId.sort()
                    //선택 id 저장 (처음에 right일 경우)
                    self.particiDidSelectedId.append(interest.id)
                case .notYet(let normal):
                    self.check2.append(false)
                    details.append(normal)
                    self.particiCVSelectedId.append(normal.id)
                    self.particiCVSelectedId.sort()
                case .clear(_):
                    for i in 0..<(self.check2.count) { self.check2[i] = false }
                }
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: self.participationCategoryCollectionView.rx.items(cellIdentifier: "participationCollectionView", cellType: FilterCollectionViewCell.self)) {
                (index: Int, element: ChildDetail, cell) in
                if(self.check2[index]) {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "5B43EF")
                    cell.tagLabel.textColor = .white
                } else {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "F0F0F0")
                    cell.tagLabel.textColor = .black
                }
            }.disposed(by: disposeBag)


        ///이용목적
        viewModel.output.returnForWhat
            .scan(into: [UserPurpose]()) { purposes, action in
                switch action {
                case .right(let right):
                    self.forWhatCheck.append(true)
                    purposes.append(right)
                    //전체 id 저장
                    self.forWhatCVSelectedId.append(right.id)
                    self.forWhatCVSelectedId.sort()
                    //선택 id 저장 (처음에 right일 경우)
                    self.forWhatDidSelectedId.append(right.id)
                    //버튼
                    self.viewModel.input.confirmButtonValid.accept(true)
                case .nope(let normal):
                    self.forWhatCheck.append(false)
                    purposes.append(normal)
                    self.forWhatCVSelectedId.append(normal.id)
                    self.forWhatCVSelectedId.sort()
                case .clear(_):
                    for i in 0..<(self.forWhatCheck.count) { self.forWhatCheck[i] = false }
                }
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: self.forWhatCollectionView.rx.items(cellIdentifier: "forWhatCollectionView", cellType: FilterCollectionViewCell.self)) {
                (index: Int, element: UserPurpose, cell) in
                if(self.forWhatCheck[index]) {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "5B43EF")
                    cell.tagLabel.textColor = .white
                } else {
                    cell.tagLabel.text = element.name
                    cell.contentView.backgroundColor = UIColor(hexString: "F0F0F0")
                    cell.tagLabel.textColor = .black
                }
            }.disposed(by: disposeBag)
        
        ///RxDataSources
//        categoryViewModel.firstLoadOutput
//            .map { [CategoryDataSection(header: "일자리", items: [] }
//            .bind(to: jobCategoryCollectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
        
        ///확인 버튼
        viewModel.output.confirmButtonValidOutput
            .drive(onNext: { [weak self] valid in
                if valid {
                    self?.confirmButton.isEnabled = valid
                    self?.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                    self?.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                } else {
                    self?.confirmButton.isEnabled = valid
                    self?.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                    self?.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .normal)
                }
            }).disposed(by: disposeBag)
    }
}

extension InterestCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 3 {
            print("인덱스: \(indexPath.row)")
            let name = InterestCategoryViewController.confirmParticiLabelSize[indexPath.row]
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 50 //indent for the first line
            paragraphStyle.headIndent = 10
            paragraphStyle.tailIndent = 10
            
            let attributes = [
                NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
            
            let nameSize = (name as NSString).size(withAttributes: attributes as [NSAttributedString.Key: Any])
            return CGSize(width: nameSize.width+28, height: 40)
            
        } else if collectionView.tag == 2 {
            let name = InterestCategoryViewController.confirmEduLabelSize[indexPath.row]
            
            let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)]
            
            let nameSize = (name as NSString).size(withAttributes: attributes as [NSAttributedString.Key: Any])
            return CGSize(width: nameSize.width+28, height: 40)
            
        } else if collectionView.tag == 1 {
            let name = InterestCategoryViewController.confirmJobLabelSize[indexPath.row]
            
            let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)]
            
            let nameSize = (name as NSString).size(withAttributes: attributes as [NSAttributedString.Key: Any])
            return CGSize(width: nameSize.width+28, height: 40)
            
            //생활지원
        } else if collectionView.tag == 5 {
            let name = InterestCategoryViewController.confirmLivingLabelSize[indexPath.row]
            
            let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)]
            
            let nameSize = (name as NSString).size(withAttributes: attributes as [NSAttributedString.Key: Any])
            return CGSize(width: nameSize.width+28, height: 40)
        }
        else {
            let name = InterestCategoryViewController.confirmIsForWhatLabelSize[indexPath.row]
            
            let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 16)]
            
            let nameSize = (name as NSString).size(withAttributes: attributes as [NSAttributedString.Key: Any])
            return CGSize(width: nameSize.width+28, height: 40)
        }
    }
}
