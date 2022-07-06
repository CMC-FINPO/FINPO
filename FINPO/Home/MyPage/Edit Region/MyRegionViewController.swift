//
//  MyRegionViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/06.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MyRegionViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: MyPageViewModel?
    
    func setViewModel(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
