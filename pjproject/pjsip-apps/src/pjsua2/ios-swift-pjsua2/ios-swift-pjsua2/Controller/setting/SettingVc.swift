//
//  SettingVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 15/12/22.
//

import UIKit

class SettingVc: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var btnAddFund: UIButton!
    @IBOutlet weak var lblVoletBelance: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSharAppLink: UILabel!
    @IBOutlet weak var btnShareLink: UIButton!
    @IBOutlet weak var iconVW: UIView!
    var dataForResponce = [String:Any]()
    var isCallUserBalance = false
    
    var hederTbl = ["ACCOUNT","REVIEW","LEGAL","CONNECT WITH US"]
    var hederDetail = [[["name":"My Account","Img": #imageLiteral(resourceName: "ic_my_account.pdf")],["name":"Referral Points","Img": #imageLiteral(resourceName: "ic_referral.pdf")],["name":"Blocked Contact's","Img": #imageLiteral(resourceName: "ic_call_settings.pdf")],["name":"Invite Friends","Img": #imageLiteral(resourceName: "ic_setting_invite.pdf")],["name":"Vuetel Promo Code","Img": #imageLiteral(resourceName: "ic_redeem_voucher.pdf")]]
                        ,[["name":"Suggest Features","Img": #imageLiteral(resourceName: "ic_suggestions.pdf")],["name":"Feedback","Img": #imageLiteral(resourceName: "ic_feedback.pdf")],["name":"Rate Vuetel","Img": #imageLiteral(resourceName: "ic_review_app.pdf")]]
                        ,[["name":"Terms of Service","Img": #imageLiteral(resourceName: "ic_terms_and_conditions.pdf")],["name":"Privacy Policy","Img": #imageLiteral(resourceName: "ic_terms_and_conditions.pdf")]]
                        ,[["name":"Social","Img": #imageLiteral(resourceName: "ic_setting_invite.pdf")]]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
        lblName.text = User.sharedInstance.getFullName()
        lblPhoneNumber.text = User.sharedInstance.getContactNumber()
        lblVoletBelance.text = User.sharedInstance.getBalance()
        lblSharAppLink.text = User.sharedInstance.getrefurlUrl()
        tableView.contentInsetAdjustmentBehavior = .never

        btnShareLink.layer.cornerRadius = 5
        btnShareLink.layer.borderColor = #colorLiteral(red: 0.09370491654, green: 0.6319099069, blue: 0.7864649892, alpha: 1)
        btnShareLink.layer.borderWidth = 1
        
        userBalance()

        iconVW.layer.cornerRadius = iconVW.layer.bounds.height/2
        if #available(iOS 15.0, *) {
           tableView.sectionHeaderTopPadding = 20
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        //self.tabBarController?.tabBar.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut) {
            if let tabBarFrame = self.tabBarController?.tabBar.frame {
                self.tabBarController?.tabBar.frame.origin.y = self.navigationController!.view.frame.maxY - tabBarFrame.height
            }
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController!.view.layoutIfNeeded()
        }
        appDelegate.sipRegistration()
        
        if isCallUserBalance == true {
            isCallUserBalance = false
            userBalance()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    
    func initCall(){
        btnAddFund.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        btnAddFund.layer.borderWidth = 1
        btnAddFund.layer.cornerRadius = 5
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0);
    }
    
    //MARK: - APi Action
    func userBalance() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"get_userbalance"
                                               ,"Device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "1" {
                dataForResponce = (diddata["response"] as! [String: Any])
                User.sharedInstance.setBalance(value: dataForResponce["Balance"] as? String ?? "")
                lblVoletBelance.text = User.sharedInstance.getBalance()
                print(dataForResponce)
            }else if diddata["status"] as? String ?? "" == "4" {
                let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "LogoutPopupVc") as! LogoutPopupVc
                nextVC.modalPresentationStyle = .overFullScreen
                self.present(nextVC, animated: false)
                print(dataForResponce)
            } else {
                self.showToastMessage(message: diddata["message"] as? String)
            }
        })
    }
    
    
    
    //MARK: - btn Click
    @IBAction func btnClickSharLink(_ sender: Any) {
        if let urlStr = NSURL(string: User.sharedInstance.getrefurlUrl()) {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAddFund(_ sender: UIButton) {
        isCallUserBalance = true
        self.tabBarController?.tabBar.isHidden = true
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "AddFundsVctr") as! AddFundsVctr
        nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        nextVC.dataForResponce = self.dataForResponce
//        self.present(nextVC, animated: true)
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
}
extension SettingVc:  UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hederTbl.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let label = UILabel()
        label.frame = CGRect.init(x: 22, y: 8, width: headerView.frame.width/2, height: headerView.frame.height/2)
        label.text = hederTbl[section]
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        headerView.addSubview(label)
        headerView.backgroundColor = #colorLiteral(red: 0.4439517856, green: 0.5258321166, blue: 0.7032657862, alpha: 1)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hederDetail[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingSocialInofCell", for: indexPath) as! SettingSocialInofCell
            cell.btnFB.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
            cell.btnInsta.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
            cell.btnTwtter.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingDetailInfoCell", for: indexPath) as! SettingDetailInfoCell
            let lbl = hederDetail[indexPath.section]
            cell.lblTitle.text = lbl[indexPath.row]["name"] as? String ?? ""
            cell.lblImg.image = lbl[indexPath.row]["Img"] as? UIImage
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 50
        }
        else{
            return 50
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return  40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let lbl = hederDetail[indexPath.section]
        let title = lbl[indexPath.row]["name"] as? String ?? ""
        
        if title == "Rate Vuetel" {
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1498923143") {
                UIApplication.shared.open(url)
            }
        }
        
        else if title == "My Account" {
            isCallUserBalance = true
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "MyAccountVc") as! MyAccountVc
            navigationController?.pushViewController(nextVC, animated: true)
        }
       else if title == "Invite Friends" {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "InviteFriendsVc") as! InviteFriendsVc
            navigationController?.pushViewController(nextVC, animated: true)
        }
        else if title == "Vuetel Promo Code"{
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "RedeemCouponVc") as! RedeemCouponVc
            navigationController?.pushViewController(nextVC, animated: true)
        }
        else if title == "Referral Points" {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ReferralPointsVc") as! ReferralPointsVc
            nextVC.dataForResponce = self.dataForResponce
            navigationController?.pushViewController(nextVC, animated: true)
        }
        else if title == "Blocked Contact's" {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "BlockCallsVc") as! BlockCallsVc
            navigationController?.pushViewController(nextVC, animated: true)
            
        }else if title == "Suggest Features" {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "FeedbackOrSuggestVc") as! FeedbackOrSuggestVc
            navigationController?.pushViewController(nextVC, animated: true)
        }
        else if title == "Feedback" {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "FeedbackOrSuggestVc") as! FeedbackOrSuggestVc
            nextVC.feedBackVeiwOrNot = true
            navigationController?.pushViewController(nextVC, animated: true)
        }
        else if title == "Terms of Service" {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "TermServiceOrPrivacyPolicyVc") as! TermServiceOrPrivacyPolicyVc
            nextVC.DocumentUrl = Constant.GlobalConstants.TERMS_CONDITION_URL
            nextVC.Title = Constant.ViewControllerTitle.TermsofService
            navigationController?.pushViewController(nextVC, animated: true)
        }
        else if title == "Privacy Policy" {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "TermServiceOrPrivacyPolicyVc") as! TermServiceOrPrivacyPolicyVc
            nextVC.DocumentUrl = Constant.GlobalConstants.PRIVACY_POLICY_URL
            nextVC.Title = Constant.ViewControllerTitle.PrivacyPolicy
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @objc func connected(sender: UIButton){
        let buttonTag = sender.tag
        var url = URL(string: "")
        
        if buttonTag == 1 {
            url = URL(string: Constant.SocialMedia.FACEBOOK_URL)!
        }else if buttonTag == 2 {
            url = URL(string: Constant.SocialMedia.TWITTER_URL)!
        }else if buttonTag == 3 {
            url = URL(string: Constant.SocialMedia.INSTAGRAM_URL)!
        }
        
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url!, options: [:], completionHandler: { (success) in
                 print("Open url : \(success)")
            })
        }
    }
}
