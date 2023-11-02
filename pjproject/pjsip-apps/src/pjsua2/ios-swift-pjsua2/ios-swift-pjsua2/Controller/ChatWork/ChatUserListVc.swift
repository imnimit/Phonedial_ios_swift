//
//  ChatUserListVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 30/01/23.
//

import UIKit
import ProgressHUD
import RealmSwift

class ChatUserListVc: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var userData = [String:Any]()
    let chatHistory = ChatHistory()
    let chat = ChatService()
    var RoomID = ""
    var FistTimeHistoyLoad = false
    var dataContectInfo = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
        
        let time = getLastSyncTime(LastSyncTimeKey: "last_sync_time")
        if time == "2019/12/13 04:14:16 PM" {
            FistTimeHistoyLoad =  true
        }else {
            FistTimeHistoyLoad = false
        }
        
        SocketEvent()
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            
            let dialogMessage = UIAlertController(title: "Alert", message: "Are you sure you want to delete Chat?", preferredStyle: .alert)
            // Create OK button with action handler
            let index = indexPath!.row
            let ok = UIAlertAction(title: "OK", style: .default, handler: { [self] (action) -> Void in
                let data = RealmDatabaseeHelper.shared.getAllUserModall()[index]
                DeleteUser(roomId: data.roomID,userID: data.receiverIdForChat)
                RealmDatabaseeHelper.shared.deletUserModal(dataUserModal: data)
                tableView.reloadData()
                print("Ok button tapped")
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button tapped")
            }
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
            print("Long press on row, at \(indexPath!.row)")
        }
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.tabBarController?.tabBar.isHidden = false
        if appDelegate.ChatTimeUserUserID == "" {
            SocketTimeLogin()
        }else {
            let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"last_sync_time":getLastSyncTime(LastSyncTimeKey: "last_sync_time")]
            print(requestData)
            chatHistory.mSocketH.emit(ChatConstanct.EventListenerHistroy.HISTORY, requestData)
            SocketEvent()
        }
        dataContectInfo = DBManager().getAllContact()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Socket Init
    func SocketHInit(Time: String) {
        let time = getLastSyncTime(LastSyncTimeKey: "last_sync_time")
        
        chatHistory.mSocketH.on(clientEvent: .connect){ [self] data, ack in
            print("socket connected")
            let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"last_sync_time":Time]
            print(requestData)
            chatHistory.mSocketH.emit(ChatConstanct.EventListenerHistroy.HISTORY, requestData)
        }
    }
    
    func SocketEvent(){
        
        chatHistory.establishConnection()
        chat.establishConnection()
        

        chatHistory.mSocketH.off(ChatConstanct.EventListenerHistroy.HISTORY)
        chatHistory.mSocketH.on(ChatConstanct.EventListenerHistroy.HISTORY) { [self]  data, ack in
            let dicData = data as? [[String:Any]]
            
            if FistTimeHistoyLoad == true && dicData?[0]["status"] as? String != "Fail" {
              //  ProgressHUD.show(interaction: false)
            }
            let time = getLastSyncTime(LastSyncTimeKey: "last_sync_time")
            
            var CountHistory = 0
            var SecondDataStore = 0

            print(data)
            if let message = data as? [[String:Any]] {
                print(message)
                for i in message {
                    guard let historyArrry = i["data"] as? [[String:Any]] else {
                        return
                    }
                    CountHistory = 0
                    for i in  historyArrry {
                        print(i)
                        if i["last_chat_msg_type"] as? String ?? "" != "" {
                            if (i["history"] as! [[String:Any]]).count > 0 {
                                for historyMessage in i["history"] as! [[String:Any]] {
                                    if RealmDatabaseeHelper.shared.DateModelDataIsExistorNot(ChatID: "\(historyMessage["chat_id"] as? Int ?? 0)") == true {
                                         CountHistory  = CountHistory  + 1
                                        if (i["type"] as? String ?? "") == "group" {
                                            let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(historyMessage["chat_id"] as? Int ?? 0)" ,userID: appDelegate.ChatTimeUserUserID,dateTime:historyMessage["chat_dateTime"] as! String, msgType: historyMessage["message_type"] as! String , message: historyMessage["message"] as! String , isSentSuccessFully: "1", senderID: historyMessage["user_id"] as? String ?? "", receiverID: "0", groupID: i["group_id"] as? String ?? "")
                                            RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                                        }
                                        else {
                                            if historyMessage["user_id"] as! String == i["user_id"] as? String ?? "" {
                                                let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(historyMessage["chat_id"] as? Int ?? 0)" ,userID: appDelegate.ChatTimeUserUserID,dateTime:historyMessage["chat_dateTime"] as! String, msgType: historyMessage["message_type"] as! String , message: historyMessage["message"] as! String , isSentSuccessFully: "1", senderID:  i["user_id"] as? String ?? "" , receiverID: historyMessage["user_id"] as! String, groupID: "")
                                                RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                                            }else{
                                                let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(historyMessage["chat_id"] as? Int ?? 0)" ,userID: appDelegate.ChatTimeUserUserID,dateTime:historyMessage["chat_dateTime"] as! String, msgType: historyMessage["message_type"] as! String , message: historyMessage["message"] as! String , isSentSuccessFully: "1", senderID: historyMessage["user_id"] as! String, receiverID:  i["user_id"] as? String ?? "", groupID: "")
                                                RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                                            }
                                        }
                                       
                                        if historyMessage["message_type"] as! String != ChatConstanct.FileTypes.TEXT_MESSAGE {
                                            let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(historyMessage["chat_id"] as? Int ?? 0)", msgType: historyMessage["message_type"] as! String , mediaURL: historyMessage["files"] as! String, localPath: "", fileSize: "\(historyMessage["size"] as? Int ??  0)" , isDownloaded: "0", isVedioImage64Encoding: "")
                                            RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                                        }
                                    }
                                }
                            }
                            
                            let count = FistTimeHistoyLoad == true ? 0 : CountHistory
                            if (i["type"] as? String ?? "") == "group" {
                                let dicForUser = UserModal(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", receiverIdForChat: i["group_id"] as? String ?? "", chatType: "group",  contactNumber: i["mobile_no"] as? String ?? "", contactName: i["group_name"] as? String ?? "", lastChatDateTime: i["last_chat_time"] as? String ?? "", lastMessage: i["last_chat_msg"] as? String ?? "", lastMessageType: i["last_chat_msg_type"] as? String ?? "", chatCounter: "\(count)", roomID: i["group_id"] as? String ?? "")
                                print(dicForUser)
                                RealmDatabaseeHelper.shared.saveUserModalUpdateGroup(dataUserModal: dicForUser)
                                storeLastSyncTime(LastSyncTime: i["last_sync_time"] as? String ?? "")
                            }else{
                                let dicForUser = UserModal(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", receiverIdForChat: i["user_id"] as? String ?? "", chatType: "private",  contactNumber: i["mobile_no"] as? String ?? "", contactName: i["group_name"] as? String ?? "", lastChatDateTime: i["last_chat_time"] as? String ?? "", lastMessage: i["last_chat_msg"] as? String ?? "", lastMessageType: i["last_chat_msg_type"] as? String ?? "", chatCounter: "\(count)", roomID: i["group_id"] as? String ?? "")
                                RealmDatabaseeHelper.shared.saveUserModalUpdate(dataUserModal: dicForUser)
                                storeLastSyncTime(LastSyncTime: historyArrry[0]["last_sync_time"] as? String ?? "")
                            }
                            
                        }
                        
                    }
                }
                DispatchQueue.main.async{ [self] in
                    ProgressHUD.dismiss()
                    tableView.reloadData()
                    FistTimeHistoyLoad = false
                }
            }
        }
        
        chat.mSocket.off(ChatConstanct.EventListener.DELETEALL)
        chat.mSocket.on(ChatConstanct.EventListener.DELETEALL) { [self] data, ack in
         if let message = data[0] as? [String:Any]
            {
                if message["status"] as? String == "Fail"
                {
                    if  message["is_confirm_delete"] as? String  == "1"
                    {
                        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":RoomID]
                        print(requestData)
                        chat.mSocket.emit(ChatConstanct.EventListener.DELETEGROP, requestData)
                    }
                }
            }
        }

        chat.mSocket.off(ChatConstanct.EventListener.DELETEGROP)
        chat.mSocket.on(ChatConstanct.EventListener.DELETEGROP) { data, ack in
           print(data)
        }
        ProgressHUD.dismiss()
    }
    
    // MARK: - btn Click
    @IBAction func btnClickAddContect(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "ContactsVc") as! ContactsVc
        nextVC.navigationBarnotShow = true
        nextVC.isInvitedBtnShow = false
        nextVC.isFavoriteBtnShow = false
        nextVC.isContectNumberShow = false
        nextVC.isShowTopNavigationBar = true
        nextVC.isAddToChatView = true
        nextVC.buttonShow = true
        nextVC.modalPresentationStyle = .overFullScreen
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    //MARK: - APi Action
    func SocketTimeLogin() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        let strReq = API_URL.SoketAPIURL + APISoketName.Login
        print(strReq)

    //    ProgressHUD.show(interaction: false)

        let requestData : [String : String] = ["device_token":appDelegate.notificationTokan,
                                               "mobile_no":User.sharedInstance.getContactNumber()]    //,"is_replace_token":"1"]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                SocketTimeGetUser()
            } else {
//                SocketTimeCreateUser()
            }
            ProgressHUD.dismiss()
        })
    }
    
    func SocketTimeGetUser() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        let strReq = API_URL.SoketAPIURL + APISoketName.GetUser

        let requestData : [String : String] = ["mobile_num":User.sharedInstance.getContactNumber()]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                let Response: [String: Any]  = (diddata["Response"] as! [String: Any])
                let Data = Response["data"] as! [String:Any]
                userData = Data
                appDelegate.ChatTimeUserUserID = "\(Data["id"] as? Int ?? 0)"
                let time = getLastSyncTime(LastSyncTimeKey: "last_sync_time")
                SocketHInit(Time: time)
                ProgressHUD.dismiss()
            } else {
                ProgressHUD.dismiss()
            }
        })
    }
    
    func SocketTimeCreateUser() {
        let isONN : Bool = APIsMain.apiCalling.isConnectedToNetwork()
        if(isONN == false) {
            let alert = UIAlertController(title: Constant.GlobalConstants.APPNAME, message: "No Internet connection", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
            }))
            alert.present(animated: true, completion: nil)
            return
        }
        let strReq = API_URL.SoketAPIURL + APISoketName.CreateUser
        print(strReq)

        let requestData : [String : String] = ["user_name":User.sharedInstance.getFullName() ,"mobile_no":User.sharedInstance.getContactNumber(),"device_token":appDelegate.notificationTokan,"is_replace_token":"1"]
        print(requestData)
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self] (result) in
            print(result)
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                let Response: [String: Any]  = (diddata["Response"] as! [String: Any])
                let Data = Response["data"] as! [String:Any]
                userData = Data
                appDelegate.ChatTimeUserUserID = "\(Data["id"] as? Int ?? 0)"
                let time = getLastSyncTime(LastSyncTimeKey: "last_sync_time")
                SocketHInit(Time: time)
                ProgressHUD.dismiss()
            } else {
                ProgressHUD.dismiss()

            }
        })
    }
    
    func DeleteUser(roomId: String,userID: String) {
        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":roomId]
        print(requestData)
        RoomID = roomId
        chat.mSocket.emit(ChatConstanct.EventListener.DELETEALL, requestData)
        RealmDatabaseeHelper.shared.DataDeleteUserKey(key: userID)
    }
 
}
extension ChatUserListVc: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  RealmDatabaseeHelper.shared.getAllUserModall().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserListCell", for: indexPath) as! ChatUserListCell
        let dicForData = RealmDatabaseeHelper.shared.getAllUserModall()[indexPath.row]
        var userLastMessageFind: Results<DataModel>
        
        cell.userImge.layer.cornerRadius = cell.userImge.layer.bounds.height/2
       
        
        if dicForData.chatType == "group" {
            cell.userName.text = dicForData.contactName
            userLastMessageFind = RealmDatabaseeHelper.shared.FilterDataModelGroup(groupId: dicForData.roomID)
            cell.userImge.image = UIImage(named: "group")
        }else{
            userLastMessageFind = RealmDatabaseeHelper.shared.FilterDataModel(ReciverId: dicForData.receiverIdForChat, SenderID:  dicForData.receiverIdForChat)
            if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == (dicForData.contactNumber).suffix(10)})
                if index != nil {
                    let infoUser = contactList[index!]
                    cell.userName.text = infoUser["name"] as? String ?? ""
                }else{
                    cell.userName.text = dicForData.contactNumber
                }
            } else {
                cell.userName.text = dicForData.contactNumber
            }
            if let student = dataContectInfo.first(where: {($0["phone"] as? String)?.digitsOnly == (dicForData["contactNumber"] as? String)?.digitsOnly}) {
               print(student["phone"])
                if student["imageData64"] as! String != "" {
                    let dataDecoded:NSData = NSData(base64Encoded: student["imageData64"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    cell.userImge.image = decodedimage
                } else {
                    cell.userImge.image = UIImage(named: "user_icon")
                }
            } else {
                cell.userImge.image = UIImage(named: "user_icon")
               print("not found")
            }
        }
        
        cell.lblUserLastMessage.text = dicForData.lastMessage// userLastMessageFind[userLastMessageFind.count - 1].message
        if userLastMessageFind[userLastMessageFind.count - 1].msgType == ChatConstanct.FileTypes.IMAGE_MESSAGE {
            cell.lblUserLastMessage.text  = "Image"
        }else if userLastMessageFind[userLastMessageFind.count - 1].msgType == ChatConstanct.FileTypes.VIDEO_MESSAGE {
            cell.lblUserLastMessage.text  = "Video"
        }
        else if userLastMessageFind[userLastMessageFind.count - 1].msgType == ChatConstanct.FileTypes.FILE_MESSAGE {
            cell.lblUserLastMessage.text  = "File"
        }
        else if userLastMessageFind[userLastMessageFind.count - 1].msgType == ChatConstanct.FileTypes.AUDIO_MESSAGE {
            cell.lblUserLastMessage.text  = "Audio"
        }
        let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: userLastMessageFind[userLastMessageFind.count - 1].dateTime)
        let fullNameArr = data.components(separatedBy: " ")
        if fullNameArr.count > 2 {
            cell.lblUserLastSeenTime.text = fullNameArr[1] + " " + fullNameArr[2]
        }
        cell.countMessageVW.layer.cornerRadius = cell.countMessageVW.bounds.height/2
        
        if Int(dicForData.chatCounter) ?? 0 > 0 {
            cell.countMessageVW.isHidden = false
            cell.lblUserLastSeenTime.textColor = #colorLiteral(red: 0.2039999813, green: 0.7799999714, blue: 0.3489999771, alpha: 1)
            cell.lblNumberMessage.text = dicForData.chatCounter
        } else {
            cell.countMessageVW.isHidden = true
            cell.lblUserLastSeenTime.textColor = #colorLiteral(red: 0.8065157533, green: 0.8065158129, blue: 0.8065157533, alpha: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        let nextVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatVc") as! ChatVc
        let dicForData = RealmDatabaseeHelper.shared.getAllUserModall()[indexPath.row]
        if dicForData.chatType == "group" {
            nextVC.Name  = dicForData.contactName
            nextVC.isgroupchat = true
//            nextVC.userGroupId = dicForData.roomID
            RealmDatabaseeHelper.shared.readTimeCountGroup(roomID: dicForData.roomID)

        }
        else{
            if UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) != nil {
                let contactList =  UserDefaults.standard.value(forKey: Constant.ValueStoreName.ContactNumber) as! [[String:Any]]
                let index = contactList.firstIndex(where: {($0["phone"] as! String).suffix(10) == (dicForData.contactNumber).suffix(10)})
                if index != nil {
                    let infoUser = contactList[index!]
                    nextVC.phoneNumber = dicForData.contactNumber
                    nextVC.Name = infoUser["name"] as? String ?? ""
                    if infoUser["imageData64"] as! String != "" {
                        
                        let dataDecoded:NSData = NSData(base64Encoded: infoUser["imageData64"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                        nextVC.userContactImage = decodedimage
                    } else {
                        nextVC.userImage = UIImage(named: "user_icon")!
                    }
                }else{
                    nextVC.phoneNumber = dicForData.contactNumber
                    nextVC.Name = ""
                }
            }else{
                nextVC.phoneNumber = dicForData.contactNumber
                nextVC.Name = ""
            }
            RealmDatabaseeHelper.shared.readTimeCountChange(phonenumber: dicForData.contactNumber)
        }
        
        nextVC.userChatId = dicForData.receiverIdForChat
        appDelegate.ChatGroupID = dicForData.roomID
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
