//
//  VideoCallWaitVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 24/04/23.
//

import UIKit
import Lottie

class VideoCallWaitVc: UIViewController {

    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var nameVW: UIView!
    @IBOutlet weak var lblNameLetter: UILabel!
    @IBOutlet weak var btnCallAnswer: UIButton!
    @IBOutlet weak var downSideVW: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    var seconds  = 0
    var minutes = 0
    var hours = 0
    var timer = Timer()
    var phoneCode = ""
    var number = ""
    var name = ""
    var incomingCallId = ""
    var mainTitle = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downSideVW.clipsToBounds = true
        downSideVW.layer.cornerRadius = 50
        downSideVW.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        CPPWrapper().call_listener_wrapper(call_status_listener_swift)

        if incomingCallId != "" {
            appDelegate.isVidoeCallIncomeing = true
            btnCallAnswer.isHidden = false
            
//            let dictValue = UserDefaults.standard.value(forKey: "loginCheckKey") as? [String: Any]
//            print(dictValue!)
  
            let a = incomingCallId.components(separatedBy: "sip:")
            let newString = a[1].components(separatedBy: "@")
            lblNumber.text = newString[0]
            
            if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == lblNumber.text?.suffix(10)})
                if index != nil {
                    appDelegate.IncomeingCallInfo = contactList[index!]
                    name = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unknown"
                }
            }
        }
        else{
            appDelegate.isVidoeCallIncomeing = false
            btnCallAnswer.isHidden = true
            CPPWrapper().outgoingCall("sip:\(phoneCode)" + (number) + "@\(Constant.GlobalConstants.SERVERNAME)" + ":" + "\(Constant.GlobalConstants.PORT)", "1")
            CPPWrapper().call_listener_wrapper(call_status_listener_swift)
            lblNumber.text = phoneCode + number
        }
        
        
        if mainTitle != "" {
            lblTitle.text = mainTitle
        }
        
        
        lblTimer.text = "00:00:00"
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        
        if name == "" {
            lblName.text = "Unknown"
        }else{
            lblName.text = name
        }
        
        lblNameLetter.text = findNameFistORMiddleNameFistLetter(name: lblName.text ?? "Unknown")
        
        nameVW.layer.cornerRadius = nameVW.layer.bounds.height/2
  
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIDevice.current.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        CPPWrapper().hangupCall();
    }
    
    @objc func onTimer() {
        lblTimer.isHidden = false
        seconds += 1
        lblTimer.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        if seconds >= 59 {
            seconds = 0
            minutes += 1
            if minutes >= 59 {
                minutes = 0
                hours += 1
            }
        }
    }
    
    func timerStop(){
        timer.invalidate()
    }
    
 //MARK: - bnt Click
    @IBAction func btnCallCut(_ sender: UIButton) {
        
        var callType = "MissCall"

        let dicCallLogData =  ["contact_name": name, "charges": "0", "call_length": "00:00:00", "type": callType, "created_date": todayYourDataFormat(dataformat: "MM-dd-yyyy HH:mm:ss"), "number": number,"type_log":"VidoeCall"]  as! [String:Any]
        DBManager().insertLog(dicLog: dicCallLogData)
        
        NotificationCenter.default.post(name: Notification.Name("callLogUpdata"), object: self, userInfo: nil)
        
        
        self.dismiss(animated: true,completion: {
            CPPWrapper().hangupCall()
        })
    }


    @IBAction func btnCallMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        AppDelegate.instance.isVideoCallMute = sender.isSelected
    }
    
    
    @IBAction func btnCallAnwnser(_ sender: UIButton) {
       CPPWrapper().answerCall()
     }
}
