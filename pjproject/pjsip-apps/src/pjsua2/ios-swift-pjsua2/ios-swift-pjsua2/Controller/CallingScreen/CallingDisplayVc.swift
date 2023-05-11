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
    @IBOutlet weak var hightMainSwip: NSLayoutConstraint!
    @IBOutlet weak var callFistInfoVW: UIView!
    @IBOutlet weak var callSecondInfoVW: UIView!
    
    
    var phoneCode = ""
    var isDeviceLock = false
    
    
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
    var isBluetoothPermissionGranted: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        } else if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        // Before iOS 13, Bluetooth permissions are not required
        return true
    }
    var seconds  = 0
    var minutes = 0
    var hours = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CallInit()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIDevice.current.isProximityMonitoringEnabled = false
        CPPWrapper().hangupCall();
    }
    
    
    
    func CallInit() {
      
        if appDelegate.callComePushNotification  == true {
            imcomeingCallVW.isHidden = true
            if  appDelegate.IncomeingCallInfo.count > 0 {
                lblDialNumber.text = appDelegate.IncomeingCallInfo["phone"] as? String ?? ""
                lblName.text = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unkown"
            }
            
            if isDeviceLock == false {
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
                    if (CPPWrapper().registerStateInfoWrapper()){
                        timer.invalidate()
                        if isDeviceLock == false {
                            CPPWrapper().answerCall()
                            CPPWrapper().call_listener_wrapper(call_status_listener_swift)
                        }
                    }
                    print("Timer fired!")
                }
            }
        }
        else {
            if incomingCallId == "" {
                lblDialNumber.text = number
                imcomeingCallVW.isHidden = true
                if (CPPWrapper().registerStateInfoWrapper()){
                    CPPWrapper().outgoingCall("sip:\(phoneCode)" + number + "@\(Constant.GlobalConstants.SERVERNAME)" + ":" + "\(Constant.GlobalConstants.PORT)")
                    CPPWrapper().call_listener_wrapper(call_status_listener_swift)
                }else {
                    self.showToast(message: "Sip Status: NOT REGISTERED")
                }
                
                if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                    let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                    let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == number.suffix(10)})
                    if index != nil {
                        appDelegate.IncomeingCallInfo = contactList[index!]
                    }
                }
                lblName.text  = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unkown"
                
                
                numberStoreinDB = number
                allbtnDisalbe()
            }else{
                
                if  appDelegate.IncomeingCallInfo.count > 0 {
                    lblIncomeingNumber.text = appDelegate.IncomeingCallInfo["phone"] as? String ?? ""
                    lblNameCallingTime.text = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unkown"
                    
                    lblDialNumber.text = appDelegate.IncomeingCallInfo["phone"] as? String ?? ""
                    lblName.text = appDelegate.IncomeingCallInfo["name"] as? String ?? "Unkown"
                }
                
                let maistr = incomingCallId.components(separatedBy: "<")
                let newString = maistr[1].replacingOccurrences(of: "sip:", with: "", options: .literal, range: nil)
                
                let phonenumber = newString.components(separatedBy: "@")

                lblDialNumber.text = phonenumber[0]
                lblIncomeingNumber.text = phonenumber[0]
                imcomeingCallVW.isHidden = false
                CPPWrapper().call_listener_wrapper(call_status_listener_swift)
                
                numberStoreinDB = lblIncomeingNumber.text ?? ""
                
                lblTimer.text = "00:00:00"
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
                lblCalling.text = "Mobile Calling..."
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
            let numberarray = CPPWrapper.callNumber().components(separatedBy: ",")
            btncallinfo.isHidden = true
            if numberarray.count > 1 {
                btncallinfo.isHidden = false
                if isMargeCallDone == false {
                    isMargeCallDone = true
                    holdVW.isHidden = true
                    print(numberarray.count)
                    if numberarray.count < 3 {
                       swipeVW.isHidden = false
                       swipeVW.alpha = 1.0
                    }
                    btnMargeCall.alpha = 1.0
                    btnMargeCall.isHidden = false
                    lblSwipTimeFistCallType.text = "Hold"
                    lblSwipTimeSecondCallType.text = "Active"
                    hightMainSwip.constant = 150
                }
                //timer.invalidate()
            }else {
                if hightMainSwip.constant == 150 {
                    hightMainSwip.constant = 0
                    let newString = number.replacingOccurrences(of: "sip:", with: "", options: .literal, range: nil)
                    let phonenumber = newString.components(separatedBy: "@")
                    swipeVW.isHidden = true
                    holdVW.isHidden = false
                    btnMargeCall.isHidden = true
                    btnAddCall.isHidden = false
                    if phonenumber[0] == (lblSwipTimeFistNumber.text ?? "" ).suffix(10) {
                        CPPWrapper().unholdCall(0)
                    }
                    else if phonenumber[0] == (lblSwipTimeSecondNumber.text ?? "" ).suffix(10) {
                        CPPWrapper().unholdCall(1)
                    }
                }
            }
        }
        
        if isBluetoothPermissionGranted == true {
            manager = CBCentralManager()
            manager.delegate = self
        }
        
        mainVWSwipCall.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mainVWSwipCall.layer.cornerRadius = 5
        mainVWSwipCall.layer.borderWidth = 1.5
        hightMainSwip.constant = 0.0
        btncallinfo.isHidden = true
        swipeVW.isHidden = true
        callTimerStart()
