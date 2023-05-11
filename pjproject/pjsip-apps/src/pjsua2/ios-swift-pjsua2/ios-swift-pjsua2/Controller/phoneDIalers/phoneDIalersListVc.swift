//
//  phoneDIalersListVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit
import Contacts
import ContactsUI
import KNContacts

class phoneDIalersListVc: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var callEmtyTimeShowVW: UIView!
    var callLogData = [[String:Any]]()
    var groupedUsers =  [Int : [[String : Any]]]()
    var indexContactsArray = [Int]()
    var numberMange = ""
    var countNumber = 0
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var IsAddContectInAudioLog = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(callLogUpdata), name: Notification.Name("callLogUpdata"), object: nil)
       
    }
    
    @objc func callLogUpdata(){
        contactBook = KNContactBook(id: "allContacts")
        ConteactNoSave()
    }
    
    func CallLogReArrage(){
        groupedUsers.removeAll()
        indexContactsArray.removeAll()
        callLogData = DBManager().getAllCallLog()
        countNumber = 0
        var d = [[String:Any]]()
        for i in callLogData {
            if numberMange != "" &&  numberMange != (i["number"]  as! String).suffix(10) {
                let gorup =  Dictionary(grouping: d, by: numberManage)
                groupedUsers =  groupedUsers.merging(gorup) { (current, _) in current }
                countNumber = countNumber + 1
                d = [[String:Any]]()
                numberMange =  String((i["number"]  as! String).suffix(10))
                d.append(i)
            }else {
                numberMange =  String((i["number"]  as! String).suffix(10))
                d.append(i)
            }
        }
        
        let gorup =  Dictionary(grouping: d, by: numberManage)
        groupedUsers =  groupedUsers.merging(gorup) { (current, _) in current }
        
        indexContactsArray = [Int](groupedUsers.keys)
        indexContactsArray = indexContactsArray.sorted()

        print(groupedUsers)
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        callLogUpdata()
        ConteactNoSave()
    }
    
    func numberManage(_ aDict: [String:Any]) -> Int {
//        if aDict["number"] as! String  == "" {
//            return ""
//        }
        return countNumber
    }
    
    func ConteactNoSave()  {
        let keys = [CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey,
                    CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey,
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as! [CNKeyDescriptor]
        
        let requestForContacts = CNContactFetchRequest(keysToFetch: keys)
        self.hideKeybordTappedAround()
        
        // And then perform actions on KNContactBook
        let randomContacts = contactBook.randomElements(number: 1)
        let randomElements = contactBook.randomElements(number: 3, except: randomContacts)
        
        do {
            try CNContactStore().enumerateContacts(with: requestForContacts) { (cnContact, _) in
                let knContact = KNContact(cnContact)
                self.contactBook.add(knContact)
            }
        } catch let error {
            // Handle error somehow!
            print(error)
        }
        
        
        print(contactBook)
        
        
        
        dataContectInfo.removeAll()
        for  i  in contactBook.contacts {
            print(i.fullName())
            print(i.getFirstEmailAddress())
            
            print(i.getFirstPhoneNumber())
            print(i.info)
            var data = [String: Any]()

            if i.fullName() != "" {
                if i.info.imageDataAvailable as? Bool == true {
                    data = ["name":i.fullName(),"phone":i.getFirstPhoneNumber(),"imageDataAvailable": i.info.imageDataAvailable as? Bool ?? false ,"imageData": i.info.imageData!,"Email":i.getFirstEmailAddress()]
                }else {
                    data = ["name":i.fullName(),"phone":i.getFirstPhoneNumber(),"imageDataAvailable": i.info.imageDataAvailable as? Bool ?? false ,"imageData":i.info.imageData ?? Data(),"Email":i.getFirstEmailAddress()]
                }
                
                if dataContectInfo.firstIndex(where: {$0["phone"] as! String == i.getFirstPhoneNumber() }) != nil {
                    
                } else {
                    dataContectInfo.append(data)
                }
            }
        }
        
        dataContectInfo.sort {
            (($0 as! Dictionary<String, AnyObject>)["name"] as! String) < (($1 as! Dictionary<String, AnyObject>)["name"] as! String)
        }
        
        CallLogReArrage()
//        tableView.reloadData()
    }
}

