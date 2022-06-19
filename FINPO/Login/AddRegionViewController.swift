//
//  AddRegionViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/16.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import CoreMedia

class AddRegionViewController: UIViewController {
    
    var user = User.instance
    let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    var selectedIndex: Int = 0
    var isSelected: Bool = false
    var setStr = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mainRegionTableView.addBorderTop(size: 1, color: UIColor(hexString: "A2A2A2"))
        mainRegionTableView.addBorderBottom(size: 1, color: UIColor(hexString: "A2A2A2"))
        localRegionTableView.addBorderTop(size: 1, color: UIColor(hexString: "A2A2A2"))
        localRegionTableView.addBorderLeft(size: 1, color: UIColor(hexString: "A2A2A2"))
        localRegionTableView.addBorderBottom(size: 1, color: UIColor(hexString: "A2A2A2"))
        mainRegionTableView.reloadData()
        localRegionTableView.reloadData()
    }
    
    
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.trackTintColor = UIColor(hexString: "C4C4C5", alpha: 1)
        progressBar.progressTintColor = UIColor(hexString: "5B43EF", alpha: 1)
        progressBar.progress = 6/6
        progressBar.clipsToBounds = true
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "6/6"
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "C4C4C4")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "추가로 원하는\n관심 지역을 선택해주세요"
        label.numberOfLines = 2
        label.textColor = .black
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var tagCollectionView: UICollectionView = {
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
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "나중에 할게요", style: .plain, target: self, action: #selector(skipThisView))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "999999")
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 14)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        mainRegionTableView.register(MainRegionTableViewCell.self, forCellReuseIdentifier: "cell")
        localRegionTableView.register(SubRegionTableViewCell.self, forCellReuseIdentifier: "cell")
        
        tagCollectionView.delegate = self
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "tagCollectionViewCell")
        
        
        self.createDefaultTag()
    }
    
    @objc private func skipThisView() {
        
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

        self.tagCollectionView.addSubview(views)
        views.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(size.height)
            $0.width.equalTo(size.width)
        }
    }
    
    fileprivate func setLayout() {
        view.backgroundColor = .white
        
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(5)
        }
        
        view.addSubview(progressLabel)
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.top)
            $0.leading.equalTo(progressBar.snp.trailing).offset(15)
            $0.height.equalTo(10)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
        }
        
        view.addSubview(tagCollectionView)
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.width.equalToSuperview().inset(10)
            $0.height.equalTo(85)
//            TODO: 나중에 지역 선택 많이 했을 때, height 조절되게 하기
        }
        
        view.addSubview(mainRegionTableView)
        mainRegionTableView.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(15)
            $0.width.equalTo(100)
            $0.height.equalTo(180)
        }
        
        view.addSubview(localRegionTableView)
//        localRegionTableView.snp.makeConstraints {
//            $0.top.equalTo(mainRegionTableView.snp.top)
//            $0.leading.equalTo(mainRegionTableView.snp.trailing)
//            $0.trailing.equalToSuperview().inset(15)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-150)
//        }
        localRegionTableView.snp.remakeConstraints {
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
        ///viewWillAppear -> tableview 통신 및 초기화
        rx.viewWillAppear.take(1).asDriver { _ in
            return .never()}
        .drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.getMainRegionDataToTableView()
            self.viewModel.getSubRegionDataToTableView(0) //default: Seoul
        }).disposed(by: disposeBag)
    
        mainRegionTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.getSubRegionDataToTableView(indexPath.row)
            }).disposed(by: disposeBag)
        
        localRegionTableView.rx.itemSelected
//            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if(self.isSelected == false) {
                    self.tagCollectionView.subviews[(self.tagCollectionView.subviews.count)-1].removeFromSuperview()
                    self.isSelected = true
                    self.viewModel.input.regeionButtonObserver.accept(true)
                }
                self.viewModel.input.subRegionTapped.accept(indexPath.row)
                self.viewModel.input.regeionButtonObserver.accept(true)
            }).disposed(by: disposeBag)
        	
        tagCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                //화면상에 보여지는 cell (만약 뷰를 스크롤해서 collectionview가 안보여지게되면 못씀)
                guard let self = self else { return }
                if self.tagCollectionView.visibleCells.count <= 1 {
                    self.createDefaultTag()
                    print("디폴트 뷰 다시 만들어지고 false")
                    self.isSelected = false
                    self.viewModel.input.regeionButtonObserver.accept(false)
                } else {
                    self.isSelected = true
                }
                print("선택된 관심 지역 리스트 \(self.viewModel.user.interestRegion)")
                self.viewModel.input.deleteTagObserver.accept(indexPath.item)
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.mainRegionUpdate
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: mainRegionTableView.rx.items(cellIdentifier: "cell")) {
                (index: Int, element: MainRegion, cell: MainRegionTableViewCell) in
                cell.selectionStyle = .none
                cell.mainRegionLabel.text = element.name
            }.disposed(by: disposeBag)
        
        viewModel.output.subRegionUpdate
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: localRegionTableView.rx.items(cellIdentifier: "cell")) {
                (index: Int, element: SubRegion, cell: SubRegionTableViewCell) in
                cell.selectionStyle = .none
                cell.subRegionLabel.text = element.name
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsets.zero
            }.disposed(by: disposeBag)
        
        viewModel.output.regionButton
            .scan([UniouRegion]()) { regions, type in
                var newRegions = regions
                switch type {
                case .add(let region):
                    newRegions.append(region)
                case .delete(let index):
                    newRegions.remove(at: index)
                }
                return newRegions
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: tagCollectionView.rx.items(cellIdentifier: "tagCollectionViewCell", cellType: TagCollectionViewCell.self)) {
                (index: Int, element: UniouRegion, cell) in
                print("들어옴")
                cell.setLayout()
                cell.tagLabel.text = element.unionRegionName
                cell.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 3
                print("tagCollectionview 인덱스 \(index)")
            }.disposed(by: disposeBag)
        
        viewModel.output.regionButtonValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid {
                    self.confirmButton.isEnabled = valid
                    self.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                    self.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                } else {
                    self.confirmButton.isEnabled = false
                    print("컨펌버튼 비활성화, 색상변경")
                    self.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .disabled)
                    self.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                }
            }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension AddRegionViewController: UICollectionViewDelegateFlowLayout {
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
