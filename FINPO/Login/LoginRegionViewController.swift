//
//  LoginRegionViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/07.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import CoreMIDI


class LoginRegionViewController: UIViewController {

    var user = User.instance
    
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    
    var setStr = [String]()
    var isSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.trackTintColor = UIColor(hexString: "C4C4C5", alpha: 1)
        progressBar.progressTintColor = UIColor(hexString: "5B43EF", alpha: 1)
        progressBar.progress = 3/6
        progressBar.clipsToBounds = true
        progressBar.layer.cornerRadius = 3
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "C4C4C5")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.text = "3/6"
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "핀포님이 거주하고 있는 \n지역은 어디인가요?"
        label.numberOfLines = 0
        label.textColor = .black
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var tagCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    private var mainRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(60)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.bounces = false
        tv.showsHorizontalScrollIndicator = false
        return tv
    }()
    
    private var localRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(40)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        tv.bounces = false
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
        button.isEnabled = false
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate func setAttribute() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        mainRegionTableView.tag = 1
        mainRegionTableView.register(MainRegionTableViewCell.self, forCellReuseIdentifier: "cell")
        
        localRegionTableView.tag = 2
        localRegionTableView.register(SubRegionTableViewCell.self, forCellReuseIdentifier: "cell")

        tagCollectionView.delegate = self
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.createDefaultTag()

    }
    
    fileprivate func createDefaultTag() {
        let dummyLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 16)
            $0.text = "어디 사시나요..?👀"
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
        titleLabel.text = "어디 사시나요..?👀"
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
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(5)
        }
        
        view.addSubview(progressLabel)
        progressLabel.snp.makeConstraints {
            $0.centerY.equalTo(progressBar.snp.centerY)
            $0.leading.equalTo(progressBar.snp.trailing).offset(15)
            $0.height.equalTo(15)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().inset(15)
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
        ///viewWillAppear -> tableview 통신 및 초기화
        rx.viewWillAppear.take(1).asDriver { _ in
            return .never()}
        .drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.titleLabel.text = "\(self.viewModel.user.nickname)님이 거주하고 있는\n지역은 어디인가요?"
            self.viewModel.getMainRegionDataToTableView()
            self.viewModel.getSubRegionDataToTableView(0)}) //default: Seoul
        .disposed(by: disposeBag)
        
        mainRegionTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.getSubRegionDataToTableView(indexPath.row)
            }).disposed(by: disposeBag)
        
        localRegionTableView.rx.itemSelected
//            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                if(self?.isSelected == false) {
                    self?.viewModel.input.subRegionTapped.accept(indexPath.row)
                    self?.tagCollectionView.subviews[0].removeFromSuperview()
                    self?.viewModel.input.regeionButtonObserver.accept(true)
                    self?.isSelected = true
                } else {
                    self?.isSelected = true
                }
            }).disposed(by: disposeBag)
        
        tagCollectionView.rx.itemSelected
            .subscribe(onNext:{ [weak self] indexPath in                
//                self?.tagCollectionView.deleteItems(at: [indexPath])
                if(self?.isSelected == true) {
                    let cell = self?.tagCollectionView.cellForItem(at: indexPath)
                    cell?.removeFromSuperview()
                    self?.createDefaultTag()
                    self?.setStr.removeAll()
                    self?.viewModel.user.region.removeAll()
                    LoginViewModel.isMainRegionSelected = false
                    self?.isSelected = false
                    self?.viewModel.input.regeionButtonObserver.accept(false)
                    print("기본 텍스트 표시할 카운트\(self?.setStr.count)")
                    print("인덱스 \(indexPath.row)")
                    print("테이블뷰 뷰컨 \(self?.viewModel.user.region)")
                } else {
                    self?.isSelected = false
                }
            }).disposed(by: disposeBag)
                        
        confirmButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                let vc = LoginInterestViewController()
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.mainRegionUpdate
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: mainRegionTableView.rx.items(cellIdentifier: "cell")) {
                (index: Int, element: MainRegion, cell: MainRegionTableViewCell) in
                print("인덱스 값: \(index)")
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
        
        viewModel.output.unionedReion
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: tagCollectionView.rx.items(cellIdentifier: "cell", cellType: TagCollectionViewCell.self)) { [weak self]
                (index: Int, element: UniouRegion , cell) in
                if (self?.setStr.contains(element.unionRegionName) != false) {
                    return
                }
                else {
                    cell.setLayout()
                    self?.setStr.append(element.unionRegionName)
                    cell.tagLabel.text = element.unionRegionName
                    cell.layer.borderColor = UIColor(hexString: "5B43EF").cgColor
                    cell.layer.borderWidth = 1
                    cell.layer.cornerRadius = 3
//                    cell.bounds = cell.frame.insetBy(dx: 0, dy: -)
                }
            }.disposed(by: disposeBag)
        
        viewModel.output.regionButtonValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    self?.confirmButton.isEnabled = valid
                    self?.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                    self?.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                } else {
                    self?.confirmButton.isEnabled = false
                    print("컨펌버튼 비활성화, 색상변경")
                    self?.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .disabled)
                    self?.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                }
            }).disposed(by: disposeBag)
    }

}

extension LoginRegionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let dummyLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 16)
            $0.text = "길이 측정용    "
            $0.sizeToFit()
        }
        let size = dummyLabel.frame.size

        return CGSize(width: size.width+12, height: size.height+15)
    }
}

