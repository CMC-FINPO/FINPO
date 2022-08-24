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
    
    ///불러온 정책 아이디 저장
    var selectedId: [Int] = [Int]()
    var idIsSelected: [Bool] = [Bool]()
    
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
    
    private var interestTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(120)
        tv.backgroundColor = UIColor(hexString: "F9F9F9")
        return tv
    }()
    ///TV -> CV 변경
    private var interestPolicyCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 20, left: 2, bottom: 15, right: 2)
        let cv = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flow)
        cv.backgroundColor = UIColor(hexString: "F0F0F0")
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
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
        interestCollectionView.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: "BookmarkCollectionViewCell")
        interestCollectionView.delegate = self
        
        interestTableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        ///TV -> CV 변경
        interestPolicyCollectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "interestPolicyCollectionViewCell")
        interestPolicyCollectionView.delegate = self
        interestPolicyCollectionView.tag = 2
        
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
        
//        view.addSubview(interestTableView)
//        interestTableView.snp.makeConstraints {
//            $0.top.equalTo(interestCollectionView.snp.bottom).offset(20)
//            $0.leading.equalTo(areaLabel.snp.leading)
//            $0.trailing.equalToSuperview().inset(21)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//        }
        
        view.addSubview(interestPolicyCollectionView)
        interestPolicyCollectionView.snp.makeConstraints {
            $0.top.equalTo(interestCollectionView.snp.bottom).offset(20)
//            $0.leading.equalTo(areaLabel.snp.leading)
            $0.trailing.leading.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                ///관심정책 데이터 트리거
                self?.viewModel.input.getUserInterestedInfo.accept(())
                
                ///나의 관심 카테고리 조회 트리거
                self?.viewModel.input.getMyCategoryObserver.accept(())
                
                ///나의 관심정책 조회 트리거
                self?.viewModel.input.getMyInterestPolicyObserver.accept(())
            }).disposed(by: disposeBag)
        
//        interestTableView.rx.itemSelected
//            .subscribe(onNext: { [weak self] indexPath in
//                let vc = HomeDetailViewController()
//                vc.initialize(id: self?.selectedId[indexPath.row] ?? -1)
//                vc.modalPresentationStyle = .fullScreen
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }).disposed(by: disposeBag)
        
        interestPolicyCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let vc = HomeDetailViewController()
                vc.initialize(id: self?.selectedId[indexPath.row] ?? -1)
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    fileprivate func setOutputBind() {
        viewModel.output.sendUserInterestedOutput
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] userData in
                guard let self = self else { return }
                self.titleLabel.text = "\(self.myPageViewModel.user.nickname)님은\n\(userData.data.count)개의 정책에 관심이 있네요!"
                self.setLabelTextColor(sender: self.titleLabel, count: userData.data.count)
            }).disposed(by: disposeBag)
        
        viewModel.output.sendMyCategoryOutput
            .asObservable()
            .scan(into: [myInterestCategory](), accumulator: { category, data in
                category.removeAll()
                for i in 0..<data.data.count {
                    category.append(data.data[i])
                    print("불러온 관심카테고리: \(category[i].name)")
                }
            })
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.interestCollectionView.rx.items(cellIdentifier: "BookmarkCollectionViewCell", cellType: BookmarkCollectionViewCell.self)) {
                (index: Int, element: myInterestCategory, cell) in
                cell.titleLabel.text = element.name
                let imageURL = URL(string: element.img)!
                cell.imageView.kf.setImage(with: imageURL)
            }.disposed(by: disposeBag)
        
