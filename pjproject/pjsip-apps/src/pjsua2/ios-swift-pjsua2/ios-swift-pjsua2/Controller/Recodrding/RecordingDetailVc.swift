//
//  RecordingDetailVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 27/12/22.
//

import UIKit
import AVFAudio
import AVFoundation


class RecordingDetailVc: UIViewController {

    @IBOutlet weak var lblNameLetter: UILabel!
    @IBOutlet weak var letterVW: UIView!
    @IBOutlet weak var imgLetter: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblDataOrTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblTotalLenthOfSound: UILabel!
    @IBOutlet weak var progressBarSound: UISlider!
    @IBOutlet weak var mainVW: UIView!
    
    var soundDetail = [String:Any]()
    var audioPlayer =  AVAudioPlayer()
    var isSoundOFF = false
    var dataContectInfo = [[String : Any]]()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(soundDetail)
        self.initCall()
    }
    
    func initCall(){
        mainVW.layer.cornerRadius = 5
        if (soundDetail["data"] as? String ?? "") != "" {
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy h:mm a"
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyyMMdd_hhmmss"
            let dataFind = dateFormatter1.date(from: (soundDetail["data"] as! String))
            lblDataOrTime.text =  df.string(from: dataFind!)
        }
        
        lblNumber.text = (soundDetail["number"] as? String ?? "")
        lblName.text = (soundDetail["name"] as? String ?? "")
        
        
        
        letterVW.layer.cornerRadius = letterVW.layer.bounds.height/2
        letterVW.layer.borderWidth = 1.5
        letterVW.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent(soundDetail["audio_name"] as? String ?? "")
        if fileManager.fileExists(atPath: fullDestPath.path){
            do {
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
                try! AVAudioSession.sharedInstance().setActive(true)
                audioPlayer = try AVAudioPlayer(contentsOf: fullDestPath)
                let duration = audioPlayer.duration
                lblTotalLenthOfSound.text = "\(duration)"
                progressBarSound.maximumValue = Float(duration)
                print(duration)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
                    if audioPlayer.currentTime == 0 {
                        progressBarSound.value = Float(duration)
                    }else{
                        let formatted = String(format: "%.2f", audioPlayer.duration - audioPlayer.currentTime)
                        lblDuration.text = "\(formatted)"
                        progressBarSound.value = Float(audioPlayer.currentTime)
                    }
                   
                }
            }
            catch {
                print(error)
            }
        }
        
        if dataContectInfo.count > 0 {
            if let index = dataContectInfo.firstIndex(where: {
                let phone = ($0["phone"] as! String).removeWhitespace()
                return phone.suffix(10) == String((soundDetail["number"] as? String ?? "").suffix(10))
            }) {
                let findNumber = dataContectInfo[index]
                lblName.text = findNumber["name"] as? String
                if findNumber["imageData64"] as! String != "" {
                    lblNameLetter.isHidden = true
                    let dataDecoded:NSData = NSData(base64Encoded: findNumber["imageData64"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    imgLetter.image = decodedimage
                }
            }else{
                imgLetter.image =  #imageLiteral(resourceName: "call_bg_image")
            }
        }
    }
    
    fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
    }
    
    //this runs the do try statement
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer.stop()
    }
    
    //MARK: - btn Click
    @IBAction func btnSoundOnOff(_ sender: UIButton) {
        if isSoundOFF == false {
            isSoundOFF = true
            audioPlayer.volume = 0.0
            sender.alpha = 0.5
        }else {
            isSoundOFF = false
            audioPlayer.volume = 1.0
            sender.alpha = 1.0
        }
    }
}
