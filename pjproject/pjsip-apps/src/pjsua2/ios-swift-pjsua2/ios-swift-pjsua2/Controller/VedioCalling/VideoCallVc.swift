//
//  VideoCallVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 24/04/23.
//

import UIKit
import AVFAudio

var vc_inst: VideoCallVc! = nil;


func preview_updata_listener_swift(window: UnsafeMutableRawPointer?) {
    DispatchQueue.main.async () {
        let vid_view:UIView =
            Unmanaged<UIView>.fromOpaque(window!).takeUnretainedValue();
        VideoCallVc.sharedInstance.updateDData(vid_win: vid_view);
    }
}

class VideoCallVc: UIViewController {

    @IBOutlet weak var displayVW: UIView!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblCallState: UILabel!
    @IBOutlet weak var priviewVW: UIView!
    @IBOutlet weak var downSideVW: UIView!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var nameVW: UIView!
    @IBOutlet weak var lblNameLetter: UILabel!
    @IBOutlet weak var lblPreViewBoxNumber: UILabel!
    @IBOutlet weak var mainVWPriview: UIView!
    
    static let sharedInstance = VideoCallVc()
    
    var isFrontCamera = true
    var holdFlag = false
    var IsHold  = false
    var IsMuted = false
    var IsSpeaker = true
    var number = ""
    var phoneCode = ""
    var timerStore = ""
    var name = ""
    
    var seconds  = 0
    var minutes = 0
    var hours = 0
    var timer = Timer()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let a = number.components(separatedBy: "sip:")
        let newString = a[1].components(separatedBy: "@")
        lblNumber.text = newString[0]
        
        mainVWPriview.layer.cornerRadius = 15
        
        downSideVW.clipsToBounds = true
        downSideVW.layer.cornerRadius = 50
        downSideVW.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        mainVWPriview.layer.borderColor = #colorLiteral(red: 0.01609096117, green: 0.4797518253, blue: 0.6173341274, alpha: 1)
        mainVWPriview.layer.borderWidth = 1.5
        
        configureAudio()
       // CPPWrapper().callunmute()
        
        setAudioOutputSpeaker(enabled: true)
        
