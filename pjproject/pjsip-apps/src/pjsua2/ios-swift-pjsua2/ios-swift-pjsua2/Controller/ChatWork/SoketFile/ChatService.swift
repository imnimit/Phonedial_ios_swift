//
//  ChatService.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 27/01/23.
//

import Foundation
import SocketIO
import Network
import StoreKit

class ChatService: NSObject {
    static let sharedInstance = ChatService()
    let socket = SocketManager(socketURL: URL(string: ChatConstanct.URLChat.SocketURL)!, config: [.log(false), .compress])
    var mSocket: SocketIOClient!

    override init() {
        super.init()
        mSocket = socket.defaultSocket
    }

    func getSocket() -> SocketIOClient {
        return mSocket
    }

    func establishConnection() {
        mSocket.connect()
  
    }

    func closeConnection() {
        mSocket.disconnect()
    }
    
    func sendMessage(message: String, withNickname nickname: String) {
        mSocket.emit("chatMessage", nickname, message)
    }
    
}

class ChatHistory: NSObject {
    static let sharedInstance = ChatHistory()
    let socketH = SocketManager(socketURL: URL(string: ChatConstanct.URLChat.SocketURL)!, config: [.log(false), .compress])
    var mSocketH: SocketIOClient!

    override init() {
        super.init()
        mSocketH = socketH.defaultSocket
    }

    func getSocket() -> SocketIOClient {
        return mSocketH
    }

    func establishConnection() {
        mSocketH = socketH.socket(forNamespace: "/history")
        mSocketH.connect()
    }

    func closeConnection() {
        mSocketH.disconnect()
    }
    
    func sendMessage(message: String, withNickname nickname: String) {
        mSocketH.emit("chatMessage", nickname, message)
    }
}
