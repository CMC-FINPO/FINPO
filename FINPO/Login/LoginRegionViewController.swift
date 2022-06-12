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
import TTGTags


class LoginRegionViewController: UIViewController, TTGTextTagCollectionViewDelegate {

    var user = User.instance
    
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    
    var setStr = [String]()
    var selectedIndexPath: IndexPath? = nil
    
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
        return progressBar
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "3/6"
        label.textAlignment = .center
        label.textColor = UIColor.systemGray.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "핀포님이 거주하고 있는 \n지역은 어디인가요?"
        label.numberOfLines = 2
        label.textColor = .black
        label.font =  UIFont(name: "AppleSDGothicNeo-SemiBold", size: 27)
        return label
    }()
    
    private var tagCollectionView: TTGTextTagCollectionView = {
        let cv = TTGTextTagCollectionView()
        cv.backgroundColor = .white
        cv.alignment = .center

        return cv
    }()

    private var mainRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(60)
        tv.backgroundColor = UIColor(hexString: "F9F9F9", alpha: 1)
        tv.bounces = false
        return tv
    }()
    
    private var localRegionTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(40)
        tv.backgroundColor = UIColor(hexString: "F9F9F9", alpha: 1)
        tv.bounces = false
        return tv
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
        mainRegionTableView.tag = 1
        mainRegionTableView.register(MainRegionTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        localRegionTableView.tag = 2
        localRegionTableView.register(SubRegionTableViewCell.self, forCellReuseIdentifier: "cell")
        
        tagCollectionView.delegate = self
                
//        confirmButton.setBackgroundColor(UIColor(hexString: ""), for: .normal)
//        confirmButton.setBackgroundColor(.lightGray.withAlphaComponent(0.6), for: .disabled)
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
            $0.height.equalTo(70)
//            TODO: 나중에 지역 선택 많이 했을 때, height 조절되게 하기
        }
        
        view.addSubview(mainRegionTableView)
        mainRegionTableView.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(15)
            $0.width.equalTo(100)
//            $0.height.equalTo(200)
            $0.height.equalTo(view.frame.size.height/2)
        }
        
        view.addSubview(localRegionTableView)
        localRegionTableView.snp.makeConstraints {
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
        mainRegionTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.getSubRegionDataToTableView(indexPath.row)
            }).disposed(by: disposeBag)
        
        localRegionTableView.rx.itemSelected
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
//                let cell = self?.localRegionTableView.cellForRow(at: indexPath) as? SubRegionTableViewCell
                self?.viewModel.input.subRegionTapped.accept(indexPath.row)
            }).disposed(by: disposeBag)
                
        ///viewWillAppear -> tableview 통신 및 초기화
        rx.viewWillAppear.take(1).asDriver { _ in
            return .never()}
        .drive(onNext: { [weak self] _ in
            self?.viewModel.getMainRegionDataToTableView()
            self?.viewModel.getSubRegionDataToTableView(0)}) //default: Seoul
        .disposed(by: disposeBag)
        
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
            }.disposed(by: disposeBag)
        
        
        //TODO: Refactoring
        viewModel.output.createRegionButton
            .asObservable()
//            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] str in
                if (self?.setStr.contains(str) != false) {
                    return
                } else {
                    self?.setStr.append(str)
                    let content = TTGTextTagStringContent.init(text: str)
                    content.textColor = UIColor.rgb(red: 119, green: 98, blue: 235)
                    content.textFont = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)!
                    
                    let normalStyle = TTGTextTagStyle.init()
                    normalStyle.backgroundColor = UIColor.rgb(red: 247, green: 246, blue: 253)
                    normalStyle.borderColor = UIColor.rgb(red: 119, green: 98, blue: 235)
                    normalStyle.borderWidth = 1
                    normalStyle.cornerRadius = 3
                    normalStyle.extraSpace = CGSize(width: 35, height: 20)
                                                        
                    let tag = TTGTextTag.init()
                    tag.content = content
                    tag.style = normalStyle
                    
                    self?.tagCollectionView.addTag(tag)
                    self?.tagCollectionView.reload()
                }
            }).disposed(by: disposeBag)
        
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
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
        textTagCollectionView.removeTag(tag)
        
        localRegionTableView.rx.itemSelected
            .take(1)
//            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] indexPath in
                textTagCollectionView.removeTag(tag)
//                self?.viewModel.output.createRegionButton.accept("어디 사시나요...?👀")
                self?.viewModel.input.subRegionTapped.accept(indexPath.row)
            }).disposed(by: disposeBag)
        
        self.setStr.remove(at: Int(index))
        ///전체선택 시 index 관리를 위해 클리어
        viewModel.user.region.removeAll()
//        viewModel.user.region.remove(at: Int(index))
        print("뷰컨 중복체크 스트링\(self.setStr)")
        print("인덱스 \(index)")
        print("테이블뷰 뷰컨 \(viewModel.user.region)")
    }

}

