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
            }).disposed(by: disposeBag)
        
        //최초 load
        searchTextField.rx.controlEvent([.editingDidEnd])
            .map { self.searchTextField.text ?? "" }
            .bind(to: viewModel.input.textFieldObserver)
            .disposed(by: disposeBag)
        
        //테이블 load more
        searchTableView.rx.reachedBottom()
            .debug()
            .bind(to: viewModel.input.loadMoreObserver)
            .disposed(by: disposeBag)
            
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
//                    contents.append(newContent.content)
                    for i in (newContent.content.count%5)..<newContent.content.count {
                        contents.append(newContent.content[i])
                        print("추가된 항목: \(newContent.content[i])")
                    }
                }
            }
            .asObservable()
            .bind(to: searchTableView.rx.items(cellIdentifier: "homeTableViewCell")) { (index: Int, element: ContentsDetail, cell: HomeTableViewCell) in
//                let region = (element.content[index].region?.parent.name ?? "") + ( element.content[index].region?.name ?? "")
                
                let region = (element.region?.parent.name ?? "") + (element.region?.name ?? "")
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
