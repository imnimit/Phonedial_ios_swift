//
//  ipjsuaLoginVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 09/11/22.
//

import UIKit
import Alamofire
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import TTTAttributedLabel
import AuthenticationServices

class ipjsuaLoginVc: UIViewController ,TTTAttributedLabelDelegate {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var SIPIP: UITextField!
    @IBOutlet weak var SIPPort: UITextField!
    @IBOutlet var commonAllVW: [UIView]!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewSIPPort: UIView!
    @IBOutlet weak var lblTermOrCondiation: TTTAttributedLabel!
    

    var ontTimeTap = false
    var userLoginSocialMidea = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()

        Init()
        
        viewSIPPort.isHidden = true
        
        SIPIP.text = Constant.GlobalConstants.SERVERNAME
        SIPPort.text = Constant.GlobalConstants.PORT
                
        self.hideKeybordTappedAround()
        
        setup()
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
    
    
    func Init() {
        //Create Lib

       // CPPWrapper().createLibWrapper()
        
        //Listen incoming call via function pointer
      //  CPPWrapper().incoming_call_wrapper(incoming_call_swift)

        //Done button to the keyboard
        txtUserName.addDoneButtonOnKeyboard()
        txtPassword.addDoneButtonOnKeyboard()
        SIPIP.addDoneButtonOnKeyboard()
        SIPPort.addDoneButtonOnKeyboard()
        
        commonAllVW.forEach { vw in
            vw.layer.cornerRadius = 5
            vw.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            vw.layer.borderWidth = 1
        }
        
        btnLogin.layer.cornerRadius = 5
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////        CPPWrapper().createLibWrapper()
////        CPPWrapper().incoming_call_wrapper(incoming_call_swift)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    
   
    //MARK: - btn Click
    @IBAction func bntLogin(_ sender: UIButton) {
        if sender.tag == 50 {
            appDelegate.loginSocialMediaUsed = "FB"
            FbLogin()
        } else  if sender.tag == 100 {
            appDelegate.loginSocialMediaUsed = "Gmail"
            GmailLogin()
        } else  if sender.tag == 150 {
            appDelegate.loginSocialMediaUsed = "appleLogin"

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            UserDefaults.standard.setValue("Menually", forKey: "WhichLoginCheck")
            signCheck()
        }
    }
    
    func FbLogin() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                // Handle login error
                print("Login error: \(error.localizedDescription)")
            } else if result?.isCancelled == true {
                // Handle cancelled login
                print("Login cancelled")
            } else {
                // Get user profile information
                let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
                graphRequest.start { [self] (_, result, error) in
                    if let error = error {
                        // Handle profile request error
                        print("Profile request error: \(error.localizedDescription)")
                    } else if let result = result as? [String: Any] {
                        // Handle profile request success
                        let name = result["name"] as? String
                        let email = result["email"] as? String
                        let id = result["id"] as? String
                        
                        UserDefaults.standard.setValue(appDelegate.loginSocialMediaUsed, forKey: "WhichLoginCheck")
                        
                        let fullNameArr = (name ?? "").components(separatedBy: " ")
                        if fullNameArr.count == 0 {
                            userLoginSocialMidea = ["first_name":name ?? "","email_name":(email == "") ? "FB Email Not Found" : (email ?? ""),"id":id ?? ""]
                        }else{
                            userLoginSocialMidea = ["first_name":fullNameArr[0],"last_name":fullNameArr[1],"email_name":(email == "") ? "FB Email Not Found" : (email ?? ""),"id":id ?? ""]
                        }
                        
                        isCehckGmailRegisration()
//                        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NumberAddRegistrationVc") as! NumberAddRegistrationVc
//                        nextVC.userDtails = self.userLoginSocialMidea
//                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                }
            }
        }
    }
    
    func GmailLogin() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [self] signInResult, error in
            guard error == nil else { return }
            
            let fullNameArr = (signInResult?.user.profile?.name ?? "").components(separatedBy: " ")
            if fullNameArr.count == 0 {
                userLoginSocialMidea = ["first_name":signInResult?.user.profile?.name ?? "","email_name":signInResult?.user.profile?.email ?? "","id":signInResult?.user.idToken?.tokenString ?? ""]
            } else {
                userLoginSocialMidea = ["first_name":fullNameArr[0],"last_name":fullNameArr[1],"email_name":signInResult?.user.profile?.email ?? "","id":signInResult?.user.idToken?.tokenString  ?? ""]
            }
            
