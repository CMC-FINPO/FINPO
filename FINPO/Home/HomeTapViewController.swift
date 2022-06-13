//
//  HomeTapViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/13.
//

import Foundation
import UIKit

class HomeTapViewController: UITabBarController {
    
    private var myPageViewController: UIViewController = {
        let vc = UINavigationController(rootViewController: MyPageViewController())
        let tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(named: "mypage_inactive"),
            selectedImage: UIImage(named: "mypage_active")
        )
        vc.tabBarItem = tabBarItem
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [myPageViewController]
    }

}