//        callEndFind()
        lblSwipTimeFistName.text = "UnKown"
        lblSwipTimeFistNumber.text = phoneCode + number

//        allbtnDisalbe()
//        callPickupCheck()
        
        NotificationCenter.default.addObserver(self, selector: #selector(callAdd), name: Notification.Name("callAdd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transferCall), name: Notification.Name("transferCall"), object: nil)
    }
    
    @objc func transferCall(_ notification: NSNotification){
        self.dismiss(animated: false,completion: { [self] in
            sleep(1)
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
    }
        
    
    @objc func callAdd(_ notification: NSNotification){
        self.dismiss(animated: false,completion: { [self] in
            sleep(1)
            btnAddCall.isHidden = true
            btnMargeCall.isHidden = false
            btnMargeCall.alpha = 0.5
            holdVW.alpha = 0.5
            isMargeCallDone = false
            if let number = notification.userInfo?["number"] as? String {
                let num1 = number.replace(string: ")", replacement: "")
                let num2 = num1.replace(string: "(", replacement: "")
                let num3 = num2.replace(string: "-", replacement: "")
                let numbercall = "sip:\(phoneCode)\(num3)@\(Constant.GlobalConstants.SERVERNAME):\(Constant.GlobalConstants.PORT)"
                lblSwipTimeSecondName.text = notification.userInfo?["name"] as? String
                lblSwipTimeSecondNumber.text = phoneCode + num3
                callFistInfoVW.alpha  = 0.8
                CPPWrapper.addConfrenceAttendee(numbercall)
            }
        })
        
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
    
    func allbtnDisalbe(){
        swipeVW.alpha = 0.5
        holdVW.alpha = 0.5
        muteVW.alpha = 0.5
        spekerVW.alpha = 0.5
        addCallVW.alpha = 0.5
        keyBordVW.alpha = 0.5
        trasfterCallVW.alpha = 0.5
        recodCallVW.alpha = 0.5
    }
    
    func allbtnEnable(){
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
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
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
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
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
//        var _: Error?
//        try? session.setCategory(AVAudioSession.Category.playAndRecord)
//        try? session.setMode(AVAudioSession.Mode.voiceChat)
        if enabled {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } else {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        }
        try? session.setActive(true)
    }
    
    
    //MARK: - btn click
    
    @IBAction func btncallEed(_ sender: UIButton) {
        callLogStore()
        
//        sleep(1)
        CallKitDelegate.sharedInstance.endCall()

//        DispatchQueue.global(qos: .background).async {
            
//        }
       
        
        UIDevice.current.isProximityMonitoringEnabled = false
        self.dismiss(animated: true)
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
            sleep(1);
            CPPWrapper().holdCall(0)
        }else {
            IsHold = false
            sleep(1);
            CPPWrapper().unholdCall(0)
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
    
        sleep(3)
        
//        CPPWrapper.addConfrenceAttendee("919696969696")
//        print(CPPWrapper.callNumber())
        
    }
    
    @IBAction func btnmargeLine(_ sender: UIButton) {
        if btnMargeCall.alpha != 1.0 {
            return
        }
        
        swipeVW.isHidden = true
        btnMargeCall.isHidden = true
        
        if IsSwipCall == true {
            CPPWrapper().unholdCall(1)
        }else{
            CPPWrapper().unholdCall(0)
        }
        sleep(4)
        CPPWrapper.connectMedia()
        hightMainSwip.constant = 0.0

        btnAddCall.isHidden = false

    }
    
    @IBAction func btnCallNumPed(_ sender: UIButton) {
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
        
        
//        CPPWrapper.call_transfer_replaces(true)
//        //        viewSwipCallShow.isHidden = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//            let transfernumber = "<sip:91" + "89798797" + "@\(Constant.GlobalConstants.SERVERNAME)" + ":" + "\(Constant.GlobalConstants.PORT)>"
//            CPPWrapper.call_transfer(true, transfernumber)
//        })
        
    }
    
    @IBAction func btnswipCall(_ sender: UIButton) {
        if swipeVW.alpha != 1.0 {
            return
        }
        if IsSwipCall == false {
            IsSwipCall = true
            sleep(1);
            CPPWrapper().holdCall(1)
            sleep(1);
            CPPWrapper().unholdCall(0)
            lblSwipTimeFistCallType.text = "Active"
            lblSwipTimeSecondCallType.text = "Hold"
            callFistInfoVW.alpha  = 1.0
            callSecondInfoVW.alpha  = 0.8
        }else {
            IsSwipCall = false
            sleep(1);
            CPPWrapper().unholdCall(1)
            sleep(1);
            CPPWrapper().holdCall(0)
            lblSwipTimeFistCallType.text = "Hold"
            lblSwipTimeSecondCallType.text = "Active"
            callFistInfoVW.alpha  = 0.8
            callSecondInfoVW.alpha  = 1.0
        }
    }
        
    @IBAction func btnCallRecoding(_ sender: UIButton) {
        if recodCallVW.alpha != 1.0 {
            return
        }
        sender.isSelected  = !sender.isSelected

        if IsCallRecod == false {
            lblRecod.text = "Stop"
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
            lblRecod.text = "Record"
            IsCallRecod = false
            CPPWrapper.stopRecording(151)
        }
    }
    
    @IBAction func btnKeyBord(_ sender: UIButton) {
        CPPWrapper.send_dtmf(sender.titleLabel?.text ?? "")
        txtKeybordNumber.text =  (txtKeybordNumber.text ?? "" ) + (sender.titleLabel?.text ?? "")
    }
    
    @IBAction func btnInfoCall(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllCallNumberVC") as! AllCallNumberVC
        self.present(nextVC, animated: true)
    }
    

    //MARK: - incomeingCall
    @IBAction func btnAnsCall(_ sender: UIButton) {
        imcomeingCallVW.isHidden = true
        CPPWrapper().answerCall()
    }
    
    @IBAction func btnDeclineCall(_ sender: UIButton) {
//        callEndFind()
        callLogStore()
        
        CallKitDelegate.sharedInstance.endCall()
        CPPWrapper().hangupCall();
        UIDevice.current.isProximityMonitoringEnabled = false
        dismiss(animated: true)
    }
    
    
    //MARK: - Data base Funcation -----------------------------------------------------------------
    func callLogStore() {
        var callType = ""
        if incomingCallId == "" {
            callType = "Outgoing"
        }else{
            if imcomeingCallVW.isHidden == false {
                callType = "MissCall"
                lblTimer.text = "00:00:00"
            } else {
                callType = "Incoming"
            }
        }

        let dicCallLogData =  ["contact_name": "unknown", "charges": "0", "call_length": lblTimer.text, "type": callType, "created_date": todayYourDataFormat(dataformat: "MM-dd-yyyy HH:mm:ss"), "number": "\(numberStoreinDB)"]  as! [String:Any]
        DBManager().insertLog(dicLog: dicCallLogData)
        
        NotificationCenter.default.post(name: Notification.Name("callLogUpdata"), object: self, userInfo: nil)
    }
    
    func callRecording(dic:[String:Any]){
        
        let dicCallRecordingData =  ["date":dic["data"] as? String, "number":"\(numberStoreinDB)", "name": "unknown" ,"audio_name": dic["recoding_name"] as? String, "audioPath": dic["recoding_path"] as? String]  as! [String:Any]
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
//        if hours > 0 {
            lblTimer.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//        }else{
//            lblTimer.text = String(format: "%02d:%02d",minutes, seconds)
//        }
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
}
