//
//  RCMessage.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 31/01/23.
//

import Foundation
class RCMessage: NSObject {
    var id = ""
    var chatID = ""
    var userID = ""
    var dateTime = ""
    var msgType = ""
    var message = ""
    var isSentSuccessFully = ""
    var senderID = ""
    var receiverID = ""
    var sizeBubble = CGSize.zero

    //-------------------------------------------------------------------------------------------------------------------------------------------
    override init() {

        super.init()
    }

    
    init(_ dbmessage: DBMessageText) {
        id = dbmessage.id
        chatID = dbmessage.chatID
        userID = dbmessage.userID
        dateTime = dbmessage.dateTime
        msgType = dbmessage.msgType
        message = dbmessage.message
        isSentSuccessFully = dbmessage.isSentSuccessFully
        senderID = dbmessage.senderID
        receiverID = dbmessage.receiverID
    }
    
}
class DBMessageText: NSObject {
    
    var id = ""
    var chatID = ""
    var userID = ""
    var dateTime = ""
    var msgType = ""
    var message = ""
    var isSentSuccessFully = ""
    var senderID = ""
    var receiverID = ""
    
}
