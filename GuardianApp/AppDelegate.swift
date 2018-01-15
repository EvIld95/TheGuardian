//
//  AppDelegate.swift
//  GuardianApp
//
//  Created by Paweł Szudrowicz on 23.11.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import RxSwift



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var receivedNotification = Variable<String>("")
    var inBackground = Variable<Bool>(false)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //IQKeyboardManager.sharedManager().enable = true
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            guard error == nil else { return }
        }
        
        application.registerForRemoteNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
        UINavigationBar.appearance().barTintColor = UIColor.orange
        //print("FCMTOKEN: ", Messaging.messaging().fcmToken!)
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = false
        inBackground.value = true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        inBackground.value = false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBHandler()
    }
    
    @objc func refreshToken(notification: NSNotification) {
        let refreshToken = InstanceID.instanceID().token()!
        print("*** \(refreshToken) ***")
        FBHandler()
    }
    
    func FBHandler() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Received: \(userInfo)")
        let value = userInfo["aps"]
        if let dict = value as? Dictionary<String,String> {
            //print("Remote notification \(dict["alert"]!)")
            receivedNotification.value = dict["alert"]!
        }
        else if let dict = userInfo["aps"] as? Dictionary<String, Dictionary<String, String>> {
            if let innerDict = dict["alert"] {
                receivedNotification.value = innerDict["title"]!
            }
        }
        
    }

}

