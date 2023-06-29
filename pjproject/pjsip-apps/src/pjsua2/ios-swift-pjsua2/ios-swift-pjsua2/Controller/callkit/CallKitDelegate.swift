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

struct HashableCallUpdate: Hashable {
    let callUUID: UUID
    let localizedCallerName: String?
    // Include other properties from CXCallUpdate that you need for hash value calculation
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(callUUID)
        hasher.combine(localizedCallerName)
        // Include other properties for hash value calculation
    }
}

class CallKitDelegate: NSObject {
    
    static let sharedInstance = CallKitDelegate()
    var callObserver = CXCallObserver()
    var backgroundTaskID: UIBackgroundTaskIdentifier!
    var call: CXCall?
    
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
    private let serialQueue = DispatchQueue(label: "my.ios10.call.status.queue")
    
    private override init() {
        provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "TS Mobile"))
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
        
        CPPWrapper().call_listener_wrapper(call_status_listener_swift)
        
        let config = CXProviderConfiguration(localizedName: "CallDirectoryExtension")
        config.iconTemplateImageData = UIImage(named: "call_deactivate_icon")!.pngData()

        if #available(iOS 11.0, *) {
            config.includesCallsInRecents = true
        }
        config.supportsVideo = false
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.phoneNumber,.generic]

        self.provider = CXProvider(configuration: config)
        self.provider?.setDelegate(self, queue: nil)
        
        
        let update = CXCallUpdate()
        update.localizedCallerName = appDelegate.IncomeingCallInfo["name"] as? String ?? appDelegate.callKitTimeShowNumber;
        update.supportsDTMF = true
        update.remoteHandle = CXHandle(type: .generic, value: appDelegate.IncomeingCallInfo["name"] as? String ?? appDelegate.callKitTimeShowNumber)
        update.hasVideo = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = false
      
        appDelegate.sipRegistration()

        sleep(3)
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
    
    func callsInRecentsContactInLogAdd(){
        let endCallAction = CXEndCallAction(call: UUID())
        let transaction = CXTransaction(action: endCallAction)

        self.callKitCallController.request(transaction) { error in
            if let error = error {
                print("EndCallAction transaction request failed: \(error.localizedDescription)")
            } else {
                print("EndCallAction transaction request successful")
            }
        }
    }
    
    func dialCall(phoneNumber: String) {

            let handle = CXHandle(type: .generic, value: phoneNumber)
            let startCallAction = CXStartCallAction(call: UUID(), handle: handle)

            let transaction = CXTransaction(action: startCallAction)

        callKitCallController.request(transaction) { error in
                if let error = error {
                    print("Error requesting transaction: \(error)")
                } else {
                    print("Call started successfully")
                }
            }
        }
    
    
    @objc func endCall() {
//        guard uuid != nil else {return}
        if uuid == nil {
           return
        }
        let handle = CXHandle(type: .generic, value: appDelegate.IncomeingCallInfo["phone"] as? String ?? appDelegate.callKitTimeShowNumber)
        let startCallAction = CXStartCallAction(call: uuid!, handle: handle)

        let transaction = CXTransaction(action: startCallAction)
        CXCallController().request(transaction) { (error) in
            if let _ = error {
                self.provider?.reportCall(with: self.uuid!, endedAt: Date(), reason: .remoteEnded)
                self.uuid = nil
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
        dialCall(phoneNumber: appDelegate.IncomeingCallInfo["phone"] as? String  ?? "")
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
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        CPPWrapper().hangupCall()
        endCall()
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
//            CPPWrapper().holdCall(0)
        }else {
            IsHold = false
            sleep(1);
//            CPPWrapper().unholdCall(0)
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
extension AVAudioSession {
    static var connectedHeadphones: AVAudioSessionPortDescription? {
        return sharedInstance().currentRoute.outputs.first(where: { $0.isHeadphones })
    }
}
extension AVAudioSessionPortDescription {
    var isHeadphones: Bool {
        return portType == AVAudioSession.Port.headphones || portType == AVAudioSession.Port.bluetoothA2DP
    }
}
class CustomCallDirectoryProvider: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        let labelsKeyedByPhoneNumber: [CXCallDirectoryPhoneNumber: String] = [ : ]
        for (phoneNumber, label) in labelsKeyedByPhoneNumber.sorted(by: <) {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
        }

        context.completeRequest()
    }
}
