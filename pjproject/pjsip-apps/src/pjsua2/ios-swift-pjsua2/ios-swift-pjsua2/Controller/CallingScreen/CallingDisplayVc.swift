//
//  CallingDisplayVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 18/11/22.
//

import UIKit
import AVFAudio
import CallKit
import CoreBluetooth
import Lottie


class CallingDisplayVc: UIViewController {
    @IBOutlet weak var lblNameCallingTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtKeybordNumber: UITextField!
    @IBOutlet weak var callVW: UIView!
    @IBOutlet weak var numPedVW: UIView!
    @IBOutlet weak var imcomeingCallVW: UIView!
    @IBOutlet weak var lblIncomeingNumber: UILabel!
    @IBOutlet weak var lblDialNumber: UILabel!
    @IBOutlet weak var btnSwip: UIButton!
    @IBOutlet weak var btncallinfo: UIButton!
    
    @IBOutlet weak var swipeVW: UIView!
    @IBOutlet weak var holdVW: UIView!
    @IBOutlet weak var muteVW: UIView!
    @IBOutlet weak var spekerVW: UIView!
    @IBOutlet weak var addCallVW: UIView!
    @IBOutlet weak var keyBordVW: UIView!
    @IBOutlet weak var btnAddCall: UIButton!
    @IBOutlet weak var btnMargeCall: UIButton!
    @IBOutlet weak var recodCallVW: UIView!
    @IBOutlet weak var lblRecod: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblCalling: UILabel!
    @IBOutlet weak var trasfterCallVW: UIView!
    @IBOutlet weak var btnHold: UIButton!
    
    @IBOutlet weak var lblSwipTimeFistNumber: UILabel!
    @IBOutlet weak var lblSwipTimeFistName: UILabel!
    @IBOutlet weak var lblSwipTimeFistCallType: UILabel!
    
    @IBOutlet weak var lblSwipTimeSecondNumber: UILabel!
    @IBOutlet weak var lblSwipTimeSecondName: UILabel!
    @IBOutlet weak var lblSwipTimeSecondCallType: UILabel!
    @IBOutlet weak var mainVWSwipCall: UIView!
    @IBOutlet weak var callFistInfoVW: UIView!
    @IBOutlet weak var callSecondInfoVW: UIView!
//    @IBOutlet var numberView: [UIView]!
//    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnTransferCall: UIButton!
    @IBOutlet weak var lblTransfer: UILabel!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var recodingAnimaion: LottieAnimationView!
    @IBOutlet weak var callAddTimeHigtht: NSLayoutConstraint!
    @IBOutlet weak var appIconCallTime: UIImageView!
    @IBOutlet weak var confrencetimeIcon: UIImageView!
    @IBOutlet weak var incomingCallIcon: UIImageView!
    
    
    var phoneCode = ""
    var isDeviceLock = false
    var nameDisplay = ""
    
    static let sharedInstance = CallingDisplayVc()

    var callingScreen = false
    var incomingCallId : String = ""
    var IsbluetoothConnected = false
    
    var IsMuted:Bool = false
    var IsHold:Bool = false
    var IsSpeker:Bool = false
    var IsCallRecod:Bool = false
    var IsSwipCall:Bool = false
    
    var arraynumber  = [String]()
    var manager:CBCentralManager!
    var number = ""
    var numberStoreinDB = ""
    var isMargeCallDone = false
    var OnetimeUsed = false
    var callManager: CallManager!

    
    var isBluetoothPermissionGranted: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        } else if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        // Before iOS 13, Bluetooth permissions are not required
        return true
    }
    
    var timerNumberGet = Timer()

    var seconds  = 0
    var minutes = 0
    var hours = 0
