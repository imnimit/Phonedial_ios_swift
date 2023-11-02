//
//  OtpVerfication.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 25/02/23.
//

import UIKit
class SuperViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "ic_back_arrow-1"), target: self, action: #selector(btnBackClicked))
    }
    
    @objc func btnBackClicked() {
        self.navigationController?.popViewController(animated: true)
    }
}
class OtpVerficationVc: SuperViewController {
    
    var phoneNumber: String = ""
    var lastId = ""
    
    @IBOutlet weak var lblPhoneNumberOrEmail: UILabel!
    @IBOutlet weak var lblWrongOtp: UILabel!
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var tf3: UITextField!
    @IBOutlet weak var tf4: UITextField!
    @IBOutlet weak var tf5: UITextField!
    @IBOutlet weak var tf6: UITextField!
    
    var messageText = ""
    var Counter: Int = 120
    var timer: Timer!
    var tempbool:Bool  = false
    var otpId:String = ""
    
    var topSafeArea: CGFloat = 0.0
    var didInvitedCode = [String: Any]()
    var userDtails = [String:Any]()
    var countryCode = ""
    
    var yesOrNoInfoCorrect = Int()
    

    //MARK:- ViewLoad
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.title = "Otp Verify"

        lblWrongOtp.isHidden = true
        self.hideKeybordTappedAround()
        setUpView()
        
        tf1.layer.cornerRadius = 10.0
        tf2.layer.cornerRadius = 10.0
        tf3.layer.cornerRadius = 10.0
        tf4.layer.cornerRadius = 10.0
        tf5.layer.cornerRadius = 10.0
        tf6.layer.cornerRadius = 10.0
        
        tf1.textContentType = .oneTimeCode
        tf2.textContentType = .oneTimeCode
        tf3.textContentType = .oneTimeCode
        tf4.textContentType = .oneTimeCode
        tf5.textContentType = .oneTimeCode
        tf6.textContentType = .oneTimeCode
        
            
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UITextField.textDidChangeNotification, object: tf1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.tf1.becomeFirstResponder()
        })
        
        
        let arrayofstring = otpId.map { String($0) }
        if arrayofstring.count == 6 {
            tf1.text = arrayofstring[0]
            tf2.text = arrayofstring[1]
            tf3.text = arrayofstring[2]
            tf4.text = arrayofstring[3]
            tf5.text = arrayofstring[4]
            tf6.text = arrayofstring[5]
        }
        
        
        
  
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer != nil {
            timer.invalidate()
        }
        navigationController?.navigationBar.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
   
    
    
    //MARK:- Custom Action
    func setUpView() {
        tf1.setBorder()
        tf2.setBorder()
        tf3.setBorder()
        tf4.setBorder()
        tf5.setBorder()
        tf6.setBorder()
        
        tf1.delegate = self
        tf2.delegate = self
        tf3.delegate = self
        tf4.delegate = self
        tf5.delegate = self
        tf6.delegate = self
    }
    
    @objc func keyboardDidShow(notifcation: NSNotification) {
        print(tf1.text!)
        if messageText.count == 6 {
        } else {
        }
    }
    
    
    func buttonUnSelected() {
        let opt = "\(tf1.text!)\(tf2.text!)\(tf3.text!)\(tf4.text!)"
        print(opt)
        print( "Check OTP Correct Or not")
       
        if tempbool == false {
           
            tf1.layer.borderWidth = 1
            tf1.layer.borderColor = #colorLiteral(red: 0.89, green: 0, blue: 0.03331184806, alpha: 1)
            tf2.layer.borderWidth = 1
            tf2.layer.borderColor = #colorLiteral(red: 0.89, green: 0, blue: 0.03331184806, alpha: 1)
            tf3.layer.borderWidth = 1
            tf3.layer.borderColor = #colorLiteral(red: 0.89, green: 0, blue: 0.03331184806, alpha: 1)
            tf4.layer.borderWidth = 1
            tf4.layer.borderColor = #colorLiteral(red: 0.89, green: 0, blue: 0.03331184806, alpha: 1)
            tf5.layer.borderWidth = 1
            tf5.layer.borderColor = #colorLiteral(red: 0.89, green: 0, blue: 0.03331184806, alpha: 1)
            tf6.layer.borderWidth = 1
            tf6.layer.borderColor = #colorLiteral(red: 0.89, green: 0, blue: 0.03331184806, alpha: 1)
            
            lblWrongOtp.isHidden = false
        }
        else {
            tf1.layer.borderWidth = 1
            tf1.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tf2.layer.borderWidth = 1
            tf2.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tf3.layer.borderWidth = 1
            tf3.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tf4.layer.borderWidth = 1
            tf4.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tf5.layer.borderWidth = 1
            tf5.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tf6.layer.borderWidth = 1
            tf6.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            lblWrongOtp.isHidden = true
        }
    }
    
    func checkAllFilled(){
        
        if (tf1.text?.isEmpty)! || (tf2.text?.isEmpty)! || (tf3.text?.isEmpty)! || (tf4.text?.isEmpty)! || (tf5.text?.isEmpty)! || (tf6.text?.isEmpty)! {
        }
        else {
            let otp = tf1.text! + tf2.text! + tf3.text! + tf4.text! + tf5.text! + tf6.text!
            
            if otp.count == 6 {
               verifyOTP()
            }
            
//            if otpId == otp {
//                tempbool = true
//                appDelegate.LoginPage()
//                buttonUnSelected()
//            } else {
//                tempbool = false
//                buttonUnSelected()
//            }
        }
    }
    
    
