/*
 * Copyright (C) 2012-2012 Teluu Inc. (http://www.teluu.com)
 * Contributed by Emre Tufekci (github.com/emretufekci)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

import UIKit
import IQKeyboardManagerSwift
import CallKit
import PushKit
import AVFAudio
import Firebase
import FirebaseCore
import FirebaseMessaging
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var hud = LottieHUD("animation_1")
    var window: UIWindow?
    var callObserver = CXCallObserver()
    var chekcOneTime = 0
    var phoneHoldCheck = false
    let callManager = CallManager()
    var providerDelegate: ProviderDelegate!
    var OneTimeCreateLib = false
    var isCallOngoing = false
    var callComePushNotification = false
    var appIsBaground = false
    let db = SQLiteDB.shared
    var pushKitTokan = ""
    var notificationTokan = ""
    var diviceID = ""
    var IncomeingCallInfo = [String:Any]()
    
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)

    var ChatTimeUserUserID = ""
    var ChatGroupID = ""
    let chatService = ChatService()
    var loginSocialMediaUsed = ""
    var timerMinCall = Timer()
    var callKitTimeShowNumber = ""
    var recentCallLogToDirectCall = ""
    var counter = 0
    var isVidoeCallIncomeing = false
    var viewdisplayView = UIView ()
    var viewwindowView = UIView()
    var isVideoCallMute = false
    var videoCallingTime = false

    static var instance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
        IQKeyboardManager.shared.enable = true
        
        let isAlready : Bool = userAlreadyExist(kUsernameKey: "isAlreadyMember")
        diviceID = UIDevice.current.identifierForVendor!.uuidString
        print(diviceID)
        

        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
            } else {
                // Show the app's signed-in state.
            }
        }
        
        
       if(isAlready) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.viewTabbarScreen()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [self] in
                self.LoginPage()
                UserDefaults.standard.set("phoneDial", forKey: "CountrySet")
            })
        }
        registerForPushNotification()
        
        let notificationSettings  = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        
        
        
        PushKitDelegate.sharedInstance.registerPushKit()
        
        navigationBarApperance()
        
        relamDataBaseLoad()
        
        
        // FB Login
        Settings.appID = "544191151038226"
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
    }
    
    func displayIncomingCall(
         uuid: UUID,
         handle: String,
         hasVideo: Bool = false,
         completion: ((Error?) -> Void)?
       ) {
         providerDelegate.reportIncomingCall(
           uuid: uuid,
           handle: handle,
           hasVideo: hasVideo,
           completion: completion)
       }
        
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        let sourceApplication: String? = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
//        let annotation: Any? = options[UIApplication.OpenURLOptionsKey.annotation]
//        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
//
//    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      /*  if let startAudioCallIntent = userActivity.interaction?.intent as? INStartAudioCallIntent {
            if let person = startAudioCallIntent.contacts?.first,
               let phoneNumber = person.personHandle?.value {
                let d: [String: Any] = [
                    "name": phoneNumber,
                    "number": phoneNumber
                ]
                recentCallLogToDirectCall = d["number"] as? String ?? ""
                
                if CPPWrapper().registerStateInfoWrapper() != false && recentCallLogToDirectCall != ""{
                   CPPWrapper.clareAllData()
                   
                   var name = "Unknown"
                   if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                       let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                       let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == recentCallLogToDirectCall.suffix(10)})
                       if index != nil {
                           appDelegate.IncomeingCallInfo = contactList[index!]
                           name = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unknown"
                       }
                   }
                   
                   let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallingDisplayVc") as! CallingDisplayVc
                   nextVC.number = recentCallLogToDirectCall
                   nextVC.phoneCode =  ""
                   nextVC.nameDisplay = name
                   nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
                   appDelegate.window?.rootViewController?.present(nextVC, animated: true)
                   recentCallLogToDirectCall = ""
               }
            }
        }
       */
        return true
    }
    
    
    func application(_ app: UIApplication,
                         open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if loginSocialMediaUsed == "FB" {
            let sourceApplication: String? = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
            let annotation: Any? = options[UIApplication.OpenURLOptionsKey.annotation]
            return ApplicationDelegate.shared.application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }else{
            return GIDSignIn.sharedInstance.handle(url)
        }
       
    }
    
    
    func relamDataBaseLoad() {
        if let url = RealmDatabaseeHelper.shared.getDatabaseURL() {
            print("Database Url",url)
        }
    }
    
    func navigationBarApperance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = #colorLiteral(red: 0.06114628166, green: 0.7453202605, blue: 0.8884316087, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance;
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBar.appearance().standardAppearance;
    }
    
    
   
    
    func viewTabbarScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarCntrl = storyboard.instantiateViewController(withIdentifier: "TabbarCntrl") as! UITabBarController
        let viewControllers = tabBarCntrl.viewControllers
        
