//
//  VideoSenderSideCell.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 08/02/23.
//

import UIKit
import AVKit
import ProgressHUD


class VideoSenderSideCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var backSideVW: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgDoubleTic: UIImageView!
    @IBOutlet weak var imageViewPlay: UIImageView!
    private var activityIndicator: UIActivityIndicatorView!
    
    var player: AVPlayer?

    @IBOutlet weak var btnVedioNotLoadTime: UIButton!
    
    var LoaderActinoAction: (()->())?
    
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
        LoaderActinoAction!()
    }
    
   
}
