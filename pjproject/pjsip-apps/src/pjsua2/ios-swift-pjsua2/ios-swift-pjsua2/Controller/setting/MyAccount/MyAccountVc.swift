//
//  MyAccountVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 16/12/22.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices


class MyAccountVc: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var lblMyaccount = [["title":"Speed Dial","Disciption":"Set your favorite contact", "image": #imageLiteral(resourceName: "ic_speed_dial.png")],["title":"Delete Account","Disciption":"Remove account from PhoneDial", "image": #imageLiteral(resourceName: "ic_delete_account.png")],["title":"Log Out","Disciption":"Are you sure want to logout?", "image": #imageLiteral(resourceName: "ic_log_out.pdf")]]
    
    var Logout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constant.ViewControllerTitle.MyAccount
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - APi Action
    func deleteAccount() {
       
        let requestData : [String : String] = ["Account_id":User.sharedInstance.getAccountID()
                                               ,"request":"account_delete"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "1" {
                appDelegate.LoginPage()
            } else {
                self.showToastMessage(message: diddata["message"] as? String)
            }
        })
    }
    
}
extension MyAccountVc:  UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lblMyaccount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountDetailsCell", for: indexPath) as! MyAccountDetailsCell
        let lbl = lblMyaccount[indexPath.row]
        cell.lblTitle.text = lblMyaccount[indexPath.row]["title"] as? String//lbl["title"] ?? "" as! String
        cell.lblDiscription.text = lblMyaccount[indexPath.row]["Disciption"] as? String
        cell.imge.image = lblMyaccount[indexPath.row]["image"] as? UIImage
        cell.imageMainVW.layer.cornerRadius = 5
        cell.btnNext.isHidden = false 
        if indexPath.row == 2 {
            cell.btnNext.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        Logout = false
        if indexPath.row == 1 {
            let Alart = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "CommonAlertVc") as? CommonAlertVc
            Alart?.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            Alart?.delegate = self
            Alart?.nameTitle = Constant.AlertDiscretion.DeleteAccountTitle
            Alart?.discretion  = Constant.AlertDiscretion.DeleteAccountDis
            self.present(Alart!, animated: false, completion: nil)
        } else  if indexPath.row == 2 {
            Logout = true
            let Alart = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "CommonAlertVc") as? CommonAlertVc
            Alart?.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            Alart?.delegate = self
            Alart?.nameTitle = "Log Out"
            Alart?.discretion  = "Are you sure want to logout?"
            self.present(Alart!, animated: false, completion: nil)
        } else{
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "SpeedDialVc") as! SpeedDialVc
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
}
extension MyAccountVc: CommonAlertVcDelegate {
    func CommonAlertAccept() {
        
        if UserDefaults.standard.string(forKey: "WhichLoginCheck") != nil {
            if  UserDefaults.standard.string(forKey: "WhichLoginCheck") == "FB" {
                let loginManager = LoginManager()
                loginManager.logOut()
            } else if  UserDefaults.standard.string(forKey: "WhichLoginCheck") == "Gmail" {
                GIDSignIn.sharedInstance.signOut()
            } else if  UserDefaults.standard.string(forKey: "WhichLoginCheck") == "appleLogin" {
                
            }
        }
        
        if Logout == true {
            User.sharedInstance.removeUserDetail()
            UserDefaults.standard.removeObject(forKey: "isAlreadyMember")
            appDelegate.LoginPage()
        } else {
            deleteAccount()
        }
        
        
        
        Logout = false
    }
}
