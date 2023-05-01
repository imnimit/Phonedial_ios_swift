//
//  CallOptionPopupVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 24/12/22.
//

import UIKit



class CallOptionPopupVc: UIViewController {

    @IBOutlet weak var lblCallerName: UILabel!
    @IBOutlet weak var lblCallNumber: UILabel!
    @IBOutlet weak var mainVW: UIView!
    @IBOutlet weak var AddcontactVW: UIView!
    var dicCall = [[String:Any]]()
    var IsAddContectInAudioLog = false
    var delegate: NewAddContact?

    var number = ""
    var name = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
        
    }
    
    func initCall(){
        mainVW.layer.cornerRadius = 5
        lblCallerName.text = name
        lblCallNumber.text = number.toPhoneNumber()
        
        if name != "unknown" {
            AddcontactVW.isHidden = true
        }
    }
    
    
    //MARK: - btn Click
    @IBAction func clickBtn(_ sender: UIButton) {
        if sender.tag == 1 {
            //call
            self.view.window?.rootViewController?.dismiss(animated: true, completion: { [self] in
                if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                    tabBarController.selectedIndex = 2
                    let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                    let dialPed = storyboard1.instantiateViewController(withIdentifier: "dialpadVc") as! dialpadVc
                    dialPed.contectNumber = (lblCallNumber.text ?? "").replace(string: "-", replacement: "")
                    dialPed.contectName = lblCallerName.text ?? ""
                    tabBarController.viewControllers![2]  = dialPed
                }
            })
        }else if sender.tag == 2 {
            //message
        }else if sender.tag == 3 {
            for i in dicCall {
                DBManager().deleteCallLog(number: i["id"] as? String ?? "")
            }
            //delete
            self.dismiss(animated: false,completion: { [self] in
                sleep(1)
                NotificationCenter.default.post(name: Notification.Name("callLogUpdata"), object: self, userInfo: nil)
            })
        }else if sender.tag == 4 {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewContectVc") as! AddNewContectVc
            nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            nextVC.number = (dicCall[0]["number"] as? String ?? "")
            nextVC.IsAddContectInAudioLog = self.IsAddContectInAudioLog
            nextVC.delegate = self
            self.present(nextVC, animated: false)
            
            //add to contact
        }else if sender.tag == 5 {
            //block contact
            blockContact()
        }
    }
    
    
    //MARK: - APi Action
    func blockContact() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token(),
                                               "Device_id":appDelegate.diviceID
                                               ,"request":"add_blockcode"
                                               ,"code":number]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "1" {
                let Data : [[String: Any]] = (diddata["response"] as! [[String: Any]])
                self.dismiss(animated: false)
            } else {
                self.showToastMessage(message: diddata["message"] as? String)
            }
        })
    }
    
}
extension CallOptionPopupVc: NewAddContact {
    func goToAudioCallLog(){
        self.dismiss(animated: true,completion: {
            NotificationCenter.default.post(name: Notification.Name("callLogUpdata"), object: self, userInfo: nil)
        })
    }
     
}
