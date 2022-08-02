//
//  HomeViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class HomeViewController: UIViewController {
    
    var user = User.instance
    
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    
    private var dataSource = [ContentsDetail]()
    private var currenetPage = -1
    
    private var selectedId: [Int] = [Int]()
    private var idIsSelected: [Bool] = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
        
        ///필터링
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didDismissDetailNotification(_:)),
            name: NSNotification.Name("sendFilteredInfo"),
            object: nil
        )
        
        ///유저 거주지역 수정 시
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didChangedUserMainRegion(_:)),
            name: NSNotification.Name("RegionChanged"),
            object: nil)
        ///유저 관심지역 수정 시
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didChangedUserMainRegion(_:)),
            name: NSNotification.Name("RegionChanged"),
            object: nil)
    }

    @objc fileprivate func didDismissDetailNotification(_ notification: Notification) {
        print("필터링 된 정보 스트림 호출부분")
        self.viewModel.input.selectedCategoryObserver.accept(FilterViewController.selectedCategories)
        self.viewModel.input.filteredRegionObserver.accept(FilterViewController.selectedRegions)
        //필터링 했으므로 나의 정책 결과는 아님
        self.currenetPage = 0
        self.viewModel.input.textFieldObserver.accept("") // 검색 초기화
        self.viewModel.input.myPolicyTrigger.accept(.notMyPolicy)
    }
    
    @objc fileprivate func didChangedUserMainRegion(_ notification: Notification) {
        self.viewModel.input.getUserInfo.accept(())
    }
    
    private var searchTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(hexString: "FFFFFF")
        tf.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 18)
        tf.addLeftImageAndPadding(image: UIImage(named: "search") ?? UIImage())
        tf.layer.borderColor = UIColor(hexString: "EBEBEB").cgColor
        tf.layer.borderWidth = 2
        tf.layer.cornerRadius = 5
        return tf
    }()
    
    private var policyCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "000000")
        label.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 18)
        return label
    }()
    
    private var filterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(named: "chip=_filter"), for: .normal)
        return button
    }()
    
    private var sortPolicyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(named: "chip=chip4"), for: .normal)
        return button
    }()
    
    private var searchTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = CGFloat(120)
        tv.separatorInset.left = 0
        tv.backgroundColor = .clear
        tv.layer.masksToBounds = true
        tv.layer.cornerRadius = 5
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
//        tv.bounces = false
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = UIColor(hexString: "F0F0F0")
        setLogo()
        searchTextField.delegate = self
        searchTableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "homeTableViewCell")
        searchTableView.delegate = self
    }
    
    fileprivate func setLogo() {
        let image = UIImage(named: "homelogo")
        navigationItem.titleView = UIImageView(image: image)
        
        //change textfield placeholder text color
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "청년정책을 검색해보세요",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "C4C4C5")])
        self.searchTableView.delegate = self
    }
    
    public func setLabelTextColor(sender: UILabel, count: Int) {
        let attributedText = NSMutableAttributedString(string: self.policyCountLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: "5B43EF"), range: (self.policyCountLabel.text! as NSString).range(of: "\(count)"))
        self.policyCountLabel.attributedText = attributedText
    }
    
    fileprivate func setLayout() {
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(55)
        }
        
        view.addSubview(policyCountLabel)
        policyCountLabel.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(18)
            $0.leading.equalTo(searchTextField.snp.leading)
            $0.width.equalTo(150)
        }
        
        view.addSubview(filterButton)
        filterButton.snp.makeConstraints {
//            $0.top.equalTo(policyCountLabel.snp.top)
            $0.centerY.equalTo(policyCountLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(23)
            $0.width.equalTo(75)
            $0.height.equalTo(35)
        }
        
        view.addSubview(sortPolicyButton)
        sortPolicyButton.snp.makeConstraints {
//            $0.top.equalTo(policyCountLabel.snp.top)
            $0.centerY.equalTo(policyCountLabel.snp.centerY)
            $0.trailing.equalTo(filterButton.snp.leading).offset(-14)
            $0.width.equalTo(75)
            $0.height.equalTo(35)
        }
                
        view.addSubview(searchTableView)
        searchTableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(62)
            $0.leading.trailing.equalTo(searchTextField)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
    }
    
    fileprivate func setInputBind() {
        rx.viewWillAppear.take(1).asDriver{ _ in return .never()}
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                ///유저 정보 가져오기
                //getUserInfo => selectedCategoryObserver, filteredRegionObserver 트리거
                self.viewModel.input.getUserInfo.accept(())
                ///맨처음 나의 정책 로드
                self.viewModel.input.myPolicyTrigger.accept(.mypolicy)
                self.viewModel.input.textFieldObserver.accept(" ")
                self.viewModel.input.sortActionObserver.accept(.latest) // check
                
                print("유저 카테고리: \(self.user.category)")
                print("유저 기본 지역: \(self.user.region)")
            }).disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent([.editingDidEnd])
            .map { self.searchTextField.text ?? "" }
            .bind(to: viewModel.input.textFieldObserver)
            .disposed(by: disposeBag)
        
        //검색하는 순간 나의 정책 검색이 아님
        searchTextField.rx.controlEvent([.editingDidEnd])
            .subscribe(onNext: { [weak self] in
                self?.viewModel.input.myPolicyTrigger.accept(.notMyPolicy)
//                self?.viewModel.input.loadMoreObserver.accept(true)
            })
            .disposed(by: disposeBag)
        
        //테이블 load more
        searchTableView.rx.reachedBottom(from: -25)
            .debug()
            .map { a -> Bool in return true }
            .subscribe(onNext: { a in
                print("추가로드 옵저버 true 방출")
                self.viewModel.input.loadMoreObserver.accept(true)
            }).disposed(by: disposeBag)