            UserDefaults.standard.setValue(appDelegate.loginSocialMediaUsed, forKey: "WhichLoginCheck")
            isCehckGmailRegisration()
            
            
            
            
            
        }
    }
    
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func btnSignupClick(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterVc") as! RegisterVc
        navigationController?.pushViewController(nextVC, animated: true)
    }
        
    
    func CallRegistrationInServer() {
        
        if (CPPWrapper().registerStateInfoWrapper() == false
            && !txtUserName.text!.isEmpty
            && !txtPassword.text!.isEmpty
            && !SIPIP.text!.isEmpty
            && !SIPPort.text!.isEmpty){
            
            CPPWrapper().createLibWrapper()
            CPPWrapper().incoming_call_wrapper(incoming_call_swift)
            
            //Register to the user
            CPPWrapper().createAccountWrapper(
                txtUserName.text,
                txtPassword.text,
                SIPIP.text,
                SIPPort.text)
        } else {
            let alert = UIAlertController(title: "SIP SETTINGS ERROR", message: "Please fill the form / Logout", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                @unknown default:
                    fatalError()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        //Wait until register/unregister
        sleep(2)
        if (CPPWrapper().registerStateInfoWrapper()){
            showToast(message: "Sip Status: REGISTERED")
            appDelegate.viewTabbarScreen()
        } else {
            ontTimeTap = false
            showToast(message: "Sip Status: NOT REGISTERED")
        }
    }
    
    //MARK: - APi Action
    func signCheck() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        
        let requestData : [String : String] = ["Username":txtUserName.text ?? "",
                                               "Password":txtPassword.text ?? "",
                                               "Device_id":appDelegate.diviceID
                                               ,"CallKit_id":appDelegate.pushKitTokan
                                               ,"Notify_token":"1"
                                               ,"Mobile_type":"IOS"
                                               ,"request":"login"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "2" {
                self.showToastMessage(message: diddata["message"] as? String)
                ontTimeTap = false
            } else {
                let Data : [String: Any] = (diddata["response"] as! [String: Any])
                print(Data)
                User.sharedInstance.removeUserDetail()
                User.sharedInstance.storeUserDetails(userData: Data)
                CallRegistrationInServer()
                UserDefaults.standard.setValue(true, forKey: "isAlreadyMember")
            }
        })
    }
    
    func isCehckGmailRegisration(){

        let requestData : [String : String] = ["Username":txtUserName.text ?? ""
                                               ,"FirstName":userLoginSocialMidea["first_name"] as? String ?? ""
                                               ,"LastName":userLoginSocialMidea["last_name"] as? String ?? ""
                                               ,"email":userLoginSocialMidea["email_name"] as? String ?? ""
                                               ,"Mobile_type":"ios"
                                               ,"Device_id":appDelegate.diviceID
                                               ,"CallKit_id":appDelegate.pushKitTokan
                                                  ,"Notify_token":"1"
                                               ,"request":"login_with_google"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? Int ?? 0 != 1 {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NumberAddRegistrationVc") as! NumberAddRegistrationVc
                nextVC.userDtails = self.userLoginSocialMidea
                self.navigationController?.pushViewController(nextVC, animated: true)
            } else {
                let Data : [String: Any] = (diddata["response"] as! [String: Any])
                print(Data)
                User.sharedInstance.removeUserDetail()
                User.sharedInstance.storeUserDetails(userData: Data)
                CallRegistrationInServer()
                UserDefaults.standard.setValue(true, forKey: "isAlreadyMember")
            }
        })
    }    
}

extension UIViewController{

    func showToast(message : String, seconds: Double = 1.0){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
 }
extension ipjsuaLoginVc: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email ?? ""
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            //self.saveUserInKeychain(userIdentifier)
            
            if let identityTokenData = appleIDCredential.identityToken,
               let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                print("Identity Token \(identityTokenString)")
                // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
                UserDefaults.standard.setValue(appDelegate.loginSocialMediaUsed, forKey: "WhichLoginCheck")
                self.showResultViewController(userIdentifier: identityTokenString, fullName: fullName, email: email)
            }
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        let name = fullName?.givenName ?? ""
        let email = email ?? ""
        let id = userIdentifier
        
        userLoginSocialMidea = ["first_name":(name == "") ? "apple" : name ,"last_name":"id","email_name":email ,"id":id]
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NumberAddRegistrationVc") as! NumberAddRegistrationVc
        nextVC.userDtails = self.userLoginSocialMidea
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}
extension ipjsuaLoginVc: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
