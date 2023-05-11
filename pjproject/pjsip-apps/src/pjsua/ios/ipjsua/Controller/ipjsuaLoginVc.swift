//
//  ipjsuaLoginVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 09/11/22.
//

import UIKit

class ipjsuaLoginVc: UIViewController {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var SIPIP: UITextField!
    @IBOutlet weak var SIPPort: UITextField!
    @IBOutlet var commonAllVW: [UIView]!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewSIPPort: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        Init()
        
        viewSIPPort.isHidden = true
        
//        self.hideKeybordTappedAround()
    }
    
//    func Init() {
//        //Create Lib
//        CPPWrapper().createLibWrapper()
//
//        //Listen incoming call via function pointer
//        CPPWrapper().incoming_call_wrapper(incoming_call_swift)
//
//        //Done button to the keyboard
//        txtUserName.addDoneButtonOnKeyboard()
//        txtPassword.addDoneButtonOnKeyboard()
//        SIPIP.addDoneButtonOnKeyboard()
//        SIPPort.addDoneButtonOnKeyboard()
//
//        commonAllVW.forEach { vw in
//            vw.layer.cornerRadius = 5
//            vw.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//            vw.layer.borderWidth = 1
//        }
//
//        btnLogin.layer.cornerRadius = 5
//    }
//
//    //MARK: - btn Click
//    @IBAction func bntLogin(_ sender: UIButton) {
//        //Check user already logged in. && Form is filled
//        if (CPPWrapper().registerStateInfoWrapper() == false
//                && !txtUserName.text!.isEmpty
//                && !txtPassword.text!.isEmpty
//                && !SIPIP.text!.isEmpty
//                && !SIPPort.text!.isEmpty){
//
//            //Register to the user
//            CPPWrapper().createAccountWrapper(
//                txtUserName.text,
//                txtPassword.text,
//                SIPIP.text,
//                SIPPort.text)
//
//
//        } else {
//            let alert = UIAlertController(title: "SIP SETTINGS ERROR", message: "Please fill the form / Logout", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                switch action.style{
//                    case .default:
//                    print("default")
//
//                    case .cancel:
//                    print("cancel")
//
//                    case .destructive:
//                    print("destructive")
//
//                @unknown default:
//                    fatalError()
//                }
//            }))
//            self.present(alert, animated: true, completion: nil)
//        }
//
//        //Wait until register/unregister
//        sleep(2)
//        if (CPPWrapper().registerStateInfoWrapper()){
//            showToast(message: "Sip Status: REGISTERED")
//            appDelegate.viewTabbarScreen()
//        } else {
//            showToast(message: "Sip Status: NOT REGISTERED")
//        }
//    }
//
//
//}
//
//extension UIViewController{
//
//    func showToast(message : String, seconds: Double = 1.0){
//        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        alert.view.backgroundColor = .black
//        alert.view.alpha = 0.5
//        alert.view.layer.cornerRadius = 15
//        self.present(alert, animated: true)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
//            alert.dismiss(animated: true)
//        }
//    }
 }