//        tabBarCntrl.viewControllers = [viewControllers![0],viewControllers![1],viewControllers![2],viewControllers![3],viewControllers![4]]
        self.window?.rootViewController = tabBarCntrl
        
        tabBarCntrl.selectedIndex = 2
    }
    
    func LoginPage(){
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let UINavigationController = storyboard1.instantiateViewController(withIdentifier: "Nav1") as! UINavigationController
        self.window?.rootViewController = UINavigationController

        let rootNavCntrl : UINavigationController = self.window?.rootViewController as! UINavigationController
        rootNavCntrl.setNavigationBarHidden(false, animated: false)
        self.makeMyNavigationApperance(navigationCntrl: rootNavCntrl)
        
        // get your storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logInVctr = storyboard.instantiateViewController(withIdentifier: "ipjsuaLoginVc") as! ipjsuaLoginVc
        rootNavCntrl.setViewControllers([logInVctr], animated: true)
    }
    
    func makeMyNavigationApperance(navigationCntrl : UINavigationController)  {
        navigationCntrl.navigationBar.shadowImage = UIImage()
        navigationCntrl.navigationBar.isTranslucent = false
        navigationCntrl.view.backgroundColor = UIColor.white

        let yourBackImage = UIImage(named: "payment_card_background")
        navigationCntrl.navigationBar.backIndicatorImage = yourBackImage
        navigationCntrl.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        if #available(iOS 13.0, *) {
            navigationCntrl.navigationBar.backIndicatorImage?.withTintColor(UIColor.black)
        } else {
            // Fallback on earlier versions
        }
        navigationCntrl.navigationBar.topItem?.title = ""
    }
 
    func applicationWillResignActive(_ application: UIApplication) {
        isCallOngoing = false
        print("1")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        isCallOngoing = false
        print("2")
        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID]
        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.LEAVE, requestData)
        chatService.closeConnection()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        isCallOngoing = true
        print("3")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        isCallOngoing = true
        print("4")
