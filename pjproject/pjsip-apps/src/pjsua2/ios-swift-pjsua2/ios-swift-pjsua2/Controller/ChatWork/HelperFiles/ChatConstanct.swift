//
//  ChatConstanct.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 27/01/23.
//

import Foundation
import UIKit

class ChatConstanct: NSObject {
    struct URLChat {
        static let SocketURL = "http://192.168.1.76:7000/" //"http://socket.nyerhosmobile.com:7000/"
    }
    
    struct EventListener {
        static let Joint =  "join"
        static let TypeStatus = "type_status"
        static let SendMSG = "send_msg_chat"
        static let LEAVE =  "leave"
        static let DELETESINGLECHATFROMONESIDE =  "delete_single_chat_from_oneside"
        static let DELETEMSG =  "delete_message"
        static let DELETEALL = "delete_all_chats_from_oneside"
        static let DELETEGROP =  "delete_group"
    }
    
    struct EventListenerHistroy {
        static let HISTORY = "history"
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    struct App {
        static let DefaultTab        = 0
        static let MaxVideoDuration    = TimeInterval(30)
        static let TextShareApp        = "Check out https://related.chat"
    }
    
    struct FileTypes {
        static let TEXT_MESSAGE = "0"
        static let IMAGE_MESSAGE = "1"
        static let FILE_MESSAGE = "2"
        static let VIDEO_MESSAGE = "3"
        static let AUDIO_MESSAGE = "4"
    }
}
//-----------------------------------------------------------------------------------------------------------------------------------------------
enum RCKit {

    // General
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var widthScreen                    = UIScreen.main.bounds.size.width
    static var heightScreen                    = UIScreen.main.bounds.size.height

    // Section
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var sectionHeaderMargin            = CGFloat(8)
    static var sectionFooterMargin            = CGFloat(20)

    // Header upper
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var headerUpperHeight            = CGFloat(20)
    static var headerUpperLeft                = CGFloat(10)
    static var headerUpperRight                = CGFloat(10)

    static var headerUpperColor                = UIColor.lightGray
    static var headerUpperFont                = UIFont.systemFont(ofSize: 12)

    // Header lower
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var headerLowerHeight            = CGFloat(15)
    static var headerLowerLeft                = CGFloat(50)
    static var headerLowerRight                = CGFloat(50)

    static var headerLowerColor                = UIColor.lightGray
    static var headerLowerFont                = UIFont.systemFont(ofSize: 12)

    // Footer upper
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var footerUpperHeight            = CGFloat(15)
    static var footerUpperLeft                = CGFloat(50)
    static var footerUpperRight                = CGFloat(50)

    static var footerUpperColor                = UIColor.lightGray
    static var footerUpperFont                = UIFont.systemFont(ofSize: 12)

    // Footer lower
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var footerLowerHeight            = CGFloat(15)
    static var footerLowerLeft                = CGFloat(10)
    static var footerLowerRight                = CGFloat(10)

    static var footerLowerColor                = UIColor.lightGray
    static var footerLowerFont                = UIFont.systemFont(ofSize: 12)

    // Bubble
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var bubbleMarginLeft                = CGFloat(40)
    static var bubbleMarginRight            = CGFloat(40)
    static var bubbleRadius                    = CGFloat(15)

    // Avatar
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var avatarDiameter                = CGFloat(30)
    static var avatarMarginLeft                = CGFloat(5)
    static var avatarMarginRight            = CGFloat(5)

    static var avatarBackColor                = UIColor.lightGray
    static var avatarTextColor                = UIColor.white

    static var avatarFont                    = UIFont.systemFont(ofSize: 12)

    // Text cell
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var textBubbleWidthMax            = 0.70 * widthScreen
    static var textBubbleWidthMin            = CGFloat(45)
    static var textBubbleHeightMin            = CGFloat(35)

    static var textBubbleColorOutgoing        = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static var textBubbleColorIncoming        = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

    static var textTextColorOutgoing        = UIColor.white
    static var textTextColorIncoming        = UIColor.black

    static var textFont                        = UIFont.systemFont(ofSize: 15)

    static var textInsetLeft                = CGFloat(10)
    static var textInsetRight                = CGFloat(10)
    static var textInsetTop                    = CGFloat(10)
    static var textInsetBottom                = CGFloat(10)

    static var textInset = UIEdgeInsets.init(top: textInsetTop, left: textInsetLeft, bottom: textInsetBottom, right: textInsetRight)

    // Photo cell
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var photoBubbleWidth                = 0.70 * widthScreen

    static var photoBubbleColorOutgoing        = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static var photoBubbleColorIncoming        = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

    static var photoImageManual                = UIImage(named: "rckit_manual")!

    // Anim cell
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var animBubbleWidth                = 0.70 * widthScreen

    static var animBubbleColorOutgoing        = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static var animBubbleColorIncoming        = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

    static var animImageManual                = UIImage(named: "rckit_manual")!

    // Video cell
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var videoBubbleWidth                = 0.70 * widthScreen
    static var videoBubbleHeight            = 0.70 * widthScreen

    static var videoBubbleColorOutgoing        = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static var videoBubbleColorIncoming        = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

    static var videoImagePlay                = UIImage(named: "rckit_videoplay")!
    static var videoImageManual                = UIImage(named: "rckit_manual")!

    // Audio cell
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var audioBubbleWidht                = CGFloat(150)
    static var audioBubbleHeight            = CGFloat(40)

    static var audioBubbleColorOutgoing        = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static var audioBubbleColorIncoming        = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

    static var audioTrackColorOutgoing        = UIColor.white
    static var audioTrackColorIncoming        = UIColor.white
    static var audioProgressColorOutgoing    = UIColor.lightGray
    static var audioProgressColorIncoming    = UIColor.lightGray

    static var audioDurationColorOutgoing    = UIColor.white
    static var audioDurationColorIncoming    = UIColor.black

    static var audioImagePlay                = UIImage(named: "rckit_audioplay")!
    static var audioImagePause                = UIImage(named: "rckit_audiopause")!
    static var audioImageManual                = UIImage(named: "rckit_manual")!

    static var audioFont                    = UIFont.systemFont(ofSize: 12)

    // Sticker cell
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var stickerBubbleWidth            = 0.50 * widthScreen
    static var stickerBubbleHeight            = 0.50 * widthScreen

    static var stickerBubbleColorOutgoing    = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static var stickerBubbleColorIncoming    = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

    static var stickerImageManual            = UIImage(named: "rckit_manual")!

    // Activity indicator
    //-------------------------------------------------------------------------------------------------------------------------------------------
    static var activityColorOutgoing        = UIColor.white
    static var activityColorIncoming        = UIColor.darkGray
}
