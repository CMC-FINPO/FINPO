//
//  LoginInterestViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/10.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class LoginInterestViewController: UIViewController, UICollectionViewDelegate {
    
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    let selectedCell = [Int]()
    
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
        progressBar.progress = 4/6
        progressBar.clipsToBounds = true
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "4/6"
        label.textAlignment = .center
        label.textColor = UIColor.systemGray.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "핀포님의 \n관심 분야를 선택해주세요"
        label.numberOfLines = 2
        label.textColor = .black
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심 분야 (복수 선택 가능)"
        label.textColor = UIColor(hexString: "494949")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        return label
    }()
    
    private var interestCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0.5
        layout.minimumInteritemSpacing = 0.5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.allowsMultipleSelection = true
        return cv
    }()
    
    private var confirmButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
        button.setTitle("선택 완료", for: .normal)
        button.setTitleColor(UIColor(hexString: "616161"), for: .normal)
        button.backgroundColor = UIColor(hexString: "F0F0F0")
        button.layer.cornerRadius = 20
        button.isEnabled = false
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate func setAttribute() {
        let attributedText = NSMutableAttributedString(string: subtitleLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "494949"), range: (subtitleLabel.text! as NSString).range(of: "관심 분야"))
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "5B43EF"), range: (subtitleLabel.text! as NSString).range(of: "(복수 선택 가능)"))
        subtitleLabel.attributedText = attributedText
        
        interestCollectionView.delegate = self
        interestCollectionView.register(InterestCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
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
        
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.equalTo(titleLabel.snp.leading)
        }
        
        view.addSubview(interestCollectionView)
        interestCollectionView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(325)
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
                self?.viewModel.getInterestCVMenuData()
            }).disposed(by: disposeBag)
        
        interestCollectionView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath in
                self?.viewModel.input.forUserInterestObserver.accept(indexPath.row+1)
                self?.viewModel.input.interestButtonTapped.accept(())
                let cell = self?.interestCollectionView.cellForItem(at: indexPath) as? InterestCollectionViewCell
                cell?.viewModel = self?.viewModel
                cell?.id = indexPath.row+1
            }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                let vc = LoginSemiCompleteViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
                
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.interestingNameOutput
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: interestCollectionView.rx.items(cellIdentifier: "cell")) { (index: Int, element: MainInterest, cell: InterestCollectionViewCell) in
                cell.setup()
                cell.titleLabel.text = element.name
            }.disposed(by: disposeBag)
        
        viewModel.output.interestButtonValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    print("트루들옴")
                    self?.confirmButton.isEnabled = valid
                    self?.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                    self?.confirmButton.backgroundColor = UIColor(hexString: "5B43EF")
                } else {
                    self?.confirmButton.isEnabled = false
                    print("컨펌버튼 비활성화, 색상변경")
                    self?.confirmButton.setTitleColor(UIColor(hexString: "616161"), for: .normal)
                    self?.confirmButton.backgroundColor = UIColor(hexString: "F0F0F0")
                }
            }).disposed(by: disposeBag)
    }
    
}

extension LoginInterestViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width / 2) - 0.5
              
        return CGSize(width: width, height: width)
    }
}
