//
//  AlertRecordingVC.swift
//  ios-swift-pjsua2
//
//  Created by TNCG - Mini2 on 19/04/23.
//

import UIKit

class AlertRecordingVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var continueVW: UIView!
    @IBOutlet weak var noVW: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    var descrtion = ""
    var settitle = ""
    var continuelbl = ""
    var nolbl = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
        
    }
    
    func initCall() {
        mainView.layer.cornerRadius = 15
        continueVW.layer.cornerRadius = 15
        noVW.layer.cornerRadius = 15
        if settitle == "Recording Plan Required" {
            lblTitle.text = settitle
            lblDescription.text = descrtion
            noVW.isHidden = true
            lblContinue.text = "Ok"
            
        }
        else if settitle == "Call Recording Disclaimer" {
            lblTitle.text = settitle
            lblDescription.text = descrtion
        }
    }
    
    @IBAction func btnContinue(_ sender: UIButton) {
        if settitle == "Call Recording Disclaimer" {
            UserDefaults.standard.set(true, forKey: "RecordPopShowOnce")
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func btnNo(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