//    var timer = Timer()
    var confrenceTimeMange = [[String:Any]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        callManager = appDelegate.callManager
        CallInit()
        setAudioOutputSpeaker(enabled: false)
        callAddTimeHigtht.constant = 0.0
        recodingAnimaion.contentMode = .scaleAspectFill
        recodingAnimaion.loopMode = .loop
        recodingAnimaion.animationSpeed = 0.5
        recodingAnimaion.play()
        recodingAnimaion.isHidden = true
        btncallinfo.isHidden = true
        
        appIconCallTime.layer.cornerRadius = appIconCallTime.layer.bounds.height/2
        confrencetimeIcon.layer.cornerRadius = confrencetimeIcon.layer.bounds.height/2
        incomingCallIcon.layer.cornerRadius = confrencetimeIcon.layer.bounds.height/2
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIDevice.current.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        CPPWrapper().hangupCall();
    }
        
    func CallInit() {
      //  numberView.forEach { $0.layer.cornerRadius = $0.layer.bounds.height/2 }
        txtKeybordNumber.layer.borderColor = #colorLiteral(red: 0.08344072165, green: 0.08344072165, blue: 0.08344072165, alpha: 0.5)
        txtKeybordNumber.layer.borderWidth = 1
        txtKeybordNumber.layer.cornerRadius = 10
        txtKeybordNumber.layer.shadowColor = #colorLiteral(red: 0.08344072165, green: 0.08344072165, blue: 0.08344072165, alpha: 0.5)
        txtKeybordNumber.layer.shadowOffset = CGSize(width: 0.0, height : -3.0)
        txtKeybordNumber.layer.shadowOpacity = 0.5
        txtKeybordNumber.layer.shadowRadius = 10
//        btnClose.layer.cornerRadius = 10
        if appDelegate.callComePushNotification  == true {
            imcomeingCallVW.isHidden = true
            if  appDelegate.IncomeingCallInfo.count > 0 {
                lblDialNumber.text = appDelegate.IncomeingCallInfo["phone"] as? String ?? ""
                lblName.text = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unknown"
            }
            
            if isDeviceLock == false {
                if (CPPWrapper().registerStateInfoWrapper()) {
                    if isDeviceLock == false {
                        if (appDelegate.isCallOngoing == true) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                CPPWrapper().answerCall()
                                CPPWrapper().call_listener_wrapper(call_status_listener_swift)
                            }
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                CPPWrapper().answerCall()
                                CPPWrapper().call_listener_wrapper(call_status_listener_swift)
                            }
                        }
                    }
                }
                print("Timer fired!")
            }
        }
        else {
            if incomingCallId == "" {
//                let dictValue = UserDefaults.standard.value(forKey: "loginCheckKey") as? [String: Any]
//                print(dictValue!)
                
                lblDialNumber.text = phoneCode + number
                lblName.text = (nameDisplay == "") ? "Unkown" : nameDisplay
                
                callManager.startCall(handle: (lblName.text ?? "" == "Unkown" ? number : lblName.text ?? ""), videoEnabled: false)

                imcomeingCallVW.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    if (CPPWrapper().registerStateInfoWrapper()) {
                        CPPWrapper().outgoingCall("sip:\(phoneCode)" + number + "@\(Constant.GlobalConstants.SERVERNAME)" + ":" + "\(Constant.GlobalConstants.PORT)", "0")
                        CPPWrapper().call_listener_wrapper(call_status_listener_swift)
                    } else {
                        self.showToast(message: "Sip Status: NOT REGISTERED")
                    }
                }
                
                if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                    let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                    let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == number.suffix(10)})
                    if index != nil {
                        appDelegate.IncomeingCallInfo = contactList[index!]
                    }
                }
                lblName.text = (nameDisplay == "") ? "Unknown" : nameDisplay
                
                
                numberStoreinDB = phoneCode + number
                allbtnDisalbe()
            }
            else{
                
                lblNameCallingTime.text = "Unkown"
                lblName.text = "Unkown"
//                if  appDelegate.IncomeingCallInfo.count > 0 {
//                    lblIncomeingNumber.text = appDelegate.IncomeingCallInfo["phone"] as? String ?? ""
//                    lblNameCallingTime.text = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unkown"
//                    
//                    lblDialNumber.text = appDelegate.IncomeingCallInfo["phone"] as? String ?? ""
//                    lblName.text = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unkown"
//                }
                
                let maistr = incomingCallId.components(separatedBy: "<")
                let newString = maistr[1].replacingOccurrences(of: "sip:", with: "", options: .literal, range: nil)
                
                let phonenumber = newString.components(separatedBy: "@")
                
                if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                    let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                    let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == phonenumber[0].suffix(10)})
                    if index != nil {
                        appDelegate.IncomeingCallInfo = contactList[index!]
                    }
                }
                
                lblDialNumber.text = phonenumber[0]
                lblIncomeingNumber.text = phonenumber[0]
                imcomeingCallVW.isHidden = false
                CPPWrapper().call_listener_wrapper(call_status_listener_swift)
                
                numberStoreinDB = lblIncomeingNumber.text ?? ""
                
                lblTimer.text = "00:00:00"
                appDelegate.timerMinCall = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
                RunLoop.main.add(appDelegate.timerMinCall, forMode: RunLoop.Mode.common)

                lblCalling.text = "Mobile Calling..."
                
                lblIncomeingNumber.text = phonenumber[0]
                lblNameCallingTime.text = (appDelegate.IncomeingCallInfo["name"] as? String ?? "" == "") ? "Unknown" : (appDelegate.IncomeingCallInfo["name"] as? String ?? "")

                lblDialNumber.text = phonenumber[0]
                lblName.text = (appDelegate.IncomeingCallInfo["name"] as? String ?? "" == "") ? "Unknown" : (appDelegate.IncomeingCallInfo["name"] as? String ?? "")
                
                appDelegate.displayIncomingCall(
                    uuid: UUID(),
                    handle: lblName.text ?? "",
                    hasVideo: false
                ) { _ in
                }
            }
        }
        
        timerNumberGet =  Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
            let numberarray = CPPWrapper.callNumber().components(separatedBy: ",")
