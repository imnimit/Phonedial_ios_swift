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
//        cell.lblRecodingName.text = "Audio \(indexPath.row + 1)"
        
        
        if let index = dataContectInfo.firstIndex(where: {
            let phone = ($0["phone"] as! String).removeWhitespace()
            return phone.suffix(10) == (dicForData["number"] as? String ?? "")
        }) {
            print(index)
            let indexPathRow = index
            cell.lblRecodingName.text = "\(dataContectInfo[indexPathRow]["name"] as? String ?? "")"
        } else {
            cell.lblRecodingName.text = "\(dicForData["number"] as? String ?? "")"
        }
        
        
        
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
        
        let dicForData =  callRecordingData[sender.tag]
        
        var number = ""
        if let index = dataContectInfo.firstIndex(where: {
            let phone = ($0["phone"] as! String).removeWhitespace()
            return phone.suffix(10) == (dicForData["number"] as? String ?? "")
        }) {
            let indexPathRow = index
            number = "\(dataContectInfo[indexPathRow]["name"] as? String ?? "")"
        } else {
            number = "\(dicForData["number"] as? String ?? "")"
        }
        
        let alert = UIAlertController(title: "Delete Call Recoding", message: "Are your sure want to delete auido \(number) call recoding??" , preferredStyle: .alert)
        
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
        dataContectInfo = DBManager().getAllContact()
        dataContectInfo.sort {
            (($0 as! Dictionary<String, AnyObject>)["name"] as! String) < (($1 as! Dictionary<String, AnyObject>)["name"] as! String)
        }
    }
}
