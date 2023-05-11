//
//  AddNewContectVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 18/11/22.
//

import UIKit


protocol NewAddContact {
    func goToAudioCallLog()
}


class AddNewContectVc: UIViewController{

    @IBOutlet weak var pickupProfileVW: UIView!
    @IBOutlet weak var submitVW: UIView!
    @IBOutlet var detailVW: [UIView]!
    @IBOutlet weak var txtCountyCide: UITextField!
    @IBOutlet weak var txtPlce: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var txtFistName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtCountryCode: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtOccupation: UITextField!
    
    let countryPicker = CountryPicker1()
    var pickerYear: UIPickerView!
    var pickerToolbar: UIToolbar?
    var isImageSelection = false
    var number = ""
    var IsAddContectInAudioLog = false
    var delegate: NewAddContact?

    
    var arrayPlce = ["Home","Main","Work","Ohter"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeybordTappedAround()
        
         countryPicker.textField = txtCountyCide
         countryPicker.delegate = self
        
        txtEmailAddress.keyboardType = .emailAddress
        txtPhoneNumber.keyboardType = .numberPad
        
        txtFistName.delegate = self
        txtPhoneNumber.delegate = self
        
        txtCountyCide.text = ""
        
        Init()
        
        txtPhoneNumber.text = number
    }
    
    func Init(){
        
        detailVW.forEach{  (view) in
            view.layer.cornerRadius = 5
            view.layer.borderWidth = 1
            view.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        }
        
        pickupProfileVW.layer.cornerRadius = pickupProfileVW.layer.bounds.height/2
        pickupProfileVW.layer.borderWidth = 1
        pickupProfileVW.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        submitVW.layer.cornerRadius = submitVW.layer.bounds.height/2
        
        pickerViewHome()
        
        submitVW.alpha = 0.5
    }

    //MARK: - btn Click
    @IBAction func btnSubmit(_ sender: UIButton) {
        
        if submitVW.alpha == 0.5 {
            return
        }
        
        var imgProfilePass = UIImage()
        if isImageSelection == true {
            imgProfilePass = imgProfile.image!
        }
        AddContacts(img: imgProfilePass,imgAddOrNot:isImageSelection, name: txtFistName.text ?? "", middleName: txtLastName.text ?? "", homeEmail: txtEmailAddress.text ?? "" , number: (txtPhoneNumber.text ?? ""), companyName: txtCompany.text ?? "", occupation: txtOccupation.text ?? "")
        
        if IsAddContectInAudioLog == true {
            self.dismiss(animated: true,completion: { [self] in
                delegate?.goToAudioCallLog()
            })
        }else {
            self.dismiss(animated: true,completion: {
//                NotificationCenter.default.post(name: Notification.Name("callListUpdata"), object: self, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("dialpadCallUpdata"), object: self, userInfo: nil)

            })
        }
       
        
    }
    
    @IBAction func btnBackBtn(_ sender: UIButton) {
        self.dismiss(animated: true,completion: {
            NotificationCenter.default.post(name: Notification.Name("callListUpdata"), object: self, userInfo: nil)
        })
    }
    
    @IBAction func btnClickChoicePic(_ sender: UIButton) {
        showActionSheet()
    }
}
extension AddNewContectVc: CountryPickerDelegate1{

    func didSelectCountry(country: Country1) {
        txtCountyCide.text = country.phoneCode + " " +  country.name
    }
}

extension AddNewContectVc: UIPickerViewDelegate , UIPickerViewDataSource, UITextFieldDelegate {
    
    func pickerViewHome() {
        pickerYear = UIPickerView()
        
        pickerYear.dataSource = self
        pickerYear.delegate = self
        
        txtPlce.inputView = pickerYear
        
//        txtPlce.text = arrayPlce[0]
        txtPlce.text = ""
        lblPlace.text = arrayPlce[0]
        
        pickerToolbar = UIToolbar()
        
        pickerToolbar?.autoresizingMask = .flexibleHeight
        
        //add buttons
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(cancelBtnClicked(_:)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain , target: self, action: #selector(self.doneBtnClicked(_ :) ))
        
        
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        pickerToolbar?.items = [cancelButton, flexSpace, doneButton]
        
        txtPlce.inputAccessoryView = pickerToolbar
    }
    
    @objc func cancelBtnClicked(_ button: UIBarButtonItem?) {
        self.view.endEditing(true)
    }
    
    @objc func doneBtnClicked(_ button: UIBarButtonItem?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayPlce.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayPlce[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtPlce.text = ""
        lblPlace.text = arrayPlce[row]
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        submitVW.alpha = 0.5
        if txtFistName.text != ""  &&  txtPhoneNumber.text != "" {
            submitVW.alpha = 1.0
        }
    }
}

extension AddNewContectVc:  UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in

            self.camera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        actionSheet.view.tintColor = UIColor.gray
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)

    }
    func camera()
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.camera
        myPickerController.allowsEditing = true;
        self.present(myPickerController, animated: true, completion: nil)
    }
    func photoLibrary()
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        myPickerController.allowsEditing = true;
        self.present(myPickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        isImageSelection = true
        imgProfile.image = (info[.editedImage] as? UIImage)!
        self.dismiss(animated: true, completion:  nil)
    }
}

