//
//  CommunityWritingViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/09/27.
//

import Foundation
import UIKit

class CommunityWritingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
