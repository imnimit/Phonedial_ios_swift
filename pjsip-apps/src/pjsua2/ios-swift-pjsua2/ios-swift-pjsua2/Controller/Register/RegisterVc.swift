//
//  RegisterVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 25/02/23.
//

import UIKit
import TTTAttributedLabel


class RegisterVc: UIViewController,TTTAttributedLabelDelegate {

    @IBOutlet weak var txtFistName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtCPassword: UITextField!
    @IBOutlet weak var btnAcceptAndContinue: UIButton!
    @IBOutlet weak var lblTermOrCondiation: TTTAttributedLabel!
    @IBOutlet var textfiledBackVW: [UIView]!
    @IBOutlet var textFildTopVW: [UIView]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtFistName.delegate = self
        txtLastName.delegate = self
        txtEmailAddress.delegate = self
        
        self.hideKeybordTappedAround()
        self.title = "Signup"
        
        textfiledBackVW.forEach { VW in
            VW.layer.cornerRadius = 8
        }
        
        textFildTopVW.forEach { VW in
            VW.layer.cornerRadius = 8
        }
        
        btnAcceptAndContinue.layer.cornerRadius = btnAcceptAndContinue.layer.bounds.height/2
        
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    
    func setup() {
        lblTermOrCondiation.numberOfLines = 0;

        let strTC = "Terms of Services"
        
        let strPP = "PrivacyPolicy"

        let string = "By clicking Login in,you agree to our \(strTC) and \(strPP)"

        let nsString = string as NSString

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2

        let fullAttributedString = NSAttributedString(string:string, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4953902364, green: 0.4953902364, blue: 0.4953902364, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Futura-Medium", size: 15)!,
            ])
        lblTermOrCondiation.textAlignment = .center
        lblTermOrCondiation.attributedText = fullAttributedString;

        let rangeTC = nsString.range(of: strTC)
        let rangePP = nsString.range(of: strPP)

        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: #colorLiteral(red: 0.1069028154, green: 0.6903560162, blue: 0.8614253998, alpha: 1),
            NSAttributedString.Key.underlineColor.rawValue: UIColor.black.cgColor,
            NSAttributedString.Key.font.rawValue: UIFont(name: "Futura-Medium", size: 15)!,
            NSAttributedString.Key.underlineStyle.rawValue: NSUnderlineStyle.single.rawValue,
            ]
        let ppActiveLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: #colorLiteral(red: 0.4953902364, green: 0.4953902364, blue: 0.4953902364, alpha: 1),
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue:UIFont(name: "Futura-Medium", size: 15)!,
         ]

        lblTermOrCondiation.activeLinkAttributes = ppActiveLinkAttributes
        lblTermOrCondiation.linkAttributes = ppLinkAttributes
        

        let urlTC = URL(string: "action://TC")!
        lblTermOrCondiation.addLink(to: urlTC, with: rangeTC)
        
        let urlPP = URL(string: "action://PP")!
        lblTermOrCondiation.addLink(to: urlPP, with: rangePP)

        lblTermOrCondiation.delegate = self
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "action://TC" {
            print("Terms or Condiation")
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "TermServiceOrPrivacyPolicyVc") as! TermServiceOrPrivacyPolicyVc
            nextVC.DocumentUrl = Constant.GlobalConstants.TERMS_CONDITION_URL
            nextVC.Title = Constant.ViewControllerTitle.TermsofService
            navigationController?.pushViewController(nextVC, animated: true)
        }
        else if url.absoluteString == "action://PP" {
            print("PrivacyPolicy")
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "TermServiceOrPrivacyPolicyVc") as! TermServiceOrPrivacyPolicyVc
            nextVC.DocumentUrl = Constant.GlobalConstants.PRIVACY_POLICY_URL
            nextVC.Title = Constant.ViewControllerTitle.PrivacyPolicy
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    
    //MARK: btn Click
    @IBAction func btnClickAccept(_ sender: UIButton) {
        if textFildDataChek(TextFild: txtFistName) == false {
            showToastMessage(message: "Please enter firstname")
            return
        }
        
        if textFildDataChek(TextFild: txtLastName) == false {
            showToastMessage(message: "Please enter lastname")
            return
        }
        
        if textFildDataChek(TextFild: txtEmailAddress) == false {
            showToastMessage(message: "Please enter email")
            return
        }
        
        if isValidEmail(testStr: txtEmailAddress.text ?? "") == false  {
            showToastMessage(message: "Please enter valid email")
            return
        }
        
        if textFildDataChek(TextFild: txtPassword) == false {
            showToastMessage(message: "Please enter password")
            return
        }
        
        if textFildDataChek(TextFild: txtCPassword) == false {
            showToastMessage(message: "Please enter confrim password")
            return
        }
        
        if txtPassword.text != txtCPassword.text {
            showToastMessage(message: "Password or Confrim Passwrod Is not Match")
            return
        }
        
        
                
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NumberAddRegistrationVc") as! NumberAddRegistrationVc
        let dic = ["first_name":txtFistName.text ?? "","last_name":txtLastName.text ?? "","email_name":txtEmailAddress.text ?? "","password":txtPassword.text ?? "","confrime_password":txtCPassword.text ?? ""]
        nextVC.userDtails = dic
        navigationController?.pushViewController(nextVC, animated: true)
         
    }
    
    @IBAction func passWordShow(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        txtPassword.isSecureTextEntry =  !sender.isSelected
    }
    
    
    @IBAction func CpasswrodShow(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        txtCPassword.isSecureTextEntry =  !sender.isSelected
    }
    
    
    
    // MARK: - api Calling
    
    
    
    
}
extension RegisterVc: UITextFieldDelegate {
    
    //MARK:- UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
       if (textField == txtFistName || textField == txtLastName) {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            if newLength > 10 {
                self.view.endEditing(true)
            }
            return (newLength > 11) ? false : true
        }
        else {
            return true
        }
    }
}
