//
//  CommentMoreView.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/25.
//

import Foundation
import UIKit

class CommentMoreView {
    private var viewController: UIViewController?
    
    private let moreView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray.withAlphaComponent(0.1)
        return view
    }()
    
    func setProperty() {
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
//        backgroundView.addGestureRecognizer(gesture)
    }
    
    func showView(on viewController: UIViewController, to cell: UITableViewCell) {
//        guard let targetView = viewController.view else { return }
        cell.contentView.addSubview(backgroundView)
        backgroundView.frame = cell.bounds
        
        backgroundView.addSubview(moreView)
        moreView.frame = CGRect(x: 30, y: 30, width: 100, height: 30)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        backgroundView.addGestureRecognizer(gesture)
    }

    @objc func dismissView(_ sender: UITapGestureRecognizer? = nil) {
        debugPrint("디스미스")
        UIView.animate(withDuration: 0.25) {
            self.moreView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
        }
        
    }
}
