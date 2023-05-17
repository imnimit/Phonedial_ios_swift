//
//  dialpadVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 18/11/22.
//

import UIKit
import CountryPickerView
import Contacts
import ContactsUI
import KNContacts
import MessageUI


class dialpadVc: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtnumber: UITextField!
    @IBOutlet weak var cpvMain: CountryPickerView!
    @IBOutlet weak var lblContectName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var btnNumber: [UIButton]!
    @IBOutlet weak var addContactVw: UIView!
    @IBOutlet weak var btnRemoveNumber: UIButton!
    @IBOutlet weak var numberShowVW: UIView!
    
    weak var cpvTextField: CountryPickerView!
    let cpvInternal = CountryPickerView()
    var showG20Contry = true
    var contrySelection = true
    var showphoneDial = true
    var contectNumber = ""
    var contectName = ""
    
    var db:DBManager = DBManager()
    var store = CNContactStore()
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var tempContectInfo = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCountryCode()
        
        logPressBtn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dialpadCallUpdata), name: Notification.Name("dialpadCallUpdata"), object: nil)
        
        numberShowVW.layer.cornerRadius = 5
        numberShowVW.layer.borderColor = #colorLiteral(red: 0.1058823529, green: 0.6903560162, blue: 0.8614253998, alpha: 1)
        numberShowVW.layer.borderWidth = 1.5
        
        InitCall()
    }
    
    @objc func dialpadCallUpdata()  {
        addContactVw.isHidden = true
        
        InitCall()
    }
    
    
    
    func InitCall() {
        if contectNumber != "" {
            let filter0 = contectNumber.replacingOccurrences(of: ")", with: "")
            let filter = filter0.replacingOccurrences(of: "(", with: "")
            txtnumber.text = filter
            lblContectName.text  = contectName
        }
        tableView.isHidden = false
        ConteactNoSave() 
        textSearchChange(txtnumber)
    }
    
    
    func logPressBtn(){
        for i in btnNumber {
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
            longGesture.view?.tag = i.tag
            i.addGestureRecognizer(longGesture)
        }
    }
    
    func showCountryCode() {
        let cp = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 10))
        self.cpvTextField = cp
        cpvMain.tag = 1
        cpvTextField.tag = 2
        
        [cpvMain, cpvTextField, cpvInternal].forEach {
            $0?.dataSource = self
        }
        
        cpvInternal.delegate = self
        cpvMain.font = UIFont.systemFont(ofSize: 15)
        cpvMain.flagSpacingInView = 5
        
        cpvMain.showCountryNameInView = true
        cpvMain.showCountryCodeInView = true
    }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        //self.tabBarController?.tabBar.backgroundColor = .white
        self.tabBarController?.tabBar.backgroundColor = #colorLiteral(red: 0.9898476005, green: 0.9898476005, blue: 0.9898476005, alpha: 1)
        self.tabBarController!.tabBar.layer.borderWidth = 0.8
        
        CPPWrapper().incoming_call_wrapper(incoming_call_swift)
        txtnumber.delegate = self
        appDelegate.sipRegistration()
        ConteactNoSave()
        DispatchQueue.main.async {
            self.userBalance()
        }
    }
    
    func textSearchChange(_ textfield:UITextField) {
        print("search")
        if tempContectInfo.count > 0 {
            dataContectInfo = tempContectInfo
        }
        dataContectInfo = dataContectInfo.filter(
            {  let filter0 = ($0["phone"] as! String).replacingOccurrences(of: ")", with: "")
                let filter1 = filter0.replacingOccurrences(of: "(", with: "")
                let filter2 = filter1.replacingOccurrences(of: "-", with: "")
                return filter2.localizedCaseInsensitiveContains(textfield.text!)
            })
        if textfield.text == "" {
            tableView.isHidden = true
            dataContectInfo = tempContectInfo
            addContactVw.isHidden = true
            btnRemoveNumber.isHidden = true
        } else {
            addContactVw.isHidden = true
            tableView.isHidden = false
            if dataContectInfo.count  == 0 {
                addContactVw.isHidden = false
            }
            btnRemoveNumber.isHidden = false
        }
        tableView.reloadData()
    }
   
    func ConteactNoSave()  {
        dataContectInfo = DBManager().getAllContact()
        
        if dataContectInfo.count > 0 {
            dataContectInfo.sort {
                (($0 as! Dictionary<String, AnyObject>)["name"] as! String) < (($1 as! Dictionary<String, AnyObject>)["name"] as! String)
            }
            UserDefaults.standard.removeObject(forKey: Constant.ValueStoreName.ContactNumber)
            UserDefaults.standard.setValue(dataContectInfo, forKey: Constant.ValueStoreName.ContactNumber)
            
            tempContectInfo = dataContectInfo
            
            tableView.reloadData()
        }
        
    }
    
    
    func DialCall(){
        if(CPPWrapper().registerStateInfoWrapper() != false) {
            CPPWrapper.clareAllData()
            
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallingDisplayVc") as! CallingDisplayVc
            nextVC.number = txtnumber.text ?? "<SIP-NUMBER>"
            let num1 = (cpvMain.selectedCountry.phoneCode).replace(string: "+", replacement: "")
            nextVC.phoneCode =  num1
            
            nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            self.present(nextVC, animated: true)
            
        }else {
            let alert = UIAlertController(title: "Outgoing Call Error", message: "Please register to be able to make call", preferredStyle: .alert)
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
    }
    
// MARK: - btn Click
    @IBAction func btnNumber(_ sender: UIButton) {
        if txtnumber.text?.count ?? 0 < 16 {
            txtnumber.text = (txtnumber.text ?? "") + "\(sender.tag)"
            textSearchChange(txtnumber)
        }
        AudioServicesPlaySystemSound (SystemSoundID(1200 + sender.tag))
    }
    
    @IBAction func btnRemoveNumber(_ sender: UIButton) {
        if  self.txtnumber.text?.count ?? 0 > 0 {
            txtnumber.text?.removeLast()
        }
        
        lblContectName.text = ""
        textSearchChange(txtnumber)
    }
    
    @IBAction func btnCall(_ sender: UIButton) {
        
        getCalleridForSelection()
        

    }
    
    
    
    @IBAction func btnAddNewContect(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewContectVc") as! AddNewContectVc
        nextVC.number = txtnumber.text ?? ""
        nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        self.present(nextVC, animated: true)
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func btnOpenPhoneBook(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactsVc") as! ContactsVc
        nextVC.navigationBarnotShow = true
        nextVC.isInvitedBtnShow = false
        nextVC.isFavoriteBtnShow = true
        nextVC.isContectNumberShow = false
        nextVC.isShowTopNavigationBar = true
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            print("Long Press\(gesture.view?.tag ?? 0)")
            if gesture.view?.tag ?? 0 == 0 {
                txtnumber.text =  (txtnumber.text ?? "") + "+"
            }else{
                if UserDefaults.standard.object(forKey: "SpeedDialList") != nil {
                    let  dicForSpeedDial =  UserDefaults.standard.object(forKey: "SpeedDialList") as! [[String:Any]]
                    if (dicForSpeedDial[(gesture.view?.tag ?? 0) - 1 ]["number"] as? String ?? "") != "" {
                        txtnumber.text =  dicForSpeedDial[(gesture.view?.tag ?? 0) - 1 ]["number"] as? String ?? ""
                    }
                }
            }
            
        }
        textSearchChange(txtnumber)
    }
    
    
    //MARK: - APi Action
    func userBalance() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"request":"get_userbalance"
                                               ,"Device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoader(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "4" {
                let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "LogoutPopupVc") as! LogoutPopupVc
                nextVC.modalPresentationStyle = .overFullScreen
                self.present(nextVC, animated: false)
            }
        })
    }
    
    func NumberYouHaveCall(flag:String,CalleridNumber:String){
        let requestData : [String : String] = ["token":User.sharedInstance.getUser_token()
                                               ,"request":"select_number_for_call_by_user"
                                               ,"device_id": appDelegate.diviceID
                                               ,"callerid_number":CalleridNumber
                                               ,"flag":flag]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoader(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "1" {
                DialCall()
            }
        })
    }
    
    func getCalleridForSelection() {
        let requestData : [String : String] = ["token":User.sharedInstance.getUser_token()
                                               ,"request":"get_calleridforselection"
                                               ,"device_id": appDelegate.diviceID]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoader(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "1" {
                let dic = (diddata["response"] as! [String: Any])
                let number = dic["numbers"] as! [[String: Any]]
                var Flage = ""
                
                if cpvMain.selectedCountry.name == "PhoneDial" {
                    Flage = "onnet"
                }else{
                    Flage = "offnet"
                }
                
                let optionMenu = UIAlertController(title: nil, message: "Choose your Number", preferredStyle: .actionSheet)
                let saveAction = UIAlertAction(title: User.sharedInstance.getContactNumber(), style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.NumberYouHaveCall(flag:Flage,CalleridNumber:User.sharedInstance.getContactNumber())
                })
                optionMenu.addAction(saveAction)

                for i in number {
                    let deleteAction = UIAlertAction(title: i["callerid_number"] as? String ?? "", style: .default, handler: {
                        (alert: UIAlertAction!) -> Void in
                        self.NumberYouHaveCall(flag:Flage,CalleridNumber: alert.title ?? "")
                    })
                    optionMenu.addAction(deleteAction)

                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    print("Cancelled")
                })
                
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)
            }else{
                DialCall()
            }
        })
    }
    
    
}
extension dialpadVc: CountryPickerViewDelegate {

    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        let title = "Selected Country"
        let message = "Name: \(country.name) \nCode: \(country.code) \nPhone: \(country.phoneCode)"
    }
}