//MARK: - Btn Action
    
    @IBAction func textEditDidBegin(_ sender: UITextField) {
        print( "textEditDidBegin has been pressed")
        
        if !(sender.text?.isEmpty)!{
            sender.selectAll(self)
            sender.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        } else {
            print( "Empty")
            sender.text = ""
        }
      }
    
    @IBAction func textEditChanged(_ sender: UITextField) {
        print( "textEditChanged has been pressed")
        let count = sender.text?.count
        
        if count == 1{
            switch sender {
            case tf1:
                tf2.becomeFirstResponder()
            case tf2:
                tf3.becomeFirstResponder()
            case tf3:
                tf4.becomeFirstResponder()
            case tf4:
                tf5.becomeFirstResponder()
            case tf5:
                tf6.becomeFirstResponder()
            case tf6:
                tf6.resignFirstResponder()
            default:
                print( "default")
            }
        }
    }
    
    //MARK: - APi Action
    func verifyOTP() {
        let otpEnter = tf1.text! + tf2.text! + tf3.text! + tf4.text! + tf5.text! + tf6.text!
        
        let requestData : [String : String] =  ["FirstName":userDtails["first_name"] as? String ?? ""
                                               ,"LastName": userDtails["last_name"] as? String ?? ""
                                               ,"google_user_id":(appDelegate.loginSocialMediaUsed == "Gmail") ? (userDtails["id"] as? String ?? "") : "1"
                                               ,"fb_user_id":(appDelegate.loginSocialMediaUsed == "FB") ? (userDtails["id"] as? String ?? "") : "1"
                                                ,"Email":(appDelegate.loginSocialMediaUsed == "appleLogin") ? (userDtails["id"] as? String ?? "") : userDtails["email_name"] as? String ?? ""
                                               ,"Password":userDtails["password"] as? String ?? "123"
                                               ,"Country_id":countryCode
                                               ,"Device_id":appDelegate.diviceID
                                               ,"Phone":phoneNumber
                                               ,"Verification_code":otpEnter
                                               ,"Mobile_type":"ios"
                                               ,"callkit_id":appDelegate.pushKitTokan
                                               ,"notify_token":appDelegate.notificationTokan
                                               ,"request":"registration"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String  == "0" {
                self.showToastMessage(message: diddata["error"] as? String)
                tempbool = false
                buttonUnSelected()
            } else {
                let Data : [String: Any] = (diddata["response"] as! [String: Any])
                print(Data)
                User.sharedInstance.removeUserDetail()
                User.sharedInstance.storeUserDetails(userData: Data)
                UserDefaults.standard.setValue(true, forKey: "isAlreadyMember")
                appDelegate.viewTabbarScreen()
            }
        })
    }
}
extension OtpVerficationVc : UITextFieldDelegate{
    
    //MARK:- UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = ""
        if textField.text == "" {
            print( "Backspace has been pressed")
        }
        
        if string == ""
        {
            print( "Backspace was pressed")
            switch textField {
            case tf2:
                tf1.becomeFirstResponder()
            case tf3:
                tf2.becomeFirstResponder()
            case tf4:
                tf3.becomeFirstResponder()
            case tf5:
                tf4.becomeFirstResponder()
            case tf6:
                tf5.becomeFirstResponder()
            default:
                print("default")
            }
            textField.text = ""
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkAllFilled()
    }
}

