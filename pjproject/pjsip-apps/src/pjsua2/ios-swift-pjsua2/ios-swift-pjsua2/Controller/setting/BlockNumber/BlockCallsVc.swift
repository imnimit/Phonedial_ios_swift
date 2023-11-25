//
//  BlockCallsVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 20/12/22.
//

import UIKit
import Contacts
import ContactsUI
import KNContacts
import MessageUI

class BlockCallsVc: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emtyTimeShowVW: UIView!
    
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var blockContactNumber = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constant.ViewControllerTitle.BlockCall
        ConteactNoSave()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
      
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut) {
            if let tabBarFrame = self.tabBarController?.tabBar.frame {
                self.tabBarController?.tabBar.frame.origin.y = self.navigationController!.view.frame.maxY + tabBarFrame.height
            }
            self.navigationController!.view.layoutIfNeeded()
        } completion: { _ in
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
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
                    data = ["name":i.fullName(),"phone":i.getFirstPhoneNumber().removeWhitespace(),"imageDataAvailable": i.info.imageDataAvailable as? Bool ?? false ,"imageData": i.info.imageData!,"Email":i.getFirstEmailAddress()]
                }else {
                    data = ["name":i.fullName(),"phone":i.getFirstPhoneNumber().removeWhitespace(),"imageDataAvailable": i.info.imageDataAvailable as? Bool ?? false ,"imageData":i.info.imageData ?? Data(),"Email":i.getFirstEmailAddress()]
                }
                
                if dataContectInfo.firstIndex(where: {$0["phone"] as! String == i.getFirstPhoneNumber().removeWhitespace() }) != nil {
                    
                } else {
                    dataContectInfo.append(data)
                }
            }
        }
        
        dataContectInfo.sort {
            (($0 as! Dictionary<String, AnyObject>)["name"] as! String) < (($1 as! Dictionary<String, AnyObject>)["name"] as! String)
        }
        
        getAllBlockContact()
    
    }
        
    //MARK: - APi Action
    func getAllBlockContact() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"Device_id":appDelegate.diviceID
                                               ,"request":"getblockcode"]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "1" {
                guard let Data = (diddata["response"] as? [[String: Any]]) else {
                    return
                }
                blockContactNumber = Data
                
                var blockarray = [String]()
                for i in blockContactNumber {
                    blockarray.append((i["blocked_patterns"] as? String ?? ""))
                }
                UserDefaults.standard.set(blockarray, forKey: "BlockNumberKey")
                tableView.reloadData()
                print(Data)
            } else {
//                self.showToastMessage(message: diddata["message"] as? String)
            }
        })
    }
    
    
    func BlockCallUnBlock(Number:String) {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token()
                                               ,"Device_id":appDelegate.diviceID
                                               ,"request":"delete_blockcode"
                                               ,"code":Number]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as? String ?? "" == "1" {
                getAllBlockContact()
                tableView.reloadData()
            } else {
                self.showToastMessage(message: diddata["message"] as? String)
            }
        })
    }
}
extension BlockCallsVc: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if blockContactNumber.count == 0 {
            emtyTimeShowVW.isHidden = false
            tableView.isHidden = true
        }else {
            emtyTimeShowVW.isHidden = true
            tableView.isHidden = false
        }
        return blockContactNumber.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCallsListCell", for: indexPath) as! BlockCallsListCell
        let dicForBlockNumber  = blockContactNumber[indexPath.row]
        cell.lblNumber.text = dicForBlockNumber["blocked_patterns"] as? String ?? ""
        
        cell.imgOrLetterVw.layer.cornerRadius = cell.imgOrLetterVw.layer.bounds.height/2
        
        if dataContectInfo.count > 0 {
            if let index = dataContectInfo.firstIndex(where: {
                let phone = ($0["phone"] as! String).removeWhitespace()
                return phone.suffix(10) == String((dicForBlockNumber["blocked_patterns"] as? String ?? "").suffix(10))
            }) {
                let findNumber = dataContectInfo[index]
                cell.lblName.text = (findNumber["name"] as? String ?? "")

                if findNumber["imageDataAvailable"] as? Bool == true {
                    cell.lblFistTwoLetter.isHidden = true
                    cell.imgContact.image = UIImage(data: (findNumber["imageData"] as! Data))!
                }
                cell.lblFistTwoLetter.text = findNameFistORMiddleNameFistLetter(name: (findNumber["name"] as? String ?? ""))
            }else{
                cell.lblName.text = "No Name"
                cell.imgContact.image =  #imageLiteral(resourceName: "call_bg_image")
                cell.lblFistTwoLetter.text = findNameFistORMiddleNameFistLetter(name: "No Name")
            }
        }
        cell.btNumUnBlock.tag = indexPath.row
        cell.btNumUnBlock.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)



        return cell
    }
    
    @objc func connected(sender: UIButton){
        let alert = UIAlertController(title: "Alert", message: "Are your sure want to unblock this number??" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self]_ in
           BlockCallUnBlock(Number: blockContactNumber[sender.tag]["blocked_patterns"] as? String ?? "")
//            blockContactNumber = blockContactNumber.filter(){$0 != blockContactNumber[sender.tag]}
           
            //blockContactNumber = (UserDefaults.standard.array(forKey: "BlockNumberKey") as? [String])!
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
