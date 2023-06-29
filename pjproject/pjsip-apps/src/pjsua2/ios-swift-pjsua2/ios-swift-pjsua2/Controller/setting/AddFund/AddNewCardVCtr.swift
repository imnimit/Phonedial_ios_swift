//
//  AddNewCardVCtr.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 05/01/23.
//

import UIKit

class AddNewCardVCtr: UIViewController {

    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var btnVisa: UIButton!
    @IBOutlet weak var btnMaster: UIButton!
    @IBOutlet weak var btnDiscover: UIButton!
    @IBOutlet weak var btnAmericanExpress: UIButton!
    @IBOutlet weak var dataPicker: UITextField!
    @IBOutlet weak var txtCVV: UITextField!
    @IBOutlet weak var imgEnterYourCard: UIImageView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtstate: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtCardHolderName: UITextField!
    @IBOutlet weak var txtBillingAddress: UITextField!
    @IBOutlet weak var txtzipCode: UITextField!
    
    let expirationDatePicker = UIDatePicker()

    var pickerCountry: UIPickerView!
    var arrayCountry = [[String:Any]]()
    var arrayState = [[String:Any]]()
    var arrayCity = [[String:Any]]()
    var pickerToolbar: UIToolbar?
    var CardValidOrNot = false
    var usCountryDetail = [String:Any]()
    var countState = -1
    var countCity = -1
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayCountry = DBManager().GetAllContry()

        
        txtCardNumber.delegate = self
        txtCVV.delegate = self
        dataPickerSet()
        EnableCard(numberCard: (txtCardNumber.text ?? "" ))
        btnSave.layer.cornerRadius = btnSave.layer.bounds.height/2
        
        //txtCountry.delegate = self
        txtCity.delegate = self
        txtstate.delegate = self
        
       
        
        let arForindex = arrayCountry.firstIndex(where: { ( $0["name"] as? String == "United States" ) } )
        if arForindex != nil {
            usCountryDetail = arrayCountry[arForindex!]
        }
        
        arrayState = DBManager().GetAllStatesName(phoneCode: usCountryDetail["phoneCode"] as! String)
        
        self.title = "Add Fund"
        
        pickerViewHome()
    }
    
    func dataPickerSet() {
        dataPicker.delegate = self
        expirationDatePicker.datePickerMode = .date
        dataPicker.inputView = expirationDatePicker
        expirationDatePicker.minimumDate = Date()

        if #available(iOS 13.4, *) {
            expirationDatePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancel, flexibleSpace, doneButton], animated: false)
        dataPicker.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func creditCardType(number: String) -> String {
        let bin = String(number.prefix(6))
        switch bin {
        case _ where bin.hasPrefix("4"):
            return "Visa"
        case _ where bin.hasPrefix("51") || bin.hasPrefix("52") || bin.hasPrefix("53") || bin.hasPrefix("54") || bin.hasPrefix("55"):
            return "Mastercard"
        case _ where bin.hasPrefix("34") || bin.hasPrefix("37"):
            return "American Express"
        case _ where bin.hasPrefix("6011"):
            return "Discover"
        default:
            return "Unknown"
        }
    }
    
    func cvvLength(cardType: String) -> Int {
        if cardType == "" {
            return 0
        }
        switch cardType {
        case "American Express":
            return 4
        default:
            return 3
        }
    }
    
    func formatCardNumber(number: String) -> String {
        // Remove any non-numeric characters from the card number
        let strippedNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        // Split the card number into groups of four digits separated by a space
        let formattedNumber = strippedNumber.replacingOccurrences(of: "(\\d{4})(?=\\d)", with: "$1 ", options: .regularExpression, range: strippedNumber.startIndex..<strippedNumber.endIndex)
        return formattedNumber
    }
    
    func EnableCard(numberCard:String){
        btnVisa.alpha = 0.5
        btnMaster.alpha = 0.5
        btnDiscover.alpha = 0.5
        btnAmericanExpress.alpha = 0.5
        imgEnterYourCard.image =  #imageLiteral(resourceName: "ic_card_number")
        
        CardValidOrNot = false
        
        if creditCardType(number: numberCard) == "Visa" {
            btnVisa.alpha = 1.0
            imgEnterYourCard.image = btnVisa.image(for: .normal)
            CardValidOrNot = true
        }
        else if creditCardType(number: numberCard) == "Mastercard" {
            btnMaster.alpha = 1.0
            imgEnterYourCard.image = btnMaster.image(for: .normal)
            CardValidOrNot = true
        }
        else if creditCardType(number: numberCard) == "American Express" {
            btnAmericanExpress.alpha = 1.0
            imgEnterYourCard.image = btnAmericanExpress.image(for: .normal)
            CardValidOrNot = true
        }
        else if creditCardType(number: numberCard) == "Discover" {
            btnDiscover.alpha = 1.0
            imgEnterYourCard.image = btnDiscover.image(for: .normal)
            CardValidOrNot = true
        }
    }
    
    //MARK: - btnClick
    @IBAction func btnSave(_ sender: UIButton) {
        dismissKeyboard()
        if txtCardNumber.text == "" {
            showToastMessage(message: "Please enter card number")
            return
        }
        
        if CardValidOrNot == false {
            showToastMessage(message: "Please enter valid card number")
            return
        }
        
        if dataPicker.text == "" {
            showToastMessage(message: "Please enter date")
            return
        }
        
        if txtCVV.text == "" {
            showToastMessage(message: "Please enter cvv")
            return
        }
        
        if txtCVV.text?.count ?? 0 < 2 {
            showToastMessage(message: "Please enter valid cvv")
            return
        }
        
        if txtCardHolderName.text == "" {
            showToastMessage(message: "Please enter card holder name")
            return
        }
        
        if txtBillingAddress.text == "" {
            showToastMessage(message: "Please enter billing address")
            return
        }
        
        
        
        if txtzipCode.text == "" {
            showToastMessage(message: "Please enter zipcode")
            return
        }
        
        let dic = ["cardnumber": txtCardNumber.text ?? "", "carddate":dataPicker.text ?? "","cvv":txtCVV.text ?? "","cardholdername":txtCardHolderName.text ?? "","billingaddress":txtBillingAddress.text ?? "","zipcode":txtzipCode.text ?? "","cardtype":creditCardType(number: txtCardNumber.text ?? "")] as! [String : Any]
        
        var dicarray = [[String:Any]]()
        if UserDefaults.standard.object(forKey: "CardDetils") != nil {
            dicarray =  UserDefaults.standard.object(forKey: "CardDetils") as! [[String:Any]]
        }
        dicarray.append(dic)
        
        UserDefaults.standard.setValue(dicarray, forKey: "CardDetils")
        UserDefaults.standard.synchronize()
        
//        self.dismiss(animated: true,completion: {
//            NotificationCenter.default.post(name: Notification.Name("crditcardDetail"), object: self, userInfo: nil)
//        })
        NotificationCenter.default.post(name: Notification.Name("crditcardDetail"), object: self, userInfo: nil)
        self.navigationController?.popViewController(animated: false)
        
    }
    
    

}
extension AddNewCardVCtr: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numeric characters
        if textField == txtCardNumber {
            let digits = CharacterSet.decimalDigits
            for uni in string.unicodeScalars {
                if !digits.contains(uni) {
                    return false
                }
            }
            if txtCardNumber.text?.count ?? 0 > 20 && string != "" {
                return false
            }
            
            return true
        }
        else if textField == txtCVV {
            if txtCVV.text?.count ?? 0 > cvvLength(cardType: txtCardNumber.text ?? "")  && string != "" {
                return false
            }
            return true
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == txtCardNumber {
            txtCardNumber.text = formatCardNumber(number: (txtCardNumber.text ?? "" ))
            EnableCard(numberCard: (txtCardNumber.text ?? "" ))
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dataPicker {
            let expirationDate = expirationDatePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/yyyy"
            dataPicker.text = dateFormatter.string(from: expirationDate)
        }
        if textField == txtCountry || textField == txtstate || textField == txtCity {
            pickerCountry.tag = textField.tag
            var indexOfData = 0
          if textField.tag == 2 {
                if arrayState.count > 0{
                    let arForindex = arrayState.firstIndex(where: { ( $0["name"] as? String == textField.text ) } )
                    if arForindex != nil {
                        indexOfData = arForindex ?? 0
                    }
                } else {
                    self.view.endEditing(true)
                    showToastMessage(message: "Please Country Selection First")
                }
            }else if textField.tag == 3 {
                if arrayCity.count > 0{
                    let arForindex =  arrayCity.firstIndex(where: { ( $0["name"] as? String == textField.text ) } )
                    if arForindex != nil {
                        indexOfData = arForindex ?? 0
                    }
                }else{
                    self.view.endEditing(true)
                    showToastMessage(message: "Please State Selection First")
                }
            }
            self.pickerCountry.selectRow(indexOfData, inComponent: 0, animated: true)
        }
    }
    
}
extension AddNewCardVCtr: UIPickerViewDelegate , UIPickerViewDataSource  {
    