//        chatService.establishConnection()
//        chatService.mSocket.on(clientEvent: .connect){ [self]data, ack in
//            print("socket connected")
//          
//        }
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
      
    }

    func applicationWillTerminate(_ application: UIApplication) {
        isCallOngoing = false
        
        print("5")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

extension AppDelegate {
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] (granted, error) in
                print("Permission granted: \(granted)")
                guard granted else {
                    print("Please enable \"Notifications\" from App Settings.")
                    self?.showPermissionAlert()
                    return
                }
                self?.getNotificationSettings()
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            
            DispatchQueue.main.async {
                
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    @available(iOS 10.0, *)
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "WARNING", message: "Please enable access to Notifications in the Settings app.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {[weak self] (alertAction) in
            self?.gotoAppSettings()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func gotoAppSettings() {
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.openURL(settingsUrl)
        }
    }
    
  

//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//        let tokenParts = deviceToken.map { data -> String in
//            return String(format: "%02.2hhx", data)
//        }
//
//        let token = tokenParts.joined()
//        print("Device Token: \(token)")
//        //UserDefaults.standard.set(token, forKey: DEVICE_TOKEN)
//    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    //Called if unable to register for APNS.
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
  
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
      //  CPPWrapper().createAccountWrapper("919999999999", "gggggggggg","switch.nyerhosmobile.com","5060")
        print(userInfo)
    }
    
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//
//        // If your app was running and in the foreground
//        // Or
//        // If your app was running or suspended in the background and the user brings it to the foreground by tapping the push notification
//
//        print("didReceiveRemoteNotific ation /(userInfo)")
//
//        guard let dict = userInfo["aps"]  as? [String: Any], let msg = dict ["alert"] as? String else {
//            print("Notification Parsing Error")
//            return
//        }
//    }
    
    
    func  sipRegistration() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            return
        }        
        /*if UserDefaults.standard.object(forKey: "isAlreadyMember") != nil {
            let dictValue = UserDefaults.standard.value(forKey: "isAlreadyMember") as? [String: Any]
            print(dictValue)
            if (CPPWrapper().registerStateInfoWrapper() == false) {
                HelperClassAnimaion.showProgressHud()
                
                if OneTimeCreateLib == false {
                    do {
                        CPPWrapper().createLibWrapper(Constant.GlobalConstants.PORT, "1")
                    } catch {
                        return
                    }
                }
                OneTimeCreateLib = true
                
                CPPWrapper().incoming_call_wrapper(incoming_call_swift)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    if (CPPWrapper().registerStateInfoWrapper() == false) {
                        //Register to the user
                        CPPWrapper().createAccountWrapper(
                            User.sharedInstance.getContactNumber(),
                            User.sharedInstance.getsipPassWord(),
                            Constant.GlobalConstants.SERVERNAME,
                            Constant.GlobalConstants.PORT)

                        sleep(2)
                        HelperClassAnimaion.hideProgressHud()

                        CPPWrapper.showCodecs()

                    }
                })
            }
        }*/
        
        if UserDefaults.standard.object(forKey: "isAlreadyMember") != nil {
            if (CPPWrapper().registerStateInfoWrapper() == false) {
                HelperClassAnimaion.showProgressHud()
                
                if OneTimeCreateLib == false {
                    do {
                        CPPWrapper().createLibWrapper(Constant.GlobalConstants.PORT, "1")
                    } catch {
                        return
                    }
                }
                
                OneTimeCreateLib = true
                
                CPPWrapper().incoming_call_wrapper(incoming_call_swift)
                CPPWrapper().update_video_wrapper(update_video_swift)
                CPPWrapper().call_listener_wrapper(call_status_listener_swift)
                //                CPPWrapper().update_video_wrapper(update_video_swift)
                
                //Register to the user
                CPPWrapper().createAccountWrapper(
                    User.sharedInstance.getContactNumber(),
                    User.sharedInstance.getsipPassWord(),
                    Constant.GlobalConstants.SERVERNAME,
                    Constant.GlobalConstants.PORT)
                HelperClassAnimaion.hideProgressHud()
                
                if recentCallLogToDirectCall != "" {
                    CPPWrapper.clareAllData()
                    
                    var name = "Unknown"
                    if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                        let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                        let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == recentCallLogToDirectCall.suffix(10)})
                        if index != nil {
                            appDelegate.IncomeingCallInfo = contactList[index!]
                            name = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unknown"
                        }
                    }
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallingDisplayVc") as! CallingDisplayVc
                    nextVC.number = recentCallLogToDirectCall
                    nextVC.phoneCode =  ""
                    nextVC.nameDisplay = name
                    nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
                    appDelegate.window?.rootViewController?.present(nextVC, animated: true)
                    recentCallLogToDirectCall = ""
                }
            }
        }
    }
}
extension AppDelegate {
    func loadCallerController(checkLockOrUnlock:Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcToPresent = storyboard.instantiateViewController(withIdentifier: "CallingDisplayVc") as! CallingDisplayVc
        vcToPresent.incomingCallId = CPPWrapper().incomingCallInfoWrapper()
        vcToPresent.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        vcToPresent.isDeviceLock = checkLockOrUnlock
        appDelegate.window?.rootViewController?.present(vcToPresent, animated: false)
    }
    
    func loadvideoCall(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "dialpadVc")
        let topVC = topMostController()
        let vcToPresent = vc.storyboard!.instantiateViewController(withIdentifier: "VideoCallWaitVc") as! VideoCallWaitVc
        vcToPresent.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        vcToPresent.incomingCallId  = CPPWrapper().incomingCallInfoWrapper()
        vcToPresent.mainTitle = "Incomeing Call"
        vcToPresent.calldireactAns = true
        topVC.present(vcToPresent, animated: true, completion: nil)
    }
}




extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        notificatoinCounter(coutString: userInfo["status"] as! String)
        
//        if tripStartOrNotCheck == 1 {
//            let bodynotifi = notification.request.content.body as? String
//            print("====================\(bodynotifi)===============================")
//            window?.rootViewController?.showAlert(withTitle: "Fr8bukyn", message: bodynotifi ?? "")
//        }
        
//        let state : UIApplication.State = application.applicationState
//        if (state == .inactive || state == .background) {
//            // go to screen relevant to Notification content
//            print("background")
//        } else {
//            // App is in UIApplicationStateActive (running in foreground)
//            print("foreground")
//            showLocalNotification()
            completionHandler([.alert, .badge, .sound])
//        }
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        // when app is onpen and in foregroud
//        completionHandler(.alert)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        // get the notification identifier to respond accordingly
//        let identifier = response.notification.request.identifier
//
//        // do what you need to do
//        print(identifier)
//        // ...
//    }
            
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo["fr8id"]!)
        print(userInfo["status"]!)
//        notificatoinCounter(coutString: userInfo["status"] as! String)
    }
    
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler:@escaping (UIBackgroundFetchResult) -> Void) {
        
        let state : UIApplication.State = application.applicationState
        if (state == .inactive || state == .background) {
            // go to screen relevant to Notification content
            print( "background")
        } else {
            // App is in UIApplicationStateActive (running in foreground)
            print( "foreground")
           // showLocalNotification()
        }
    }

    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if #available(iOS 13.0, *) {
            print("===================================")
            print(getStringFrom(deviceToken: deviceToken))
        } else {
            let tokenData = deviceToken as NSData
            let token = "\(tokenData)".replacingOccurrences(of: " ", with: "")
                                      .replacingOccurrences(of: "<", with: "")
                                      .replacingOccurrences(of: ">", with: "")
            
            print(token)
        }
    }
    
    func getStringFrom(deviceToken: Data) -> String {
        var token = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        return token
    }
    

    
    
/// Register for push notifications
    func registerForPushNotification() {
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
//            notificationCenter = UNUserNotificationCenter.current()
//            notificationCenter.delegate = self
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            //          application.registerUserNotificationSettings(settings)
        }
        Messaging.messaging().delegate = self
        
        UIApplication.shared.registerForRemoteNotifications()
    }
}
extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
           // Check for error. Otherwise do what you will with token here
            if let error = error {
                print( "Error fetching remote instance ID: \(error)")
            } else if token != nil {
                print( "Remote instance ID token: \(token!)")
                let fcmToken = token!
                self.notificationTokan = fcmToken
//                fcmTokenpass = fcmToken!
//                userDefaults.setValue(fcmTokenpass, forKey: "fcmToken")
            }
        }
    }
}


extension AppDelegate {
    func showHUD(progressLabel:String) {
        hud.showHUD()
    }
    
    func showHUD(progressLabel:String,showOn: UIView) {
        hud.stopHUD()
    }
    
    func removeHUD(showOn: UIView) {
        hud.stopHUD()
    }
    
    func dismissHUD(isAnimated:Bool) {
        hud.stopHUD()
    }
}
extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print("\(#function) voip token: \(credentials.token)")
        
        let deviceToken = credentials.token.reduce("", {$0 + String(format: "%02X", $1) })
        print("\(#function) token is: \(deviceToken)")
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        
//        print("\(#function) incoming voip notfication: \(payload.dictionaryPayload)")
        let callData = payload.dictionaryPayload

        let aps = callData["aps"] as! [String:Any]
        let alert = aps["alert"] as! [String:Any]
        
//        let uuidString = UUID()
        let handle = (alert["subtitle"] as? String ?? "")
        let uuid = UUID()
        
        OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
        
        // display incoming call UI when receiving incoming voip notification
        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        self.displayIncomingCall(uuid: uuid, handle: handle, hasVideo: false) { _ in
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("\(#function) token invalidated")
    }
        
    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
    }
    
    
}
