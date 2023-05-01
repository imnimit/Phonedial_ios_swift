//
//  VideoReceiverSideCell.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 08/02/23.
//

import UIKit
import AVKit


class VideoReceiverSideCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var backSideVW: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imageViewPlay: UIImageView!
    private var activityIndicator: UIActivityIndicatorView!
    
    var player: AVPlayer?
    
    
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
    
    
    @IBOutlet weak var btnVedioNotLoadTime: UIButton!
    
    @IBAction func btnDownloadVedio(_ sender: UIButton) {
        LoaderActinoAction!()
        
//        if #available(iOS 13.0, *) {
//            activityIndicator = UIActivityIndicatorView(style: .large)
//        } else {
//            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
//        }
//        activityIndicator.center.x = backSideVW.layer.bounds.width / 2
//        activityIndicator.center.y = backSideVW.layer.bounds.height / 2
//
//        backSideVW.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//
//        let imageURL = URL(string: urlAudio)!
//        downloadImageConvertToBase64(from: imageURL) { [self] (base64String) in
//            if let base64String = base64String {
//                RealmDatabaseeHelper.shared.UpdateToBase64Key(key: keyStoreDataBase, Base64Key: base64String)
//            }else{
//                print("Failed to download and convert to Base64")
//            }
//            DispatchQueue.main.sync {
//                activityIndicator.stopAnimating()
//            }
//        }
    }
    
   
}
