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
import Alamofire

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
        progressBar.progressTintColor = UIColor.P01
        progressBar.progress = 4/6
        progressBar.clipsToBounds = true
        progressBar.layer.cornerRadius = 3
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.G05
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.text = "4/6"
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "핀포님의 \n관심 분야를 선택해주세요"
        label.numberOfLines = 2
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심 분야 (복수 선택 가능)"
        label.textColor = UIColor.G01
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        return label
    }()
    
    private var interestCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.allowsMultipleSelection = true
        cv.isScrollEnabled = false
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
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        let attributedText = NSMutableAttributedString(string: subtitleLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor.G01, range: (subtitleLabel.text! as NSString).range(of: "관심 분야"))
        attributedText.addAttribute(.foregroundColor, value: UIColor.P01, range: (subtitleLabel.text! as NSString).range(of: "(복수 선택 가능)"))
        subtitleLabel.attributedText = attributedText
        
        interestCollectionView.delegate = self
        interestCollectionView.register(InterestCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
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
                guard let self = self else { return }
                self.titleLabel.text = "\(self.viewModel.user.nickname)님의\n관심 분야를 선택해주세요"
                self.viewModel.getInterestCVMenuData()
            }).disposed(by: disposeBag)
        
        interestCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.input.forUserInterestObserver.accept(indexPath.row+1)
                self?.viewModel.input.interestButtonTapped.accept(())
                let cell = self?.interestCollectionView.cellForItem(at: indexPath) as? InterestCollectionViewCell
                cell?.viewModel = self?.viewModel
                cell?.id = indexPath.row+1
            }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind(to: viewModel.input.semiSignupConfirmButtonTapped)
            .disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.interestingNameOutput
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind(to: interestCollectionView.rx.items(cellIdentifier: "cell")) { (index: Int, element: MainInterest, cell: InterestCollectionViewCell) in
                cell.setup()
                cell.titleLabel.text = element.name
                cell.imageView.image = UIImage(named: "MainInterest\(index)")
                cell.layer.frame.size = CGSize(width: 168, height: 143)
            }.disposed(by: disposeBag)
        
        viewModel.output.interestButtonValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] valid in
                if valid {
                    print("트루들옴")
                    self?.confirmButton.isEnabled = valid
                    self?.confirmButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
                    self?.confirmButton.backgroundColor = UIColor.P01
                } else {
                    self?.confirmButton.isEnabled = false
                    print("컨펌버튼 비활성화, 색상변경")
                    self?.confirmButton.setTitleColor(UIColor.G02, for: .normal)
                    self?.confirmButton.backgroundColor = UIColor.G08
                }
            }).disposed(by: disposeBag)
        
        ///세미 회원가입 확인
        viewModel.output.isSemiSignupComplete
//            .asDriver(onErrorJustReturn: false)
            .asSignal()
            .emit(onNext: { [weak self] value in
                guard let self = self else { return }
                User.instance = value
                
                User.instance.profileImg = value.profileImg
                print("세미회원가입 최종 유저 정보: \(User.instance.name)")
                print("세미회원가입 최종 유저 정보: \(User.instance.nickname)")
                print("세미회원가입 최종 유저 정보: \(User.instance.birth)")
                print("세미회원가입 최종 유저 정보: \(User.instance.gender)")
                print("세미회원가입 최종 유저 정보: \(User.instance.region)")
                print("세미회원가입 최종 유저 정보: \(User.instance.category)")
                print("세미회원가입 최종 유저 정보: \(User.instance.accessTokenFromSocial)")
                print("세미회원가입 최종 유저 정보: \(User.instance.refreshToken)")

                let vc = LoginSemiCompleteViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }).disposed(by: disposeBag)
                           
        viewModel.output.errorValue.asSignal()
            .emit(onNext: { [weak self] error in
                guard let self = self else { return }
                let ac = UIAlertController(title: "에러", message: "이미 가입된 회원입니다.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(ac, animated: true)
            }).disposed(by: disposeBag)
    
    }
}

extension LoginInterestViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width / 2) - 0.5              
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -22
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
