//
//  HomeTapViewController.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/13.
//

import Foundation
import UIKit

final class HomeTapViewController: UITabBarController {    
    private var homeViewController: UIViewController = {
        let vc = UINavigationController(rootViewController: HomeViewController())
        let tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(named: "home_inactive"),
            selectedImage: UIImage(named: "home_active")?.withRenderingMode(.alwaysOriginal)
        )
        ///탭바 타이틀 컬러 변경
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.G04]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.P01]
        
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarItem.standardAppearance = tabBarAppearance
        tabBarItem.scrollEdgeAppearance = tabBarAppearance
        vc.tabBarItem = tabBarItem
        return vc
    }()
    
    private var communityMainViewController: UIViewController = {
        let vc = UINavigationController(rootViewController: CommunityMainViewController())
        let tabBarItem = UITabBarItem(
            title: "커뮤니티",
            image: UIImage(named: "community_inactive")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "community_active")?.withRenderingMode(.alwaysOriginal)
        )
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.G04]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.P01]

        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarItem.standardAppearance = tabBarAppearance
        tabBarItem.scrollEdgeAppearance = tabBarAppearance
        vc.tabBarItem = tabBarItem
        return vc
    }()
    
    private var myPageViewController: UIViewController = {
        let vc = UINavigationController(rootViewController: MyPageViewController())
        let tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(named: "mypage_inactive")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "mypage_active")?.withRenderingMode(.alwaysOriginal)
        )
        
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.G04]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.P01]

        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarItem.standardAppearance = tabBarAppearance
        tabBarItem.scrollEdgeAppearance = tabBarAppearance
        vc.tabBarItem = tabBarItem
        return vc
    }()
    
    private var bookmarkViewController: UIViewController = {
        let vc = UINavigationController(rootViewController: BookmarkViewController())
        let tabBarItem = UITabBarItem(
            title: "북마크",
            image: UIImage(named: "scrap_inactive_tap")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "scrap_active")?.withRenderingMode(.alwaysOriginal)
        )
        
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.G04]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.P01]

        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarItem.standardAppearance = tabBarAppearance
        tabBarItem.scrollEdgeAppearance = tabBarAppearance
        vc.tabBarItem = tabBarItem
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [homeViewController, communityMainViewController ,bookmarkViewController, myPageViewController]
    }

}