    func pickerViewHome() {
        pickerCountry = UIPickerView()
        
        pickerCountry.dataSource = self
        pickerCountry.delegate = self
        
//        txtCountry.inputView = pickerCountry
        txtCountry.text = usCountryDetail["name"] as? String ?? ""
 
        
        txtstate.inputView = pickerCountry
        txtstate.text = ""
        
        txtCity.inputView = pickerCountry
        txtCity.text = ""
        
        pickerToolbar = UIToolbar()
        
        pickerToolbar?.autoresizingMask = .flexibleHeight
        
        //add buttons
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(cancelBtnClicked(_:)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain , target: self, action: #selector(self.doneBtnClicked(_ :) ))
        
        
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        pickerToolbar?.items = [cancelButton, flexSpace, doneButton]
        
//        txtCountry.inputAccessoryView = pickerToolbar
        txtstate.inputAccessoryView = pickerToolbar
        txtCity.inputAccessoryView = pickerToolbar
    }
    
    @objc func cancelBtnClicked(_ button: UIBarButtonItem?) {
        self.view.endEditing(true)
    }
    
    @objc func doneBtnClicked(_ button: UIBarButtonItem?) {
        self.view.endEditing(true)
        if pickerCountry.tag == 2 {
            if countState != -1 {
                txtstate.text = ""
                txtstate.text = arrayState[countState]["name"] as? String
                arrayCity = DBManager().GetAllCityName(stateId: arrayState[countState]["country_id"] as! String)
                txtCity.text = ""
            }
        }else {
            if countCity != -1 {
                txtCity.text = ""
                txtCity.text = arrayCity[countCity]["name"] as? String
            }
       }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerCountry.tag == 2 {
            return arrayState.count
        }else {
            return arrayCity.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerCountry.tag == 2 {
            if arrayState.count > 0 {
                return arrayState[row]["name"] as? String
            }else{
                return ""
            }
        }else {
            if arrayCity.count > 0 {
                return arrayCity[row]["name"] as? String
            }else{
                return ""
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         if pickerCountry.tag == 2 {
             countState = row
             let itemselected = arrayState[row]["name"] as? String
             txtstate.text = itemselected
             txtCity.text = ""
             arrayCity.removeAll()
         }else {
             countCity = row
             let itemselected = arrayCity[row]["name"] as? String
             txtCity.text = itemselected
        }
    }
}
