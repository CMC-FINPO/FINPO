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
    }
}
