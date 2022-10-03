//
//  EditCommentViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/10/03.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class EditCommentViewController: UIViewController {
    
    let viewModel: EditCommentViewModelType
    let disposeBag = DisposeBag()
    let data: CommentContentDetail?
    
    init(viewModel: EditCommentViewModelType = EditCommentViewModel(), data: CommentContentDetail) {
        self.viewModel = viewModel
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = EditCommentViewModel()
        data = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
        setLayout()
        setInputBind()
        setOutputBind()
    }
    
    private func setAttribute() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setInputBind() {
        let firstLoad = rx.viewWillAppear.asDriver { _ in return .never()}
            .drive(onNext: { [weak self] _ in
                //MARK: TODO SET Data
//                self?.viewModel
            }).disposed(by: disposeBag)
    }
    
    private func setOutputBind() {
        
    }
}
