//
//  RecordingListVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 26/12/22.
//

import UIKit
import Contacts
import ContactsUI
import KNContacts

class RecordingListVc: UIViewController {

    @IBOutlet weak var recodingEmtyTimeShowVW: UIView!
    @IBOutlet weak var tableView: UITableView!
    var callRecordingData = [[String:Any]]()
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(callRecodingUpdata), name: Notification.Name("callRecodingUpdata"), object: nil)
        ConteactNoSave()
    }
    
    @objc func callRecodingUpdata(){
        callRecordingData =  DBManager().getAllRecording()
        tableView.reloadData()
        print("recording Data ......\(callRecordingData) ")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callRecodingUpdata()
    }
   
}
extension RecordingListVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if callRecordingData.count == 0 {
            tableView.isHidden = true
            recodingEmtyTimeShowVW.isHidden = false
        }else {
            tableView.isHidden = false
            recodingEmtyTimeShowVW.isHidden = true

        }
        return callRecordingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecodingListCell", for: indexPath) as! RecodingListCell
        let dicForData =  callRecordingData[indexPath.row]
        cell.lblRecodingName.text = "Audio \(indexPath.row + 1)"
        
        if (dicForData["data"] as? String ?? "") != "" {
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy h:mm a"
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyyMMdd_hhmmss"
            let dataFind = dateFormatter1.date(from: (dicForData["data"] as! String))
            cell.lblDataAndTime.text =  df.string(from: dataFind!)
        }
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.DeleteRecoding(_:)), for: .touchUpInside)

        
        return cell
    }
    
    @objc func DeleteRecoding(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Call Recoding", message: "Are your sure want to delete auido \(sender.tag + 1) call recoding??" , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self]_ in
            DataBaseinRemoveCallRecoding(tag: sender.tag)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
       
    }
    
    func DataBaseinRemoveCallRecoding(tag: Int){
        let dicForData =  callRecordingData[tag]
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent((dicForData["name"] as? String ?? ""))
        if FileManager.default.fileExists(atPath: fullDestPath.path) {
            do {
                try FileManager.default.removeItem(atPath: fullDestPath.path)
            } catch {
                print("Could not delete file, probably read-only filesystem")
            }
        }
        
        
        DBManager().deleteByRecording(audio_name: dicForData["audio_name"] as? String ?? "")
        callRecodingUpdata()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordingDetailVc") as! RecordingDetailVc
        nextVC.modalPresentationStyle = .overFullScreen
        nextVC.dataContectInfo = self.dataContectInfo
        nextVC.soundDetail = callRecordingData[indexPath.row]
        self.present(nextVC, animated: false,completion: {
            nextVC.view.superview?.isUserInteractionEnabled = true
            nextVC.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func ConteactNoSave()  {
        let keys = [CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey,
                    CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey,
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as! [CNKeyDescriptor]
        
        let requestForContacts = CNContactFetchRequest(keysToFetch: keys)
        self.hideKeybordTappedAround()
        
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
        
        
       
    }
    
    
}
