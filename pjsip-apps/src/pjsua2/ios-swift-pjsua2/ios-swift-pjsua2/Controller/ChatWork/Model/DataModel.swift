//
//  DataModel.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 30/01/23.
//

import Foundation
import UIKit
import RealmSwift


class DataModel : Object{
    @Persisted var id: String
    @Persisted var chatID: String
    @Persisted var userID: String
    @Persisted var dateTime: String
    @Persisted var msgType: String
    @Persisted var message: String
    @Persisted var isSentSuccessFully: String
    @Persisted var senderID: String
    @Persisted var receiverID: String
    
    convenience init(id: String, chatID: String, userID: String, dateTime: String, msgType: String, message: String, isSentSuccessFully: String, senderID: String, receiverID: String) {
        self.init()
        self.id = id
        self.chatID = chatID
        self.userID = userID
        self.dateTime = dateTime
        self.msgType = msgType
        self.message = message
        self.isSentSuccessFully = isSentSuccessFully
        self.senderID = senderID
        self.receiverID = receiverID
    }
}
