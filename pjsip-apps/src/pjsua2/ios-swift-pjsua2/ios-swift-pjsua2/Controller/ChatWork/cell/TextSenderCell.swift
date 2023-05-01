//
//  TextSenderCell.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 01/02/23.
//

import UIKit

class TextSenderCell: UITableViewCell {
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgDoubleTic: UIImageView!
    @IBOutlet weak var chatVW: UIView!
    
        
    
    class func height(_ messagesView: ChatVc, at indexPath: IndexPath) -> CGFloat {
        let size = self.size(messagesView, at: indexPath)
        return size.height + 15
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    class func size(_ messagesView: ChatVc, at indexPath: IndexPath) -> CGSize {
        let rcmessage = messagesView.rcmessageAt(indexPath)
        if rcmessage.message == "" {
            return CGSize.zero
        }else {
            return calculate(rcmessage)
        }
        
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    private class func calculate(_ rcmessage: DataModel) -> CGSize {

        let maxwidth = RCKit.textBubbleWidthMax - RCKit.textInsetLeft - RCKit.textInsetRight

        let rect = rcmessage.message.boundingRect(with: CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: RCKit.textFont], context: nil)

        let width = rect.size.width + RCKit.textInsetLeft + RCKit.textInsetRight
        let height = rect.size.height + RCKit.textInsetTop + RCKit.textInsetBottom

        let widthBubble = CGFloat.maximum(width, RCKit.textBubbleWidthMin)
        let heightBubble = CGFloat.maximum(height, RCKit.textBubbleHeightMin)

        return  CGSize(width: widthBubble, height: heightBubble)
    }
    
}
