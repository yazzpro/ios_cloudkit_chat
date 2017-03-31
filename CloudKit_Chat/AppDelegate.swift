//
//  AppDelegate.swift
//  CloudKit_Chat
//
//  Created by Jarosław Pawlak on 13.03.2017.
//  Copyright © 2017 Jarosław Pawlak. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                application.registerForRemoteNotifications()
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
         var notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
         var cloud = CloudController()
        
        if application.applicationState != UIApplicationState.active && notification.recordFields != nil
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: ChatController = storyboard.instantiateViewController(withIdentifier: "ChatController") as! ChatController;
            if let controller = window?.rootViewController as? UINavigationController
            {
               
                cloud.fetchCurrentUser(callback: { (user) in
                    cloud.fetchPublicUserRecord(recordId: CKRecordID( recordName: notification.recordFields?["from"] as! String), callback: { (other) in
                        viewController.otherPerson = other
                        viewController.currentUser = user
                        controller.popToRootViewController(animated: false)
                        controller.pushViewController(viewController, animated: false)

                        
                    })
                    
                })
            }
            
        }
        else if application.applicationState == .active
        {
            if notification.recordFields != nil
            {
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IncomingMessage"), object: nil, userInfo: notification.recordFields)
            }
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadPhoto"), object: nil, userInfo: nil)

            }
        }
        
       
        var recordId = notification.recordFields?["from"]
        
        // Access the storyboard and fetch an instance of the view controller
       
        completionHandler(UIBackgroundFetchResult.newData)
       
        
        
    }

}

