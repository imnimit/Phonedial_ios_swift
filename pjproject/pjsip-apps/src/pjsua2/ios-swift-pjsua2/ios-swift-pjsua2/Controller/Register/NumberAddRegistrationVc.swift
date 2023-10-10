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
    var allCountries = [String]()
    var allCountriesCode = [String]()
    var dicForAllContry = [[String:Any]]()
    var indexFindToCountryCode = ""
    var country_arr = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnNext.layer.cornerRadius = btnNext.layer.bounds.height/2
        txtFiledBackVW.layer.cornerRadius = 5
        txtFiledTopVW.layer.cornerRadius = 5
        txtPhoneNumber.delegate = self
        APICountryCodes()
        getCountry()
        
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
    
    func APICountryCodes() {
        guard let jsonFileURL = Bundle.main.url(forResource: "CountryCodes", withExtension: "json") else {
            // Handle the error if the JSON file cannot be found
            print("Unable to find JSON file")
            return
        }

        do {
            // Read the data from the JSON file
            let jsonData = try Data(contentsOf: jsonFileURL)
            
            // Parse the JSON data into an array of dictionaries
            let countries = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]]
            
            // Process the countries data
            if let countries = countries {
                for country in countries {
                    if let name = country["name"] as? String, let dialCode = country["dial_code"] as? String, let code = country["code"] as? String {
                        // Access the country details (name, dial code, code) and perform desired operations
                        let dic = ["name":name,"dialcode":dialCode,"code":code]
                        dicForAllContry.append(dic)
                        print("Name: \(name), Dial Code: \(dialCode), Code: \(code)")
                    }
                }
            }
        } catch {
            // Handle the error if there's an issue with reading or parsing the JSON data
            print("Error reading JSON file: \(error)")
        }
    }
    
    
    // MARK: - Btn Click
    @IBAction func pick() {
      //  startPicker()
        var countryName = [String: Any]()
        for i in allCountries{
            let index = dicForAllContry.firstIndex(where: {$0["name"] as? String ?? "" == i})
            if index != nil {
                let dic = ["name":i,"img": (dicForAllContry[index!]["code"] as? String ?? ""),"code":dicForAllContry[index!]["code"] as? String ?? ""] as [String : Any]
                dicForAllContry.append(dic)
            }
        }
        
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CountryPickerVC") as! CountryPickerVC
        nextVC.dicForAllContry = dicForAllContry
        nextVC.arrOfCountriesCode = allCountriesCode
        nextVC.indexFindToCountryCode = self.indexFindToCountryCode
        nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        nextVC.delegate = self
        self.present(nextVC, animated: true)
    }
    
    func getCountryName(countryName: String) -> String {
        let countryString = countryName
        let countryComponents = countryString.components(separatedBy: " (")
        let countryName = countryComponents[0]
        return countryName
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
                for i in country_arr {
                    if (i["country_name"] as? String)?.digitsOnly == indexFindToCountryCode.digitsOnly{
                        countryID = i["country_id"] as? String ?? ""
                    }
                }
                
                nextVC.countryCode = countryID
                navigationController?.pushViewController(nextVC, animated: true)
                print(Data)
            }
        })
    }
    
    func getCountry() {
        let requestData : [String : String] = [:]
        let url = "?request=get_country_info"
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : url, withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "1" {
                let Data : [String: Any] = (diddata["response"] as! [String: Any])
                let selectedData = Data["selected"] as? [String:Any]
                let countryID = selectedData?["country_id"] as? String
                country_arr = Data["country_arr"] as! [[String:Any]]
                
                for countryData in country_arr {
                    allCountries.append(countryData["country_name"] as? String ?? "")
                    allCountriesCode.append((countryData["country_name"] as? String ?? "").digitsOnly)
                }
                print(allCountries)
                print(allCountriesCode)
                
            } else {
//                self.showToastMessage(message: diddata["message"] as? String)
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

extension NumberAddRegistrationVc : getCountryCodeDelegate{
    func getCountryCode(countryShortName: String, countryCode: String) {
        indexFindToCountryCode = countryCode
        let countryCode = countryShortName + "(" + countryCode + ")"
        btnContryCode.setTitle(countryCode, for: .normal)
        dismiss(animated: false)
    }
}
