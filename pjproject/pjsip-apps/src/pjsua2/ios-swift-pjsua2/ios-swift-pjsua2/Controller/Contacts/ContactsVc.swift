//
//  ContactsVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 16/12/22.
//

import UIKit
import Contacts
import ContactsUI
import KNContacts
import MessageUI
import AudioToolbox
import ProgressHUD


class ContactsVc: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hightTopNavigationBar: NSLayoutConstraint!
    @IBOutlet weak var contactAllowVW: UIView!
    @IBOutlet weak var emtyVW: UIView!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var numberPadVW: UIView!
    @IBOutlet var numbersView: [UIView]!
    @IBOutlet weak var txtnumber: UITextField!
    @IBOutlet var btnNumber: [UIButton]!
    @IBOutlet weak var lblCallHistoryNotFound: UILabel!
    @IBOutlet weak var heightOfNewGroup: NSLayoutConstraint!


    
    ///////////////////////- ----------------------------------------
    @IBOutlet weak var keyPedBackSideVW: UIView!
    @IBOutlet weak var keyPedUsedTblView: UITableView!
    @IBOutlet weak var keypadUIGestureVW: UIView!
    @IBOutlet weak var dummyVW: UIView!
    
    
    var store = CNContactStore()
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var tempContectInfo = [[String : Any]]()
    var dataContectInfoOld = [[String : Any]]()
    var keypadContectInfo = [[String : Any]]()
    var tempkeypadContectInfo = [[String : Any]]()
    
    var isCallLogData = [[String:Any]]()
    var isCallDummyLogData = [[String:Any]]()

    var groupedUsersCallHistory =  [Int : [[String : Any]]]()
    var groupedUsersAudio =  [Int : [[String : Any]]]()
    var indexContactsArray = [Int]()
    var indexAudioContactsArray = [Int]()
    var iscountNumberHistory = 0


    let indexLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var indexLettersInContactsArray = [String]()
    
    var contactNamesDictionary = [String: [String]]()
    var contactallData = [[String: Any]]()
    var searchActive = true

    var groupedUsers =  [Character : [[String : Any]]]()
    var navigationBarnotShow = false
    var isInvitedBtnShow = true
    var isFavoriteBtnShow = true
    var isContectNumberShow = true
    var isShowTopNavigationBar = false
    var iscallAdd = false
    var iscallTransfer = false
    var iscallAddSpeedDial = false
    var Favourite = [[String : Any]]()
    var pullControl = UIRefreshControl()
    var isFistTimeShowAnimation = true
    var isAddToChatView = false
    var isContactNumberDetailShow = false
    var isRefreshContact = false
    var iscallVideoAdd = false
    var isOnlayOneTimeMoveToKeyPed = false
    var buttonShow = false
    override func viewDidLoad() {
        super.viewDidLoad()
        emtyVW.isHidden = true
        lblCallHistoryNotFound.isHidden = true

        hightTopNavigationBar.constant = 0
        if isShowTopNavigationBar == true {
            hightTopNavigationBar.constant = 90
        }
       
        heightOfNewGroup.constant = 0
        if buttonShow == true {
            heightOfNewGroup.constant = 55
        }
        self.title = Constant.ViewControllerTitle.Contacts
        NotificationCenter.default.addObserver(self, selector: #selector(callListUpdata), name: Notification.Name("callListUpdata"), object: nil)
        
        pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(pullControl)
        
        self.tableView.sectionIndexColor = #colorLiteral(red: 0.3333255053, green: 0.4644713998, blue: 0.7242901325, alpha: 1)

        callListUpdata()
//        if isFistTimeShowAnimation == true {
//            HelperClassAnimaion.showProgressHud()
//        }
        
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        searchBar.isMultipleTouchEnabled = true

        contactAllowVW.layer.cornerRadius = 8
        
        keyPedBackSideVW.alpha = 0.0
        keyPedBackSideVW.isHidden = true
        numberPadVW.isHidden = true
        floatingButton.isHidden = true
        if iscallAdd == true || iscallTransfer == true {
            floatingButton.isHidden = false
            floationButtonCreate()
           
            // Set up the shadow properties
            numberPadVW.layer.shadowColor = UIColor.black.cgColor
            numberPadVW.layer.shadowOffset = CGSize(width: 0, height: -5) // Negative height for top-side shadow
            numberPadVW.layer.shadowOpacity = 0.2
            
            // Clip the shadow to the bounds of the view
            numberPadVW.layer.masksToBounds = false
            
            numbersView.forEach { $0.layer.cornerRadius = $0.layer.bounds.height/2 }
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleHidleKeypadVW(_:)))
            keypadUIGestureVW.addGestureRecognizer(tap)
        }
        
        
        logPressBtn()
        
    }
    
    func logPressBtn(){
        for i in btnNumber {
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
            longGesture.view?.tag = i.tag
            i.addGestureRecognizer(longGesture)
        }
    }
    
    @objc func handleHidleKeypadVW(_ sender: UITapGestureRecognizer? = nil) {
        floatingButton.isSelected  = false
        //hide us the view with fade in animations
        UIView.animate (withDuration: 0.5, delay: 0.2, options: .curveEaseOut,
                        animations: {
            self.keyPedBackSideVW.alpha = 0.0
            self.keyPedBackSideVW.isHidden = true
            self.numberPadVW.isHidden = true
        })
        isOnlayOneTimeMoveToKeyPed = false
        
        txtnumber.text = ""
        txtnumber.delegate = self
        keypadContectInfo.removeAll()
        keyPedUsedTblView.reloadData()
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
        keypedTimeSearchContact(number: txtnumber.text ?? "")
    }
    
    
    func shadowAplly(view:UIView){
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        view.layer.shadowRadius = 3.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.masksToBounds = false
    }
    
    func floationButtonCreate(){
        // Set up the floating behavior
        floatingButton.layer.cornerRadius = floatingButton.frame.width / 2
        floatingButton.layer.masksToBounds = true
        
        // Add a shadow to the button
        floatingButton.layer.shadowColor = UIColor.black.cgColor
        floatingButton.layer.shadowOpacity = 0.5
        floatingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        floatingButton.layer.shadowRadius = 4
        
        // Add a pan gesture recognizer to enable dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        floatingButton.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        // Calculate the new position for the button
        let newX = floatingButton.center.x + translation.x
        let newY = floatingButton.center.y + translation.y
        
        // Ensure the button stays within the bounds of the screen
        let minX = floatingButton.frame.width / 2
        let maxX = view.bounds.width - floatingButton.frame.width / 2
        let minY = floatingButton.frame.height / 2
        let maxY = view.bounds.height - floatingButton.frame.height / 2
        
        let clampedX = min(maxX, max(minX, newX))
        let clampedY = min(maxY, max(minY, newY))
        
        // Move the button to the new position
        floatingButton.center = CGPoint(x: clampedX, y: clampedY)
        
        // Reset the translation to avoid cumulative movement
        gesture.setTranslation(CGPoint.zero, in: view)
        
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
//        callListUpdata()
//        DBManager().deleteAllContact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [self] in
            isRefreshContact = true
            Favourite = DBManager().getAllFavorite()
            contactBook = KNContactBook(id: "allContacts")
            dataContectInfoOld = DBManager().getAllContact()

            self.ConteactNoSave()
        })
       
    }
    
    @objc func callListUpdata()  {
        
        Favourite = DBManager().getAllFavorite()
        contactBook = KNContactBook(id: "allContacts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.initCall()
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            callListUpdata()
        
        navigationController?.navigationBar.isHidden = navigationBarnotShow
        
        if #available(iOS 15.0, *) {
           tableView.sectionHeaderTopPadding = 0
        }
    }
 

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    func initCall() {
        searchBar.placeholder = "Search"
        if isContactNumberDetailShow == false {
            self.contactGetInDataBase()
            CallLogReArrage()
        }
        isContactNumberDetailShow = false

    }
    
    func CallLogReArrage() {
        groupedUsersCallHistory.removeAll()
        indexContactsArray.removeAll()
        groupedUsersAudio.removeAll()
        
        let allcallLogData = DBManager().getAllCallLog()
        isCallLogData  =  allcallLogData.filter { $0["type_log"] as? String == "Call" }
        isCallDummyLogData = isCallLogData
        iscountNumberHistory = 0
        var dv = [[String:Any]]()
        var numberMange = ""
        for i in isCallLogData {
            if numberMange != "" &&  numberMange != (i["number"]  as! String).suffix(10) {
                let gorup =  Dictionary(grouping: dv, by: numberManage)
                groupedUsersAudio =  groupedUsersAudio.merging(gorup) { (current, _) in current }
                iscountNumberHistory = iscountNumberHistory + 1
                dv = [[String:Any]]()
                numberMange =  String((i["number"]  as! String).suffix(10))
                dv.append(i)
            }else{
                numberMange =  String((i["number"]  as! String).suffix(10))
                dv.append(i)
            }
        }
        
        let gorupV =  Dictionary(grouping: dv, by: numberManage)
        groupedUsersAudio =  groupedUsersAudio.merging(gorupV) { (current, _) in current }
        indexAudioContactsArray = [Int](groupedUsersAudio.keys)
        indexAudioContactsArray = indexAudioContactsArray.sorted()
        
        self.keyPedUsedTblView.reloadData()
    }
    
    func numberManage(_ aDict: [String:Any]) -> Int {
//        if aDict["number"] as! String  == "" {
//            return ""
//        }
        return iscountNumberHistory
    }
    
    
    func contactGetInDataBase(){
        if isShowTopNavigationBar == true {
            HelperClassAnimaion.showProgressHud()
        }

        dataContectInfo = DBManager().getAllContact()
        tempkeypadContectInfo = DBManager().getAllContact()

        if dataContectInfo.count > 0 {
            dataContectInfo.sort {
                (($0 as! Dictionary<String, AnyObject>)["name"] as! String) < (($1 as! Dictionary<String, AnyObject>)["name"] as! String)
            }


            UserDefaults.standard.removeObject(forKey: Constant.ValueStoreName.ContactNumber)
            UserDefaults.standard.setValue(dataContectInfo, forKey: Constant.ValueStoreName.ContactNumber)
         
            groupedUsers.removeAll()
            groupedUsers = Dictionary(grouping: dataContectInfo, by: firstCharOfFirstName)
            
            tempContectInfo = dataContectInfo
            createNameDictionary()
        }else{
            if requestAccess() {
              //  ProgressHUD.show()
                self.ConteactNoSave()
            }else{
                emtyVW.isHidden = false
            }
        }
        
        if isShowTopNavigationBar == true {
            HelperClassAnimaion.hideProgressHud()
        }
    }
    
    func ConteactNoSave()  {
        
        DispatchQueue.main.async { [self] in
            let keys = [CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey,
                        CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey,
                        CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as! [CNKeyDescriptor]
            
            let requestForContacts = CNContactFetchRequest(keysToFetch: keys)
            self.hideKeybordTappedAround()
            // And then perform actions on KNContactBook
            do {
                try CNContactStore().enumerateContacts(with: requestForContacts) { (cnContact, _) in
                    let knContact = KNContact(cnContact)
                    self.contactBook.add(knContact)
                }
            } catch let error {
                // Handle error somehow!
                print(error)
            }
    //        print(contactBook)
            
            groupedUsers.removeAll()
            dataContectInfo.removeAll()
            tempContectInfo.removeAll()

            for  i  in contactBook.contacts {
                var data = [String: Any]()
                if i.fullName() != "" {
                    if i.info.imageDataAvailable == true {
                        data = ["name":i.fullName(),"phone":i.getFirstPhoneNumber().removeWhitespace(),"imageDataAvailable": i.info.imageDataAvailable,"imageData": i.info.imageData!,"Email":i.getFirstEmailAddress()]
                    }else {
                        data = ["name":i.fullName(),"phone":i.getFirstPhoneNumber().removeWhitespace(),"imageDataAvailable": i.info.imageDataAvailable,"imageData":i.info.imageData ?? Data(),"Email":i.getFirstEmailAddress()]
                    }
                    
                    if dataContectInfo.firstIndex(where: {$0["name"] as! String == i.fullName()}) != nil {
                    } else {
                        var strBase64  = ""
                        if i.info.imageDataAvailable == true {
                            let img = UIImage(data: i.info.imageData ?? Data())!
                            let vidoImageData = img.pngData()
                            strBase64 = vidoImageData!.base64EncodedString()
                        }
                        
                        let dicContactData =  ["name": i.fullName(), "phone": i.getFirstPhoneNumber().removeWhitespace(), "imageDataAvailable": i.info.imageDataAvailable, "imageData64": strBase64, "Email": i.getFirstEmailAddress(), "phoneDialers":"0", "newContact":"0"] as [String : Any]
                        
                        if isRefreshContact == false {
                            DBManager().insertcontact(dicContact: dicContactData)
                        }
                        else {
                            if dataContectInfoOld.firstIndex(where: {$0["name"] as! String == data["name"] as! String}) != nil {
                                DBManager().updateContact(dicContact: dicContactData, phoneNumber: data["phone"] as! String)
                            }
                        }
                        
                        
                        if i.info.phoneNumbers.count >= 2 {
                            for j in i.info.phoneNumbers {
//                                mulipleContact.append(j.value.stringValue)
                            }
                        }

                        dataContectInfo.append(data)
                    }
                }
            }
            
        }
         
        DispatchQueue.main.async { [self] in
            if isRefreshContact == true {
                isRefreshContact = false
                for i in dataContectInfoOld {
                    if (dataContectInfo.firstIndex(where: {$0["name"] as! String == i["name"] as! String}) != nil){
                    }else {
                        print("Delete Contarct")
                        print(i["name"] as! String)
                        DBManager().deleteContact(name: i["name"] as! String)
                    }
                }
                for i in dataContectInfo {
                    if dataContectInfoOld.firstIndex(where: {$0["name"] as! String == i["name"] as! String}) != nil {

                    }else{
                        print("Add Contarct")
                        print(i["name"] as! String)
                        DBManager().insertcontact(dicContact: i)
                    }
                }
            }
        }
        
        DispatchQueue.main.async { [self] in
            dataContectInfo.removeAll()
            dataContectInfo = DBManager().getAllContact()
            dataContectInfo.sort {
                (($0 as! Dictionary<String, AnyObject>)["name"] as! String) < (($1 as! Dictionary<String, AnyObject>)["name"] as! String)
            }
            
            UserDefaults.standard.removeObject(forKey: Constant.ValueStoreName.ContactNumber)
            UserDefaults.standard.setValue(dataContectInfo, forKey: Constant.ValueStoreName.ContactNumber)
           
            groupedUsers.removeAll()
            groupedUsers = Dictionary(grouping: dataContectInfo, by: firstCharOfFirstName)
            
            tempContectInfo = dataContectInfo
            createNameDictionary()
            
        //    ProgressHUD.showSucceed()
//            ProgressHUD.dismiss()
            HelperClassAnimaion.hideProgressHud()
        }
              
    }
    
    func firstCharOfFirstName(_ aDict: [String:Any]) -> Character {
        if aDict["name"] as! String  == "" {
            return Character("")
        }
        
        return (aDict["name"] as! String).uppercased().first!
    }
    
    func createNameDictionary() {
        
        contactNamesDictionary.removeAll()
        for name in dataContectInfo {
            let firstLetter = (name["name"] as? String)?.first
            let uppercasedLetter = firstLetter?.uppercased()
            
            if var separateNamesArray = contactNamesDictionary[uppercasedLetter ?? ""] { //check if key already exists
                separateNamesArray.append(name["name"] as? String ?? "")
                contactNamesDictionary[uppercasedLetter ?? ""] = separateNamesArray
            } else {
                contactNamesDictionary[uppercasedLetter ?? ""] = [name["name"] as? String ?? ""]
            }
        }
        
        indexLettersInContactsArray = [String](contactNamesDictionary.keys)
        indexLettersInContactsArray = indexLettersInContactsArray.sorted()
        
//        DispatchQueue.main.async { [self] in
            tableView.reloadData()
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [self] in // your network call
            if pullControl != nil {
                pullControl.endRefreshing()
            }
            if isFistTimeShowAnimation == true {
                isFistTimeShowAnimation = false
                HelperClassAnimaion.hideProgressHud()
            }
        }
    }
        
    func requestAccess()-> Bool {
        var allow = false
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            allow = true
        case .denied:
            allow = false
        case .restricted, .notDetermined:
            allow = false
        }
        return allow
    }
    
    func checkPermissionToDeviceContacts() {

        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        if authorizationStatus == .notDetermined {
            // 3
            store.requestAccess(for: .contacts) { [weak self] didAuthorize,
                                                              error in
                if didAuthorize {
//                    self?.retrieveContacts(from: store)
                    self?.ConteactNoSave()
                }
            }
        } else if authorizationStatus == .authorized {
//            retrieveContacts(from: store)
            self.ConteactNoSave()
        }  else if authorizationStatus == .denied {
            let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.headToSettingsOfPermissions()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func headToSettingsOfPermissions() {
        if let bundleId = Bundle.main.bundleIdentifier,
           let url = URL(string: "\(UIApplication.openSettingsURLString)&path=APPNAME/\(bundleId)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
//    func retrieveContacts(from store: CNContactStore) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//            self.ConteactNoSave()
//        })
//      }
    
    
    func DialCall(name:String,number:String){
        
        if(CPPWrapper().registerStateInfoWrapper() != false) {
//            CPPWrapper.clareAllData()
            
            
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallingDisplayVc") as! CallingDisplayVc
            nextVC.number = number
            nextVC.phoneCode =  ""
            //nextVC.nameDisplay = name
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
    
    func vidoeCall(name:String,number:String){
        
        if(CPPWrapper().registerStateInfoWrapper() != false) {
            CPPWrapper.clareAllData()
            
//            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoCallWaitVc") as! VideoCallWaitVc
//            nextVC.phoneCode =  ""
//            nextVC.number = number
//            nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
//            nextVC.name = name
//            self.present(nextVC, animated: true)
            
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
    
    func animShow(view: UIView){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut],
                       animations: {
            view.center.y -= view.bounds.height
            view.layoutIfNeeded()
        }, completion: nil)
        view.isHidden = false
    }
    
    func animHide(view: UIView){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear],
                       animations: {
            view.center.y += view.bounds.height
            view.layoutIfNeeded()

        },  completion: {(_ completed: Bool) -> Void in
            view.isHidden = true
            })
    }
    
    func keypedTimeSearchContact(number: String) {
        if isCallDummyLogData.count > 0 {
            isCallLogData = isCallDummyLogData
        }
        
        isCallLogData = isCallLogData.filter({($0["number"] as! String).lowercased().contains(number.lowercased())})
        
        groupedUsersAudio.removeAll()
        if searchBar.text == "" {
            dataContectInfo = tempContectInfo
            searchActive = false
        } else {
            searchActive = true
        }
        groupedUsersAudio = Dictionary(grouping: isCallLogData, by: numberManage)
        
        iscountNumberHistory = 0
        var dv = [[String:Any]]()
        var numberMange = ""
        for i in isCallLogData {
            if numberMange != "" &&  numberMange != (i["number"]  as! String).suffix(10) {
                let gorup =  Dictionary(grouping: dv, by: numberManage)
                groupedUsersAudio =  groupedUsersAudio.merging(gorup) { (current, _) in current }
                iscountNumberHistory = iscountNumberHistory + 1
                dv = [[String:Any]]()
                numberMange =  String((i["number"]  as! String).suffix(10))
                dv.append(i)
            }else{
                numberMange =  String((i["number"]  as! String).suffix(10))
                dv.append(i)
            }
        }
        
        let gorupV =  Dictionary(grouping: dv, by: numberManage)
        groupedUsersAudio =  groupedUsersAudio.merging(gorupV) { (current, _) in current }
        indexAudioContactsArray = [Int](groupedUsersAudio.keys)
        indexAudioContactsArray = indexAudioContactsArray.sorted()
        
        keyPedUsedTblView.reloadData()
    }
    
        
    //MARK: - btn Click
    
    @IBAction func btnClickNewGroup(_ sender: UIButton) {
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "CreateParticipantVC") as? CreateParticipantVC
            self.navigationController?.pushViewController(nextVC!, animated: true)
            
        }
    
    @IBAction func btnClickCall(_ sender: UIButton) {
        if txtnumber.text != "" {
            let letter = txtnumber.text
            var nameCaller = ""
            if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == letter!})
                if index != nil {
                    nameCaller = contactList[index!]["name"] as? String ?? ""
                }
                else {
                    nameCaller = "Unknown"
                }
            }
            
            if iscallTransfer == true {
                let calldata = ["number":letter,"name":nameCaller]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transferCall"), object: nil, userInfo: calldata as [AnyHashable : Any])
            }else{
                let calldata = ["number":letter,"name":nameCaller]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callAdd"), object: nil, userInfo: calldata as [AnyHashable : Any])
            }
            
        }else{
            showToastMessage(message: "Please Enter Number")
        }
        
        
    }
    
    @IBAction func btnNumber(_ sender: UIButton) {
        if txtnumber.text?.count ?? 0 < 16 {
            txtnumber.text = (txtnumber.text ?? "") + "\(sender.tag)"
        }
        AudioServicesPlaySystemSound (SystemSoundID(1200 + sender.tag))
        
        keypedTimeSearchContact(number: txtnumber.text ?? "")
    }
    
    @IBAction func btnTapDialPed(_ sender: UIButton) {

        if floatingButton.isSelected == false {
           
            if isOnlayOneTimeMoveToKeyPed == false {
                numberPadVW.center.y += numberPadVW.bounds.height
                numberPadVW.layoutIfNeeded()
                isOnlayOneTimeMoveToKeyPed = true
            }
            floatingButton.isSelected  = true
            //show us the view with fade in animations
            dummyVW.isHidden  = false
            if txtnumber.text == "" {
                keyPedBackSideVW.alpha = 0.0
                keyPedBackSideVW.isHidden = false

                UIView.animate (withDuration: 0.5, delay: 0.2, options: .curveEaseIn,
                                animations: { [self] in
                    keyPedBackSideVW.alpha = 1.0
                })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
               animShow(view: numberPadVW)
                
//                numberPadVW.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//                UIView.animate(withDuration: 1.35, delay: 0,
//                               usingSpringWithDamping: 0.25,
//                               initialSpringVelocity: 5,
//                               options: .curveEaseIn,
//                               animations: {
//                    self.numberPadVW.transform = .identity
//                })
                
                var count = 0.02
                for i in numbersView {
                    UIView.animate(withDuration: count, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                        var frame = i.frame
                        frame.origin.y += 8 // Move the view up by 8 points
                        i.frame = frame
                    }) { (_) in
                        UIView.animate(withDuration: count
                                       , delay: 0
                                       , usingSpringWithDamping: 0.25
                                       , initialSpringVelocity: 5
                                       , options: .curveEaseIn, animations: {
                            var frame = i.frame
                            frame.origin.y -= 8 // Move the view back down to its original position
                            i.frame = frame
                        })
                    }
                    count  = count + 0.04
                }
             })
        } else {
            floatingButton.isSelected  = false
            //hide us the view with fade in animations
            UIView.animate (withDuration: 0.5, delay: 0.2, options: .curveEaseOut,
                            animations: {
                self.keyPedBackSideVW.alpha = 0.0
                self.keyPedBackSideVW.isHidden = true
                self.numberPadVW.isHidden = true
            })
            isOnlayOneTimeMoveToKeyPed = false
            
            if txtnumber.text == "" {
                txtnumber.text = ""
                keypadContectInfo.removeAll()
                keyPedUsedTblView.reloadData()
            }
           
        }
            
        