//            btncallinfo.isHidden = true
            if numberarray.count > 1 {
                if isMargeCallDone == false {
                    isMargeCallDone = true
                    holdVW.isHidden = true
                    print(numberarray.count)
                      
                    swipeVW.isHidden = false
                    swipeVW.alpha = 1.0
                    
                    btnMargeCall.alpha = 1.0
                    btnMargeCall.isHidden = false
                    lblSwipTimeFistCallType.text = "Hold"
//                     lblSwipTimeSecondCallType.text = "Active"
//                     hightMainSwip.constant = 150
                    OnetimeUsed = true
                    callAddTimeHigtht.constant = 75
//                    NameORNumberFind(numberarray: numberarray)
                }
                let confirmNumber = CPPWrapper.confirmCallNumber().components(separatedBy: ",")
                if numberarray.count == confirmNumber.count {
                    swipeVW.alpha = 1
                    btnMargeCall.alpha = 1
                } else {
                    swipeVW.alpha = 0.5
                    btnMargeCall.alpha = 0.5
                }
                
                if confirmNumber.count == Constant.ConfrenceCallConnectUserNumber {
                    btnAddCall.alpha = 0.5
                } else {
                    btnAddCall.alpha = 1.0
                }
                
                //timer.invalidate()
            }
            else {
                btnAddCall.alpha = 1.0
                if numberarray.count == 1 && OnetimeUsed == true && callAddTimeHigtht.constant == 75 {
                    callAddTimeHigtht.constant = 0
   
                    NameORNumberFind(numberarray: numberarray)
                    
                    CPPWrapper().unholdAllCall()
                    
                    CPPWrapper().valuePop()
                    
                    btnAddCall.isHidden = false
                    btnMargeCall.isHidden = true
                    holdVW.isHidden = false
                    swipeVW.isHidden = true
                    holdVW.alpha = 1.0
                }
                else if callAddTimeHigtht.constant == 150 {
//                    hightMainSwip.constant = 0
                    callAddTimeHigtht.constant = 0
                    let newString = number.replacingOccurrences(of: "sip:", with: "", options: .literal, range: nil)
                    let phonenumber = newString.components(separatedBy: "@")
                    swipeVW.isHidden = true
                    holdVW.isHidden = false
                    btnMargeCall.isHidden = true
                    btnAddCall.isHidden = false
                    if phonenumber[0] == (lblSwipTimeFistNumber.text ?? "" ).suffix(10) {
                        CPPWrapper().unholdCall("0") // Change
                    }
                    else if phonenumber[0] == (lblSwipTimeSecondNumber.text ?? "" ).suffix(10) {
                        CPPWrapper().unholdCall("1") // Change
                     }
                    
//                    NameORNumberFind(numberarray: numberarray)
                }
                else if numberarray.count == 1 && OnetimeUsed == true {
                    btncallinfo.isHidden = true

                    let newString = numberarray[0].replacingOccurrences(of: "sip:", with: "", options: .literal, range: nil)
                    let phonenumber = newString.components(separatedBy: "@")

                    NameORNumberFind(numberarray: numberarray)

                    
                    btnAddCall.isHidden = false
                    btnMargeCall.isHidden = true
                    holdVW.isHidden = false
                    swipeVW.isHidden = true
                    holdVW.alpha = 1.0
                    
                    OnetimeUsed = false
                    
                    CPPWrapper().valuePop()
                    
                    if confrenceTimeMange.count  > 1 {
                        for i in confrenceTimeMange {
                            if (i["number"] as? String ?? "") != phonenumber[0] {
                                callLogStoreCallCut(dic: i)
                            }
                        }
                    }
                }
            }
        }
        
        if isBluetoothPermissionGranted == true {
            manager = CBCentralManager()
            manager.delegate = self
        }
        
        mainVWSwipCall.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mainVWSwipCall.layer.cornerRadius = 10
        mainVWSwipCall.layer.borderWidth = 1.5
//        hightMainSwip.constant = 0.0
        callAddTimeHigtht.constant = 0.0
        btncallinfo.isHidden = true
        swipeVW.isHidden = true
        callTimerStart()
        callEndFind()
//        lblSwipTimeFistName.text = lblName.text
//        lblSwipTimeFistNumber.text = phoneCode + number
        
        let dic = ["number": lblDialNumber.text, "time":"","name":lblName.text] as! [String:Any]

        confrenceTimeMange.append(dic)

