//
//  VoiceMailLogsVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 27/12/22.
//

import UIKit
import ContactsUI
import KNContacts
import AVFoundation

class VoiceMailLogsVc: UIViewController {
    
    @IBOutlet weak var voiceMailEmtyTimeShowVW: UIView!
    @IBOutlet weak var tableView: UITableView!
    var voiceMailData = [[String:Any]]()
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var loadOnce : [String] = []
    var durationTimeStroe =  [[String:Any]]()
    var isFistContactSave = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFistContactSave = true
//        VoiceMailAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VoiceMailAPI()
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
        
        tableView.reloadData()
    }
    
    
    //MARK: - APi Action
    func VoiceMailAPI() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token(),
                                               "Number":User.sharedInstance.getContactNumber(),
                                                "Device_id":appDelegate.diviceID
                                               ,"request":"voicemaildata"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "1" {
                let Data : [[String: Any]] = (diddata["response"] as! [[String: Any]])
                loadOnce.removeAll()
                voiceMailData.removeAll()
                voiceMailData = Data
                if isFistContactSave == true {
                    ConteactNoSave()
                    isFistContactSave = false
                }else{
                    tableView.reloadData()
                }
            } else {
                self.showToastMessage(message: diddata["message"] as? String)
            }
        })
    }
    
}
extension VoiceMailLogsVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if voiceMailData.count == 0 {
            voiceMailEmtyTimeShowVW.isHidden = false
            tableView.isHidden = true
        }else {
            voiceMailEmtyTimeShowVW.isHidden = true
            tableView.isHidden = false
        }
        return voiceMailData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceMailLogsCell", for: indexPath) as! VoiceMailLogsCell
        let dicForVoiceMail = voiceMailData[indexPath.row]
        cell.lblNumber.text = dicForVoiceMail["cid_number"] as? String ?? ""
        cell.lblFistTwoletter.isHidden = false
        cell.contactimgeOrLetterVW.layer.cornerRadius =  cell.contactimgeOrLetterVW.layer.bounds.height/2
        cell.lblDuration.text  = printSecondsToHoursMinutesSeconds(Int(dicForVoiceMail["message_len"] as? String ?? "") ?? 0)
        
        if dataContectInfo.count > 0 {
            if let index = dataContectInfo.firstIndex(where: {
                let phone = ($0["phone"] as! String).removeWhitespace()
                return phone.suffix(10) == String((dicForVoiceMail["cid_name"] as? String ?? "").suffix(10))
            }) {
                let findNumber = dataContectInfo[index]
                cell.lblName.text = (findNumber["name"] as? String ?? "")

                if findNumber["imageDataAvailable"] as? Bool == true {
                    cell.lblFistTwoletter.isHidden = true
                    cell.imgContact.image = UIImage(data: (findNumber["imageData"] as! Data))!
                }
                cell.lblFistTwoletter.text = findNameFistORMiddleNameFistLetter(name: (findNumber["name"] as? String ?? ""))
            }else{
                cell.lblName.text = "No Name"
                cell.imgContact.image =  #imageLiteral(resourceName: "call_bg_image")
                cell.lblFistTwoletter.text = findNameFistORMiddleNameFistLetter(name: "No Name")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoiceMailDetailVc") as! VoiceMailDetailVc
        nextVC.voiceMailDetail = voiceMailData[indexPath.row]
        nextVC.dataContectInfo = self.dataContectInfo
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
   
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func printSecondsToHoursMinutesSeconds(_ seconds: Int) -> String {
      let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
      return "\(h < 10 ? "0\(h)" : "\(h)"):\(m < 10 ? "0\(m)" : "\(m)"):\(s < 10 ? "0\(s)" : "\(s)")"
    }
    
}
