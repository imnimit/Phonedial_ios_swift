//
//  LogoutPopupVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 10/01/23.
//

import UIKit

class LogoutPopupVc: UIViewController {
    
    @IBOutlet weak var callVW: UIView!
    @IBOutlet weak var inviteVW: UIView!
    @IBOutlet weak var mainVW: UIView!
    @IBOutlet weak var InfoImgeVW: UIView!
    
    var callData = [String:Any]()
    var nameContact = ""
    weak var delegate: goToContactDetailScreen?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
    }
    func initCall(){
        InfoImgeVW.layer.cornerRadius = InfoImgeVW.layer.bounds.height/2
        mainVW.layer.cornerRadius = 5
        callVW.layer.cornerRadius = 5
        inviteVW.layer.cornerRadius = 5
    }
    
    //MARK: btn Click
    @IBAction func btnClickInviteCall(_ sender: UIButton) {
    }
    
    @IBAction func btnClickCall(_ sender: UIButton) {
        User.sharedInstance.removeUserDetail()
        self.dismiss(animated: false,completion: { 
            appDelegate.LoginPage()
        })
    }
    
}