extension dialpadVc: CountryPickerViewDataSource {
    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {
         if countryPickerView.tag == cpvMain.tag && showG20Contry {
            return ["AR", "AU", "BR","CA","CN","Fr","DE","IN","IDN","IT","JP","KR","MX","RU","SA","TR","UK","US","EU"].compactMap { countryPickerView.getCountryByCode($0) }
        }
        return []
    }
    
    func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
        if countryPickerView.tag == cpvMain.tag && showG20Contry {
            return "G20"
        }
        return nil
    }

    
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select a Country"
    }
    
        
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .tableViewHeader
    }

}

extension dialpadVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataContectInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchNumberCell", for: indexPath) as? searchNumberCell else { return UITableViewCell() }
        let dicForData = dataContectInfo[indexPath.row]
        cell.lblName.text = dicForData["name"] as? String
        cell.lblNumber.text = dicForData["phone"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let dicForData = dataContectInfo[indexPath.row]
        let filter0 = (dicForData["phone"] as? String)?.replacingOccurrences(of: ")", with: "")
        let filter1 = filter0?.replacingOccurrences(of: "(", with: "")
        let filter2 = filter1?.replacingOccurrences(of: "-", with: "")
        txtnumber.text = String((filter2 ?? "").suffix(10))
        lblContectName.text = dicForData["name"] as? String
    }
}