//        viewModel.output.sendMyInterestPoliciesOutput
//            .scan(into: [ParticipationModel](), accumulator: { model, acceptedModel in
//                model.removeAll()
//                for i in 0..<(acceptedModel.data.count) {
//                    model.append(acceptedModel.data[i])
//                }
//                ///save selected Id
//                self.selectedId.removeAll()
//                self.idIsSelected.removeAll()
//                if(acceptedModel.data.count > 0) {
//                    for i in 0..<(acceptedModel.data.count) {
//                        self.selectedId.append(acceptedModel.data[i].policy.id)
//                        self.idIsSelected.append(acceptedModel.data[i].policy.isInterest)
//                    }
//                }
//                print("선택된 정책 아이디: \(self.selectedId)")
//            })
//            .asObservable()
//            .observe(on: MainScheduler.instance)
//            .bind(to: self.interestTableView.rx.items(cellIdentifier: "HomeTableViewCell", cellType: HomeTableViewCell.self)) {
//                (index: Int, element: ParticipationModel, cell) in
//                ///ex 서울 성북 -> 서울 전체일 경우 예외처리 할 것
//                cell.regionLabel.text = (element.policy.region.parent?.name ?? "") + " " + (element.policy.region.name)
//
//
//                ///공고명, 정책이름
//                cell.policyNameLabel.text = element.policy.title
//
//                ///기관명
//                cell.organizationLabel.text = element.policy.institution ?? "기관명 없음"
//
//                ///북마크 여부
//                if element.policy.isInterest {
//                    cell.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
//                } else {
//                    cell.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
//                }
//
//                cell.bookMarkButton.rx.tap
//                    .asDriver()
//                    .drive(onNext: { [weak self] _ in
//                        guard let self = self else { return }
//                        if(self.idIsSelected[index]) {
//                            print("인덱스: \(index)")
//                            self.homeViewModel.input.bookmarkDeleteObserver.accept(self.selectedId[index])
//                            cell.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
//                            self.idIsSelected[index] = false
//                        } else {
//                            self.homeViewModel.input.bookmarkObserver.accept(self.selectedId[index])
//                            cell.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
//                            self.idIsSelected[index] = true
//                        }
//                    }).disposed(by: cell.disposeBag)
//
//            }.disposed(by: disposeBag)
        
        viewModel.output.sendMyInterestPoliciesOutput
            .scan(into: [ParticipationModel](), accumulator: { model, acceptedModel in
                model.removeAll()
                for i in 0..<(acceptedModel.data.count) {
                    model.append(acceptedModel.data[i])
                }
                ///save selected Id
                self.selectedId.removeAll()
                self.idIsSelected.removeAll()
                if(acceptedModel.data.count > 0) {
                    for i in 0..<(acceptedModel.data.count) {
                        self.selectedId.append(acceptedModel.data[i].policy.id)
                        self.idIsSelected.append(acceptedModel.data[i].policy.isInterest)
                    }
                }
                print("선택된 정책 아이디: \(self.selectedId)")
            })
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.interestPolicyCollectionView.rx.items(cellIdentifier: "interestPolicyCollectionViewCell", cellType: HomeCollectionViewCell.self)) {
                (index: Int, element: ParticipationModel, cell) in
                ///ex 서울 성북 -> 서울 전체일 경우 예외처리 할 것
                cell.regionLabel.text = (element.policy.region.parent?.name ?? "") + " " + (element.policy.region.name)
                               
                ///공고명, 정책이름
                cell.policyNameLabel.text = element.policy.title
                
                ///기관명
                cell.organizationLabel.text = element.policy.institution ?? "기관명 없음"
                
                ///북마크 여부
                if element.policy.isInterest {
                    cell.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
                } else {
                    cell.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                }
                
                cell.bookMarkButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        if(self.idIsSelected[index]) {
                            print("인덱스: \(index)")
                            self.homeViewModel.input.bookmarkDeleteObserver.accept(self.selectedId[index])
                            cell.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                            self.idIsSelected[index] = false
                        } else {
                            self.homeViewModel.input.bookmarkObserver.accept(self.selectedId[index])
                            cell.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
                            self.idIsSelected[index] = true
                        }
                    }).disposed(by: cell.disposeBag)
                
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
        //정책 뿌려줄 때
        if collectionView.tag == 2 {
            let collectionViewWidth = collectionView.bounds.width
            return CGSize(width: collectionViewWidth-30, height: 110)
        } else {
            return CGSize(width: 95, height: 111)
        }
        return CGSize(width: 95, height: 111)
    }
     
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 2 {
            return 10
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.tag == 2 {
            guard let cell = interestPolicyCollectionView.dequeueReusableCell(withReuseIdentifier: "interestPolicyCollectionViewCell", for: indexPath) as? HomeCollectionViewCell else { return }
            
            cell.disposeBag = DisposeBag()
        }
    }
}

extension BookmarkViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = interestTableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell else { return }
        
        ///화면 밖에서 사라질 때 subscription을 dispose 하기
        cell.disposeBag = DisposeBag()
    }
}
