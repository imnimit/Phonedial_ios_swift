//
//  NumberAddRegistrationVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 25/02/23.
//

import UIKit
import CountryPicker


class NumberAddRegistrationVc: UIViewController {

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnContryCode: UIButton!
    @IBOutlet weak var txtFiledBackVW: UIView!
    @IBOutlet weak var txtFiledTopVW: UIView!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    
    var passContryCode = "US"
    var userDtails = [String:Any]()
    var countryID = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnNext.layer.cornerRadius = btnNext.layer.bounds.height/2
        txtFiledBackVW.layer.cornerRadius = 5
        txtFiledTopVW.layer.cornerRadius = 5
        txtPhoneNumber.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func startPicker() {
        let countryPicker = CountryPickerViewController()
        countryPicker.selectedCountry = passContryCode
        countryPicker.delegate = self
        self.present(countryPicker, animated: true)
    }
    
    // MARK: - Btn Click
    @IBAction func pick() {
        startPicker()
    }
    
    @IBAction func btnNext(_ sender: UIButton) {
        if textFildDataChek(TextFild: txtPhoneNumber) == false {
            showToastMessage(message: "Please enter phone number")
            return
        }
        GetOtp()
    }
    
    // MARK: - API Calling
    func GetOtp() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        
        let requestData : [String : String] = [:]
        let url = "?request=verification_api&Country_id=\(countryID)&Device_id=\(appDelegate.diviceID)&Phone=\(txtPhoneNumber.text ?? "")&Mobile_type=ios"
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : url, withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "0" {
                self.showToastMessage(message: diddata["message"] as? String)
            } else {
                let Data : [String: Any] = (diddata["response"] as! [String: Any])
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OtpVerficationVc") as! OtpVerficationVc
                nextVC.otpId = "\(Int(Data["OTP"] as? Double ?? 0.0))"
                nextVC.userDtails = self.userDtails
                nextVC.phoneNumber = (txtPhoneNumber.text ?? "")
                nextVC.countryCode = countryID
                navigationController?.pushViewController(nextVC, animated: true)
                print(Data)
            }
        })
    }
  
}
extension NumberAddRegistrationVc: CountryPickerDelegate {
    func countryPicker(didSelect country: Country) {
        print(country.localizedName)
        passContryCode = country.isoCode
        countryID = country.phoneCode.replace(string: "+", replacement: "")
        let contryCode = country.localizedName + " (+" + country.phoneCode + ")"
        btnContryCode.setTitle(contryCode, for: .normal)
    }
}
extension NumberAddRegistrationVc: UITextFieldDelegate {
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == txtPhoneNumber) {
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