//        allbtnDisalbe()
//        callPickupCheck()
        
        NotificationCenter.default.addObserver(self, selector: #selector(callAdd), name: Notification.Name("callAdd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transferCall), name: Notification.Name("transferCall"), object: nil)
    }
    
    func NameORNumberFind(numberarray: [String]){
        var number = ""
        var name = ""
        if numberarray.count > 1 {
            name = "Conference Call"
            number = ""
        }else{
            for i in numberarray {
                let newString = i.replacingOccurrences(of: "sip:", with: "", options: .literal, range: nil)
                let phonenumber = newString.components(separatedBy: "@")
                if number == "" {
                    number = phonenumber[0]
                    if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                        let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                        let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == phonenumber[0]})
                        if index != nil {
                            name = contactList[index!]["name"] as? String ?? ""
                        }
                        else {
                            name = "Unknown"
                        }
                    }
                }else {
                    number = number + "&" + phonenumber[0]
                    if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                        let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                        let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == phonenumber[0]})
                        if index != nil {
                            name = name + "&" + (contactList[index!]["name"] as? String ?? "")
                        }
                        else {
                            name = "Unknown"
                        }
                    }
                }
            }
        }
        lblName.text = name
        lblDialNumber.text = number
    }
    
    @objc func transferCall(_ notification: NSNotification){
        
        DispatchQueue.main.async {
            self.dismiss(animated: false,completion: { [self] in
//                sleep(1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [self] in
//                    let dictValue = UserDefaults.standard.value(forKey: "loginCheckKey") as? [String: Any]
//                    print(dictValue!)
                    
                    if let number = notification.userInfo?["number"] as? String {
                        let num1 = number.replace(string: ")", replacement: "")
                        let num2 = num1.replace(string: "(", replacement: "")
                        let num3 = num2.replace(string: "-", replacement: "")
                        CPPWrapper.call_transfer_replaces(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            let transfernumber = "<sip:\(self.phoneCode)" + num3 + "@\(Constant.GlobalConstants.SERVERNAME)" + ":" + "\(Constant.GlobalConstants.PORT)>"
                            CPPWrapper.call_transfer(true, transfernumber)
                        })
                    }
                })
            })
        }
    }
        
    @objc func callAdd(_ notification: NSNotification){
        DispatchQueue.main.async {
            self.dismiss(animated: false,completion: { [self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
                    btnAddCall.isHidden = true
                    btnMargeCall.isHidden = false
                    btnMargeCall.alpha = 0.5
                    holdVW.alpha = 0.5
                    isMargeCallDone = false
//                    let dictValue = UserDefaults.standard.value(forKey: "loginCheckKey") as? [String: Any]
//                    print(dictValue!)
                    
                    if let number = notification.userInfo?["number"] as? String {
                        let num1 = number.replace(string: ")", replacement: "")
                        let num2 = num1.replace(string: "(", replacement: "")
                        let num3 = num2.replace(string: "-", replacement: "")
                        let numbercall = "sip:\(phoneCode)\(num3)@\(Constant.GlobalConstants.SERVERNAME):\(Constant.GlobalConstants.PORT)"

                        lblSwipTimeFistName.text = lblName.text ?? ""
                        lblSwipTimeFistNumber.text = lblDialNumber.text ?? ""
                        
                        lblName.text = notification.userInfo?["name"] as? String ?? ""
                        lblDialNumber.text = notification.userInfo?["number"] as? String ?? ""
                        if lblSwipTimeFistNumber.text == "" {
                            CPPWrapper().unholdCall(lblDialNumber.text!) // Change
                        }else{
                            let swipNumber = lblSwipTimeFistNumber.text ?? ""
                            CPPWrapper().holdCall(swipNumber)
                        }
                        let dic = ["number": notification.userInfo?["number"] as? String ?? "", "time":lblTimer.text,"name":notification.userInfo?["name"] as? String ?? ""]
                        confrenceTimeMange.append(dic as [String : Any])
                        
                        CPPWrapper.addConfrenceAttendee(numbercall)
                    }
                })
                
               
            })
        }
    }
        
    func callEndFind(){
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
            if CPPWrapper().checkCallEnd() == true {
                callLogStore()
                timer.invalidate()
                print("Call log Store..........")
            }
        }
    }
    
    func allbtnDisalbe() {
        swipeVW.alpha = 0.5
        holdVW.alpha = 0.5
        muteVW.alpha = 0.5
//        spekerVW.alpha = 0.5
        addCallVW.alpha = 0.5
        keyBordVW.alpha = 0.5
        trasfterCallVW.alpha = 0.5
        recodCallVW.alpha = 0.5
    }
    
    func allbtnEnable() {
        swipeVW.alpha = 1.0
        holdVW.alpha = 1.0
        muteVW.alpha = 1.0
        spekerVW.alpha = 1.0
        addCallVW.alpha = 1.0
        keyBordVW.alpha = 1.0
        trasfterCallVW.alpha = 1.0
        recodCallVW.alpha = 1.0
    }
    
    func callPickupCheck() {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if CPPWrapper().checkCallConnected() == true {
//                timer.invalidate()
                print("Call Answer..........")
            }
        }
    }
    
    func callTimerStart(){
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
            if CPPWrapper().chekCallPickupOrNot() == true {
                timer.invalidate()
                Timer.scheduledTimer(withTimeInterval: (incomingCallId == "") ? 0 : 0 , repeats: false) { [self] timer in
                    allbtnEnable()
                    appDelegate.timerMinCall = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
                    lblCalling.text = "Mobile Calling..."
                }
                print("Call ring..........")
            }
        }
    }
        
    func callBluetoothTimeOpen(){
        var deviceAction = UIAlertAction()
        var headphonesExist = false
        
        let audioSession = AVAudioSession.sharedInstance()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let currentRoute = audioSession.currentRoute
        for input in audioSession.availableInputs!{
            if input.portType == AVAudioSession.Port.bluetoothA2DP || input.portType == AVAudioSession.Port.bluetoothHFP || input.portType == AVAudioSession.Port.bluetoothLE{
                let localAction = UIAlertAction(title: input.portName, style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                    do {
                        try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                    } catch let error as NSError {
                        print("audioSession error turning off speaker: \(error.localizedDescription)")
                    }
                    
                    do {
                        try audioSession.setPreferredInput(input)
                    }catch _ {
                        print("cannot set mic ")
                    }
                    
                    
                })
                
                for description in currentRoute.outputs {
                    if description.portType == AVAudioSession.Port.bluetoothA2DP {
                        localAction.setValue(true, forKey: "checked")
                        break
                    }else if description.portType == AVAudioSession.Port.bluetoothHFP {
                        localAction.setValue(true, forKey: "checked")
                        break
                    }else if description.portType == AVAudioSession.Port.bluetoothLE{
                        localAction.setValue(true, forKey: "checked")
                        break
                    }
                }
                localAction.setValue(UIImage(named:"bluetooth.png"), forKey: "image")
                optionMenu.addAction(localAction)
                
            } else if input.portType == AVAudioSession.Port.builtInMic || input.portType == AVAudioSession.Port.builtInReceiver  {
                
                deviceAction = UIAlertAction(title: "iPhone", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                    do {
                        try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                    } catch let error as NSError {
                        print("audioSession error turning off speaker: \(error.localizedDescription)")
                    }
                    
                    do {
                        try audioSession.setPreferredInput(input)
                    }catch _ {
                        print("cannot set mic ")
                    }
                    
                })
                
                for description in currentRoute.outputs {
                    if description.portType == AVAudioSession.Port.builtInMic || description.portType  == AVAudioSession.Port.builtInReceiver {
                        deviceAction.setValue(true, forKey: "checked")
                        break
                    }
                }
                
            } else if input.portType == AVAudioSession.Port.headphones || input.portType == AVAudioSession.Port.headsetMic {
                headphonesExist = true
                let localAction = UIAlertAction(title: "Headphones", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                    do {
                        try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                    } catch let error as NSError {
                        print("audioSession error turning off speaker: \(error.localizedDescription)")
                    }
                    
                    do {
                        try audioSession.setPreferredInput(input)
                    }catch _ {
                        print("cannot set mic ")
                    }
                })
                for description in currentRoute.outputs {
                    if description.portType == AVAudioSession.Port.headphones {
                        localAction.setValue(true, forKey: "checked")
                        break
                    } else if description.portType == AVAudioSession.Port.headsetMic {
                        localAction.setValue(true, forKey: "checked")
                        break
                    }
                }
                
                optionMenu.addAction(localAction)
            }
        }
        
        if !headphonesExist {
            optionMenu.addAction(deviceAction)
        }
        
        let speakerOutput = UIAlertAction(title: "Speaker", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            do {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } catch let error as NSError {
                print("audioSession error turning on speaker: \(error.localizedDescription)")
            }
        })
        for description in currentRoute.outputs {
            if description.portType == AVAudioSession.Port.builtInSpeaker{
                speakerOutput.setValue(true, forKey: "checked")
                break
            }
        }
        speakerOutput.setValue(UIImage(named:"speaker.png"), forKey: "image")
        optionMenu.addAction(speakerOutput)
        
        let cancelAction = UIAlertAction(title: "Hide", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: - Manual Speaker Enagle and Disable
    func setAudioOutputSpeaker(enabled: Bool) {
        let session = AVAudioSession.sharedInstance()
        if enabled {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } else {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        }
        try? session.setActive(true)
    }
    
    //MARK: - btn click
    
    @IBAction func btncallEed(_ sender: UIButton) {
        if btnMargeCall.isHidden == false  {
            
            CPPWrapper.passCallHangOut(confrenceTimeMange[confrenceTimeMange.count - 1 ]["number"] as? String ?? "")
            callLogStoreCallCut(dic: confrenceTimeMange[confrenceTimeMange.count - 1 ])
            
            swipeVW.isHidden = true
            btnMargeCall.isHidden = true
            
            let numberarray = CPPWrapper.callNumber().components(separatedBy: ",")
            NameORNumberFind(numberarray: numberarray)
            CPPWrapper().holdCall("1")
            callAddTimeHigtht.constant = 0.0
            btnAddCall.isHidden = false
            btncallinfo.isHidden = false
            return
        }
        
//        CallKitDelegate.sharedInstance.endCall()

        appDelegate.callComePushNotification = false

        timerNumberGet.invalidate()
        callLogStore()

        UIDevice.current.isProximityMonitoringEnabled = false
        self.dismiss(animated: true,completion: {
            CPPWrapper().hangupCall()
            for call in self.callManager.calls {
                self.callManager.end(call: call)
                self.callManager.remove(call: call)
            }
            CPPWrapper.clareAllData()
        })
    }
    
    @IBAction func btnMute(_ sender: UIButton) {
        if muteVW.alpha != 1.0 {
            return
        }
        sender.isSelected  = !sender.isSelected
        if IsMuted == false {
            IsMuted = true
            CPPWrapper().callmute()
        } else {
            IsMuted = false
            CPPWrapper().callunmute()
        }
    }
    
    @IBAction func btncallHold(_ sender: UIButton) {
        if holdVW.alpha != 1.0 {
            return
        }
        
        sender.isSelected  = !sender.isSelected
        if IsHold == false {
            IsHold = true
//            sleep(1);
            CPPWrapper().holdCall(lblDialNumber.text!) // Change
        }else {
            IsHold = false
//            sleep(1);
            CPPWrapper().unholdCall(lblDialNumber.text!) // Change
        }
    }
    
    @IBAction func btnCallSpeker(_ sender: UIButton) {
        if spekerVW.alpha != 1.0 {
            return
        }
        
        sender.isSelected  = !sender.isSelected
        
//        if IsbluetoothConnected == true {
//            callBluetoothTimeOpen()
//        }else{
//            if IsSpeker == false {
//                IsSpeker = true
//                setAudioOutputSpeaker(enabled: IsSpeker)
//            }else {
//                IsSpeker = false
//                setAudioOutputSpeaker(enabled: IsSpeker)
//            }
//        }
        
        if IsSpeker == false {
            IsSpeker = true
            setAudioOutputSpeaker(enabled: IsSpeker)
        }else {
            IsSpeker = false
            setAudioOutputSpeaker(enabled: IsSpeker)
        }
        
    }
 
    @IBAction func btnCallMearge(_ sender: UIButton) {
        if addCallVW.alpha != 1.0 {
            return
        }
        
        if btnAddCall.alpha != 1.0 {
            return
        }
        
        sender.isSelected  = !sender.isSelected
        
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactsVc") as! ContactsVc
        nextVC.navigationBarnotShow = true
        nextVC.isInvitedBtnShow = false
        nextVC.isFavoriteBtnShow = true
        nextVC.isContectNumberShow = false
        nextVC.isShowTopNavigationBar = true
        nextVC.iscallAdd = true
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true)
    
//        sleep(3)
        
       
//        CPPWrapper.addConfrenceAttendee("919696969696")
//        print(CPPWrapper.callNumber())
        
    }
    
    @IBAction func btnmargeLine(_ sender: UIButton) {
        if btnMargeCall.alpha != 1.0 {
            return
        }
     

        swipeVW.isHidden = true
        btnMargeCall.isHidden = true
        
        let numberarray = CPPWrapper.callNumber().components(separatedBy: ",")
        NameORNumberFind(numberarray: numberarray)
        
//        lblName.text = (lblName.text ?? "") + " & " +  (lblSwipTimeFistName.text ?? "")
//        lblDialNumber.text = (lblDialNumber.text ?? "") + " & " +  (lblSwipTimeFistNumber.text ?? "")
        
//        if IsSwipCall == true {
//            CPPWrapper().unholdCall(1)
//        }else{
//            CPPWrapper().unholdCall(0)
//        }
        CPPWrapper().holdCall("1") // Change
//        sleep(4)
        CPPWrapper.connectMedia()
//        hightMainSwip.constant = 0.0
        callAddTimeHigtht.constant = 0.0
        btnAddCall.isHidden = false
        btncallinfo.isHidden = false
    }
    
    @IBAction func btnCallNumPed(_ sender: UIButton) {
        txtKeybordNumber.text = ""
        if keyBordVW.alpha != 1.0 {
            return
        }
        
        UIView.transition(with: callVW, duration: 0.5,
                          options: [.transitionFlipFromRight,
                                    .showHideTransitionViews],
                          animations: {
            self.callVW.alpha = 0
            self.numPedVW.alpha = 1
            self.numPedVW.isHidden = false
        }) { _ in
            self.callVW.isUserInteractionEnabled = false
            self.numPedVW.isUserInteractionEnabled = true
            self.trasfterCallVW.isUserInteractionEnabled = false
            self.btnTransferCall.alpha = 0.5
            self.lblTransfer.alpha = 0.5
        }
    }
    
    @IBAction func btnNumPedClose(_ sender: UIButton) {
        UIView.transition(with: numPedVW, duration: 0.5,
                          options: [.transitionFlipFromRight,
                                    .showHideTransitionViews],
                          animations: {
            self.callVW.alpha = 1
            self.numPedVW.alpha = 0
            self.numPedVW.isHidden = true

        }) { _ in
            self.callVW.isUserInteractionEnabled = true
            self.numPedVW.isUserInteractionEnabled = false
            self.trasfterCallVW.isUserInteractionEnabled = true
            self.btnTransferCall.alpha = 1
            self.lblTransfer.alpha = 1
        }
    }
    
    @IBAction func btnCallTrasfer(_ sender: UIButton) {
        if trasfterCallVW.alpha != 1.0 {
            return
        }
        
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactsVc") as! ContactsVc
        nextVC.navigationBarnotShow = true
        nextVC.isInvitedBtnShow = false
        nextVC.isFavoriteBtnShow = true
        nextVC.isContectNumberShow = false
        nextVC.isShowTopNavigationBar = true
        nextVC.iscallTransfer = true
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true)
    }
    
    @IBAction func btnswipCall(_ sender: UIButton) {
        if swipeVW.alpha != 1.0 {
            return
        }
        if IsSwipCall == false {
            IsSwipCall = true
//            sleep(1);
//            CPPWrapper().holdCall(1)
//            sleep(1);
//            CPPWrapper().unholdCall(0)
//            lblSwipTimeFistCallType.text = "Active"
            lblSwipTimeSecondCallType.text = "Hold"
//            callFistInfoVW.alpha  = 1.0
            callSecondInfoVW.alpha  = 0.8
            
            let FistName = lblName.text
            let number = lblDialNumber.text
            
            
            lblName.text = lblSwipTimeFistName.text
            lblDialNumber.text = lblSwipTimeFistNumber.text
            
            lblSwipTimeFistName.text = FistName
            lblSwipTimeFistNumber.text = number
            
            
            CPPWrapper().holdCall(lblSwipTimeFistNumber.text!) // Change


        }else {
            IsSwipCall = false
//            sleep(1);
//            CPPWrapper().unholdCall(1)
//            sleep(1);
//            CPPWrapper().holdCall(0)
            lblSwipTimeFistCallType.text = "Hold"
//            lblSwipTimeSecondCallType.text = "Active"
//            callFistInfoVW.alpha  = 0.8
            callSecondInfoVW.alpha  = 1.0
         
            let FistName = lblSwipTimeFistName.text
            let number = lblSwipTimeFistNumber.text
            
            lblSwipTimeFistName.text =  lblName.text
            lblSwipTimeFistNumber.text = lblDialNumber.text
           
            lblName.text = FistName
            lblDialNumber.text = number
            
            CPPWrapper().holdCall(lblDialNumber.text!) // Change
        }
    }
        
    @IBAction func btnCallRecoding(_ sender: UIButton) {
        if recodCallVW.alpha != 1.0 {
            return
        }
     
        sender.isSelected  = !sender.isSelected
        
//        if UserDefaults.standard.object(forKey: "InAppPurchaseRecordingCheck") == nil {
//            //plan purchase popup
//            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertRecordingVC") as! AlertRecordingVC
//            nextVC.settitle = "Recording Plan Required"
//            nextVC.descrtion = "To unlock the recording features, you need to subscribe to our recording plan. Do you want to subscribe now?"
//            nextVC.modalPresentationStyle = .overFullScreen
//            self.present(nextVC, animated: false)
//            btnRecord.isSelected = false
//        } else {
            //Recording Terms & Condition
            btnRecord.alpha = 1
            lblRecod.alpha = 1
        
            if UserDefaults.standard.object(forKey: "RecordPopShowOnce") == nil {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertRecordingVC") as! AlertRecordingVC
                nextVC.settitle = "Call Recording Disclaimer"
                nextVC.descrtion = "By Tapping the call recording button, you confirm that you have the consent of every one in this call and that you agree and abide by the law governing recording phone conversation. Do you want to continue?"
                nextVC.modalPresentationStyle = .overFullScreen
                self.present(nextVC, animated: false)
                btnRecord.isSelected = false
                return
            }
            
            if IsCallRecod == false {
                lblRecod.text = "Stop"
                recodingAnimaion.isHidden = false
                IsCallRecod = true
                let currentDateTime = Date()

                // Instantiate a NSDateFormatter
                let dateFormatter = DateFormatter()

                // Set the dateFormatter format
                dateFormatter.dateFormat = "yyyyMMdd_hhmmss"

                // Get the date time in NSString
                let toDateInString = dateFormatter.string(from: currentDateTime)

                print("\(toDateInString)")

                let strFileName = "rec_\(toDateInString)_\(111111).wav"
                
                let urlstring = CPPWrapper.startRecording(151, userfilename: strFileName)

                let dicRecodingInfo = ["recoding_name":strFileName,"data":toDateInString,"recoding_path":urlstring]
                print(dicRecodingInfo)
                callRecording(dic: dicRecodingInfo)

    //            CPPWrapper.startRecording(151, userfilename: strFileName)
            }else {
                recodingAnimaion.isHidden = true
                
                lblRecod.text = "Record"
                IsCallRecod = false
                CPPWrapper.stopRecording(151)
            }
//        }

        
    }
    
    @IBAction func btnKeyBord(_ sender: UIButton) {
        CPPWrapper.send_dtmf(sender.titleLabel?.text ?? "")
        txtKeybordNumber.text =  (txtKeybordNumber.text ?? "" ) + (sender.titleLabel?.text ?? "")
    }
    
    @IBAction func btnInfoCall(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllCallNumberVC") as! AllCallNumberVC
        nextVC.confrenceTimeMange = self.confrenceTimeMange
        self.present(nextVC, animated: true)
    }

    //MARK: - incomeingCall
    @IBAction func btnAnsCall(_ sender: UIButton) {
        imcomeingCallVW.isHidden = true
        CPPWrapper().answerCall()
    }
    
    @IBAction func btnDeclineCall(_ sender: UIButton) {
//        callEndFind()
//        CallKitDelegate.sharedInstance.endCall()
//
//        timerNumberGet.invalidate()
//        callLogStore()
//
//        appDelegate.callComePushNotification = false
//
//        CPPWrapper().hangupCall();
//        CPPWrapper.clareAllData()
//
//        UIDevice.current.isProximityMonitoringEnabled = false
//
//        dismiss(animated: true)
        CPPWrapper().hangupCall();
                //        CallKitDelegate.sharedInstance.endCall()
                
                for call in callManager.calls {
                    callManager.end(call: call)
                    callManager.remove(call: call)
                }

                
                UIDevice.current.isProximityMonitoringEnabled = false
                dismiss(animated: true)
                
                appDelegate.callComePushNotification = false
        
    }
    
    
    //MARK: - Data base Funcation -----------------------------------------------------------------
    func callLogStore() {
        var callType = ""
        if incomingCallId == "" {
            callType = "Outgoing"
        }else{
            if imcomeingCallVW.isHidden == false {
                callType = "MissCall"
                lblTimer.text = "00h:00m:00s"
            } else {
                callType = "Incoming"
            }
        }
        
        for i in confrenceTimeMange {
            if i["time"] as? String ?? "" == "" {
                let dicCallLogData =  ["contact_name": (i["name"] as? String ?? ""), "charges": "0", "call_length": lblTimer.text, "type": callType, "created_date": todayYourDataFormat(dataformat: "MM-dd-yyyy HH:mm:ss"), "number": (i["number"] as? String ?? "" ),"type_log":"Call"]  as! [String:Any]
                print(dicCallLogData)
                DBManager().insertLog(dicLog: dicCallLogData)
            }else{
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "HH:mm:ss"
                
                let FendTime = (i["time"] as? String ?? "" ).replace(string: "h", replacement: "").replace(string: "m", replacement: "").replace(string: "s", replacement: "")
                let FstartTime = (lblTimer.text ?? "").replace(string: "h", replacement: "").replace(string: "m", replacement: "").replace(string: "s", replacement: "")
                
                let startTime = outputFormatter.date(from: FstartTime)// Replace with your start time
                let endTime = outputFormatter.date(from: FendTime)
                let calendar = Calendar.current

                // Calculate the difference
                let components = calendar.dateComponents([.hour, .minute, .second], from:endTime!,to: startTime!)

                // Extract the difference values
                let hours = components.hour ?? 0
                let minutes = components.minute ?? 0
                let seconds = components.second ?? 0
                
                let FindCallTime = "\((hours > 9) ? "\(hours)" : "0\(hours)"):\((minutes > 9) ? "\(minutes)" : "0\(minutes)"):\((seconds > 9) ? "\(seconds)" : "0\(seconds)")"
                
                let dicCallLogData =  ["contact_name": (i["name"] as? String ?? ""), "charges": "0", "call_length": FindCallTime, "type": callType, "created_date": todayYourDataFormat(dataformat: "MM-dd-yyyy HH:mm:ss"), "number": (i["number"] as? String ?? "" ),"type_log":"Call"]  as! [String:Any]
                print(dicCallLogData)
                DBManager().insertLog(dicLog: dicCallLogData)
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name("callLogUpdata"), object: self, userInfo: nil)
    }
        
    func callLogStoreCallCut(dic: [String:Any]) {
        var callType = ""
        if incomingCallId == "" {
            callType = "Outgoing"
        }else{
            if imcomeingCallVW.isHidden == false {
                callType = "MissCall"
                lblTimer.text = "00h:00m:00s"
            } else {
                callType = "Incoming"
            }
        }
        
        let index = confrenceTimeMange.firstIndex(where: {$0["number"] as! String == dic["number"] as! String })

        var count = 1
        for i in confrenceTimeMange {
            if i["number"] as? String ?? "" == dic["number"] as? String ?? "" && dic["time"] as? String ?? "" == "" {
                let dicCallLogData =  ["contact_name": (confrenceTimeMange[0]["name"] as? String ?? ""), "charges": "0", "call_length": lblTimer.text, "type": callType, "created_date": todayYourDataFormat(dataformat: "MM-dd-yyyy HH:mm:ss"), "number": (confrenceTimeMange[0]["number"] as? String ?? "" ),"type_log":"Call"]  as! [String:Any]
                print(dicCallLogData)
                DBManager().insertLog(dicLog: dicCallLogData)
                if let index = confrenceTimeMange.firstIndex(where: {$0["name"] as? String  == i["number"] as? String ?? "" }) {
                    confrenceTimeMange.remove(at: index)
                }
                break
            }else{
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "HH:mm:ss"
                
                let FendTime = (confrenceTimeMange[index!]["time"] as? String ?? "" ).replace(string: "h", replacement: "").replace(string: "m", replacement: "").replace(string: "s", replacement: "")
                let FstartTime = (lblTimer.text ?? "").replace(string: "h", replacement: "").replace(string: "m", replacement: "").replace(string: "s", replacement: "")
                
                let startTime = outputFormatter.date(from: FstartTime)// Replace with your start time
                let endTime = outputFormatter.date(from: FendTime)
                let calendar = Calendar.current
                
                var components: DateComponents
                var hours = Int()
                var minutes = Int()
                var seconds = Int()
                
                if FendTime == ""{
                    // Calculate the difference
 //                      components = calendar.dateComponents([.hour, .minute, .second], from:endTime!,to: startTime!)
                    hours = 0
                    minutes = 0
                    seconds = 0
                }else{
                    components = calendar.dateComponents([.hour, .minute, .second], from:endTime!,to: startTime!)
                    // Extract the difference values
                    hours = components.hour ?? 0
                    minutes = components.minute ?? 0
                    seconds = components.second ?? 0
                }

                
                let FindCallTime = "\((hours > 9) ? "\(hours)" : "0\(hours)"):\((minutes > 9) ? "\(minutes)" : "0\(minutes)"):\((seconds > 9) ? "\(seconds)" : "0\(seconds)")"
                
                let dicCallLogData =  ["contact_name": (confrenceTimeMange[index!]["name"] as? String ?? ""), "charges": "0", "call_length": FindCallTime, "type": callType, "created_date": todayYourDataFormat(dataformat: "MM-dd-yyyy HH:mm:ss"), "number": (confrenceTimeMange[index!]["number"] as? String ?? "" ),"type_log":"Call"]  as! [String:Any]
                print(dicCallLogData)
                DBManager().insertLog(dicLog: dicCallLogData)
                
                if let index = confrenceTimeMange.firstIndex(where: {$0["name"] as? String  == i["number"] as? String ?? "" }) {
                    confrenceTimeMange.remove(at: index)
                }
                break
            }
        }
        confrenceTimeMange.removeAll(where: { $0["number"] as? String ?? "" == dic["number"] as? String })

        NotificationCenter.default.post(name: Notification.Name("callLogUpdata"), object: self, userInfo: nil)
    }
    
    func callRecording(dic:[String:Any]){
        let dicCallRecordingData =  ["date":dic["data"] as? String, "number":"\(numberStoreinDB)", "name": "Unknown" ,"audio_name": dic["recoding_name"] as? String, "audioPath": dic["recoding_path"] as? String]  as! [String:Any]
        DBManager().insertrecording(dicrecording: dicCallRecordingData)
    }
}

extension CallingDisplayVc: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        IsbluetoothConnected = false
        switch central.state {
        case .poweredOn:
            IsbluetoothConnected = true
            break
        case .poweredOff:
            print("Bluetooth is Off.")
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        default:
            break
        }
    }
}

extension CallingDisplayVc {
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
        appDelegate.timerMinCall.invalidate()
    }
}
