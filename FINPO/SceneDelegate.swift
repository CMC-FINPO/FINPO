//
//  SceneDelegate.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/02.
//

import UIKit
import KakaoSDKAuth
import RxKakaoSDKAuth
import KakaoSDKCommon

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        KakaoSDK.initSDK(appKey: "a9fd79ba4b7f4e57f0a867113df50302")
        self.window = UIWindow(windowScene: windowScene)
        
        ///string -> object 수정
        let acToken = KeyChain.read(key: KeyChain.accessToken)
        print("acToken: \(acToken)")
        
        if(acToken != nil) {
            let rootVC = HomeTapViewController()
            window?.rootViewController = rootVC
            window?.makeKeyAndVisible()
        } else {
            if(UserDefaults.standard.object(forKey: "isOnboarding") == nil) {
                let rootVC = OnBoardingViewController()
                window?.rootViewController = rootVC
                window?.makeKeyAndVisible()
            } else {
                let rootVC = LoginViewController()
                let navVC = UINavigationController(rootViewController: rootVC)
                window?.rootViewController = navVC
                window?.makeKeyAndVisible()
            }
        }

        
//        let rootVC = LoginDetailViewController()
//        let rootVC = LoginBasicInfoViewController()
//        let rootVC = LoginRegionViewController()
//        let rootVC = LoginInterestViewController()
//        let rootVC = LoginSemiCompleteViewController()
//        let rootVC = HomeTapViewController()
//        let rootVC = AddRegionViewController()
//        let rootVC = AddPurposeViewController()
//        let rootVC = HomeDetailViewController()
//        let rootVC = AlarmViewController()
//        let navVC = UINavigationController(rootViewController: rootVC)
        
//        window?.rootViewController = rootVC
//        window?.rootViewController = navVC
//        window?.makeKeyAndVisible()

    }
    
    //add kakao login
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
//                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
       
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
       
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }


}

