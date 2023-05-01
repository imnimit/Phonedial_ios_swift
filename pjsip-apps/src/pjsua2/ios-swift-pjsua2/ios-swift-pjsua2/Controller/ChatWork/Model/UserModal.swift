//
//  UserModal.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 30/01/23.
//

import Foundation
import UIKit
import RealmSwift


class UserModal : Object{
    @Persisted var id: String
    @Persisted var receiverIdForChat: String
    @Persisted var contactNumber: String
    @Persisted var contactName: String
    @Persisted var lastChatDateTime: String
    @Persisted var lastMessage: String
    @Persisted var lastMessageType: String
    @Persisted var chatCounter: String
    @Persisted var roomID: String
    
    convenience init(id: String, receiverIdForChat: String, contactNumber: String, contactName: String, lastChatDateTime: String, lastMessage: String, lastMessageType: String, chatCounter: String, roomID: String) {
        self.init()
        self.id = id
        self.receiverIdForChat = receiverIdForChat
        self.contactNumber = contactNumber
        self.contactName = contactName
        self.lastChatDateTime = lastChatDateTime
        self.lastMessage = lastMessage
        self.lastMessageType = lastMessageType
        self.chatCounter = chatCounter
        self.roomID = roomID
    }
}
