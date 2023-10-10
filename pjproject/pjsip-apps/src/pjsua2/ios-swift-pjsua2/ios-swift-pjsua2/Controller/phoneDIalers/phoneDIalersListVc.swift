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
    var IsVideoLog = false
    var groupedUsersVideo =  [Int : [[String : Any]]]()
    var VidoecallLogData = [[String:Any]]()
    var indexVideoContactsArray = [Int]()

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
        groupedUsersVideo.removeAll()
        
        let allcallLogData = DBManager().getAllCallLog()
        //print(allcallLogData)
        callLogData  =  allcallLogData.filter { $0["type_log"] as? String == "Call" }
       // print(callLogData)
        VidoecallLogData  =  allcallLogData.filter { $0["type_log"] as? String == "VidoeCall" }
      //  print(VidoecallLogData)
        
        // Vidoe  Call Log Group
        countNumber = 0
        var dv = [[String:Any]]()
        numberMange = ""
        for i in VidoecallLogData {
            if numberMange != "" &&  numberMange != (i["number"]  as! String).suffix(10) {
                let gorup =  Dictionary(grouping: dv, by: numberManage)
                groupedUsersVideo =  groupedUsersVideo.merging(gorup) { (current, _) in current }
                countNumber = countNumber + 1
                dv = [[String:Any]]()
                numberMange =  String((i["number"]  as! String).suffix(10))
                dv.append(i)
            }else{
                numberMange =  String((i["number"]  as! String).suffix(10))
                dv.append(i)
            }
        }
        
        let gorupV =  Dictionary(grouping: dv, by: numberManage)
        groupedUsersVideo =  groupedUsersVideo.merging(gorupV) { (current, _) in current }
        
        indexVideoContactsArray = [Int](groupedUsersVideo.keys)
        indexVideoContactsArray = indexVideoContactsArray.sorted()
        
        // Audio Call Log Group
        countNumber = 0
        var d = [[String:Any]]()
        numberMange = ""
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

//        print(groupedUsers)
        self.tableView.reloadData()
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
        dataContectInfo.removeAll()
        dataContectInfo = DBManager().getAllContact()
        dataContectInfo.sort {
            (($0 as! Dictionary<String, AnyObject>)["name"] as! String) < (($1 as! Dictionary<String, AnyObject>)["name"] as! String)
        }
        CallLogReArrage()
        
//        tableView.reloadData()
    }
}

extension phoneDIalersListVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if IsVideoLog == true {
            if groupedUsersVideo.count == 0 {
                callEmtyTimeShowVW.isHidden = false
                tableView.isHidden = true
            }else{
                callEmtyTimeShowVW.isHidden = true
                tableView.isHidden = false
            }
            return groupedUsersVideo.count
        }else{
            if groupedUsers.count == 0 {
                callEmtyTimeShowVW.isHidden = false
                tableView.isHidden = true
            }else{
                callEmtyTimeShowVW.isHidden = true
                tableView.isHidden = false
            }
            return groupedUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "phoneDIalersListCell", for: indexPath) as? phoneDIalersListCell else { return UITableViewCell() }
        let dicForData = (IsVideoLog == true) ? indexVideoContactsArray[indexPath.row] : indexContactsArray[indexPath.row]
        let infoContact = (IsVideoLog == true) ? groupedUsersVideo[dicForData] :groupedUsers[dicForData]
        
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
        cell.imgContacts.image =  #imageLiteral(resourceName: "call_bg_image")
        cell.lblName.text = "Unknown"
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

                if findNumber["imageData64"] as! String != "" {
                    cell.lblNameLetter.isHidden = true
                    let dataDecoded:NSData = NSData(base64Encoded: findNumber["imageData64"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    cell.imgContacts.image = decodedimage
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
        
        cell.boderVW.isHidden = false
        if groupedUsers.count == indexPath.row + 1 {
            cell.boderVW.isHidden = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dicForData = (IsVideoLog == true) ? indexVideoContactsArray[indexPath.row] : indexContactsArray[indexPath.row]
        let infoContact = (IsVideoLog == true) ? groupedUsersVideo[dicForData] :groupedUsers[dicForData]
       
        
        var findNumber  = [String:Any]()
        if dataContectInfo.count > 0 {
            if let index = dataContectInfo.firstIndex(where: {
                let phone = ($0["phone"] as! String).removeWhitespace()
                return phone == String((infoContact?[0]["number"] as? String ?? ""))
            }) {
                findNumber = dataContectInfo[index]
            }
        }
        
        
        
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallOptionPopupVc") as! CallOptionPopupVc
        nextVC.modalPresentationStyle = .overFullScreen
        if findNumber.count > 0 {
            nextVC.number = (findNumber["phone"] as! String).removeWhitespace()
            nextVC.name = findNumber["name"] as? String ?? ""
            nextVC.checkVideoOrAudio = "Video"
        }else{
            nextVC.number = String((infoContact?[0]["number"] as? String ?? ""))
            nextVC.name = infoContact?[0]["contact_name"] as? String ?? ""
            nextVC.checkVideoOrAudio = "Audio"
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
        let dicForData = (IsVideoLog == true) ? indexVideoContactsArray[sender.tag] : indexContactsArray[sender.tag]
        let infoContact = (IsVideoLog == true) ? groupedUsersVideo[dicForData] :groupedUsers[dicForData]
       
        
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
