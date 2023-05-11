//
//  ImgeSenderSideCell.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 03/02/23.
//

import UIKit
import SDWebImage


class ImgeSenderSideCell: UITableViewCell {
    @IBOutlet weak var backSideVW: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgDoubleTic: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    var LoaderActinoAction: (()->())?

    @IBOutlet weak var btnVedioNotLoadTime: UIButton!
    
    var isRunning : Bool = false {
            didSet {
                isRunning ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            }
        }
    
    override func awakeFromNib() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        activityIndicator.center.x = backSideVW.layer.bounds.width / 2
        activityIndicator.center.y = backSideVW.layer.bounds.height / 2
        
        
        backSideVW.addSubview(activityIndicator)
    }
    

    @IBAction func btnDownloadVedio(_ sender: UIButton) {
        isRunning = true
    }
    
    
    
}
