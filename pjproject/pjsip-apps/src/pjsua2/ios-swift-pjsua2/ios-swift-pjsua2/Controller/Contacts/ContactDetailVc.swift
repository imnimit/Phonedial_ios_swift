//
//  ContactDetailVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 21/12/22.
//

import UIKit
import Contacts
import ContactsUI
import KNContacts
import MessageUI

class ContactDetailVc: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContactNumber: UILabel!
    @IBOutlet weak var lblNameInitial: UILabel!
    @IBOutlet weak var imgContact: UIImageView!
    @IBOutlet weak var letterImgeVW: UIView!
    @IBOutlet weak var imgFavorite: UIImageView!
    @IBOutlet weak var lblBlock: UILabel!
    @IBOutlet weak var imgBlock: UIImageView!
    var mulipleContact = [String]()
    
    
    var infoContactNumber = [[String:Any]]()
    var iscallAdd = false
    var iscallTransfer = false
    var iscallAddSpeedDial = false
    var contactDetail = [String:Any]()
    var Favourite = [[String : Any]]()
    var blockArray = [String]()
    var store = CNContactStore()
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var number1 = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        initCall()
        
        ConteactNoSave()
    }
    
    func initCall(){
        letterImgeVW.layer.cornerRadius = letterImgeVW.layer.bounds.height/2
        
        if contactDetail["imageData64"] as! String != "" {
            let dataDecoded:NSData = NSData(base64Encoded: contactDetail["imageData64"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            imgContact.image =  decodedimage
            lblNameInitial.isHidden = true
        }else {
            imgContact.isHidden = true
            lblNameInitial.text = findNameFistORMiddleNameFistLetter(name: contactDetail["name"] as? String ?? "")
        }
        lblName.text = contactDetail["name"] as? String ?? ""
        let number = findLast(number: (contactDetail["phone"] as? String ?? ""))
        let revnumber = String(number.reversed())
        lblContactNumber.text = revnumber.toPhoneNumber()
        
//        if lblContactNumber.text != "" {
//            let dic = ["heder":"Mobile","Info":lblContactNumber.text,"img": #imageLiteral(resourceName: "ic_call_dtl.png")] as! [String: Any]
//            infoContactNumber.append(dic)
//        }
//
//
//        if (contactDetail["Email"] as? String ?? "") != "" {
//            let dic = ["heder":"Email","Info":(contactDetail["Email"] as? String ?? ""),"img": #imageLiteral(resourceName: "ic_email_dtl") ]as! [String: Any]
//            infoContactNumber.append(dic)
//        }
//
//        tableView.reloadData()
        Favourite = DBManager().getAllFavorite()

        
        if Favourite.contains(where: {$0["number"] as? String == contactDetail["phone"] as? String ?? ""}) {
            imgFavorite.image = #imageLiteral(resourceName: "ic_contact_fav_check.png")
        }else{
            imgFavorite.image = #imageLiteral(resourceName: "ic_contact_fav_uncheck.png")
        }
        
        if UserDefaults.standard.object(forKey: "BlockNumberKey") != nil {
            blockArray = (UserDefaults.standard.array(forKey: "BlockNumberKey") as? [String])!
            print(blockArray)
        }
        
        if blockArray.contains(contactDetail["phone"] as? String ?? "") {
            lblBlock.text = "unblock"
           // imgBlock.image = #imageLiteral(resourceName: "ic_block_user.png")
        }
        else {
            lblBlock.text = "Block"
            //imgBlock.image = #imageLiteral(resourceName: "ic_block_user.png")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.post(name: Notification.Name("callListUpdata"), object: self, userInfo: nil)
    }
    
    func updateContactNumber() {
//           let index = dataContectInfo.firstIndex(where: {$0["name"] as! String == contactDetail["name"] as? String ?? ""})
//
//           if index == -1 {
//               return
//           }
           
           let identifier = dataContectInfo[0]["identifier"] as? String ?? ""
              let store = CNContactStore()
              do {
                 let contactToEdit = try store.unifiedContact(withIdentifier: identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
                  let mutableContact = contactToEdit.mutableCopy() as! CNMutableContact
                  let editViewController = CNContactViewController(for: mutableContact)
                  editViewController.delegate = self
                   UINavigationBar.appearance().tintColor = UIColor.white
                   UINavigationBar.appearance().backgroundColor = #colorLiteral(red: 0.1033737585, green: 0.6896910071, blue: 0.8629385829, alpha: 1)
                   UINavigationBar.appearance().titleTextAttributes =  [.foregroundColor: UIColor.white]
                  let navigationController = UINavigationController(rootViewController: editViewController)
                  navigationController.modalPresentationStyle = .overFullScreen
                  self.present(navigationController, animated: true, completion: nil)
              } catch {
                  print(error)
              }
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
        
        for  i  in contactBook.contacts {
            print(i.fullName())
            print(i.getFirstEmailAddress())
            
            print(i.getFirstPhoneNumber())
            print(i.info.phoneNumbers)
            var data = [String: Any]()
            if i.fullName() == (lblName.text ?? "").components(separatedBy:.whitespacesAndNewlines).filter({ $0.count > 0 }).joined(separator: " ") || i.getFirstPhoneNumber().digitsOnly == number1.digitsOnly{
                if i.info.imageDataAvailable as? Bool == true {
                    data = ["name":i.fullName(),"phone":i.getFirstPhoneNumber().removeWhitespace(),"imageDataAvailable": i.info.imageDataAvailable as? Bool ?? false ,"imageData": i.info.imageData!,"Email":i.getFirstEmailAddress(),"identifier":i.info.identifier]
                }else {
                    data = ["name":i.fullName(),"phone":i.getFirstPhoneNumber().removeWhitespace(),"imageDataAvailable": i.info.imageDataAvailable as? Bool ?? false ,"imageData":i.info.imageData ?? Data(),"Email":i.getFirstEmailAddress(),"identifier":i.info.identifier]
                }
                
                if dataContectInfo.firstIndex(where: {$0["phone"] as! String == i.getFirstPhoneNumber().removeWhitespace() }) != nil {
                } else {
                    if i.info.phoneNumbers.count >= 2 {
                        for j in i.info.phoneNumbers {
                            mulipleContact.append(j.value.stringValue)
                        }
                    }
                    dataContectInfo.append(data)
                }
            }
        }
        
        
        for i in dataContectInfo {
            if i["phone"] as? String != "" && (i["phone"] as? String ?? "") != "undefined" {
                if mulipleContact.count > 0 {
                    for i in mulipleContact {
                        let dic = ["heder":"Mobile","Info":i,"img": #imageLiteral(resourceName: "ic_contact_dtl_call")] as! [String: Any]
                        infoContactNumber.append(dic)
                    }
                }else{
                    let dic = ["heder":"Mobile","Info":i["phone"] as? String,"img": #imageLiteral(resourceName: "ic_contact_dtl_call")] as! [String: Any]
                    infoContactNumber.append(dic)
                }
               
            }
            if i["Email"] as? String != "" {
                let dic = ["heder":"Email","Info":i["Email"] as? String,"img": #imageLiteral(resourceName: "ic_email_dtl") ] as! [String: Any]
                infoContactNumber.append(dic)
            }
        }
        
        tableView.reloadData()
    }
    

    
    //MARK: - btn Click
    @IBAction func btnClickAditContact(_ sender: UIButton) {
        updateContactNumber()
    }
    
    @IBAction func btnClickBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnClickDeleteContact(_ sender: Any) {
        
        var dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { [self] (action) -> Void in
            print("Ok button tapped")
            let store = CNContactStore()
            
            let predicate = CNContact.predicateForContacts(matchingName: contactDetail["name"] as? String ?? "")
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
    
    @IBAction func btnClickFavorite(_ sender: UIButton) {
        
        if Favourite.contains(where: {$0["number"] as? String == contactDetail["phone"] as? String ?? ""}) {
            DBManager().deleteByFavorite(number: contactDetail["phone"] as? String ?? "")
            Favourite = DBManager().getAllFavorite()
            imgFavorite.image = #imageLiteral(resourceName: "ic_contact_fav_uncheck.png")
        }else{
            let dicNumber = ["number":contactDetail["phone"] as? String ?? "","isfavourite":"1"] as! [String : Any]
            DBManager().insertFavorite(dicFavorite: dicNumber)
            Favourite = DBManager().getAllFavorite()
            imgFavorite.image = #imageLiteral(resourceName: "ic_contact_fav_check.png")
        }
    }
    
    @IBAction func btnCallAddBlock(_ sender: UIButton) {
   
        var PopupTextAlert = ""
        var PopupTextMessage = ""
        
        if lblBlock.text == "Block" {
            PopupTextAlert = "Block - \(contactDetail["phone"] as? String ?? "")"
            PopupTextMessage = "You will no longer receive calls from this number"
        }else{
            PopupTextAlert = "UnBlock - \(contactDetail["phone"] as? String ?? "")"
        }
        
        let dialogMessage = UIAlertController(title: PopupTextAlert, message: PopupTextMessage, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: ((lblBlock.text == "Block") ? "Block": "UnBlock") , style: .default, handler: { [self] (action) -> Void in
            var blockNumber = [String]()
            number1 = (contactDetail["phone"] as? String ?? "").digitsOnly
            if UserDefaults.standard.object(forKey: "BlockNumberKey") != nil {
                blockNumber = UserDefaults.standard.array(forKey: "BlockNumberKey") as! [String]
//                let dictValueLogin = UserDefaults.standard.value(forKey: "loginCheckKey") as? [String: Any]

                if lblBlock.text == "Block" {
                    blockNumber.append(number1)
                    //imgBlock.image = #imageLiteral(resourceName: "ic_block_user.png")
                    lblBlock.text = "unblock"
                    blockContact()
//                    CPPWrapper.bolockContact(number1)
                } else {
                   // imgBlock.image = #imageLiteral(resourceName: "ic_block_user.png")
                    lblBlock.text = "Block"
                    blockNumber = blockNumber.filter(){$0 != number1}
//                    CPPWrapper.unBolockContact(number1)
                }
            }
            else{
                blockNumber.append(number1)
            }
            UserDefaults.standard.set(blockNumber, forKey: "BlockNumberKey")
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }

        //Add OK and Cancel button to an Alert object
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)

        // Present alert message to user
        self.present(dialogMessage, animated: false, completion: nil)
    }
    
    @IBAction func btnClickMessage(_ sender: UIButton) {
        // Message
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "test"
            controller.recipients = ["\(lblContactNumber.text ?? "")"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnDialOut(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: { [self] in
            if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 2
                let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                let dialPed = storyboard1.instantiateViewController(withIdentifier: "dialpadVc") as! dialpadVc
                let number = (lblContactNumber.text ?? "").replace(string: "-", replacement: "")
                dialPed.contectNumber = "+" + number
                dialPed.contectName = lblName.text ?? ""
                tabBarController.viewControllers![2]  = dialPed
            }
        })
    }
    
    
    
    
    //MARK: - APi Action
    func blockContact() {
        let requestData : [String : String] = ["Token":User.sharedInstance.getUser_token(),
                                               "Device_id":appDelegate.diviceID
                                               ,"request":"add_blockcode"
                                               ,"code":number1]
        print(requestData)
        APIsMain.apiCalling.callData(credentials: requestData,requstTag : "", withCompletionHandler: { [self] (result) in
            print(result)
            
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "1" {
                let Data : [[String: Any]] = (diddata["response"] as! [[String: Any]])
               // self.dismiss(animated: false)
            } else {
                self.showToastMessage(message: diddata["message"] as? String)
            }
        })
    }

    
}
extension ContactDetailVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoContactNumber.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactDetailListCell", for: indexPath) as! ContactDetailListCell
        let dicData = infoContactNumber[indexPath.row]
        cell.lblHeder.text = dicData["heder"] as? String ?? ""
        cell.lblInfo.text = dicData["Info"] as? String ?? ""
        cell.imgProperty.image = dicData["img"] as? UIImage
        cell.contactListMainVW.layer.cornerRadius = 10
        cell.btnClickAction.tag = indexPath.row
        cell.btnClickAction.setTitle(String(format: "%@ %@" , String(indexPath.section) , String(indexPath.row)), for:.disabled)
        cell.btnClickAction.addTarget(self, action: #selector(self.callInvitePopup(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc func callInvitePopup(_ sender: UIButton){	
        let strIndexPath = sender.title(for: .disabled)
        let arrForIndexPath = strIndexPath?.components(separatedBy: " ")
        let sectionValue:Int? = Int(arrForIndexPath![0] )
        let rowValue:Int? = Int(arrForIndexPath![1])
        
        let dicData = infoContactNumber[rowValue!]
        
        
        if iscallAddSpeedDial == true {
            let alert = UIAlertController(title: "Alert", message: "Are You Sure Want To Add This Number In Speed Dial List ?" , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self]_ in
                self.dismiss(animated: false, completion: {
                    let calldata = ["number":dicData["Info"] as? String ?? "","name": self.lblName.text ?? ""]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddSpeedDila"), object: nil, userInfo: calldata)
                })
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "InviteContactPopup") as! InviteContactPopup
            nextVC.delegate = self
            nextVC.callData = dicData
            nextVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            nextVC.nameContact =  lblName.text ?? ""
            self.present(nextVC, animated: false,completion: {
                nextVC.view.superview?.isUserInteractionEnabled = true
                nextVC.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: false, completion: nil)
    }
                                    
}

extension ContactDetailVc: CNContactViewControllerDelegate{
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension ContactDetailVc:goToContactDetailScreen {
    func callApplyAction(contactNumber: String,contactName: String) {
         if iscallTransfer == true {
            self.dismiss(animated: false, completion: {
                let calldata = ["number":contactNumber,"name":contactName]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transferCall"), object: nil, userInfo: calldata)
            })
        }
       else  if iscallAdd == true {
            self.dismiss(animated: false, completion: {
                let calldata = ["number":contactNumber,"name":contactName]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callAdd"), object: nil, userInfo: calldata)
            })
        }else {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                    tabBarController.selectedIndex = 2
                    let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                    let dialPed = storyboard1.instantiateViewController(withIdentifier: "dialpadVc") as! dialpadVc
                    dialPed.contectNumber = contactNumber
                    dialPed.contectName = contactName
                    tabBarController.viewControllers![2]  = dialPed
                }
            })
        }
       
    }
}
extension ContactDetailVc: MFMessageComposeViewControllerDelegate {
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
