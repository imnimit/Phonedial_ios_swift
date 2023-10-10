//
//  PhoneDialUserListVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 02/03/23.
//

import UIKit
import KNContacts
import Contacts

class PhoneDialUserListVc: UIViewController {

    var store = CNContactStore()
    var contactBook = KNContactBook(id: "allContacts")
    
    var dataContectInfo = [[String : Any]]()
    var tempPhoneDialerContect = [[String : Any]]()
    var phoneDialerContactsData = [[String : Any]]()
    var number = ""
    var numbers = [String]()
    var pullControl = UIRefreshControl()
    var storeCount = UserDefaults.standard.value(forKey: "storeCount") as? Int ?? 0
    var arrOfPhoneDialercontact = [String]()
    var searchActive = true
    var contactNamesDictionary = [String: [String]]()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataContectInfo = DBManager().getAllContact()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataContectInfo = DBManager().getAllContact()
        listAllPhoneDialresContacts()
        
        pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(pullControl)
        self.searchBar.tintColor = UIColor.black
        
    }
    
    func countManage() -> Int {
        let remainingCount = dataContectInfo.count - storeCount
        if remainingCount >= 20 {
            return 20
        } else if remainingCount > 0 {
            return remainingCount
        } else {
            return 0
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
       
        if storeCount != dataContectInfo.count {
            for _ in 0..<countManage() {
                var number1 = (dataContectInfo[storeCount]["phone"] as? String ?? "").digitsOnly
                numbers.append(number1)
                storeCount += 1
                UserDefaults.standard.set(storeCount, forKey: "storeCount")
            }
            getSipContact()
            
        } else {
            showToastMessage(message: "All number are sync")
            pullControl.endRefreshing()
        }
        
    }
    
    func listAllPhoneDialresContacts() {
        phoneDialerContactsData = DBManager().getAllPhoneDialer()
        
        var set = Set<String>()
        let arraySet: [[String: Any]] = phoneDialerContactsData.compactMap {
            guard let phone = $0["phone"] as? String else { return nil }
            
            return set.insert(phone).inserted ? $0 : nil
        }
            phoneDialerContactsData = arraySet
            tempPhoneDialerContect = phoneDialerContactsData
            tableView.reloadData()
    }
    
    func DialCall(senderTag: Int){
        if(CPPWrapper().registerStateInfoWrapper() != false) {
            CPPWrapper.clareAllData()
            
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallingDisplayVc") as! CallingDisplayVc
            let dic = phoneDialerContactsData[senderTag]
            nextVC.number = dic["phone"] as? String ?? ""
            nextVC.phoneCode =  ""
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
    
    
    // MARK: - API CAlling
    
    func getSipContact() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        let unique = Array(Set(numbers))
        let requestData : [String : String] = ["Number":"\(unique.joined(separator: ","))"
                                               ,"Token":User.sharedInstance.getUser_token()
                                               ,"Device_id":appDelegate.diviceID
                                               ,"request":"get_sip_contact"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "0" {
                self.showToastMessage(message: diddata["message"] as? String)
                pullControl.endRefreshing()
            } else {
                let Data : [String: Any] = (diddata["response"] as! [String: Any])
              
                let phoneDialerContact = Data["contacts"] as? String ?? ""
                    
                if phoneDialerContact != "" {
                    arrOfPhoneDialercontact = phoneDialerContact.components(separatedBy: ",")
         
                    for i in arrOfPhoneDialercontact {
                        if dataContectInfo.contains(where: { ($0["phone"] as? String) == i }) {
                            DBManager().updatePhoneDialerContact(phoneNumber: i)
                        }
                    }
                    listAllPhoneDialresContacts()
                }
                pullControl.endRefreshing()
            }
        })
    }
    
    func NumberYouHaveCall(flag:String,CalleridNumber:String,tag:Int){
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
                DialCall(senderTag: tag)
            }
        })
    }
    
    func getCalleridForSelection(tag: Int) {
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
                
                Flage = "onnet"
                
                let optionMenu = UIAlertController(title: nil, message: "Choose your Number", preferredStyle: .actionSheet)
                let saveAction = UIAlertAction(title: User.sharedInstance.getContactNumber(), style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.NumberYouHaveCall(flag:Flage,CalleridNumber:User.sharedInstance.getContactNumber(), tag: tag)
                })
                optionMenu.addAction(saveAction)

                for i in number {
                    let deleteAction = UIAlertAction(title: i["callerid_number"] as? String ?? "", style: .default, handler: {
                        (alert: UIAlertAction!) -> Void in
                        self.NumberYouHaveCall(flag:Flage,CalleridNumber: alert.title ?? "", tag: tag)
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
               DialCall(senderTag: tag)
            }
        })
    }
    
    
}
extension PhoneDialUserListVc:  UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneDialerContactsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhoneDialerUserListCell", for: indexPath) as! PhoneDialerUserListCell
        let dict = phoneDialerContactsData[indexPath.row]
        cell.lblName.text = dict["phone"] as? String
        cell.lblNumber.text = dict["name"] as? String
        cell.profileVW.layer.cornerRadius = cell.profileVW.layer.bounds.height/2
        cell.profileImageVW.layer.cornerRadius = cell.profileImageVW.layer.bounds.height/2
        if dict["imageData64"] as! String != "" {
            let dataDecoded:NSData = NSData(base64Encoded: dict["imageData64"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            cell.profileImageVW.image = decodedimage
        } else {
            cell.profileImageVW.image = UIImage(named: "app_logo_country")
        }
        cell.btnVideoCall.tag = indexPath.row
        cell.btnMessage.tag = indexPath.row
        cell.btnPhoneCall.tag = indexPath.row
        cell.btnVideoCall.addTarget(self, action: #selector(self.btnVideoCall(_:)), for: .touchUpInside)
        cell.btnMessage.addTarget(self, action: #selector(self.btnMessage(_:)), for: .touchUpInside)
        cell.btnPhoneCall.addTarget(self, action: #selector(self.btnPhoneCall(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    @objc func btnVideoCall(_ sender: UIButton) {
        
        if(CPPWrapper().registerStateInfoWrapper() != false) {
            CPPWrapper.clareAllData()
            AppDelegate.instance.counter = 0
            
            let dict = phoneDialerContactsData[sender.tag]
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoCallWaitVc") as! VideoCallWaitVc
            nextVC.phoneCode =  ""
            nextVC.number = dict["phone"] as? String ?? ""
            nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            nextVC.name = dict["name"] as? String ?? ""
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
    
    @objc func btnMessage(_ sender: UIButton) {
        
        self.tabBarController?.tabBar.isHidden = true
        let dic = phoneDialerContactsData[sender.tag]
        let nextVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatVc") as! ChatVc
        let allData = RealmDatabaseeHelper.shared.getAllUserModall()
        let index = allData.firstIndex(where: {$0.contactNumber.suffix(10) == (dic["phone"] as? String ?? "" ).suffix(10)})
        if index  != nil {
            let dicForData = allData[index!]
            RealmDatabaseeHelper.shared.readTimeCountChange(phonenumber: dicForData.contactNumber)
            nextVC.userChatId = dicForData.receiverIdForChat
            appDelegate.ChatGroupID = dicForData.roomID
        }
        nextVC.phoneNumber = (dic["phone"] as? String ?? "")
        nextVC.Name = (dic["name"] as? String ?? "")
        nextVC.fistTimeUserEntry = true
        nextVC.fromPhoneDialers = true
        navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    @objc func btnPhoneCall(_ sender: UIButton) {
        getCalleridForSelection(tag: sender.tag)
    }
}

extension PhoneDialUserListVc : UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
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
        if tempPhoneDialerContect.count > 0 {
            phoneDialerContactsData = tempPhoneDialerContect
        }
        
        phoneDialerContactsData = phoneDialerContactsData.filter({($0["name"] as! String).localizedCaseInsensitiveContains(searchBar.text!)})
        
        if searchBar.text == "" {
            phoneDialerContactsData = tempPhoneDialerContect
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
        
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
}
