//
//  SpeedDialVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 31/12/22.
//

import UIKit
import Contacts
import ContactsUI
import KNContacts
import MessageUI

class SpeedDialVc: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var store = CNContactStore()
    var contactBook = KNContactBook(id: "allContacts")
    var dataContectInfo = [[String : Any]]()
    var edit =  UIBarButtonItem()
    var SpeedDialList = [["No": "1", "number": ""],["No": "2", "number": ""],["No": "3", "number": ""],["No": "4", "number": ""],["No": "5", "number": ""],["No": "6", "number": ""],["No": "7", "number": ""],["No": "8", "number": ""],["No": "9", "number": ""]]
    var  dicForCotract = [[String:Any]]()
    var selectedList = -1
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constant.ViewControllerTitle.SpeedDial
        edit = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(playTapped))
        navigationItem.rightBarButtonItems = [edit]
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddSpeedDila), name: Notification.Name("AddSpeedDila"), object: nil)
        ConteactNoSave()
        
        if UserDefaults.standard.object(forKey: "SpeedDialList") == nil {
            UserDefaults.standard.setValue(SpeedDialList, forKey: "SpeedDialList")
            UserDefaults.standard.synchronize()
        }
        
        dicForCotract =  UserDefaults.standard.object(forKey: "SpeedDialList") as! [[String:Any]]
        
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
            print(i.info)
            var data = [String: Any]()
            if i.fullName() != "" {
                if i.info.imageDataAvailable as? Bool == true {
                    data = ["name":i.fullName(),"phone":[i.getFirstPhoneNumber().removeWhitespace()],"imageDataAvailable": i.info.imageDataAvailable as? Bool ?? false ,"imageData": i.info.imageData!,"Email":i.getFirstEmailAddress()]
                }else {
                    data = ["name":i.fullName(),"phone":[i.getFirstPhoneNumber().removeWhitespace()],"imageDataAvailable": i.info.imageDataAvailable as? Bool ?? false ,"imageData":i.info.imageData ?? Data(),"Email":i.getFirstEmailAddress()]
                }
                
                if dataContectInfo.firstIndex(where: {
                  let num =   $0["phone"] as! [String]
                    for j in num {
                        if j == i.getFirstPhoneNumber().removeWhitespace() {
                            return  true
                        }
                    }
                    return  false
                }) != nil {
                    
                } else {
                    var phoneNumber = [String]()
                    if i.info.phoneNumbers.count >= 2 {
                        for j in i.info.phoneNumbers {
                            phoneNumber.append(j.value.stringValue)
                        }
                    }
                    if((phoneNumber.count) != 0) {
                        data["phone"] = phoneNumber
                        dataContectInfo.append(data)

                    }else{
                        dataContectInfo.append(data)

                    }
                }
            }
        }
        
        dataContectInfo.sort {
            (($0 as! Dictionary<String, AnyObject>)["name"] as! String) < (($1 as! Dictionary<String, AnyObject>)["name"] as! String)
        }
        
        
        print(dataContectInfo)
        print(dataContectInfo)
    }
    
    
    @objc func AddSpeedDila(_ notification: NSNotification){
        self.dismiss(animated: false,completion: { [self] in
            sleep(1)
            if let number = notification.userInfo?["number"] as? String {
                let num1 = number.replace(string: ")", replacement: "")
                let num2 = num1.replace(string: "(", replacement: "")
                let num3 = num2.replace(string: "-", replacement: "")
                var temp  = dicForCotract
                temp[selectedList]["number"] = num3
                UserDefaults.standard.removeObject(forKey: "SpeedDialList")
                UserDefaults.standard.setValue(temp, forKey: "SpeedDialList")
                dicForCotract =  UserDefaults.standard.object(forKey: "SpeedDialList") as! [[String:Any]]
                collectionView.reloadData()
            }
        })
    }
    
   

    @objc func playTapped(){
        isEdit = !isEdit
        if isEdit == true {
            edit.title = "Done"
        }else{
            edit.title = "Edit"
        }
        collectionView.reloadData()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
  
}
extension SpeedDialVc:  UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "speedDialListCell", for: indexPath as IndexPath) as! speedDialListCell
        cell.lblIndex.text = "\(indexPath.row + 1)"
        cell.btnSelectionNumber.tag = indexPath.row
        cell.deletContactList.tag = indexPath.row
        cell.btnSelectionNumber.addTarget(self, action: #selector(self.contactList), for: .touchUpInside)
        cell.deletContactList.addTarget(self, action: #selector(self.removeToSpeedDial), for: .touchUpInside)
        let dic =  dicForCotract[indexPath.row]
        cell.detailVW.isHidden = true
        cell.deletContactList.isHidden = !isEdit
        cell.btnSelectionNumber.isHidden  = isEdit
        cell.imgContact.layer.cornerRadius =  cell.imgContact.layer.bounds.height/2
        print(dic["number"] as? String ?? "")
        if dataContectInfo.count > 0 && (dic["number"] as? String ?? "") != "" {
            if let index = dataContectInfo.firstIndex(where: {
                let num = $0["phone"] as! [String]
                print(num)
                for i in num {
                    print(num)
                    print(dic["number"] as? String ?? "")
                    if i.suffix(10) == String((dic["number"] as? String ?? "").suffix(10)){
                        return true
                    }
                }
                
                return false
            })
            {
                cell.detailVW.isHidden = false
                let findNumber = dataContectInfo[index]
                
                cell.lblName.text = (findNumber["name"] as? String ?? "")
                cell.lblContactNumber.text = (dic["number"] as? String ?? "")
               // cell.imgContact.isHidden = true
                cell.lblFistTwoLetter.isHidden = true
                if findNumber["imageDataAvailable"] as? Bool == true {
                    cell.lblFistTwoLetter.isHidden = true
                    cell.imgContact.isHidden = false
                    cell.imgContact.image = UIImage(data: (findNumber["imageData"] as! Data))!
                }else {
                   // cell.imgContact.isHidden = true
                    cell.lblFistTwoLetter.isHidden = false
                    cell.lblFistTwoLetter.text  = findNameFistORMiddleNameFistLetter(name: (findNumber["name"] as? String ?? ""))
                    cell.imgContact.image = #imageLiteral(resourceName: "call_bg_image.png")
                }
            }
        }else{
            cell.deletContactList.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.size
        return CGSize(width: (size.width - 4 * 8)/3, height: (collectionView.layer.bounds.height/3) - 5)
    }
    
    @objc func contactList(sender : UIButton){
        print(sender.tag)
        selectedList = sender.tag
        if (dicForCotract[sender.tag]["number"] as? String ?? "") != "" {
            return
        }
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactsVc") as! ContactsVc
        nextVC.navigationBarnotShow = true
        nextVC.isInvitedBtnShow = false
        nextVC.isFavoriteBtnShow = true
        nextVC.isContectNumberShow = false
        nextVC.isShowTopNavigationBar = true
        nextVC.iscallAddSpeedDial = true
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true)
    }
    
    @objc func removeToSpeedDial(sender : UIButton){
        print("Remove Detail = \(sender.tag)")
        var temp  = dicForCotract
        temp[sender.tag]["number"] = ""
        UserDefaults.standard.removeObject(forKey: "SpeedDialList")
        UserDefaults.standard.setValue(temp, forKey: "SpeedDialList")
        dicForCotract =  UserDefaults.standard.object(forKey: "SpeedDialList") as! [[String:Any]]
        collectionView.reloadData()
    }
}

