//
//  mp3ReceiverSideCell.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 10/02/23.
//

import UIKit
import AVFAudio


class mp3ReceiverSideCell: UITableViewCell ,AVAudioPlayerDelegate {
    @IBOutlet weak var btnPlaySound: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var backSideVW: UIView!
    @IBOutlet weak var whiteVW: UIView!
    private var activityIndicator: UIActivityIndicatorView!

    
    var timer: Timer!

    var base64key =  ""
    var urlAudio  = ""
    var keyStoreDataBase = ""
    var audioPlayer =  AVAudioPlayer()
    var SoundPlay = false
   
    
    @IBAction func audioControlButtonAction(sender: UIButton) {
       
        if base64key == "" {
            if #available(iOS 13.0, *) {
                activityIndicator = UIActivityIndicatorView(style: .large)
            } else {
                activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            }
            activityIndicator.center.x = backSideVW.layer.bounds.width / 2
            activityIndicator.center.y = backSideVW.layer.bounds.height / 2

            backSideVW.addSubview(activityIndicator)
            activityIndicator.startAnimating()

            let mp3URL = URL(string: urlAudio)!
            
            downloadAndConvertToBase64(mp3URL: mp3URL){ [self] (base64String) in
                if let base64String = base64String {
                    base64key = base64String
                    RealmDatabaseeHelper.shared.UpdateToBase64Key(key: keyStoreDataBase, Base64Key: base64key, localUrl: "")
                }
                DispatchQueue.main.sync {
                    activityIndicator.stopAnimating()
                    PlayMusic()
                }
            }
        }else {
            if SoundPlay == false {
                SoundPlay = true
                if let mp3Data = Data(base64Encoded: base64key) {
                    do {
                        audioPlayer = try AVAudioPlayer(data: mp3Data)
                        audioPlayer.delegate = self
                    } catch {
                        print("Error playing Base64-encoded music: \(error)")
                    }
                } else {
                    print("Error decoding Base64-encoded string")
                }
            }
       
            if sender.isSelected == false {
                audioPlayer.play()
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
                sender.isSelected = true
            } else {
                audioPlayer.pause()
                sender.isSelected = false
            }
        }
       
        

    }
    
    func PlayMusic(){
        if SoundPlay == false {
            SoundPlay = true
            if let mp3Data = Data(base64Encoded: base64key) {
                do {
                    audioPlayer = try AVAudioPlayer(data: mp3Data)
                    audioPlayer.delegate = self
                    audioPlayer.play()
                    timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
                    btnPlaySound.isSelected = true
                } catch {
                    print("Error playing Base64-encoded music: \(error)")
                }
            } else {
                print("Error decoding Base64-encoded string")
            }
        }
    }
 
    func audioStop(){
        audioPlayer.pause()
        btnPlaySound.isSelected = false
    }
    
    @objc func updateProgress() {
        let progress = Float(audioPlayer.currentTime / audioPlayer.duration)
        let x = audioPlayer.currentTime
        let y = Double(round(1000 * x) / 1000)
        lblDuration.text = "\(y.roundToDecimal(2))"
        progressBar.progress = (progress > 0.05) ? progress : 0
    }
    
       
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer.invalidate()
        btnPlaySound.isSelected = false
        progressBar.progress = 0
        lblDuration.text = "0"
    }
}