        if AppDelegate.instance.isVideoCallMute == true {
            IsMuted = false
            CPPWrapper().callunmute()
            btnMute.isSelected = true
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)

        
        if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
            let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
            let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == lblNumber.text!.suffix(10)})
            if index != nil {
                appDelegate.IncomeingCallInfo = contactList[index!]
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(callVideoAdd), name: Notification.Name("callVideoAdd"), object: nil)
        CPPWrapper().preview_updata_listener_wrapper(preview_updata_listener_swift)

        
        lblNameLetter.text = findNameFistORMiddleNameFistLetter(name: appDelegate.IncomeingCallInfo["name"] as? String ?? "Unknown")
        
        nameVW.layer.cornerRadius = nameVW.layer.bounds.height/2
        
        lblPreViewBoxNumber.text = lblNumber.text
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIDevice.current.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        CPPWrapper().hangupCall();
    }
    
    @objc func callVideoAdd(_ notification: NSNotification){
        self.dismiss(animated: false,completion: { [self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
                let dictValue = UserDefaults.standard.value(forKey: "loginCheckKey") as? [String: Any]
                print(dictValue!)
                if let number = notification.userInfo?["number"] as? String {
                    let num1 = number.replace(string: ")", replacement: "")
                    let num2 = num1.replace(string: "(", replacement: "")
                    let num3 = num2.replace(string: "-", replacement: "")
                    let numbercall = "sip:\(phoneCode)\(num3)@\(dictValue!["hostName"] as? String ?? ""):\(dictValue!["portNumber"] as? String ?? "")"
                    CPPWrapper().outgoingCall(numbercall, "1")
                }
            })
        })
    }
    
    
    func updateVideo(vid_win: UIView!) {
        displayVW.addSubview(vid_win);
        vid_win.center = displayVW.center;
        vid_win.frame = displayVW.bounds;
        vid_win.contentMode = .scaleAspectFit;
    }
    
    func updateDVideo(vid_win: UIView!) {
        priviewVW.addSubview(vid_win);
        vid_win.center = priviewVW.center;
        vid_win.frame = priviewVW.bounds;
        vid_win.contentMode = .scaleAspectFill;
        
        addPanGestureOnOwnVideoPreview()
        
        let transform = CGAffineTransform(scaleX: -1, y: 1)
        priviewVW.transform = transform;
    }
    
    func updateDData(vid_win: UIView!) {
        priviewVW = vid_win
    }
    
    
    private func addPanGestureOnOwnVideoPreview(){
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        mainVWPriview?.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer){
        let translation = gestureRecognizer.translation(in: displayVW!)
        dragOnPanGesture(gestureRecognizer, translation)
    }
    
    private func dragOnPanGesture(_ gestureRecognizer: UIPanGestureRecognizer,
                                  _ translation: CGPoint) {
        let yPosition = gestureRecognizer.view!.center.y + translation.y
        let xPosition = gestureRecognizer.view!.center.x + translation.x
        
        gestureRecognizer.view!.center.x=xPosition
        gestureRecognizer.view!.center.y=yPosition
        gestureRecognizer.setTranslation(CGPoint.zero, in: displayVW!)
    }
    
    func callDismiss(){
        self.dismiss(animated: true, completion: {
            UIApplication.shared.windows.first { $0.isKeyWindow}?.rootViewController?.dismiss(animated: false, completion: nil)
        })
    }
    
    
    //MARK: - bnt Click
    @IBAction func hangupClick(_ sender: UIButton) {
        callLogStore()
        
        CPPWrapper().hangupCall()
        for call in appDelegate.callManager.calls {
            appDelegate.callManager.end(call: call)
            appDelegate.callManager.remove(call: call)
        }
    }
    
    @IBAction func btnPriviewHideShow(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            CPPWrapper.previewHide();
        }else{
            CPPWrapper.previewShow();
        }
    }
    
    
    
    @IBAction func btnTapCameraFlip(_ sender: UIButton) {
        sender.isSelected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sender.isSelected = false
        }
        if isFrontCamera == true {
            isFrontCamera = false
            let transform = CGAffineTransform(scaleX: 1, y: 1)
            priviewVW.transform = transform;
            CPPWrapper.swapCamera("3")
        }else{
            isFrontCamera = true
            CPPWrapper.swapCamera("2")
            let transform = CGAffineTransform(scaleX: -1, y: 1)
            priviewVW.transform = transform;
        }
      print("Button tapped")
    }
    
    @IBAction func btnSoundMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if IsMuted == false {
            IsMuted = true
            CPPWrapper().callmute()
        } else {
            IsMuted = false
            CPPWrapper().callunmute()
        }
        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
//            try AVAudioSession.sharedInstance().setActive(!IsMuted)
//        } catch { print(error.localizedDescription) }
    }
    
    @IBAction func btnHold(_ sender: UIButton) {
        sender.isSelected  = !sender.isSelected
        if IsHold == false {
            IsHold = true
//            CPPWrapper().holdCall(0) // Change
        }else {
            IsHold = false
//            CPPWrapper().unholdCall(0) // Change
        }
    }
    
    @IBAction func btnSpeaker(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if IsSpeaker == false {
            IsSpeaker = true
            setAudioOutputSpeaker(enabled: true)
        }else{
            IsSpeaker = false
            setAudioOutputSpeaker(enabled: false)
        }
    }
    
    @IBAction func btnAddContact(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactsVc") as! ContactsVc
        nextVC.navigationBarnotShow = true
        nextVC.isInvitedBtnShow = false
        nextVC.isFavoriteBtnShow = true
        nextVC.isContectNumberShow = false
        nextVC.isShowTopNavigationBar = true
        nextVC.iscallVideoAdd = true
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true)
    }
    
    
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
    
    
    func callLogStore() {
        var callType = ""
        if appDelegate.isVidoeCallIncomeing == false {
            callType = "Outgoing"
        }else{
            callType = "Incoming"
        }

        let dicCallLogData =  ["contact_name": appDelegate.IncomeingCallInfo["name"] as? String ?? "Unknown", "charges": "0", "call_length": timerStore, "type": callType, "created_date": todayYourDataFormat(dataformat: "MM-dd-yyyy HH:mm:ss"), "number": lblNumber.text ?? "","type_log":"VidoeCall"]  as! [String:Any]
        DBManager().insertLog(dicLog: dicCallLogData)
        
        NotificationCenter.default.post(name: Notification.Name("callLogUpdata"), object: self, userInfo: nil)
    }
    
}
extension VideoCallVc {
    @objc func onTimer() {
        seconds += 1
        timerStore = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        lblCallState.text = timerStore
        
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
