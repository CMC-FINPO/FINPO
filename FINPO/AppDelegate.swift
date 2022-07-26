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
import AuthenticationServices
import Firebase
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let googleSiginInConfig = GIDConfiguration.init(clientID: "845892149030-nb47tiirkmtqmgs34f7klha903pip0g2.apps.googleusercontent.com")
    
    ///APNs 성공/실패 함수
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register for notifications: \(error.localizedDescription)")
//
//    }
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
//
//        //서버로 이 토큰을 보내는가?(디바이스토큰 / FCM 토큰이 있는데 여기선 디바이스 토큰 UserDefaults 저장)
//        let token = tokenParts.joined()
//        UserDefaults.standard.setValue(token, forKey: "fcmToken")
//        print("Device Token: \(token)")
//
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var window: UIWindow?
        KakaoSDK.initSDK(appKey: "a9fd79ba4b7f4e57f0a867113df50302")
        
        ///FCM
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        registerRemoteNotification()
        
        ///APNs
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current()
//            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
//                print("APNs permission granted: \(granted)")
//            }
        
        ///APNs 등록
//        application.registerForRemoteNotifications()        

        //GID 사용자의 로그인 상태 복원 시도
        GoogleSignIn.GIDSignIn.sharedInstance.restorePreviousSignIn { (user, error) in
            if error != nil || user == nil {
                //Show the app's signed-out state
                return
            } else {
                //Show the app's signed-in state

            }
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: "c27788904329f48749f60d6edf4967b1b.0.rxtv.uq8kf6GupklTTDAEJWo5fw") { credentialState, error in
            switch credentialState {
                ///회원가입된 상태면 로그인
            case .authorized:
                print("해당 애플 ID는 연동되어 있습니다.")
                let rootVC = LoginViewController()
                let navVC = UINavigationController(rootViewController: rootVC)
                window?.rootViewController = navVC
                window?.makeKeyAndVisible()
            case .revoked, .notFound:
                DispatchQueue.main.async {
                    print("애플 ID revoked or notFound in your system")
                    let rootVC = LoginViewController()
                    let navVC = UINavigationController(rootViewController: rootVC)
                    window?.rootViewController = navVC
                    window?.makeKeyAndVisible()
                }
            default:
                break
            }
        }
        return true
    }
    
    ///FCM
    private func registerRemoteNotification() {
        ///APN에 디바이스 등록 및 사용자 권한 받기
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) { granted, _ in
            // 1. APNs에 device token 등록 요청
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            ///허가 유무 저장
            UserDefaults.standard.setValue(granted, forKey: "FCMpermission")
            print("허가 유무: \(granted)")
        }
    }
    
//    ///FCM
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//    }
    
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

    //세로모드 고정
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

}

///FCM
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound])
    }
    
    ///푸시를 클릭했을 때 실행되는 햄수
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

///FCM
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        UserDefaults.standard.setValue(fcmToken, forKey: "fcmToken")
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        //TODO: if necessary send token to application server
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //TODO: Handle data of notification
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
