//
//  CallKitDelegate.swift
//  CallKitSample
//
//  Created by Mathews on 06/07/18.
//  Copyright © 2018 mathews. All rights reserved.
//

import Foundation
import UIKit
import CallKit
import AVFAudio
import DeviceCheck

class CallKitDelegate: NSObject {
    
    static let sharedInstance = CallKitDelegate()
    var callObserver = CXCallObserver()
    var backgroundTaskID: UIBackgroundTaskIdentifier!

    var IsMuted:Bool = false
    var IsHold:Bool = false
    var IsSpeker:Bool = false
    var IsCallRecod:Bool = false
    var IsSwipCall:Bool = false

    let deviceCheck = DCDevice()
    
    fileprivate var uuid: UUID?
    fileprivate var provider: CXProvider?
    let callKitCallController: CXCallController
    var isappLock = false
    
    
    override init() {
        provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "Phone Dial"))
        callKitCallController = CXCallController()


        // Initialize the superclass
        super.init()

    }
    
    
   

    static var providerConfiguration: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "vKclub dev2")
        
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        return providerConfiguration
    }
    
    
    func reportIncomingCall(completionHandler: @escaping ()->Void) {
        configureAudioSession()
        
        let config = CXProviderConfiguration(localizedName: "CallDirectoryExtension")
        config.iconTemplateImageData = UIImage(named: "call_deactivate_icon")!.pngData()

        if #available(iOS 11.0, *) {
            config.includesCallsInRecents = false
        }
        config.supportsVideo = false
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.phoneNumber]
        self.provider = CXProvider(configuration: config)
        self.provider?.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.supportsDTMF = true
        update.remoteHandle = CXHandle(type: .generic, value: appDelegate.IncomeingCallInfo["name"] as? String ?? "Unkown")
        update.hasVideo = false
        self.uuid = UUID()
        self.provider?.reportNewIncomingCall(with: self.uuid!, update: update) { (error) in
            
            if error == nil {
                self.configureAudioSession()
            }
            
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                // Initiate PJSIP call here
               appDelegate.sipRegistration()
            }

            completionHandler()
        }
    }
   
    
   
    
    
    
    @objc func endCall() {
        guard uuid != nil else {return}
        let endCallAction = CXEndCallAction(call: self.uuid!)
        let transaction = CXTransaction(action: endCallAction)
        CXCallController().request(transaction) { (error) in
            if let _ = error {
                self.provider?.reportCall(with: self.uuid!, endedAt: Date(), reason: .remoteEnded)
                return
            }
        }
    }
        
    
    
   
}

extension CallKitDelegate: CXProviderDelegate {
    @available(iOS 10.0, *)
    func providerDidReset(_ provider: CXProvider) {
    
    }
    
    @available(iOS 10.0, *)
    func providerDidBegin(_ provider: CXProvider) {
    }
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
       
        
    }
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        appDelegate.callComePushNotification = true
        //   CPPWrapper().answerCall()
        configureAudioSession()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: { [self] in
            if (CPPWrapper().registerStateInfoWrapper()) {
                if CPPWrapper().checkCallConnected() == true {
                    appDelegate.loadCallerController(checkLockOrUnlock: false) // Change
                }
            } else {
                print("Sip Status: NOT REGISTERED")
            }
        })
      
        action.fulfill()
    }
    
    func showPhoneState(_ deviceLockState: DeviceLockState) -> Bool {
        switch deviceLockState {
        case .locked:
            print("locked")
            return true
        case .unlocked:
            print("Unlocked")
            return false
        }
    }
    
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        CPPWrapper().hangupCall()
        sleep(1)
        UIDevice.current.isProximityMonitoringEnabled = false
        action.fulfill()
    }
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
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
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        configureAudioSession1()
        /// Mead  by Shubham prakh 
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        if IsMuted == false {
            IsMuted = true
            CPPWrapper().callmute()
        } else {
            IsMuted = false
            CPPWrapper().callunmute()
        }
    }
    
    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try? session.setCategory(AVAudioSession.Category.playAndRecord)
            try? session.setMode(AVAudioSession.Mode.voiceChat)
            try? session.setPreferredSampleRate(44100.0)
            try? session.setPreferredIOBufferDuration(0.005)
            try? session.setActive(true)
        }
    }
    
    func configureAudioSession1() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            setAudioOutputSpeaker(enabled: false)

        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
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
}
