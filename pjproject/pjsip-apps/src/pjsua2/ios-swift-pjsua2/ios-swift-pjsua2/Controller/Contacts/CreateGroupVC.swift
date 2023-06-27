//
//  CreateGroupVC.swift
//  ios-swift-pjsua2
//
//  Created by TNCG - Mini2 on 14/06/23.
//

import UIKit

class CreateGroupVC: UIViewController {

   
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var CameraVW: UIView!
    
    var arrOfCreateGroupDic = [[String: Any]]()
    
    var userChatId = ""
    var arrChatID = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        CameraVW.layer.cornerRadius = CameraVW.layer.bounds.height/2
        
        let rightButton: UIBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.CreateGroup(_:)))
        navigationItem.rightBarButtonItem = rightButton
        self.hideKeybordTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
   
   
    @objc func CreateGroup(_ sender: UIBarButtonItem) {
        if txtGroupName.text == "" {
            showToastMessage(message: "Please enter the group name")
            self.view.endEditing(true)
            
        } else {
            sender.isEnabled = false
            for dictionary in arrOfCreateGroupDic {
                if let phoneNumber = dictionary["phone"] as? String {
                    print(dictionary["phone"] as? String ?? "")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        self.SocketTimeConnected(number: phoneNumber.replace(string: "+", replacement: ""))
                    })
                    
                }
            }
            
            
        }
        
        
        //        let phoneNumbers = arrOfCreateGroupDic.compactMap { dictionary -> String? in
        //            if let phoneNumber = dictionary["phone"] as? String {
        //                SocketTimeConnected(number: phoneNumber)
        //            }
        //            return ""
        //        }
    }

    
    //MARK: Socket init
    func SocketInit() {
//        appDelegate.chatService.establishConnection()
       
        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID]
        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.Joint, requestData)
    }
    
    //MARK: Api Call
    
    func SocketTimeConnected(number : String) {
        let strReq = API_URL.SoketAPIURL + APISoketName.GetUser
        let requestData : [String : String] = ["mobile_num":number] //  ["mobile_num":"919033269045"] //
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self] (result) in
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                let Response: [String: Any]  = (diddata["Response"] as! [String: Any])
                let Data = Response["data"] as! [String:Any]
                userChatId = "\(Data["id"] as? Int ?? 0)"
                arrChatID.append(userChatId)
                print(arrChatID)
                if arrChatID.count == arrOfCreateGroupDic.count {
                    SocketTimeCreateGruop()
                }
                
            }
        })
    }
    
  
    
    func SocketTimeCreateGruop() {
        let strReq = API_URL.SoketAPIURL + APISoketName.CreateGroup
        
        let requestData : [String : String] = ["user_id": appDelegate.ChatTimeUserUserID + "," + "\(arrChatID.joined(separator:","))" ,"name":txtGroupName.text ?? "","type":"1"]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self](result) in
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                let Response: [String: Any]  = (diddata["Response"] as! [String: Any])
                let Data = Response["data"] as! [String:Any]
                appDelegate.ChatGroupID = "\(Data["id"] as? Int ?? 0)"
                SocketInit()
                let nextVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatVc") as! ChatVc
                let allData = RealmDatabaseeHelper.shared.getAllUserModall()
                nextVC.Name = txtGroupName.text ?? ""
                nextVC.fistTimeUserEntry = true
                nextVC.isgroupchat = true
                navigationController?.pushViewController(nextVC, animated: false)
            } else {
                
            }
        })
    }
    
    
}

extension CreateGroupVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfCreateGroupDic.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateGroupCell", for: indexPath) as! CreateGroupCell
       // let dic = arrOfDicDemo[indexPath.row]
        //cell.contactName.text = dic[""] as? String
        let dic = arrOfCreateGroupDic[indexPath.row]
        cell.contactName.text = dic["name"] as? String ?? ""
        let text = dic["name"] as? String ?? ""
        cell.lblContactLetter.text = findNameFistORMiddleNameFistLetter(name: text)
        cell.contactImage.image = UIImage(named: "")
        

        cell.contactSubView.layer.cornerRadius = cell.contactSubView.layer.bounds.height/2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let CollectionWidth = collectionView.layer.bounds.width
        let CollectionHeight = collectionView.layer.bounds.height
        return CGSize(width: CollectionWidth/3-6, height: 101)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
    
    
}
