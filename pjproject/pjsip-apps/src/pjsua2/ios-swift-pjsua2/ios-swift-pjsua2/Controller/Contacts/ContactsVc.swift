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

class ContactsVc: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hightTopNavigationBar: NSLayoutConstraint!
    @IBOutlet weak var contactAllowVW: UIView!
    
    
    var store = CNContactStore()
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var tempContectInfo = [[String : Any]]()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        hightTopNavigationBar.constant = 0
        if isShowTopNavigationBar == true {
            hightTopNavigationBar.constant = 90
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
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        DBManager().deleteAllContact()
//        callListUpdata()
        Favourite = DBManager().getAllFavorite()
        contactBook = KNContactBook(id: "allContacts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
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
//        if requestAccess() {
            self.contactGetInDataBase()
//        }
//        else{
//            checkPermissionToDeviceContacts()
//            let  Alert = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactsPermitionVC") as? ContactsPermitionVC
//            Alert?.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
////            Alert?.delegate = self
//            self.present(Alert!, animated: false, completion: nil)
//        }
    }
    
    func contactGetInDataBase(){
        if isShowTopNavigationBar == true {
            HelperClassAnimaion.showProgressHud()
        }

        dataContectInfo = DBManager().getAllContact()

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
        }
        
        if isShowTopNavigationBar == true {
            HelperClassAnimaion.hideProgressHud()
        }
    }
    
    func ConteactNoSave()  {
        
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
                    
                    let dicContactData =  ["name": i.fullName(), "phone": i.getFirstPhoneNumber().removeWhitespace(), "imageDataAvailable": i.info.imageDataAvailable, "imageData64": strBase64, "Email": i.getFirstEmailAddress()] as [String : Any]
                    DBManager().insertcontact(dicContact: dicContactData)
                    
                    dataContectInfo.append(data)
                }
            }
        }
        
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
        
        HelperClassAnimaion.hideProgressHud()
        
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
    
    //MARK: - btn Click
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
        tableView.isHidden = false
        if contactNamesDictionary.keys.count == 0 {
            tableView.isHidden = true
        }
        return contactNamesDictionary.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int()
        let letter = indexLettersInContactsArray[section]
        if let names = contactNamesDictionary[letter] {
            count = names.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if #available(iOS 16.0, *) {
            if indexLettersInContactsArray.contains(indexLetters) {
                return indexLetters
            }
        }
        var output = indexLettersInContactsArray.filter(indexLetters.contains)
        return output
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        //        self.tabBarController?.tabBar.isHidden = true
        
        let letter = indexLettersInContactsArray[indexPath.section]
        let dic =  groupedUsers[Character(letter)]?[indexPath.row]
        
        if isAddToChatView == true {
//            self.tabBarController?.tabBar.isHidden = true
//            let nextVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatVc") as! ChatVc
//            let allData = RealmDatabaseeHelper.shared.getAllUserModall()
//            let index = allData.firstIndex(where: {$0.contactNumber.suffix(10) == (dic!["phone"] as? String ?? "" ).suffix(10)})
//            if index  != nil {
//                let dicForData = allData[index!]
//                RealmDatabaseeHelper.shared.readTimeCountChange(phonenumber: dicForData.contactNumber)
//                nextVC.userChatId = dicForData.receiverIdForChat
//                appDelegate.ChatGroupID = dicForData.roomID
//            }
//            nextVC.phoneNumber = (dic!["phone"] as? String ?? "")
//            nextVC.Name = (dic!["name"] as? String ?? "")
//            nextVC.fistTimeUserEentry = true
//            navigationController?.pushViewController(nextVC, animated: false)
        }else{
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactDetailVc") as! ContactDetailVc
            nextVC.iscallAdd = self.iscallAdd
            nextVC.iscallTransfer = self.iscallTransfer
            nextVC.iscallAddSpeedDial = self.iscallAddSpeedDial
            nextVC.contactDetail = dic!
            nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            self.present(nextVC, animated: true)
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
extension ContactsVc : ContactsPermitionDelegate{
    func contectPermtion(){
        HelperClassAnimaion.showProgressHud()
        dismiss(animated: false, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [self] in
                self.ConteactNoSave()
             })
        })
       
//        self.properSetPhoneNumber()
    }
}
