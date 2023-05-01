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
//import IQKeyboardManagerSwift
import CallKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CXCallObserverDelegate {
  
    var window: UIWindow?
    var callObserver = CXCallObserver()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

//        let isAlready : Bool = userAlreadyExist(kUsernameKey: "isAlreadyMember")
//        if(isAlready) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//                self.viewTabbarScreen()
//            })
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.LoginPage()
//            })
//        }

        callObserver.setDelegate(self, queue: nil)

//        IQKeyboardManager.shared.enable = true
        
        return true
    }
    
    @objc func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall)
    {
        if call.isOutgoing == true && call.hasConnected == false && call.hasEnded == false {
            //.. 1. detect a dialing outgoing call
          }
          if call.isOutgoing == true && call.hasConnected == true && call.hasEnded == false {
            //.. 2. outgoing call in process
          }
          if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            //.. 3. incoming call ringing (not answered)
          }
          if call.isOutgoing == false && call.hasConnected == true && call.hasEnded == false {
            //.. 4. incoming call in process
          }
          if call.isOutgoing == true && call.hasEnded == true {
            //.. 5. outgoing call ended.
          }
          if call.isOutgoing == false && call.hasEnded == true {
            //.. 6. incoming call ended.
          }
          if call.hasConnected == true && call.hasEnded == false && call.isOnHold == false {
            //.. 7. call connected (either outgoing or incoming)
          }
          if call.isOutgoing == true && call.isOnHold == true {
            //.. 8. outgoing call is on hold
          }
          if call.isOutgoing == false && call.isOnHold == true {
            //.. 9. incoming call is on hold
          }
    }
    
    
    func viewTabbarScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarCntrl = storyboard.instantiateViewController(withIdentifier: "TabbarCntrl") as! UITabBarController
        let viewControllers = tabBarCntrl.viewControllers
        tabBarCntrl.viewControllers = [viewControllers![0],viewControllers![1],viewControllers![2],viewControllers![3],viewControllers![4]]
        self.window?.rootViewController = tabBarCntrl
    }
    
    func LoginPage(){
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
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
   
}
