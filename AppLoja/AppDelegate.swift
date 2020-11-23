//
//  AppDelegate.swift
//  AppLoja
//
//  Created by Lucas Mengarda on 28/01/20.
//  Copyright © 2020 Lucas Mengarda. All rights reserved.
//

import UIKit
import Parse
import PopupDialog
import AudioToolbox
import FBSDKCoreKit
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "yAfaruGpF739WZrajDcTBs0ebcvZeVrWee9JcHda"
            $0.clientKey = "7LbXWjeze41bZr6iWCJSZioqDyfQt5abjYDxZtJv"
            $0.server = "https://parseapi.back4app.com"
        }
        
        Parse.initialize(with: configuration)
        PFUser.enableRevocableSessionInBackground()
        PFUser.enableAutomaticUser()
        
        let types : UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: types) { (accepted, error) in
            
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        if let launchOptions = launchOptions{
            if let notificationDictionary = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification]{
                self.application(application, didReceiveRemoteNotification: notificationDictionary as! [AnyHashable : Any])
            }
        }
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(inBackground: launchOptions, block: nil)
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        BranchScene.shared().initSession(launchOptions: launchOptions, registerDeepLinkHandler: { (params, error, scene) in
            if let params = params {
                processarDeeplink(.branch, params: params, nil)
            }
        })
        
        //FBAdSettings.setAdvertiserTrackingEnabled(true)
        
        return true;
    }
              
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
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

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let currentInstallation = PFInstallation.current()
        if PFUser.current() != nil{
            currentInstallation?["user"] = PFUser.current()
        }
        currentInstallation?.setDeviceTokenFrom(deviceToken as Data?)
        currentInstallation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications:  \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("didReceiveRemoteNotification")
        print(userInfo)
        
        var limveApp : UIWindow?
        limveApp = UIApplication.shared.keyWindow
        
        var appTopController = limveApp?.rootViewController
        
        if (appTopController?.presentedViewController != nil){
            appTopController = limveApp?.rootViewController?.presentedViewController
        }
        
        if (UIApplication.shared.applicationState == .inactive){
            //INATIVO
            print("Inactive Notification")
            PFPush.handle(userInfo)
        } else if (UIApplication.shared.applicationState == .background) {
            //BACKGROUND..
            print("Background Notification")
            PFPush.handle(userInfo)
        } else {
            //APP ABERTO
            print("App aberto")
            
            let alertDic = userInfo["aps"] as! [String : Any]
            
            if (alertDic["alert"] != nil){
                
                //Mensagem
                var body = ""
                var title = "Notificação para você!"
                
                if (alertDic["alert"] is [String : Any]){
                    body = (alertDic["alert"] as! [String : Any])["body"] as! String
                    title = (alertDic["alert"] as! [String : Any])["title"] as! String
                } else {
                    body = (alertDic["alert"] as! String)
                }
                
                print("body: \(body)")
                print("title: \(title)")
                
                //-------------------/--------------------//
                
                let popup = PopupDialog(title: title, message: body)
                popup.buttonAlignment = .horizontal
                popup.transitionStyle = .zoomIn
                let button = CancelButton(title: "Ok", action: {
                })
                popup.addButton(button)
                // Present dialog
                appTopController?.present(popup, animated: true, completion: nil)
                
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }

}