//            .bind(to: viewModel.input.loadMoreObserver.accept(true))
//            .disposed(by: disposeBag)
            
        sortPolicyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let alertVC = UIAlertController(title: "정렬", message: nil, preferredStyle: .actionSheet)
                //title color/font
                alertVC.setTitle(font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 18), color: UIColor(named: "000000"))
                
                let latestAction = UIAlertAction(title: "최신순", style: .default) { [weak self] action in
                    guard let self = self else { return }
                    //최신순 - 최신순 했을 때 page 0 중복 방지
                    self.viewModel.currentPage = 0
                    self.viewModel.input.loadMoreObserver.accept(false) //구독 해지됨
//                    self.viewModel.input.currentPage.accept(self.viewModel.currentPage)
                    self.viewModel.input.sortActionObserver.accept(.latest)
                    DispatchQueue.main.async {
                        self.sortPolicyButton.setImage(UIImage(named: "chip=chip4"), for: .normal)
                    }
                }
                let popularAction = UIAlertAction(title: "인기순", style: .default) { [weak self] action in
                    guard let self = self else { return }
                    self.viewModel.currentPage = 0
                    self.viewModel.input.loadMoreObserver.accept(false)
//                    self.viewModel.input.currentPage.accept(self.viewModel.currentPage)
                    self.viewModel.input.sortActionObserver.accept(.popular)
                    DispatchQueue.main.async {
                        self.sortPolicyButton.setImage(UIImage(named: "chip=chip13"), for: .normal)
                    }
                }
                let cancelAction = UIAlertAction(title: "취소", style: .destructive)
                
                latestAction.setValue(UIColor(hexString: "5B43EF"), forKey: "titleTextColor")
                popularAction.setValue(UIColor(hexString: "5B43EF"), forKey: "titleTextColor")
                alertVC.addAction(latestAction)
                alertVC.addAction(popularAction)
                alertVC.addAction(cancelAction)
                alertVC.view.layer.masksToBounds = true
                alertVC.view.layer.cornerRadius = 5
                self?.present(alertVC, animated: true)
            }).disposed(by: disposeBag)
    
        filterButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let vc = FilterViewController()
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        searchTableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                let vc = HomeDetailViewController()
                vc.initialize(id: HomeViewModel.detailId[indexPath.row])
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setOutputBind() {
        ///유저 정보 가져오기
        viewModel.output.sendUserInfo
            .subscribe(onNext: { [weak self] userInfo in
                self?.user = userInfo
            }).disposed(by: disposeBag)
        
        viewModel.output.policyResult
            .debug()
            .scan(into: [ContentsDetail]()) { contents, type in
                switch type {
                case .load(let content):
                    contents.removeAll()
                    self.selectedId.removeAll()
                    self.idIsSelected.removeAll()
                    for i in 0..<(content[0].content.count) {
                        self.selectedId.append(content[0].content[i].id ?? -1)
                        self.idIsSelected.append(content[0].content[i].isInterest)
                    }
                    contents = content[0].content
                    self.policyCountLabel.text = "\(contents.count)개의 정책 결과"
                    self.setLabelTextColor(sender: self.policyCountLabel, count: contents.count)
                    
                case .loadMore(let newContent):
//                    contents.append(newContent.content[])
                    for i in 0..<newContent.content.count {
                        contents.append(newContent.content[i])
                        print("추가된 항목: \(newContent.content[i])")
                        self.selectedId.append(newContent.content[i].id ?? -1)
                        self.idIsSelected.append(newContent.content[i].isInterest)
                    }
                    self.policyCountLabel.text = "\(contents.count)개의 정책 결과"
                    self.setLabelTextColor(sender: self.policyCountLabel, count: contents.count)
                }
            }
            .asObservable()
            .bind(to: searchTableView.rx.items(cellIdentifier: "homeTableViewCell")) { (index: Int, element: ContentsDetail, cell: HomeTableViewCell) in
                let region = (element.region?.parent?.name ?? "") + " " + (element.region?.name ?? "")
                cell.selectionStyle = .none
                cell.regionLabel.text = region
                cell.policyNameLabel.text = element.title
                cell.organizationLabel.text = element.institution ?? "미정"
                if element.isInterest {
                    cell.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
                } else {
                    cell.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                }
                
                cell.bookMarkButton.rx.tap
                    .asDriver()
                    .drive(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        if(self.idIsSelected[index]) {
                            self.viewModel.input.bookmarkDeleteObserver.accept(self.selectedId[index])
                            cell.bookMarkButton.setImage(UIImage(named: "scrap_inactive"), for: .normal)
                            self.idIsSelected[index] = false
                        } else {
                            self.viewModel.input.bookmarkObserver.accept(self.selectedId[index])
                            cell.bookMarkButton.setImage(UIImage(named: "scrap_active"), for: .normal)
                            self.idIsSelected[index] = true
                        }
                    }).disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
    }
    
}

extension HomeViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension Reactive where Base: UIScrollView {
  func reachedBottom(from space: CGFloat = 0.0) -> ControlEvent<Void> {
    let source = contentOffset.map { contentOffset in
      let visibleHeight = self.base.frame.height - self.base.contentInset.top - self.base.contentInset.bottom
      let y = contentOffset.y + self.base.contentInset.top
      let threshold = self.base.contentSize.height - visibleHeight - space
      return y >= threshold
    }
    .distinctUntilChanged()
    .filter { $0 }
    .map { _ in () }
    return ControlEvent(events: source)
  }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = searchTableView.dequeueReusableCell(withIdentifier: "homeTableViewCell", for: indexPath) as? HomeTableViewCell else { return }
        
        cell.disposeBag = DisposeBag()
    }    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}
