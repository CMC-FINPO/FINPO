//
//  NestCommentView.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/24.
//

import Foundation
import UIKit
import SnapKit

class NestCommentView {
    private let nestView: UIView = {
        let view = UIView()
        view.backgroundColor = .G08
        return view
    }()
    
    private var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .G03
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        return label
    }()
    
    private let nestCancleBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "delete_gray")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private var viewModel: CommunityDetailViewModel?
    private var pageId: Int?
    
    func setProperty(_ nickName: String, _ viewModel: CommunityDetailViewModel, pageId: Int) {
        self.viewModel = viewModel
        self.pageId = pageId
        textLabel.text = "\(nickName)님에게 답글 남기는 중..."
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        nestCancleBtn.addGestureRecognizer(gesture)
    }
    
    func showView(on viewController: UIViewController, _ sizeView: CGFloat) {
        guard let targetView = viewController.view else { return }
        targetView.addSubview(nestView)
        nestView.frame = CGRect(x: 0, y: sizeView + 20, width: targetView.frame.width, height: 30)
        nestView.addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
        }
        nestView.addSubview(nestCancleBtn)
        nestCancleBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(5)
            $0.width.height.equalTo(17)
        }
        
    }
    
    @objc func dismissView(_ sender: UITapGestureRecognizer? = nil) {
        //대댓글 취소버튼을 누르면 일반 댓글로 남겨야 함
        guard let viewModel = viewModel, let pageId = pageId else {
            return
        }
        viewModel.input.isNestedObserver.accept(.comment(id: pageId))
        UIView.animate(withDuration: 0.25) {
            self.nestView.removeFromSuperview()
        }
    }
    
}
