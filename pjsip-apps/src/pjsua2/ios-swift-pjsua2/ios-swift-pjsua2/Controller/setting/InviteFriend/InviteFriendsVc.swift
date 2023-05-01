//
//  InviteFriendsVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 16/12/22.
//

import UIKit

class InviteFriendsVc: UIViewController {

    @IBOutlet weak var sharVW: UIView!
    @IBOutlet weak var lblLink: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constant.ViewControllerTitle.InviteFriends
        lblLink.text = User.sharedInstance.getrefurlUrl()
        initCall()
    }
    
    func initCall(){
        sharVW.layer.cornerRadius = sharVW.layer.bounds.height/2
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    
    //MARK: - btn Click
    @IBAction func btnCopyText(_ sender: UIButton) {
        UIPasteboard.general.string = User.sharedInstance.getrefurlUrl()
    }
    
    @IBAction func btnSharLinck(_ sender: UIButton) {
        if let urlStr = NSURL(string: Constant.GlobalConstants.LinkApp) {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSharToContect(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactsVc") as! ContactsVc
        nextVC.isFavoriteBtnShow = false
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
