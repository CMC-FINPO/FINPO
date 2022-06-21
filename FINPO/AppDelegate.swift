//
//  AppDelegate.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/02.
//

import UIKit
import KakaoSDKCommon
import RxKakaoSDKAuth
import KakaoSDKAuth
import GoogleSignIn


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
//    public static var user: GIDGoogleUser!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        KakaoSDK.initSDK(appKey: "a9fd79ba4b7f4e57f0a867113df50302")
        
//        let signInConfig = GIDConfiguration(clientID: "845892149030-nb47tiirkmtqmgs34f7klha903pip0g2.apps.googleusercontent.com")

        //GID 사용자의 로그인 상태 복원 시도
        GoogleSignIn.GIDSignIn.sharedInstance.restorePreviousSignIn { (user, error) in
            if error != nil || user == nil {
                //Show the app's signed-out state
                return
            } else {
                //Show the app's signed-in state
            }
        }
        return true
    }
    
    //구글 로그인 요청이 들어왔을 때 로그인 화면 로드 함수
    //인증 리디렉션 URL 처리
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        var handled: Bool
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
       
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
       
    }


}

