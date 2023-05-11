//
//  HelperClassAnimaion.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 03/01/23.
//

import Foundation
import UIKit

class HelperClassAnimaion: NSObject {
    
    static func showProgressHud() {
        appDelegate.showHUD(progressLabel: "Loading...")
    }
    
    static func showProgressHud(showView : UIView)  {
        appDelegate.showHUD(progressLabel: "Loading...", showOn: showView)
    }
    
    static func removeProgressHud(showView : UIView)  {
        appDelegate.removeHUD(showOn: showView)
    }
    
    static func hideProgressHud()  {
        DispatchQueue.main.async {
            appDelegate.hud.stopHUD()
        }
    }
}
