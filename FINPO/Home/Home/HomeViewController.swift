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
    
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    
    private var dataSource = [ContentsDetail]()
    private var currenetPage = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
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
        return tv
    }()
    
    fileprivate func setAttribute() {
        view.backgroundColor = UIColor(hexString: "F0F0F0")
        setLogo()
        searchTextField.delegate = self
        searchTableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "homeTableViewCell")
        
    }
    
    fileprivate func setLogo() {
        let image = UIImage(named: "homelogo")
        navigationItem.titleView = UIImageView(image: image)
        
        //change textfield placeholder text color
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "청년정책을 검색해보세요",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "C4C4C5")])
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
            $0.top.equalTo(searchTextField.snp.bottom).offset(14)
            $0.leading.equalTo(searchTextField.snp.leading)
            $0.width.equalTo(100)
        }
        
        view.addSubview(filterButton)
        filterButton.snp.makeConstraints {
            $0.top.equalTo(policyCountLabel.snp.top)
            $0.trailing.equalToSuperview().inset(23)
            $0.width.equalTo(75)
            $0.height.equalTo(35)
        }
        
        view.addSubview(sortPolicyButton)
        sortPolicyButton.snp.makeConstraints {
            $0.top.equalTo(policyCountLabel.snp.top)
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
                self?.viewModel.input.textFieldObserver.accept(" ")
                self?.viewModel.input.sortActionObserver.accept(.latest)
            }).disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent([.editingDidEnd])
            .map { self.searchTextField.text ?? "" }
            .bind(to: viewModel.input.textFieldObserver)
            .disposed(by: disposeBag)
        
        //테이블 load more
        searchTableView.rx.reachedBottom(from: -25)
            .debug()
            .bind(to: viewModel.input.loadMoreObserver)
            .disposed(by: disposeBag)
            
        sortPolicyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let alertVC = UIAlertController(title: "정렬", message: nil, preferredStyle: .actionSheet)
                //title color/font
                alertVC.setTitle(font: UIFont(name: "AppleSDGothicNeo-Semibold", size: 18), color: UIColor(named: "000000"))
                
                let latestAction = UIAlertAction(title: "최신순", style: .default) { [weak self] action in
                    guard let self = self else { return }
                    //최신순 - 최신순 했을 때 page 0 중복 방지
                    self.viewModel.currentPage = 0
                    self.viewModel.input.currentPage.accept(self.viewModel.currentPage)
                    self.viewModel.input.sortActionObserver.accept(.latest)
                    DispatchQueue.main.async {
                        self.sortPolicyButton.setImage(UIImage(named: "chip=chip4"), for: .normal)
                    }
                }
                let popularAction = UIAlertAction(title: "인기순", style: .default) { [weak self] action in
                    guard let self = self else { return }
                    self.viewModel.currentPage = 0
                    self.viewModel.input.currentPage.accept(self.viewModel.currentPage)
                    self.viewModel.input.sortActionObserver.accept(.popular)
                    DispatchQueue.main.async {
                        self.sortPolicyButton.setImage(UIImage(named: "chip=chip13"), for: .normal)
                    }
                }
                latestAction.setValue(UIColor(hexString: "5B43EF"), forKey: "titleTextColor")
                popularAction.setValue(UIColor(hexString: "5B43EF"), forKey: "titleTextColor")
                alertVC.addAction(latestAction)
                alertVC.addAction(popularAction)
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
    }
    
    fileprivate func setOutputBind() {
//        viewModel.output.textFieldResult
//            .map { $0.content }
//            .debug()
//            .asObservable()
//            .bind(to: searchTableView.rx.items(cellIdentifier: "homeTableViewCell")) {
//                (index: Int, element: ContentsDetail, cell: HomeTableViewCell) in
//                let region = (element.region?.parent.name ?? "") + ( element.region?.name ?? "")
//
//                cell.regionLabel.text = region
//                cell.policyNameLabel.text = element.title
//                cell.organizationLabel.text = element.institution ?? "미정"
//            }.disposed(by: disposeBag)
        
        viewModel.output.policyResult
            .debug()
            .scan(into: [ContentsDetail]()) { contents, type in
                switch type {
                case .load(let content):
                    contents = content[0].content
                case .loadMore(let newContent):
//                    contents.append(newContent.content[])
                    for i in 0..<newContent.content.count {
                        contents.append(newContent.content[i])
                        print("추가된 항목: \(newContent.content[i])")
                    }
                }
            }
            .asObservable()
            .bind(to: searchTableView.rx.items(cellIdentifier: "homeTableViewCell")) { (index: Int, element: ContentsDetail, cell: HomeTableViewCell) in
                let region = (element.region?.parent?.name ?? "") + (element.region?.name ?? "")
                cell.regionLabel.text = region
                cell.policyNameLabel.text = element.title
                cell.organizationLabel.text = element.institution ?? "미정"
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
