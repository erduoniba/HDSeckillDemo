//
//  AppDelegate.swift
//  HDSeckillDemo
//
//  Created by denglibing on 2022/10/11.
//

import UIKit

import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 通知step1 App启动提示用户授权通知权限
        debugPrint("通知step1 App启动提示用户授权通知权限 start")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { isGrand, error in
            if isGrand {
                debugPrint("通知step1 App启动提示用户授权通知权限，用户授权通知")
                // 通知step2 授权后请求获取得到DeviceToken(主工程调用)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    // 设置代理，具体看 UNUserNotificationCenterDelegate 的代理方法
                    UNUserNotificationCenter.current().delegate = self
                }
                debugPrint("通知step2 授权后请求获取得到DeviceToken")
            }
            else {
                debugPrint("通知step1 App启动提示用户授权通知权限，用户不授权通知： end")
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // 通知step3 用户同意通知权限后，获取得到的deviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint("通知step3 用户同意通知权限后，获取得到的deviceToken：\(String(data: deviceToken, encoding: .utf8) ?? "")")
    }
    
    // 通知step3 获取deviceToken失败
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Try again later.
        debugPrint("通知step3 获取deviceToken失败: \(error.localizedDescription)")
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    // 通知step4 收到后台点击进入App的推送消息
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugPrint("通知step4 收到后台点击进入App的推送消息: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
    // 通知step4 收到前台的推送消息
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("通知step4 收到前台的推送消息: \(notification.request.content.userInfo)")
    }
}
