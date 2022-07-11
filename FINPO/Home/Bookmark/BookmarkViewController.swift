//
//  BookmarkViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/10.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
import UIKit
import Kingfisher

class BookmarkViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = BookmarkViewModel()
    let myPageViewModel = MyPageViewModel()
    let homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "핀포님은\n2개의 정책에 참여했네요!"
        label.numberOfLines = 0
        label.textColor = UIColor(hexString: "000000")
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private let areaLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "494949")
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.text = "관심 분야"
        return label
    }()
    
    private var interestCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumInteritemSpacing = 20
        flow.scrollDirection = .horizontal
        //섹션인셋 유무 차이 확인
        flow.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = .white
        self.interestCollectionView.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: "BookmarkCollectionViewCell")
        
        self.interestCollectionView.delegate = self
    }
 
    fileprivate func setLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.trailing.equalToSuperview().inset(21)
        }
        
        view.addSubview(areaLabel)
        areaLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(7)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(258)
        }
        
        view.addSubview(interestCollectionView)
        interestCollectionView.snp.makeConstraints {
            $0.top.equalTo(areaLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(18)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(115)
        }
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                ///관심정책 데이터 트리거
                self?.viewModel.input.getUserInterestedInfo.accept(())
                
                ///나의 관심 카테고리 조회 트리거
                self?.viewModel.input.getMyCategoryObserver.accept(())
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.sendUserInterestedOutput
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] userData in
                guard let self = self else { return }
                self.titleLabel.text = "\(self.myPageViewModel.user.nickname)님은\n\(userData.data.count)개의 정책에 관심이 있네요!"
                self.setLabelTextColor(sender: self.titleLabel, count: userData.data.count)
            }).disposed(by: disposeBag)
        
        viewModel.output.sendMyCategoryOutput
            .asObservable()
            .scan(into: [myInterestCategory](), accumulator: { category, data in
                for i in 0..<data.data.count {
                    category.append(data.data[i])
                    print("불러온 관심카테고리: \(category[i].name)")
                }
            })
            .observe(on: MainScheduler.instance)
            .bind(to: self.interestCollectionView.rx.items(cellIdentifier: "BookmarkCollectionViewCell", cellType: BookmarkCollectionViewCell.self)) {
                (index: Int, element: myInterestCategory, cell) in
                cell.titleLabel.text = element.name
                let imageURL = URL(string: element.img)!
                cell.imageView.kf.setImage(with: imageURL)
            }.disposed(by: disposeBag)
        
        
    }
    
    func setLabelTextColor(sender: UILabel, count: Int) {
        let attributedText = NSMutableAttributedString(string: self.titleLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "5B43EF"), range: (self.titleLabel.text! as NSString).range(of: "\(count)"))
        self.titleLabel.attributedText = attributedText
    }

}

extension BookmarkViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 111)
    }
    
}