//        numberPadVW.isHidden = floatingButton.isSelected
//        floatingButton.isSelected = !floatingButton.isSelected
    }
    
    @IBAction func btnClickNumberErase(_ sender: UIButton) {
        if  self.txtnumber.text?.count ?? 0 > 0 {
            txtnumber.text?.removeLast()
        }
        
        keypedTimeSearchContact(number: txtnumber.text ?? "")

    }
    
    @IBAction func btnClickBack(_ sender: UIButton) {
        if isAddToChatView == true {
            self.navigationController?.popToRootViewController(animated: true)
        }else {
            self.dismiss(animated: true)
        }
        
    }
    
    @IBAction func btnContactAllow(_ sender: UIButton) {
        let  Alert = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactsPermitionVC") as? ContactsPermitionVC
        Alert?.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
        Alert?.delegate = self
        self.present(Alert!, animated: false, completion: nil)
    }
    
    
}
//MARK: TableView ------------------------------------------------------------------------------
extension ContactsVc: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == keyPedUsedTblView {
            return 1
        }else{
            tableView.isHidden = false
            if contactNamesDictionary.keys.count == 0  && tempContectInfo.count  == 0 {
                tableView.isHidden = true
            }
            return contactNamesDictionary.keys.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == keyPedUsedTblView {
            tableView.isHidden = false
            keypadUIGestureVW.isUserInteractionEnabled = false
//            if keypadContectInfo.count == 0 {
//                tableView.isHidden = true
//                keypadUIGestureVW.isUserInteractionEnabled = true
//            }
//            return keypadContectInfo.count
            
            if groupedUsersAudio.count == 0 {
                lblCallHistoryNotFound.isHidden = false
                tableView.isHidden = true
                keypadUIGestureVW.isUserInteractionEnabled = true
            } else {
                lblCallHistoryNotFound.isHidden = true
            }

            return groupedUsersAudio.count
            
            
        }else{
            var count = Int()
            let letter = indexLettersInContactsArray[section]
            if let names = contactNamesDictionary[letter] {
                count = names.count
            }
            return count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == keyPedUsedTblView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddContactsListCell", for: indexPath) as? AddContactsListCell else { return UITableViewCell() }
            
            let dicForData = indexAudioContactsArray[indexPath.row]
            let infoContact = groupedUsersAudio[dicForData]
            
            cell.contactNumber.text = infoContact?[0]["number"] as? String ?? ""
            cell.lblNameLetter.text = findNameFistORMiddleNameFistLetter(name: infoContact?[0]["contact_name"] as? String ?? "")
            cell.lblNameLetter.isHidden = false
            cell.lblNameLetter.layer.cornerRadius = cell.lblNameLetter.layer.bounds.height/2
            
            if tempkeypadContectInfo.count > 0 {
                if let index = tempkeypadContectInfo.firstIndex(where: {
                    let phone = ($0["phone"] as! String).removeWhitespace()
                    return phone.suffix(10) == String((infoContact?[0]["number"] as? String ?? "").suffix(10))
                }) {
                    let findNumber = tempkeypadContectInfo[index]
                    if infoContact?.count ?? 0 > 1 {
                        cell.contactName.text = (findNumber["name"] as? String ?? "") + "(\(infoContact?.count ?? 0))"
                    }else{
                        cell.contactName.text = (findNumber["name"] as? String ?? "")
                    }
                    
                    cell.lblNameLetter.text = findNameFistORMiddleNameFistLetter(name: (findNumber["name"] as? String ?? ""))
                    

                    cell.contactImage.layer.cornerRadius = cell.contactImage.layer.bounds.height/2
                    if findNumber["imageData64"] as! String != "" {
                        cell.lblNameLetter.isHidden = true
                        let dataDecoded:NSData = NSData(base64Encoded: findNumber["imageData64"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                        cell.contactImage.image = decodedimage
                    } else {
                        cell.contactImage.image = UIImage(named: "")
                    }
                } else {
                    if infoContact?.count ?? 0 > 1 {
                        cell.contactName.text = (infoContact?[0]["contact_name"] as? String ?? "") +  "(\(infoContact?.count ?? 0))"
                    } else {
                        cell.contactName.text = (infoContact?[0]["contact_name"] as? String ?? "")
                    }
                    cell.contactImage.image = UIImage(named: "")
                }
            }
            cell.contactImage.layer.cornerRadius = cell.contactImage.layer.bounds.height/2
            cell.lblVW.layer.cornerRadius = cell.lblVW.layer.bounds.height/2
            
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as? ContactsCell else { return UITableViewCell() }
            
            
            
            var attributedText = NSAttributedString()
            
            let letter = indexLettersInContactsArray[indexPath.section]
            if var names = contactNamesDictionary[letter.uppercased()] {
                names = names.sorted()
                
                let text = names[indexPath.row]
                let attributedString = NSMutableAttributedString(string: text)
                attributedText = attributedString
                
                cell.contactImage.isHidden = false
                cell.lblVW.isHidden = false
                
                let dic =  groupedUsers[Character(letter)]?[indexPath.row]
    //
                if dic?["imageData64"] as! String != "" {
                    cell.lblVW.isHidden = true
                    let dataDecoded:NSData = NSData(base64Encoded: dic?["imageData64"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    cell.contactImage.image = decodedimage
                }else {
                    cell.contactImage.isHidden = true
                    cell.lblNameLetter.text = findNameFistORMiddleNameFistLetter(name: text)
                }
                cell.contactNumber.text = (dic?["phone"] as? String)
                cell.contactName.text = (dic?["name"] as? String)

            }
            
            
            cell.contactImage.layer.cornerRadius = cell.contactImage.layer.bounds.height/2
            cell.lblVW.layer.cornerRadius = cell.lblVW.layer.bounds.height/2
            cell.btnInvite.layer.cornerRadius = cell.btnInvite.bounds.height/2
            cell.btnInvite.layer.borderColor = #colorLiteral(red: 0.1069028154, green: 0.6903560162, blue: 0.8614253998, alpha: 1)
            cell.btnInvite.layer.borderWidth = 1.0
            cell.btnInvite.tag = indexPath.row
            cell.btnInvite.addTarget(self, action: #selector(self.documentSlection(_:)), for: .touchUpInside)
         
            
            cell.btnInvite.isHidden = !isInvitedBtnShow
            cell.btnFavorite.isHidden = !isFavoriteBtnShow
            cell.contactNumber.isHidden = !isContectNumberShow
            cell.btnFavorite.setImage(#imageLiteral(resourceName: "ic_fav_uncheck"), for: .normal)
            cell.btnFavorite.tag = 0
            cell.heightForFavouriteBtn.constant = 0
            
            if Favourite.count > 0 {
                if  Favourite.contains(where: {$0["number"] as? String == cell.contactNumber.text}) {
                    cell.btnFavorite.setImage(#imageLiteral(resourceName: "ic_fav_check"), for: .normal)
                    cell.heightForFavouriteBtn.constant = 25
                }
            }

            cell.btnFavorite.setTitle(String(format: "%@ %@ %@" , String(indexPath.section) , String(indexPath.row),"\(cell.btnFavorite.tag)"), for:.disabled)
            cell.btnFavorite.addTarget(self, action: #selector(self.FavoriteContactAdd(_:)), for: .touchUpInside)
            
            
            if isContectNumberShow == true {
                cell.PolistionorName.constant = -15
            }else {
                cell.PolistionorName.constant = 0
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == keyPedUsedTblView {
            return 50
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == keyPedUsedTblView {
            return UIView()
        }else{
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x: 22, y: 8, width: headerView.frame.width/2, height: headerView.frame.height/2)
            label.text = indexLettersInContactsArray[section]
            label.font = .boldSystemFont(ofSize: 16)
            label.textColor = .white
            headerView.addSubview(label)
            headerView.backgroundColor = #colorLiteral(red: 0.4439517856, green: 0.5258321166, blue: 0.7032657862, alpha: 1)
            return headerView
        }
        
    }
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == keyPedUsedTblView {
            return 0
        }else{
            return 40
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        floatingButton.isSelected  = false
        self.numberPadVW.isHidden = true
        isOnlayOneTimeMoveToKeyPed = false
        dummyVW.isHidden = true
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == keyPedUsedTblView {
            return []
        }else{
            if #available(iOS 16.0, *) {
                if indexLettersInContactsArray.contains(indexLetters) {
                    return indexLetters
                }
            }
            var output = indexLettersInContactsArray.filter(indexLetters.contains)
            return output
        }
        
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if tableView == keyPedUsedTblView {
            
            let dicForData = indexAudioContactsArray[indexPath.row]
            let infoContact = groupedUsersAudio[dicForData]
            
            let removeplusnumber = (infoContact?[0]["number"] as? String ?? "").replace(string: "+", replacement: "")
            let removeBraket1 = removeplusnumber.replace(string: "(", replacement: "")
            let removeBraket2 = removeBraket1.replace(string: ")", replacement: "")
            let removeDesh = removeBraket2.replace(string: "-", replacement: "")
            let removewhideSpace = removeDesh.removeWhitespace()
            
            if iscallTransfer == true {
                let calldata = ["number":removewhideSpace,"name":(infoContact?[0]["contact_name"] as? String ?? "")]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transferCall"), object: nil, userInfo: calldata)
            }else{
                let calldata = ["number":removewhideSpace,"name":(infoContact?[0]["contact_name"] as? String ?? "")]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callAdd"), object: nil, userInfo: calldata)
            }
            
        }else{
            //        self.tabBarController?.tabBar.isHidden = true
            
            let letter = indexLettersInContactsArray[indexPath.section]
            let dic =  groupedUsers[Character(letter)]?[indexPath.row]
            
            if isAddToChatView == true {
                self.tabBarController?.tabBar.isHidden = true
                let nextVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatVc") as! ChatVc
                let allData = RealmDatabaseeHelper.shared.getAllUserModall()
                let index = allData.firstIndex(where: {$0.contactNumber.suffix(10) == (dic!["phone"] as? String ?? "" ).suffix(10)})
                if index  != nil {
                    let dicForData = allData[index!]
                    RealmDatabaseeHelper.shared.readTimeCountChange(phonenumber: dicForData.contactNumber)
                    nextVC.userChatId = dicForData.receiverIdForChat
                    appDelegate.ChatGroupID = dicForData.roomID
                }
                nextVC.phoneNumber = (dic!["phone"] as? String ?? "")
                nextVC.Name = (dic!["name"] as? String ?? "")
                nextVC.fistTimeUserEntry = true
                navigationController?.pushViewController(nextVC, animated: false)
            }else{
                floatingButton.isSelected  = false
                floatingButton.isSelected = false
                numberPadVW.isHidden = !floatingButton.isSelected
                
                searchActive = false
                searchBar.setShowsCancelButton(false, animated: true)
                searchBar.endEditing(true)
                
                isContactNumberDetailShow = true
                
                let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactDetailVc") as! ContactDetailVc
                nextVC.iscallAdd = self.iscallAdd
                nextVC.iscallTransfer = self.iscallTransfer
                nextVC.iscallAddSpeedDial = self.iscallAddSpeedDial
                nextVC.contactDetail = dic!
//                nextVC.iscallVideoAdd = self.iscallVideoAdd
                nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
                self.present(nextVC, animated: true)
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
//    func tableView(_ tableView: UITableView,
//                            contextMenuConfigurationForRowAt indexPath: IndexPath,
//                   point: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil,
//                                          previewProvider: nil,
//                                          actionProvider: { [self]
//            suggestedActions in
//
//            let letter = indexLettersInContactsArray[indexPath.section]
//            let dic =  groupedUsers[Character(letter)]?[indexPath.row]
//
//            let number =   dic!["phone"] as? String ?? ""
//            let removeplusnumber = number.replace(string: "+", replacement: "")
//            let removeBraket1 = removeplusnumber.replace(string: "(", replacement: "")
//            let removeBraket2 = removeBraket1.replace(string: ")", replacement: "")
//            let removeDesh = removeBraket2.replace(string: "-", replacement: "")
//            let remvoewhitespace = removeDesh.removeWhitespace()
//
//            if UserDefaults.standard.object(forKey: "InAppPurchaseCheckVideoCall") == nil{
//                let inspectAction =
//                UIAction(title: NSLocalizedString("Call", comment: ""),
//                         image: UIImage(systemName: "phone")) { [self] action in
//
//                    DialCall(name: dic!["name"] as? String ?? "", number: remvoewhitespace)
//
//                }
//                let deleteAction =
//                UIAction(title: NSLocalizedString("Delete", comment: ""),
//                         image: UIImage(systemName: "trash"),
//                         attributes: .destructive) { [self] action in
//                    deleteContact(number: dic!["phone"] as? String ?? "")
//                }
//                return UIMenu(title: "", children: [inspectAction, deleteAction])
//            }
//            else{
//                let inspectAction =
//                UIAction(title: NSLocalizedString("Call", comment: ""),
//                         image: UIImage(systemName: "phone")) { [self] action in
//                    DialCall(name: dic!["name"] as? String ?? "", number: remvoewhitespace)
//                }
//                let duplicateAction =
//                UIAction(title: NSLocalizedString("Video", comment: ""),
//                         image: UIImage(systemName: "video")) { [self] action in
//                    let number =   dic!["phone"] as? String ?? ""
//                    vidoeCall(name: dic!["name"] as? String ?? "", number: remvoewhitespace)
//                }
//                let deleteAction =
//                UIAction(title: NSLocalizedString("Delete", comment: ""),
//                         image: UIImage(systemName: "trash"),
//                         attributes: .destructive) { [self] action in
//                    deleteContact(number: dic!["phone"] as? String ?? "")
//                }
//                return UIMenu(title: "", children: [inspectAction,duplicateAction,deleteAction])
//            }
//        })
//    }
    
    
    @objc func FavoriteContactAdd(_ sender: UIButton){
        let strIndexPath = sender.title(for: .disabled)
        let arrForIndexPath = strIndexPath?.components(separatedBy: " ")
        let sectionValue:Int? = Int(arrForIndexPath![0] )
        let rowValue:Int? = Int(arrForIndexPath![1] )
        let slection:Int? = Int(arrForIndexPath![2] )
        
        
        let letter = indexLettersInContactsArray[sectionValue!]
        let dic =  groupedUsers[Character(letter)]?[rowValue!]
       
                    
        if Favourite.contains(where: {$0["number"] as? String == dic!["phone"] as? String ?? ""}) {
            DBManager().deleteByFavorite(number: dic!["phone"] as? String ?? "")
            Favourite = DBManager().getAllFavorite()
        }else{
            let dicNumber = ["number":dic!["phone"] as? String ?? "","isfavourite":"1"] as! [String : Any]
            DBManager().insertFavorite(dicFavorite: dicNumber)
            Favourite = DBManager().getAllFavorite()
        }
        self.tableView.reloadData()
    }
    
    func deleteContact(number: String){
        var dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { [self] (action) -> Void in
            print("Ok button tapped")
            let store = CNContactStore()
            
            let predicate = CNContact.predicateForContacts(matchingName: number)
            let toFetch = [CNKeyDescriptor]()
            
            do{
                let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: toFetch)
                guard contacts.count > 0 else{
                    print("No contacts found")
                    return
                }
                
                guard let contact = contacts.first else{
                    return
                }
                
                let req = CNSaveRequest()
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                req.delete(mutableContact)
                
                do{
                    try store.execute(req)
                    print("Success, You deleted the user")
                } catch let e{
                    print("Error = \(e)")
                }
            } catch let err{
                print(err)
            }
            self.dismiss(animated: true)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
}



extension ContactsVc : UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
       // searchBar.showsCancelButton = true
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchBar.showsCancelButton = false
        searchController.searchBar.becomeFirstResponder()
        searchController.searchBar.showsCancelButton = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if tempContectInfo.count > 0 {
            dataContectInfo = tempContectInfo
        }
        
        dataContectInfo = dataContectInfo.filter({($0["name"] as! String).lowercased().contains(searchBar.text!.lowercased())})
        groupedUsers.removeAll()
        if searchBar.text == "" {
            dataContectInfo = tempContectInfo
            searchActive = false
        } else {
            searchActive = true
        }
        groupedUsers = Dictionary(grouping: dataContectInfo, by: firstCharOfFirstName)

        createNameDictionary()
    }


    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    

}
class CustomSearchBar: UISearchBar {

    override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        super.setShowsCancelButton(false, animated: false)
    }

}

extension ContactsVc: MFMessageComposeViewControllerDelegate{
    @objc func documentSlection(_ sender: UIButton) {
        let data = dataContectInfo[sender.tag]
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "test"
            controller.recipients = ["\(data["phone"] as! String)"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func filterNumber(phoneNumber: String) -> String {
        let str = phoneNumber
        let filter0 = str.replacingOccurrences(of: ")", with: "")
        let filter = filter0.replacingOccurrences(of: "(", with: "")
        let filter1 = filter.replacingOccurrences(of: "-", with: "")
        let filter2 = filter1.replacingOccurrences(of: "+", with: "")
        let filter3 = filter2.replacingOccurrences(of: " ", with: "")
        let filter4 = filter3.replacingOccurrences(of: "*", with: "")
        let filter5 = filter4.replacingOccurrences(of: "#", with: "")
        let filter6 = filter5.replacingOccurrences(of: "&", with: "")

        if filter6.count > 10 {
            let last4 = String(filter6.suffix(10))
            print(last4)
            return last4
        }
        return filter6
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            print("Message sent")
        case .cancelled:
            print("Message Cancelled")
        case .failed:
            print("Message Fail")
        default:
            print("Some issue Face")
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension ContactsVc : ContactsPermitionDelegate {
    func contectPermtion(){
        HelperClassAnimaion.showProgressHud()
       // ProgressHUD.show()

        dismiss(animated: false, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [self] in
                self.ConteactNoSave()
             })
        })
//        self.properSetPhoneNumber()
    }
    
   
}
extension ContactsVc: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtnumber {
            return false
        }
        else{
            return true
        }
    }
}
