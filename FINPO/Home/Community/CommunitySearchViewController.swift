//
//  CommunitySearchViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/02.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CommunitySearchViewController: UIViewController {
    
    let viewModel: CommunitySearchViewModelType
    let disposeBag = DisposeBag()
    
    init(viewModel: CommunitySearchViewModelType = CommunitySearchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = CommunitySearchViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private lazy var searchBar: UISearchBar = {
        var bounds = UIScreen.main.bounds
        var width = bounds.size.width
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: width-28, height: 0))
        searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "제목이나 내용을 검색해주세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.G05])
        searchBar.searchTextField.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        searchBar.searchTextField.backgroundColor = UIColor.G08
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.layer.cornerRadius = 7
        searchBar.searchTextField.layer.borderColor = UIColor.G06.cgColor
        searchBar.searchTextField.layer.borderWidth = 1
        return searchBar
    }()
    
    private var resultTableView: UITableView = {
        let resultTableView = UITableView()
        resultTableView.backgroundColor = UIColor.G09
        resultTableView.rowHeight = CGFloat(150)
        resultTableView.separatorInset.left = 0
        return resultTableView
    }()
    
    private func setAttribute() {
        view.backgroundColor = UIColor.G09
        //textfield in NavigationItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
    }
    
    private func setLayout() {
        view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setInputBind() {
        
    }
    
    private func setOutputBind() {
        
    }
}

extension CommunitySearchViewController: UITextFieldDelegate {
    
}