extension phoneDIalersListVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupedUsers.count == 0 {
            callEmtyTimeShowVW.isHidden = false
            tableView.isHidden = true
        }else{
            callEmtyTimeShowVW.isHidden = true
            tableView.isHidden = false
        }
        return groupedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "phoneDIalersListCell", for: indexPath) as? phoneDIalersListCell else { return UITableViewCell() }
        let dicForData = indexContactsArray[indexPath.row]
        let infoContact = groupedUsers[dicForData]
        
        cell.lblNumber.text = infoContact?[0]["number"] as? String ?? ""
        cell.lblNameLetter.text = findNameFistORMiddleNameFistLetter(name: infoContact?[0]["contact_name"] as? String ?? "")
        cell.imgContacts.layer.cornerRadius = cell.imgContacts.layer.bounds.height/2
        if infoContact?[0]["type"] as? String == "Outgoing" {
            cell.imgeCallType.image = #imageLiteral(resourceName: "ic_outgoing_call.png")
        }else if infoContact?[0]["type"] as? String == "MissCall" {
            cell.imgeCallType.image = #imageLiteral(resourceName: "ic_miss_call.png")
        }else{
            cell.imgeCallType.image = #imageLiteral(resourceName: "ic_incoming_call.png")
        }
        cell.lblTimer.text = findExpiryData(FindExData: infoContact?[0]["created_date"] as? String ?? "")
        cell.btnGoDetail.tag = indexPath.row
        cell.btnGoDetail.addTarget(self, action: #selector(self.GoDetailSection(_:)), for: .touchUpInside)
        cell.lblNameLetter.isHidden = false

        if dataContectInfo.count > 0 {
            if let index = dataContectInfo.firstIndex(where: {
                let phone = ($0["phone"] as! String).removeWhitespace()
                return phone.suffix(10) == String((infoContact?[0]["number"] as? String ?? "").suffix(10))
            }) {
                let findNumber = dataContectInfo[index]
                if infoContact?.count ?? 0 > 1 {
                    cell.lblName.text = (findNumber["name"] as? String ?? "") + "(\(infoContact?.count ?? 0))"
                }else{
                    cell.lblName.text = (findNumber["name"] as? String ?? "")
                }
                
                cell.lblNameLetter.text = findNameFistORMiddleNameFistLetter(name: (findNumber["name"] as? String ?? ""))

                if findNumber["imageDataAvailable"] as? Bool == true {
                    cell.lblNameLetter.isHidden = true
                    cell.imgContacts.image = UIImage(data: (findNumber["imageData"] as! Data))!
                }else {
                    cell.imgContacts.image =  #imageLiteral(resourceName: "call_bg_image")
                }
            }else{
                if infoContact?.count ?? 0 > 1 {
                    cell.lblName.text = (infoContact?[0]["contact_name"] as? String ?? "") +  "(\(infoContact?.count ?? 0))"
                } else {
                    cell.lblName.text = (infoContact?[0]["contact_name"] as? String ?? "")

                }
                cell.imgContacts.image =  #imageLiteral(resourceName: "call_bg_image")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dicForData = indexContactsArray[indexPath.row]
        let infoContact = groupedUsers[dicForData]
        
        var findNumber  = [String:Any]()
        if dataContectInfo.count > 0 {
            if let index = dataContectInfo.firstIndex(where: {
                let phone = ($0["phone"] as! String).removeWhitespace()
                return phone.suffix(10) == String((infoContact?[0]["number"] as? String ?? "").suffix(10))
            }) {
                findNumber = dataContectInfo[index]
            }
        }
        
        
        
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallOptionPopupVc") as! CallOptionPopupVc
        nextVC.modalPresentationStyle = .overFullScreen
        if findNumber.count > 0 {
            nextVC.number = (findNumber["phone"] as! String).removeWhitespace()
            nextVC.name = findNumber["name"] as? String ?? ""
        }else{
            nextVC.number = String((infoContact?[0]["number"] as? String ?? "").suffix(10))
            nextVC.name = infoContact?[0]["contact_name"] as? String ?? ""
        }
        nextVC.dicCall = infoContact!
        nextVC.IsAddContectInAudioLog = self.IsAddContectInAudioLog
        self.present(nextVC, animated: false,completion: {
            nextVC.view.superview?.isUserInteractionEnabled = true
            nextVC.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func GoDetailSection(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = true
        let dicForData = indexContactsArray[sender.tag]
        let infoContact = groupedUsers[dicForData]
        
        var findNumber  = [String:Any]()
        if dataContectInfo.count > 0 {
            if let index = dataContectInfo.firstIndex(where: {
                let phone = ($0["phone"] as! String).removeWhitespace()
                return phone.suffix(10) == String((infoContact?[0]["number"] as? String ?? "").suffix(10))
            }) {
                findNumber = dataContectInfo[index]
            }
        }
        
        
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallLogDtlVc") as! CallLogDtlVc
        nextVC.dicCall = infoContact!
        nextVC.findNumber = findNumber
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
