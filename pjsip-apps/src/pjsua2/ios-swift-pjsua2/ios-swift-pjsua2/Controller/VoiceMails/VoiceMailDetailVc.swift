//
//  VoiceMailDetailVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 27/12/22.
//

import UIKit
import AVFoundation
import MessageUI
import SwiftySound
import ProgressHUD
import AVFoundation


class VoiceMailDetailVc: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var lblFistTwoLetter: UILabel!
    @IBOutlet weak var imgContact: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var lblTotalDuration: UILabel!
    @IBOutlet weak var timerPgoressBar: UISlider!
    @IBOutlet weak var lblStartTimer: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var progressBarSound: UISlider!
    @IBOutlet weak var btnPlaySound: UIButton!
    @IBOutlet weak var letterOrImgVW: UIView!
    

    var voiceMailDetail = [String:Any]()
    var dataContectInfo =  [[String:Any]]()
    var audioPlayer =  AVAudioPlayer()
    var isPlaySoundPlay = true
    var timer = Timer()
    private var dogSound: Sound?
    var isProgressBarStart = true
    
    private let byteFormatter: ByteCountFormatter = {
           let formatter = ByteCountFormatter()
           formatter.allowedUnits = [.useKB, .useMB]
           return formatter
       }()

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.colorProgress = .systemBlue
        ProgressHUD.animationType = .circleSpinFade
        
        
        letterOrImgVW.layer.cornerRadius = letterOrImgVW.layer.bounds.height/2
        
        if let thumbImage = UIImage(named: "ic_slider_thumb") {
            progressBarSound.setThumbImage(thumbImage, for: .normal)
            progressBarSound.setThumbImage(thumbImage, for: .highlighted)
        }
        

        lblTotalDuration.text =  "Duration: \(printSecondsToHoursMinutesSeconds(Int(voiceMailDetail["message_len"] as? String ?? "") ?? 0))"
        lblTotalTime.text = printSecondsToHoursMinutesSeconds(Int(voiceMailDetail["message_len"] as? String ?? "") ?? 0)
        progressBarSound.value = 0.0
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)

        progressBarSound.maximumValue = Float((voiceMailDetail["message_len"] as? String ?? "")) ?? 0.0
        
        
        let epochTime = (voiceMailDetail["created_epoch"] as? String ?? "")

        let seconds = TimeInterval(Double(epochTime) ?? 0.0)

        let epochNSDate = Date(timeIntervalSince1970: seconds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy, EEEE, hh:mm a"
        lblData.text = dateFormatter.string(from: epochNSDate)

        let audioUrl = (voiceMailDetail["file_path"] as? String ?? "" ).components(separatedBy: "msg")
        
        let fileManager = FileManager.default
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent("msg" + audioUrl[1])
        if fileManager.fileExists(atPath: fullDestPath.path){
            do {
                ProgressHUD.dismiss();
//                audioPlayer = try AVAudioPlayer(contentsOf: fullDestPath)
//                audioPlayer.delegate = self
//
//                let duration = audioPlayer.duration
//                audioPlayer.prepareToPlay()
//                audioPlayer.play()
//
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                audioPlayer = try AVAudioPlayer(contentsOf: fullDestPath, fileTypeHint: AVFileType.mp3.rawValue)

                /* iOS 10 and earlier require the following line:
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
                
//                audioPlayer.play()
            }
            catch {
                print(error)
            }
        }else {
            palymusic()
        }         
        
        
        if dataContectInfo.count > 0 {
            if let index = dataContectInfo.firstIndex(where: {
                let phone = ($0["phone"] as! String).removeWhitespace()
                return phone.suffix(10) == String((voiceMailDetail["cid_name"] as? String ?? "").suffix(10))
            }) {
                let findNumber = dataContectInfo[index]
                lblName.text = (findNumber["name"] as? String ?? "")
                lblNumber.text = (findNumber["phone"] as? String ?? "")
                if findNumber["imageDataAvailable"] as? Bool == true {
                    lblFistTwoLetter.isHidden = true
                    imgContact.image = UIImage(data: (findNumber["imageData"] as! Data))!
                }else{
                    imgContact.image =  #imageLiteral(resourceName: "call_bg_image")
                }
                lblName.text = findNameFistORMiddleNameFistLetter(name: (findNumber["name"] as? String ?? ""))
            }else{
                lblName.text = "No Name"
                imgContact.image =  #imageLiteral(resourceName: "call_bg_image")
                lblFistTwoLetter.text = findNameFistORMiddleNameFistLetter(name: "No Name")
                lblNumber.text = voiceMailDetail["cid_name"] as? String ?? ""

            }
        }
        
      
        
        
       
       
      
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
      
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if timer != nil {
            timer.invalidate()
            audioPlayer.pause()
            audioPlayer.stop()
        }
        ProgressHUD.dismiss();
    }

    
    func palymusic(){
//        customJKView.isHidden = true
//
//        hightProgressBar.constant = 0.0
        let audioUrl = (voiceMailDetail["file_path"] as? String ?? "" ).components(separatedBy: "msg")
        
        let fileManager = FileManager.default
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent("msg" + audioUrl[1])
        if fileManager.fileExists(atPath: fullDestPath.path){
            do {
                DispatchQueue.main.async {
                    self.btnPlaySound.setImage(#imageLiteral(resourceName: "ic_pause_voice_mail"), for: .normal)
                }
                
                isPlaySoundPlay = false

//                ProgressHUD.dismiss();
                audioPlayer = try AVAudioPlayer(contentsOf: fullDestPath)
                let duration = audioPlayer.duration
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                
            }
            catch {
                print(error)
            }
        }else {
//            let audioUrl = URL(string: (API_URL.URLAUDIODOWNLOAD) + (voiceMailDetail["file_path"] as? String ?? "" ))
//            let item = AVPlayerItem(url: audioUrl!)
//            let duration = Double(item.asset.duration.value) / Double(item.asset.duration.timescale)
//            customJKView.animationDuration = duration
//            addFullCircleView()
            ProgressHUD.show();
            download()
        }
    }
    
    
    
    
    @objc func fireTimer() {
        if audioPlayer != nil {
            let duration = audioPlayer.duration
            if audioPlayer.currentTime == 0 {
                progressBarSound.value = 0.0
                lblStartTimer.text = "0.00"
            }else{
                lblStartTimer.text = printSecondsToHoursMinutesSeconds(Int(audioPlayer.currentTime))
                progressBarSound.value = Float(audioPlayer.currentTime)
            }
        }
    }
    
    func download() {
        
        if let audioUrl = URL(string: (API_URL.URLAUDIODOWNLOAD) + (voiceMailDetail["file_path"] as? String ?? "" )) {

            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)

            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")

                // if the file doesn't exist
            } else {

//                let config = URLSessionConfiguration.default
//                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
//
//                // Don't specify a completion handler here or the delegate won't be called
//                session.downloadTask(with: audioUrl).resume()
//
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { [self] (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        palymusic()
                        ProgressHUD.dismiss();
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
                

              
                                               
            }
        }
    }
    
    
    
     
    
    //MARK: - btn Click
    @IBAction func btnCallMDShar(_ sender: UIButton) {
        if sender.tag == 1{
          //call
            self.tabBarController?.tabBar.isHidden = false
            navigationController?.popViewController(animated: false)
            DispatchQueue.main.async { [self] in
                self.tabBarController?.tabBar.isHidden = false
                if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                    tabBarController.selectedIndex = 2
                    let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                    let dialPed = storyboard1.instantiateViewController(withIdentifier: "dialpadVc") as! dialpadVc
                    dialPed.contectNumber = lblNumber.text ?? ""
                    dialPed.contectName = lblName.text ?? ""
                    tabBarController.viewControllers![2]  = dialPed
                }
            }
        }else if sender.tag == 2 {
            // Message
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "test"
                controller.recipients = ["\(lblNumber.text ?? "")"]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
            
            
        }else if sender.tag == 3 {
            // Delete
            let alert = UIAlertController(title: "Alert", message: "Are your sure want to delete voice call recoding??" , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self]_ in
                deleteVoiceMail()
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if sender.tag == 4 {
            //share
            let audioUrl = URL(string: (API_URL.URLAUDIODOWNLOAD) + (voiceMailDetail["file_path"] as? String ?? "" ))
            let fileManager = FileManager.default
            let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent(audioUrl?.lastPathComponent ?? "")
            let activityVC = UIActivityViewController(activityItems: [fullDestPath],applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func btnPlayOrPush(_ sender: UIButton) {
        if audioPlayer != nil {
            if isPlaySoundPlay == true {
                audioPlayer.play()
                isPlaySoundPlay = false
                btnPlaySound.setImage(#imageLiteral(resourceName: "ic_pause_voice_mail"), for: .normal)
            }else {
                isPlaySoundPlay = true
                audioPlayer.pause()
                btnPlaySound.setImage(#imageLiteral(resourceName: "ic_play_voice_mail"), for: .normal)
            }
        }else{
            palymusic()
        }
    }
    
    
    //MARK: - APi Action
    func deleteVoiceMail() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        
        let requestData : [String : String] = ["uuid":voiceMailDetail["uuid"] as? String ?? "",
                                               "request":"voicemail_mark_read"
                                               ,"Token":User.sharedInstance.getUser_token()
                                               ,"Number":User.sharedInstance.getContactNumber()
                                               ,"Device_id":appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "2" {
                self.showToastMessage(message: diddata["message"] as? String)
            } else {
                navigationController?.popViewController(animated: false)
            }
        })
        
        
        
    }
    
}
extension VoiceMailDetailVc: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            print("Message sent")
        case .cancelled:
            print("Message Cancelled")
        case .failed:
            print("Message Fail")
        default:
            print("Some issue Face")
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}


/*extension VoiceMailDetailVc: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("Task has been resumed")
       
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let audioUrl = URL(string: (API_URL.URLAUDIODOWNLOAD) + (voiceMailDetail["file_path"] as? String ?? "" ))
            // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl!.lastPathComponent)
        print(destinationUrl)
            
        do {
            // after downloading your file you need to move it to your destination url
            try FileManager.default.moveItem(at: location, to: destinationUrl)

            print("File moved to documents folder")
           // palymusic()

        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        debugPrint("ByteWritten: \(bytesWritten)")
        debugPrint("TotalbyteWritten:\(totalBytesWritten)")
        debugPrint("TotalExpectedBytes:\(totalBytesExpectedToWrite)")
        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        print("Downloaded \(written) / \(expected)")
        let str = String(written)
        let str1 = str.removeWhitespace()
        let str2 = str1.replace(string: "KB", replacement: "")
        let strr = String(expected)
        let strr1 = strr.removeWhitespace()
        let strr2 = strr1.replace(string: "KB", replacement: "")
        if isProgressBarStart == true {
            isProgressBarStart = false
            let time1 = Float(str2) ?? 0.5
            let time2 = Float(strr2) ?? 0.5
            let totole = time1/time2
            if totole > 0.5 {
                //customJKView.animateCircle(angle:CGFloat(totole))
            }else{
               // customJKView.animateCircle(angle:0.5)
            }
    //            self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }
}




*/
