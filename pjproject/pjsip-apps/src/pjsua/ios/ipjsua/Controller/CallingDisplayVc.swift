//
//  CallingDisplayVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 18/11/22.
//

import UIKit
import AVFAudio

class CallingDisplayVc: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var txtKeybordNumber: UITextField!
    @IBOutlet weak var callVW: UIView!
    @IBOutlet weak var numPedVW: UIView!
    
    
    var IsMuted:Bool = false
    var IsHold:Bool = false
    var IsSpeker:Bool = false
    var IsCallRecod:Bool = false
    
    var number = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNumber.text = number
        
//        if (CPPWrapper().registerStateInfoWrapper()){
//            CPPWrapper().outgoingCall("sip:91" + number + "@\(Constant.GlobalConstants.SERVERNAME)" + ":" + "\(Constant.GlobalConstants.PORT)")
//            CPPWrapper().call_listener_wrapper(call_status_listener_swift)
//            
//        }else {
//            self.showToast(message: "Sip Status: NOT REGISTERED")
//        }
        
        
    }
    
   /*
    override func viewDidDisappear(_ animated: Bool) {
        if (CPPWrapper().registerStateInfoWrapper()){
            CPPWrapper().hangupCall();
        }
    }
    
    
    @IBAction func btncallEed(_ sender: UIButton) {
        CPPWrapper().hangupCall();
        UIDevice.current.isProximityMonitoringEnabled = false
        self.dismiss(animated: true)
    }
    
    @IBAction func btnMute(_ sender: UIButton) {
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
        sender.isSelected  = !sender.isSelected
        if IsHold == false {
            IsHold = true
            sleep(1);
            CPPWrapper().holdCall()
        }else {
            IsHold = false
            sleep(1);
            CPPWrapper().unholdCall()
        }
    }
    
    @IBAction func btnCallSpeker(_ sender: UIButton) {
        sender.isSelected  = !sender.isSelected
        if IsSpeker == false {
            IsSpeker = true
            setAudioOutputSpeaker(enabled: IsSpeker)
        }else {
            IsSpeker = false
            setAudioOutputSpeaker(enabled: IsSpeker)
        }
    }
 
    @IBAction func btnCallMearge(_ sender: UIButton) {
        sender.isSelected  = !sender.isSelected
        CPPWrapper.addConfrenceAttendee("917886958659")
        sender.isHidden = true
        
        
        
    }
    
    
    @IBAction func btnmargeLine(_ sender: UIButton) {
        CPPWrapper().unholdCall()
        sleep(2)
        CPPWrapper.connectMedia()
    }
    
    @IBAction func btnCallNumPed(_ sender: UIButton) {
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
        
        CPPWrapper.call_transfer_replaces(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            let transfernumber = "<sip:91" + "9974465535" + "@\(Constant.GlobalConstants.SERVERNAME)" + ":" + "\(Constant.GlobalConstants.PORT)>"
            CPPWrapper.call_transfer(true, transfernumber)
        })
    }
    
    
    @IBAction func btnCallRecoding(_ sender: UIButton) {
        sender.isSelected  = !sender.isSelected

        if IsCallRecod == false {
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
            
            CPPWrapper.startRecording(151, userfilename: strFileName)
        }else {
            IsCallRecod = false
            CPPWrapper.stopRecording(151)
        }
        
    }
    
    @IBAction func btnKeyBord(_ sender: UIButton) {
        txtKeybordNumber.text =  (txtKeybordNumber.text ?? "" ) + (sender.titleLabel?.text ?? "")
    }
    
    
    
    //MARK: - Manual Speaker Enagle and Disable
    func setAudioOutputSpeaker(enabled: Bool) {
        let session = AVAudioSession.sharedInstance()
        var _: Error?
        try? session.setCategory(AVAudioSession.Category.playAndRecord)
        try? session.setMode(AVAudioSession.Mode.voiceChat)
        if enabled {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } else {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        }
        try? session.setActive(true)
    }
    
    
    
    
   
    
    
    
*/
    
}
