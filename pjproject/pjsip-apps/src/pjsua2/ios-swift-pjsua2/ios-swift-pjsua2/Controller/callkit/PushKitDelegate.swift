//
//  PushKitDelegate.swift
//  CallKitSample
//
//  Created by Mathews on 06/07/18.
//  Copyright © 2018 mathews. All rights reserved.
//

import Foundation
import UIKit
import PushKit
import UserNotifications
import CallKit

class PushKitDelegate: NSObject {
    
    static let sharedInstance = PushKitDelegate()
    var timer2 = Timer()
    var seconds2 = 0
    var isPushNotificationCallReceived = false
    
    func registerPushKit() {
        if #available(iOS 8.0, *) {
            let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
            voipRegistry.delegate = self
            voipRegistry.desiredPushTypes = [PKPushType.voIP]
        }
    }
}

extension PushKitDelegate: PKPushRegistryDelegate {
    
    @available(iOS 8.0, *)   
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        appDelegate.pushKitTokan = deviceToken
        print("pushRegistry -> deviceToken :\(deviceToken)")
    }
    
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        let callData = payload.dictionaryPayload
        CallKitDelegate.sharedInstance.reportIncomingCall {
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print(payload.dictionaryPayload)
        CPPWrapper.clareAllData()
        appDelegate.providerDelegate = ProviderDelegate(callManager: appDelegate.callManager)
        
        let callData = payload.dictionaryPayload
        let aps = callData["aps"] as! [String:Any]
        let alert = aps["alert"] as! [String:Any]
        print(alert)
        if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
            let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
            let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == (alert["subtitle"] as? String ?? "").suffix(10)})
            if index != nil {
                appDelegate.IncomeingCallInfo = contactList[index!]
            }
        }
        
        appDelegate.callKitTimeShowNumber = (alert["subtitle"] as? String ?? "")
        appDelegate.callComePushNotification = true
        
        //        let bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        
        appDelegate.callComePushNotification = true
        
        appDelegate.displayIncomingCall(
            uuid: UUID(),
            handle: appDelegate.IncomeingCallInfo["name"] as? String ?? appDelegate.callKitTimeShowNumber,
            hasVideo:((alert["calltype"] as? String ?? "" ) == "audio" ) ? false : true
        ) { _ in
        }
        
    }
    
   
    

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("Invalidated for type: \(type)")
    }
    
    func pushRegistry(registry: PKPushRegistry!, didUpdatePushCredentials credentials: PKPushCredentials!, forType type: String!){

    }
    
    // MARK: - PushCallNotifierDelegate -
    func handlePushNotification(_ pushPayload: [AnyHashable : Any], withPushCompletion pushProcessingCompletion: (()->Void)?) {

    }
    
}
protocol PushCallNotifierDelegate: AnyObject {
    func didReceiveIncomingCall(
        _ uuid: UUID,
        from fullUsername: String,
        withDisplayName userDisplayName: String,
        withPushCompletion pushProcessingCompletion: (() -> Void)?
    )
}
