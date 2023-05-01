//
//  MediaModel.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 30/01/23.
//

import Foundation
import UIKit
import RealmSwift

class MediaModel : Object{
    @Persisted var id: String
    @Persisted var chatID: String
    @Persisted var msgType: String
    @Persisted var mediaURL: String
    @Persisted var localPath: String
    @Persisted var fileSize: String
    @Persisted var isDownloaded: String
    @Persisted var isVedioImage64Encoding: String
    
    convenience init(id: String, chatID: String, msgType: String, mediaURL: String, localPath: String, fileSize: String, isDownloaded: String,isVedioImage64Encoding: String) {
        self.init()
        self.id = id
        self.chatID = chatID
        self.msgType = msgType
        self.mediaURL = mediaURL
        self.localPath = localPath
        self.fileSize = fileSize
        self.isDownloaded = isDownloaded
        self.isVedioImage64Encoding = isVedioImage64Encoding
    }
}


