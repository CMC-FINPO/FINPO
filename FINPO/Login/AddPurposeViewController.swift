//
//  AddPurposeViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/19.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class AddPurposeViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.navigationController?.isNavigationBarHidden = false
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.trackTintColor = UIColor.G05
        progressBar.progressTintColor = UIColor.P01
        progressBar.progress = 5/6
        progressBar.clipsToBounds = true
        progressBar.layer.cornerRadius = 3
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textAlignment = .center
        label.textColor = UIColor.G05
        label.text = "5/6"
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .black
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 상태"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor.G01
        return label
    }()
    
    private var statusCollectionView: UICollectionView = {
//        let flow = LeftAlignedCollectionViewFlowLayout()
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private var bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.G06
        return view
    }()
    
    private var purposeLabel: UILabel = {
        let label = UILabel()
        label.text = "이용 목적 (복수 선택 가능)"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor.G01
        return label
    }()
    
    private var purposeCollectionView: UICollectionView = {
//        let flow = LeftAlignedCollectionViewFlowLayout()
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.allowsMultipleSelection = true
        return cv
    }()
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
        button.setTitle("선택 완료", for: .normal)
        button.setTitleColor(UIColor.G02, for: .normal)
        button.backgroundColor = UIColor.G08
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate func setAttribute() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "나중에 할게요", style: .plain, target: self, action: #selector(skipThisView))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.G03
        let attributes = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 10)!]
//        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, for: [.normal, .selected])
        
        statusCollectionView.delegate = self
        statusCollectionView.register(AddPurposeCollectionViewCell.self, forCellWithReuseIdentifier: "AddStatusCollectionViewCell")
        
        purposeCollectionView.delegate = self
        purposeCollectionView.register(AddPurposeCollectionViewCell.self, forCellWithReuseIdentifier: "AddPurposeCollectionViewCell")
        
        let attributedText = NSMutableAttributedString(string: purposeLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor.G01, range: (purposeLabel.text! as NSString).range(of: "이용 목적"))
        attributedText.addAttribute(.foregroundColor, value: UIColor.P01, range: (purposeLabel.text! as NSString).range(of: "(복수 선택 가능)"))
        purposeLabel.attributedText = attributedText
    }
    
    @objc private func skipThisView() {
        let vc = HomeTapViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    fileprivate func setLayout() {
        
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
        }
        
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(23)
            $0.leading.equalTo(titleLabel.snp.leading)
        }
        
        view.addSubview(statusCollectionView)
        statusCollectionView.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(10)
            $0.leading.equalTo(statusLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(68)
            $0.height.equalTo(152)
        }
        
        view.addSubview(bottomBorderView)
        bottomBorderView.snp.makeConstraints {
            $0.top.equalTo(statusCollectionView.snp.bottom).offset(10)
            $0.leading.equalTo(statusCollectionView.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(1)
        }
        
        view.addSubview(purposeLabel)
        purposeLabel.snp.makeConstraints {
            $0.top.equalTo(bottomBorderView.snp.bottom).offset(20)
            $0.leading.equalTo(statusCollectionView.snp.leading)
        }
        
        view.addSubview(purposeCollectionView)
        purposeCollectionView.snp.makeConstraints {
            $0.top.equalTo(purposeLabel.snp.bottom).offset(10)
            $0.leading.equalTo(purposeLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(44)
            $0.height.equalTo(152)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.text = "\(self.viewModel.user.nickname)님의 현재 상태와\n이용 목적을 선택해주세요"
                self.viewModel.getStatus()
                self.viewModel.getPurpose()
            }).disposed(by: disposeBag)
        
        statusCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.input.statusButtonTapped.accept(indexPath.row+1)
            }).disposed(by: disposeBag)
        
        purposeCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.purposeBag.append(indexPath.row+1)
                self.viewModel.input.purposeButtonTapped.accept(true)
                print("이용 목적 저장됨!!!: \(self.viewModel.purposeBag)")
            }).disposed(by: disposeBag)
        
        purposeCollectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if(self.viewModel.purposeBag.contains(indexPath.row+1)) {
                    let array = self.viewModel.purposeBag.filter { $0 != indexPath.row+1 }
                    self.viewModel.purposeBag = array
                    if(self.viewModel.purposeBag.count == 0) {
                        self.viewModel.input.purposeButtonTapped.accept(false)
                    }
                    print("이용 목적 삭제됨!!: \(self.viewModel.purposeBag)")
                }
            }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.input.statusPurposeButtonTapped.accept(())
                let vc = AddRegionViewController()
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.getStatus
            .asObservable()
            .bind(to: statusCollectionView.rx.items(cellIdentifier: "AddStatusCollectionViewCell")) {
                (index: Int, element: UserStatus, cell: AddPurposeCollectionViewCell) in
                cell.setup()
                cell.statusButton.setTitle(element.name, for: .normal)
                
//                cell.statusButton.sizeToFit()
//                let cellWidth = cell.statusLabel.frame.width + 10
//                cell.layer.frame.size = CGSize(width: cellWidth, height: 40)
//                cell.statusButton.rx.tap
//                    .asDriver()
//                    .drive(onNext: { [weak self] in
//                        self?.viewModel.input.statusButtonTapped.accept(element.id)
//                    }).disposed(by: cell.bag)
            }.disposed(by: disposeBag)
        
        viewModel.output.getPurpose
            .asObservable()
            .bind(to: purposeCollectionView.rx.items(cellIdentifier: "AddPurposeCollectionViewCell")) {
                (index: Int, element: UserPurpose, cell: AddPurposeCollectionViewCell) in
                cell.setup()
                cell.statusButton.setTitle(element.name, for: .normal)
                
            }.disposed(by: disposeBag)
        
        viewModel.output.statusPurposeButtonValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                guard let self = self else { return }
                if valid {
                    print("버튼 활성화")
                    self.confirmButton.isEnabled = valid
                    self.confirmButton.backgroundColor = UIColor.P01
                    self.confirmButton.setTitleColor(UIColor.W01, for: .normal)
                } else {
                    print("버튼 비활성화")
                    self.confirmButton.isEnabled = valid
                    self.confirmButton.backgroundColor = UIColor.G08
                    self.confirmButton.setTitleColor(UIColor.G02, for: .normal)
                }
            }).disposed(by: disposeBag)
    }
}

extension AddPurposeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width / 3) - 8.5
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

