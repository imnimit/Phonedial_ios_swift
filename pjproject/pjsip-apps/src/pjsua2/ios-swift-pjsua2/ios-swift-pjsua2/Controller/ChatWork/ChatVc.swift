//
//  ChatVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 27/01/23.
//

import UIKit
import SocketIO
import InputBarAccessoryView
import SDWebImage
import ImageViewer_swift
import AVKit
import RealmSwift

class ChatVc: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var navTitleSec: UILabel!
    @IBOutlet weak var navImage: UIImageView!
    @IBOutlet weak var imgNavVW: UIView!
    @IBOutlet weak var tabelVW: UIView!
    @IBOutlet weak var navigationVW: UIView!
    
    var playerViewController = AVPlayerViewController()
    var playerView = AVPlayer()
    var FistTimeKeyBordOpen = true
//    let chatService = ChatService()
    var messageInputBar = InputBarAccessoryView()
    private var keyboardManager = KeyboardManager()
    private var heightKeyboard: CGFloat = 0
    var userChatId = ""
    var userDataChat = [String:Any]()
    var avatarImages: [String: UIImage] = [:]
    var phoneNumber = ""
    var Name = ""
    var fistTimeUserEntry = false
    var isAudioScreenOpne = false
    var groupedUserData =  [String : [DataModel]]()
    var indexLettersInContactsArray = [String]()
    var last7Days = [String]()
    var isgroupchat = false
    var userGroupId = ""
    
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        DispatchQueue.main.async {
//            if self.userChatId == "" {
//                self.SocketTimeConnected()
//            }else{
//                self.SocketTimeGetGroup()
//            }
//        }
        print(appDelegate.ChatGroupID)
        DispatchQueue.main.async {
            self.callInit()
        }
        
        DispatchQueue.main.async { [self] in
//            appDelegate.ChatGroupID = ""
            
            if Name == "" {
                navTitle.text = phoneNumber
            }else {
                navTitle.text = Name
            }
            last7Days = Date.getDates(forLastNDays: 7)
        }
    }
  
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isAudioScreenOpne == false {
            LeaveChat()
        }
        isAudioScreenOpne = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.async { [self] in
            if isgroupchat == false {
                if self.userChatId == "" {
                    self.SocketTimeConnected()
                }else{
                    self.SocketTimeGetGroup()
                }
            }else{
                SocketInit()
            }
        }
    }
    
    func LeaveChat() {
        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID]
        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.LEAVE, requestData)
    }
    
    func callInit() {
        DispatchQueue.main.async {
            self.configureMessageInputBar()
            self.configureKeyboardActions()
        }
        
        
        imgNavVW.layer.cornerRadius = imgNavVW.layer.bounds.height/2
        imgNavVW.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        imgNavVW.layer.borderWidth = 1
        
        DispatchQueue.main.async {
            self.SocketEvent()
        }
        
        DispatchQueue.main.async {
            if #available(iOS 15.0, *) {
                self.tableView.sectionHeaderTopPadding = 0
            }
            if self.isgroupchat == true {
                self.dataMange()
            }
           else if self.userChatId != ""  {
                self.dataMange()
            }
        }
    }
    
    func dataMange(ScallMove:Bool = true){
        groupedUserData.removeAll()
        indexLettersInContactsArray = [String]()
        if self.isgroupchat == true {
            groupedUserData = Dictionary(grouping: RealmDatabaseeHelper.shared.FilterDataModelGroup(groupId: appDelegate.ChatGroupID), by: {
                return DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd", data: $0.dateTime)
            })
        }
        else{
            groupedUserData = Dictionary(grouping: RealmDatabaseeHelper.shared.FilterDataModel(ReciverId: userChatId, SenderID:  userChatId), by: {
                return DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd", data: $0.dateTime)
            })
        }
        
        indexLettersInContactsArray = [String](groupedUserData.keys)
        indexLettersInContactsArray = indexLettersInContactsArray.sorted()
        FistTimeKeyBordOpen = true

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if ScallMove == true {
            DispatchQueue.main.async {
                self.scrollToBottom(animated: true)
                self.positionToBottom()
            }
        }
    }
    
    // MARK: - Socket Init
    func SocketInit() {
//        appDelegate.chatService.establishConnection()
       
        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID]
        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.Joint, requestData)
    }
    
    func SocketEvent() {
        
        appDelegate.chatService.mSocket.off(ChatConstanct.EventListener.SendMSG)
        appDelegate.chatService.mSocket.on(ChatConstanct.EventListener.SendMSG) { [self] data, ack in
            print(data)
            if let message = data[0] as? [String:Any] {
                if message["msg_type"] as? String ?? "" == ChatConstanct.FileTypes.IMAGE_MESSAGE {
                    if message["user_id"] as? String ?? "" == appDelegate.ChatTimeUserUserID {
                        RealmDatabaseeHelper.shared.UpdateRowGet(key: message["chat_unique_id"] as? String ?? "", Data: message["sendtime"] as! String,Updatechatid: "\(message["chat_id"] as? Int ?? 0)")
                        RealmDatabaseeHelper.shared.UpdateRowtMediaModel(key: message["chat_unique_id"] as? String ?? "",Updatechatid: "\(message["chat_id"] as? Int ?? 0)")
                        tableView.reloadData()
                        DispatchQueue.main.async {
                            self.scrollToBottom()
                        }
                    }else {

                        DispatchQueue.main.async {
                            let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)" ,userID: appDelegate.ChatTimeUserUserID,dateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss") , msgType: ChatConstanct.FileTypes.IMAGE_MESSAGE , message: "Image" , isSentSuccessFully: "0", senderID: message["user_id"] as! String , receiverID: (self.isgroupchat == true) ?  "0" : appDelegate.ChatTimeUserUserID, groupID: "\(message["group_id"] as? Int ?? 0)")
                            RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                        }
                        
                        DispatchQueue.main.async {
                            let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)", msgType: ChatConstanct.FileTypes.IMAGE_MESSAGE, mediaURL:  message["files"] as? String ?? "", localPath: "", fileSize: message["size"] as? String ??  "" , isDownloaded: "0", isVedioImage64Encoding: "")
                            RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                            self.dataMange()
                        }
                        
//                        DispatchQueue.main.async {
//                            self.scrollToBottom()
//                        }
                        
//                        let imageURL = URL(string: message["files"] as? String ?? "")!
//                        downloadImageConvertToBase64(from: imageURL) { [self] (base64String) in
//                            if let base64String = base64String {
//                                DispatchQueue.main.async {
//                                    let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: message["chat_unique_id"] as? String ?? "" ,userID: appDelegate.ChatTimeUserUserID,dateTime: Date().string(format: "MM/dd/yyyy h:mm a") , msgType: ChatConstanct.FileTypes.IMAGE_MESSAGE , message: "Image" , isSentSuccessFully: "0", senderID: message["user_id"] as! String , receiverID: appDelegate.ChatTimeUserUserID)
//                                    RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
//                                }
//
//                                DispatchQueue.main.async {
//                                    let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: message["chat_unique_id"] as? String ?? "", msgType: ChatConstanct.FileTypes.IMAGE_MESSAGE, mediaURL:  message["files"] as? String ?? "", localPath: "", fileSize: message["size"] as? String ??  "" , isDownloaded: "0", isVedioImage64Encoding: base64String)
//                                    RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
//                                    self.tableView.reloadData()
//                                }
//
//                                DispatchQueue.main.async {
//                                    self.scrollToBottom()
//                                }
//
//                            }else{
//                                print("Failed to download and convert to Base64")
//                            }
//                        }
                        
                    }
                }
                else  if message["msg_type"] as? String ?? "" == ChatConstanct.FileTypes.VIDEO_MESSAGE {
                    if message["user_id"] as? String ?? "" == appDelegate.ChatTimeUserUserID {
                        RealmDatabaseeHelper.shared.UpdateRowGet(key: message["chat_unique_id"] as? String ?? "", Data: message["sendtime"] as! String, Updatechatid: "\(message["chat_id"] as? Int ?? 0)")
                        RealmDatabaseeHelper.shared.UpdateRowtMediaModel(key: message["chat_unique_id"] as? String ?? "",Updatechatid: "\(message["chat_id"] as? Int ?? 0)")
                        tableView.reloadData()
                        DispatchQueue.main.async {
                            self.scrollToBottom()
                        }
                    } else {
                        let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)" ,userID: appDelegate.ChatTimeUserUserID,dateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss") , msgType: ChatConstanct.FileTypes.VIDEO_MESSAGE , message: "Video" , isSentSuccessFully: "0", senderID: message["user_id"] as! String , receiverID: (isgroupchat == true) ?  "0" : appDelegate.ChatTimeUserUserID, groupID: "\(message["group_id"] as? Int ?? 0)")
                        RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                        
                        DispatchQueue.main.async {
                            let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)", msgType: ChatConstanct.FileTypes.VIDEO_MESSAGE, mediaURL:  message["files"] as? String ?? "", localPath: "", fileSize: message["size"] as? String ??  "" , isDownloaded: "0", isVedioImage64Encoding: "")
                            RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                            self.dataMange()
                        }
                        
                        
//                        generateThumbnailVideo(path: URL(string: message["files"] as? String ?? "")!){ [self] (imge) in
//                            let vidoImageData = imge!.pngData()
//                            let imageString = vidoImageData?.base64EncodedString()
//
//                            let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: message["chat_unique_id"] as? String ?? "", msgType: ChatConstanct.FileTypes.VIDEO_MESSAGE, mediaURL:  message["files"] as? String ?? "", localPath: "", fileSize: message["size"] as? String ??  "" , isDownloaded: "0", isVedioImage64Encoding: imageString!)
//                            RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
//                            self.dataMange()
//                        }
                    }
                }
                else  if message["msg_type"] as? String ?? "" == ChatConstanct.FileTypes.AUDIO_MESSAGE {
                    if message["user_id"] as? String ?? "" == appDelegate.ChatTimeUserUserID {
                        RealmDatabaseeHelper.shared.UpdateRowGet(key: message["chat_unique_id"] as? String ?? "", Data: message["sendtime"] as! String, Updatechatid: "\(message["chat_id"] as? Int ?? 0)")
                        RealmDatabaseeHelper.shared.UpdateRowtMediaModel(key: message["chat_unique_id"] as? String ?? "",Updatechatid: "\(message["chat_id"] as? Int ?? 0)")

                        tableView.reloadData()
                        DispatchQueue.main.async {
                            self.scrollToBottom()
                        }
                    } else {
                        
                        let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)" ,userID: appDelegate.ChatTimeUserUserID,dateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss") , msgType: ChatConstanct.FileTypes.AUDIO_MESSAGE , message: "Auido" , isSentSuccessFully: "0", senderID: message["user_id"] as! String , receiverID: (isgroupchat == true) ?  "0" : appDelegate.ChatTimeUserUserID, groupID: "\(message["group_id"] as? Int ?? 0)")
                        RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                        
                        let mp3URL = URL(string: message["files"] as? String ?? "")!
                        downloadAndConvertToBase64(mp3URL: mp3URL){ [self] (base64String) in
                            if let base64String = base64String {
                                DispatchQueue.main.async { [self] in
                                    let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)", msgType: ChatConstanct.FileTypes.AUDIO_MESSAGE, mediaURL:  message["files"] as? String ?? "", localPath: "", fileSize: message["size"] as? String ??  "" , isDownloaded: "0", isVedioImage64Encoding: base64String)
                                    RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                                    self.dataMange()
                                }
                            }else{
                                print("Failed to download and convert to Base64")
                            }
                        }
                    }
                }
                else  if message["msg_type"] as? String ?? "" == ChatConstanct.FileTypes.FILE_MESSAGE{
                    if message["user_id"] as? String ?? "" == appDelegate.ChatTimeUserUserID {
                        
                        RealmDatabaseeHelper.shared.UpdateRowGet(key: message["chat_unique_id"] as? String ?? "", Data: message["sendtime"] as! String, Updatechatid: "\(message["chat_id"] as? Int ?? 0)")
                        RealmDatabaseeHelper.shared.UpdateRowtMediaModel(key: message["chat_unique_id"] as? String ?? "",Updatechatid: "\(message["chat_id"] as? Int ?? 0)")

                        tableView.reloadData()
                        DispatchQueue.main.async {
                            self.scrollToBottom()
                        }
                        
                    } else {
                        let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)" ,userID: appDelegate.ChatTimeUserUserID,dateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss") , msgType: ChatConstanct.FileTypes.FILE_MESSAGE , message: "Doc" , isSentSuccessFully: "0", senderID: message["user_id"] as! String , receiverID: (isgroupchat == true) ?  "0" : appDelegate.ChatTimeUserUserID, groupID: "\(message["group_id"] as? Int ?? 0)")
                        RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                        
                        let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)", msgType: ChatConstanct.FileTypes.FILE_MESSAGE, mediaURL:  message["files"] as? String ?? "", localPath: "", fileSize: message["size"] as? String ??  "" , isDownloaded: "0", isVedioImage64Encoding: "")
                        RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                        self.dataMange()
                    }
                }
                else{
                    if message["user_id"] as? String ?? "" == appDelegate.ChatTimeUserUserID {
                        RealmDatabaseeHelper.shared.UpdateRowGet(key: message["chat_unique_id"] as? String ?? "", Data: message["sendtime"] as! String, Updatechatid: "\(message["chat_id"] as? Int ?? 0)")
                        tableView.reloadData()
                        DispatchQueue.main.async {
                            self.scrollToBottom()
                        }
                    } else {
                        let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(message["chat_id"] as? Int ?? 0)" ,userID: appDelegate.ChatTimeUserUserID,dateTime: message["sendtime"] as! String , msgType: message["msg_type"] as! String , message: message["msg"] as! String , isSentSuccessFully: "1", senderID: message["user_id"] as! String, receiverID: (isgroupchat == true) ?  "0" : appDelegate.ChatTimeUserUserID, groupID: "\(message["group_id"] as? Int ?? 0)")
                        RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                        self.dataMange()
                    }
                }
            }
        }
        
        appDelegate.chatService.mSocket.off(ChatConstanct.EventListener.LEAVE)
        DispatchQueue.main.async { [self] in
            appDelegate.chatService.mSocket.on(ChatConstanct.EventListener.LEAVE) { [self] data, ack in
                if let message = data[0] as? [String:Any] {
                    if message["last_seen_time"] as? String == "NA" {
                        navTitleSec.isHidden = true
                    } else {
                        navTitleSec.isHidden = false
                        let fullNameArr = (message["last_seen_time"] as? String ?? "").components(separatedBy: " ")
                        if fullNameArr.count > 0 {
                            if Date().string(format: "yyyy/dd/MM") == fullNameArr[0] {
                                navTitleSec.text = "last seen today at " +  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "h:mm a", data: message["last_seen_time"] as? String ?? "")
                            }else{
                                navTitleSec.text = "last seen at " +  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "h:mm a", data: message["last_seen_time"] as? String ?? "")
                            }
                        }
                    }
                }
            }
        }
        
        appDelegate.chatService.mSocket.off(ChatConstanct.EventListener.Joint)
        appDelegate.chatService.mSocket.on(ChatConstanct.EventListener.Joint) { [self]data, ack in
            if let message = data[0] as? [String:Any] {
                if message["chat_connectivity_state"] as? String == "2" {
                    navTitleSec.isHidden = false
                    navTitleSec.text = "Online"
                } else if message["chat_connectivity_state"] as? String == "1" {
                    if message["last_seen_time"] as? String == "NA" {
                        navTitleSec.isHidden = true
                    } else {
                        navTitleSec.isHidden = false
                        let fullNameArr = (message["last_seen_time"] as? String ?? "").components(separatedBy: " ")
                        if fullNameArr.count > 0 {
                            if Date().string(format: "yyyy/dd/MM") == fullNameArr[0] {
                                navTitleSec.text = "last seen today at " +  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "h:mm a", data: message["last_seen_time"] as? String ?? "")
                            }else{
                                navTitleSec.text = "last seen at " +  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "h:mm a", data: message["last_seen_time"] as? String ?? "")
                            }
                        }
                    }
                }
            }
        }
        
        appDelegate.chatService.mSocket.off(ChatConstanct.EventListener.TypeStatus)
        appDelegate.chatService.mSocket.on(ChatConstanct.EventListener.TypeStatus) { [self]data, ack in
            if let message = data[0] as? [String:Any] {
                //print("received message: \(message["status"] as? String ?? "")")
                if message["is_type_status"] as? String == "1" {
                    navTitleSec.text = "Typing.."
                } else if message["is_type_status"] as? String == "0" {
                    navTitleSec.text = "Online"
                }
            }
        }
    }
    
   
    // MARK: - Helper methods
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func resizeTableView(_ duration: TimeInterval) {
        
        var frame1 = tableView.frame
        var frame2 = tableView.frame
        
        frame1.origin.y = frame1.origin.y - heightKeyboard
        frame2.size.height = frame2.size.height - heightKeyboard 
        
        UIView.animate(withDuration: duration, animations: {
            self.tableView.frame = frame1
        }, completion: { _ in
            self.tableView.frame = frame2
            self.positionToBottom()
        })
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func layoutTableView() {
        
        let widthView    = view.frame.size.width
        let heightView    = view.frame.size.height
        
        let leftSafe    = view.safeAreaInsets.left
        let rightSafe    = view.safeAreaInsets.right
        
        let heightInput = messageInputBar.bounds.height
        
        let widthTable = widthView - leftSafe - rightSafe
        let heightTable = heightView - heightInput - heightKeyboard
        
        tableView.frame = CGRect(x: leftSafe, y: 0, width: widthTable, height: heightTable)
    }
    
    // MARK: -
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTableView() {
        tableView.reloadData()
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTableView(keepOffset: Bool) {
        
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        
        let contentSize1 = tableView.contentSize
        tableView.reloadData()
        tableView.layoutIfNeeded()
        let contentSize2 = tableView.contentSize
        
        let offsetX = tableView.contentOffset.x + (contentSize2.width - contentSize1.width)
        let offsetY = tableView.contentOffset.y + (contentSize2.height - contentSize1.height)
        
        tableView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
    
    // MARK: -
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func positionToBottom() {
        scrollToBottom(animated: false)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func scrollToBottom() {
        scrollToBottom(animated: true)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func scrollToBottom(animated: Bool) {
        if (tableView.numberOfSections == 1) {
            if tableView.numberOfRows(inSection: 0) - 1 != -1 {
                let indexPath = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }else{
            if (tableView.numberOfSections > 0 ) {
                if tableView.numberOfRows(inSection: 0) - 1 != -1 {
                    let indexPath = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
                    tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
            }
        }
    }
    
    //MARK: - btn Action
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func btnCallNumber(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.view.window?.rootViewController?.dismiss(animated: true, completion: { [self] in
            if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 2
                let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                let dialPed = storyboard1.instantiateViewController(withIdentifier: "dialpadVc") as! dialpadVc
                dialPed.contectNumber = phoneNumber
                dialPed.contectName = Name
                tabBarController.viewControllers![2]  = dialPed
            }
        })
    }
    
    
    //MARK: - APi Action
    func SocketTimeConnected() {
        let strReq = API_URL.SoketAPIURL + APISoketName.GetUser
        let requestData : [String : String] = ["mobile_num":phoneNumber] //  ["mobile_num":"919033269045"] //
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self] (result) in
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                let Response: [String: Any]  = (diddata["Response"] as! [String: Any])
                let Data = Response["data"] as! [String:Any]
                userChatId = "\(Data["id"] as? Int ?? 0)"
                userDataChat = Data
                SocketTimeGetGroup()
            } else {
                //createUser()
            }
        })
    }
    
    func createUser() {
        let strReq = API_URL.SoketAPIURL + APISoketName.CreateUser
        let requestData : [String : String] = ["user_name":Name ,"mobile_no":phoneNumber, "is_replace_token": "0", "device_token": appDelegate.notificationTokan] //  ["mobile_num":"919033269045"] //
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self] (result) in
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                let Response: [String: Any]  = (diddata["Response"] as! [String: Any])
                let Data = Response["data"] as! [String:Any]
                userChatId = "\(Data["id"] as? Int ?? 0)"
                userDataChat = Data
                SocketTimeCreateGruop()
            } else {
            }
        })
    }
    
    
    func SocketTimeGetGroup() {
        let strReq = API_URL.SoketAPIURL + APISoketName.GetGroup
        let requestData : [String : String] = ["user_id":(isgroupchat == true ? "\(userChatId)" : "\(appDelegate.ChatTimeUserUserID),\(userChatId)")]
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self] (result) in
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                let Response: [String: Any]  = (diddata["Response"] as! [String: Any])
                let Data = Response["data"] as! [String:Any]
                appDelegate.ChatGroupID = "\(Data["group_id"] as? Int ?? 0)"
                SocketInit()
            } else {
                SocketTimeCreateGruop()
            }
        })
    }
    
    func SocketTimeCreateGruop() {
        let strReq = API_URL.SoketAPIURL + APISoketName.CreateGroup
        let requestData : [String : String] = ["user_id": appDelegate.ChatTimeUserUserID + "," + userChatId ,"name":"","type":(isgroupchat == true ? "1" : "0")]
        APIsMain.apiCalling.callDataWithoutLoaderSoket(credentials: requestData,requstTag : strReq, withCompletionHandler: { [self](result) in
            let diddata : [String: Any] = (result as! [String: Any])
            if diddata["status"] as! String == "Success" {
                let Response: [String: Any]  = (diddata["Response"] as! [String: Any])
                let Data = Response["data"] as! [String:Any]
                print(Data)
                appDelegate.ChatGroupID = "\(Data["id"] as? Int ?? 0)"
                SocketInit()
            } else {
                
            }
        })
    }
}

// MARK: - Keyboard methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatVc {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func configureKeyboardActions() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func keyboardWillShow(_ notification: Notification?) {
        
        if (heightKeyboard != 0) { return }
        
        if let newFrame = (notification?.userInfo?[ UIResponder.keyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            let insets = UIEdgeInsets( top: 0, left: 0, bottom: newFrame.height +  ((FistTimeKeyBordOpen == true) ? 50 : 50), right: 0 )
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
            scrollToBottom()
        }
        UIMenuController.shared.menuItems = nil
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func keyboardWillHide(_ notification: Notification?) {
        
        heightKeyboard = 0
        FistTimeKeyBordOpen = false
        
        if ((notification?.userInfo?[ UIResponder.keyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue) != nil {
            var insets: UIEdgeInsets
            insets = UIEdgeInsets( top: 0, left: 0, bottom: 30, right: 0 )
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func keyboardWillChange(_ notification: Notification?) {
        
        if let info = notification?.userInfo {
            if let frameBegin = info[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
                if let frameEnd = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    let heightScreen = UIScreen.main.bounds.size.height
                    if (frameBegin.origin.y != heightScreen) && (frameEnd.origin.y != heightScreen) {
                        heightKeyboard = frameEnd.size.height
                        layoutTableView()
                        scrollToBottom()
                    }
                }
            }
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func dismissKeyboard() {
        
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    private func keyboardHeight() -> CGFloat {
        
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
           let inputSetContainerView = NSClassFromString("UIInputSetContainerView"),
           let inputSetHostView = NSClassFromString("UIInputSetHostView") {
            
            for window in UIApplication.shared.windows {
                if window.isKind(of: keyboardWindowClass) {
                    for firstSubView in window.subviews {
                        if firstSubView.isKind(of: inputSetContainerView) {
                            for secondSubView in firstSubView.subviews {
                                if secondSubView.isKind(of: inputSetHostView) {
                                    return secondSubView.frame.size.height
                                }
                            }
                        }
                    }
                }
            }
        }
        return 0
    }
}

// MARK: - Message Input Bar methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatVc: InputBarAccessoryViewDelegate {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func configureMessageInputBar() {
        
        view.addSubview(messageInputBar)
        
        keyboardManager.bind(inputAccessoryView: messageInputBar)
        keyboardManager.bind(to: tableView)
        
        messageInputBar.delegate = self
        
        let button = InputBarButtonItem()
        button.image = UIImage(named: "rckit_attach")
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        
        button.onKeyboardSwipeGesture { item, gesture in
            if (gesture.direction == .left)     { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true) }
            if (gesture.direction == .right) { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true) }
        }
        
        button.onTouchUpInside { item in
            self.actionAttachMessage()
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPress(_:)))
        button.addGestureRecognizer(longPress)
        
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(named: "rckit_send")
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionLongPress(_ gesture: UILongPressGestureRecognizer) {
        
        if (gesture.state == .began) {
            actionAttachLong()
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionAttachLong() {
        
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionAttachMessage() {
        
        dismissKeyboard()
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let alertCamera = UIAlertAction(title: "Camera", style: .default) { action in
            ImagePicker.cameraMulti(self, edit: true)
        }
        let alertPhoto = UIAlertAction(title: "Photo", style: .default) { action in
            ImagePicker.photoLibrary(self, edit: true)
        }
        let alertVideo = UIAlertAction(title: "Video", style: .default) { action in
            ImagePicker.videoLibrary(self, edit: true)
        }
        let alertAudio = UIAlertAction(title: "Audio", style: .default) { action in
            self.actionAudio()
        }
        let alertDoc = UIAlertAction(title: "Document", style: .default) { action in
            ImagePicker.documentLibrary(self)
        }
        
        let configuration     = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let imageCamera       = UIImage(systemName: "camera", withConfiguration: configuration)
        let imagePhoto        = UIImage(systemName: "photo", withConfiguration: configuration)
        let imageVideo        = UIImage(systemName: "play.rectangle", withConfiguration: configuration)
        let imageAudio        = UIImage(systemName: "music.mic", withConfiguration: configuration)
        let imageDoc          = UIImage(systemName: "doc.fill", withConfiguration: configuration)
        
        alertCamera.setValue(imageCamera, forKey: "image");     alert.addAction(alertCamera)
        alertPhoto.setValue(imagePhoto, forKey: "image");        alert.addAction(alertPhoto)
        alertVideo.setValue(imageVideo, forKey: "image");        alert.addAction(alertVideo)
        alertAudio.setValue(imageAudio, forKey: "image");        alert.addAction(alertAudio)
        alertDoc.setValue(imageDoc, forKey: "image");            alert.addAction(alertDoc)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
   
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func actionAudio() {
        isAudioScreenOpne = true

        let audioView = AudioView()
        audioView.delegate = self
        let navController = NavigationController(rootViewController: audioView)
        navController.isModalInPresentation = true
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}
// MARK: - InputBarAccessoryViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatVc {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if (text != "") {
            if text.count == 1 {
                let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"is_typing":"1"]
                appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.TypeStatus, requestData)
            }
        }else{
            if text.count == 0 {
                let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"is_typing":"0"]
                appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.TypeStatus, requestData)
            }
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            tableView.reloadData()
            positionToBottom()
        })
       
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                textSaveInDataBase(text: text)
            }
        }
        messageInputBar.inputTextView.text = ""
        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"is_typing":"0"]
        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.TypeStatus, requestData)
        messageInputBar.invalidatePlugins()
    }
    
    func textSaveInDataBase(text:String) {
        let time = UInt64(Date().timeIntervalSince1970 * 1000)
        print(time)
        let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(time)" ,userID: appDelegate.ChatTimeUserUserID,dateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss") , msgType: ChatConstanct.FileTypes.TEXT_MESSAGE , message: text , isSentSuccessFully: "0", senderID: appDelegate.ChatTimeUserUserID, receiverID: (isgroupchat == true) ?  "0" : userChatId, groupID: appDelegate.ChatGroupID)

        print("socket connected")
        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"msg":text,"msg_type":ChatConstanct.FileTypes.TEXT_MESSAGE,"chat_unique_id": "\(time)","bs64_string":""]
        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.SendMSG, requestData)
        RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
        
        if fistTimeUserEntry == true {
            if isgroupchat == true {
                let dicForUser = UserModal(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", receiverIdForChat: appDelegate.ChatGroupID, chatType: "group", contactNumber: phoneNumber, contactName: Name, lastChatDateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss"), lastMessage:text, lastMessageType: ChatConstanct.FileTypes.TEXT_MESSAGE, chatCounter: "0", roomID: appDelegate.ChatGroupID)
                RealmDatabaseeHelper.shared.saveUserModal(dataUserModal: dicForUser)
            }else{
                let dicForUser = UserModal(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", receiverIdForChat: userChatId, chatType: "private", contactNumber: phoneNumber, contactName: "", lastChatDateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss"), lastMessage:text, lastMessageType: ChatConstanct.FileTypes.TEXT_MESSAGE, chatCounter: "0", roomID: appDelegate.ChatGroupID)
                RealmDatabaseeHelper.shared.saveUserModal(dataUserModal: dicForUser)
            }
            fistTimeUserEntry = false
        }
        
        dataMange()
    }
}
// MARK: - AudioDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatVc: AudioDelegate {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func didRecordAudio(path: String) {
        messageSend(text: nil, photo: nil, video: nil, audio: path)
    }
}

extension ChatVc {
    //-------------------------------------------------------------------------------------------------------------------------------------------
    @objc func rcmessageAt(_ indexPath: IndexPath) -> DataModel {
        let letter = indexLettersInContactsArray[indexPath.section]
        return  groupedUserData[letter]![indexPath.row]
    }
    
    @objc func rcImgeAt(_ indexPath: IndexPath) -> MediaModel {
        return RealmDatabaseeHelper.shared.getAllMediaModel()[indexPath.row]
    }
    
    func avatarImage(_ indexPath: IndexPath) -> UIImage? {

        let rcmessage = rcImgeAt(indexPath)
        let userId = rcmessage.chatID

        if let image = avatarImages[userId] {
            return image
        }

        MediaDownload.user(rcmessage.localPath) { image, later in
            if let image = image {
                DispatchQueue.main.async {
                    self.avatarImages[userId] = image
                    self.refreshTableView()
                }
            }
        }
        return nil
    }
    
    @objc func imge64BaseKeyStore(_ sender: UIButton) {
        let strIndexPath = sender.title(for: .disabled)
        let arrForIndexPath = strIndexPath?.components(separatedBy: " ")
        let sectionValue:Int? = Int(arrForIndexPath![0] )
        let rowValue:Int? = Int(arrForIndexPath![1] )
        
        let letter = indexLettersInContactsArray[sectionValue!]
        let rcmessage =  groupedUserData[letter]![rowValue!]
        
        //let rcmessage = RealmDatabaseeHelper.shared.FilterDataModel(ReciverId: chatFindUserId, SenderID:  chatFindUserId)[sender.tag]
        let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
        let imageURL = URL(string: imgData.mediaURL)!
        downloadImageConvertToBase64(from: imageURL) { [self] (base64String) in
            if let base64String = base64String {
                DispatchQueue.main.sync {
                    RealmDatabaseeHelper.shared.UpdateToBase64Key(key: rcmessage.chatID, Base64Key: base64String,localUrl: "")
                }
                DispatchQueue.main.sync {
                    let indexPathRow:Int = sender.tag
                    let indexPosition = IndexPath(row: indexPathRow, section: sectionValue!)
                    tableView.reloadRows(at: [indexPosition], with: .none)
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            } else {
                print("Failed to download and convert to Base64")
            }
        }
    }
    
    @objc func video64BaseKeyStore(_ sender: UIButton) {
            
        let strIndexPath = sender.title(for: .disabled)
        let arrForIndexPath = strIndexPath?.components(separatedBy: " ")
        let sectionValue:Int? = Int(arrForIndexPath![0] )
        let rowValue:Int? = Int(arrForIndexPath![1])
        
        let letter = indexLettersInContactsArray[sectionValue!]
        let rcmessage =  groupedUserData[letter]![rowValue!]
        let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
        let url = imgData.mediaURL
        print(imgData)
        let time = UInt64(Date().timeIntervalSince1970 * 1000)

        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoURL = documentsDirectory.appendingPathComponent("\(time).mp4")
        
        DispatchQueue.global(qos: .default).async {
            generateThumbnailVideo(url: URL(string: url)!,saveTo: videoURL){ (imge) in
                var base64 = ""
                DispatchQueue.main.async {
                    let vidoImageData = imge!.pngData()
                    base64 = vidoImageData!.base64EncodedString()
                    RealmDatabaseeHelper.shared.UpdateToBase64Key(key: rcmessage.chatID, Base64Key: base64,localUrl: videoURL.absoluteString)
                    let indexPathRow:Int = sender.tag
                    let indexPosition = IndexPath(row: indexPathRow, section: sectionValue!)
                    self.tableView.reloadRows(at: [indexPosition], with: .none)
                }
            }
        }
        
    }
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatVc: UITableViewDataSource {
  
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedUserData.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int()
        let letter = indexLettersInContactsArray[section]
        if let names = groupedUserData[letter] {
            count = names.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "hederCellDateOrTime") as! hederCellDateOrTime
        
        if Date().string(format: "yyyy/MM/dd") == indexLettersInContactsArray[section] {
            header.lblDate.text =  "Today"
        } else  if last7Days[0] == indexLettersInContactsArray[section] {
            header.lblDate.text =  "Yesterday"
        } else  if last7Days[1] == indexLettersInContactsArray[section] {
            header.lblDate.text =  DataFormateSet(yourDataFormate: "yyyy/MM/dd", getDataFormat: "EEEE", data: indexLettersInContactsArray[section])
        } else if last7Days[2] == indexLettersInContactsArray[section] {
            header.lblDate.text =  DataFormateSet(yourDataFormate: "yyyy/MM/dd", getDataFormat: "EEEE", data: indexLettersInContactsArray[section])
        } else if last7Days[3] == indexLettersInContactsArray[section] {
            header.lblDate.text =  DataFormateSet(yourDataFormate: "yyyy/MM/dd", getDataFormat: "EEEE", data: indexLettersInContactsArray[section])
        } else if last7Days[4] == indexLettersInContactsArray[section] {
            header.lblDate.text =  DataFormateSet(yourDataFormate: "yyyy/MM/dd", getDataFormat: "EEEE", data: indexLettersInContactsArray[section])
        } else if last7Days[5] == indexLettersInContactsArray[section] {
            header.lblDate.text =  DataFormateSet(yourDataFormate: "yyyy/MM/dd", getDataFormat: "EEEE", data: indexLettersInContactsArray[section])
        } else {
            header.lblDate.text = DataFormateSet(yourDataFormate: "yyyy/MM/dd", getDataFormat: "E, d MMM", data: indexLettersInContactsArray[section])
        }
        header.lblBackVW.layer.cornerRadius = 10
        
        return header
    }
    

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let letter = indexLettersInContactsArray[indexPath.section]
        let rcmessage =  groupedUserData[letter]![indexPath.row]
        if (rcmessage.msgType  == ChatConstanct.FileTypes.TEXT_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextSenderCell", for: indexPath) as! TextSenderCell
                cell.lblMessage.text = rcmessage.message
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                if rcmessage.isSentSuccessFully == "1"  {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "Ic_DubleTic.png")
                }else{
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "ic_singleTic.png")
                }
                cell.chatVW.layer.cornerRadius = 10.0
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
               

                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextReceiverCell", for: indexPath) as! TextReceiverCell
                cell.lblMessage.text = rcmessage.message
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.chatVW.layer.cornerRadius = 10.0
              
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }
        }
        else if (rcmessage.msgType  == ChatConstanct.FileTypes.IMAGE_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImgeSenderSideCell", for: indexPath) as! ImgeSenderSideCell
                let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                cell.btnVedioNotLoadTime.isHidden = true
                cell.btnVedioNotLoadTime.tag = indexPath.row
                if imgData.isVedioImage64Encoding == "" {
                    cell.btnVedioNotLoadTime.isHidden = false
                    cell.img.image = #imageLiteral(resourceName: "ic_imge_defult.png")
                    cell.LoaderActinoAction = {
                        cell.isRunning = true
                    }
                    cell.btnVedioNotLoadTime.setTitle(String(format: "%@ %@ %@", String(indexPath.section) , String(indexPath.row), "false"), for:.disabled)
                    cell.btnVedioNotLoadTime.addTarget(self, action: #selector(self.imge64BaseKeyStore(_:)), for: .touchUpInside)
                }else {
                    let dataDecoded:NSData = NSData(base64Encoded: imgData.isVedioImage64Encoding, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    cell.img.image = decodedimage
//                    cell.img.setupImageViewer(url: URL(string: imgData.mediaURL)!,from: self)
                    cell.isRunning = false
                }
                
                if rcmessage.isSentSuccessFully == "1" {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "Ic_DubleTic.png")
                } else {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "ic_singleTic.png")
                }
                cell.backSideVW.layer.cornerRadius = 10.0
                cell.img.layer.cornerRadius = 10.0
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImgeReceiverSideCell", for: indexPath) as! ImgeReceiverSideCell
                let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                cell.btnVedioNotLoadTime.isHidden = true
                cell.btnVedioNotLoadTime.tag = indexPath.row
                if imgData.isVedioImage64Encoding == "" {
                    cell.btnVedioNotLoadTime.isHidden = false
                    cell.img.image = #imageLiteral(resourceName: "ic_imge_defult.png")
                    cell.LoaderActinoAction = {
                        cell.isRunning = true
                    }
                    cell.btnVedioNotLoadTime.setTitle(String(format: "%@ %@ %@", String(indexPath.section) , String(indexPath.row), "false"), for:.disabled)
                    cell.btnVedioNotLoadTime.addTarget(self, action: #selector(self.imge64BaseKeyStore(_:)), for: .touchUpInside)
                } else {
                    let dataDecoded:NSData = NSData(base64Encoded: imgData.isVedioImage64Encoding, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    cell.img.image = decodedimage
//                    cell.img.setupImageViewer(url: URL(string: imgData.mediaURL)!,from: self)
                    cell.isRunning = false
                }
 
                cell.backSideVW.layer.cornerRadius = 10.0
                cell.img.layer.cornerRadius = 10.0
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                return cell
            }
        }
        else if (rcmessage.msgType  == ChatConstanct.FileTypes.VIDEO_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSenderSideCell", for: indexPath) as! VideoSenderSideCell
                cell.btnVedioNotLoadTime.isHidden = false
                cell.imageViewPlay.isHidden = false
                let videoData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                cell.btnVedioNotLoadTime.tag = indexPath.row
                if videoData.isVedioImage64Encoding == "" {
                    cell.imageViewPlay.isHidden = true
                    cell.img.image = #imageLiteral(resourceName: "ic_imge_defult.png")
                    cell.LoaderActinoAction = {
                        cell.isRunning = true
                    }
                    cell.btnVedioNotLoadTime.setTitle(String(format: "%@ %@ %@", String(indexPath.section) , String(indexPath.row), "false"), for:.disabled)
                    cell.btnVedioNotLoadTime.addTarget(self, action: #selector(self.video64BaseKeyStore(_:)), for: .touchUpInside)
                }else {
                    cell.btnVedioNotLoadTime.isHidden = true
                    cell.isRunning = false

                    let dataDecoded:NSData = NSData(base64Encoded: videoData.isVedioImage64Encoding, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    cell.img.image = decodedimage
                }
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.backSideVW.layer.cornerRadius = 10.0
                cell.img.layer.cornerRadius = 10.0
                if rcmessage.isSentSuccessFully == "1" {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "Ic_DubleTic.png")
                } else {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "ic_singleTic.png")
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoReceiverSideCell", for: indexPath) as! VideoReceiverSideCell
                cell.btnVedioNotLoadTime.isHidden = false
                cell.imageViewPlay.isHidden = false
                let videoData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                cell.btnVedioNotLoadTime.tag = indexPath.row
                if videoData.isVedioImage64Encoding == "" {
                    cell.imageViewPlay.isHidden = true
                    cell.img.image = #imageLiteral(resourceName: "ic_imge_defult.png")
                    cell.LoaderActinoAction = {
                        cell.isRunning = true
                    }
                    cell.btnVedioNotLoadTime.setTitle(String(format: "%@ %@ %@", String(indexPath.section) , String(indexPath.row), "false"), for:.disabled)
                    cell.btnVedioNotLoadTime.addTarget(self, action: #selector(self.video64BaseKeyStore(_:)), for: .touchUpInside)
                }else {
                    cell.btnVedioNotLoadTime.isHidden = true
                    cell.isRunning = false

                    let dataDecoded:NSData = NSData(base64Encoded: videoData.isVedioImage64Encoding, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    cell.img.image = decodedimage
                }
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.backSideVW.layer.cornerRadius = 10.0
                cell.img.layer.cornerRadius = 10.0
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                return cell
            }
        }
        else if (rcmessage.msgType  == ChatConstanct.FileTypes.AUDIO_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mp3SenderSideCell", for: indexPath) as! mp3SenderSideCell
                let audioData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                if audioData.isVedioImage64Encoding == "" {
                    cell.urlAudio = audioData.mediaURL
                    cell.keyStoreDataBase = rcmessage.chatID
                } else {
                    cell.base64key = audioData.isVedioImage64Encoding
                }
                cell.backSideVW.layer.cornerRadius = 10.0
                if rcmessage.isSentSuccessFully == "1" {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "Ic_DubleTic.png")
                } else {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "ic_singleTic.png")
                }
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mp3ReceiverSideCell", for: indexPath) as! mp3ReceiverSideCell
                let audioData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                if audioData.isVedioImage64Encoding == "" {
                    cell.urlAudio = audioData.mediaURL
                    cell.keyStoreDataBase = rcmessage.chatID
                } else {
                    cell.base64key = audioData.isVedioImage64Encoding
                }
                
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.backSideVW.layer.cornerRadius = 10.0
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                return cell
            }
        }
        else if (rcmessage.msgType  == ChatConstanct.FileTypes.FILE_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocSenderSideCell", for: indexPath) as! DocSenderSideCell
                let DocData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                cell.lblFileName.text = DocData.mediaURL.components(separatedBy: "/").last
                cell.lblSiizeExtation.text = byteToSizeGet(size: DocData.fileSize) + " .\(URL(string: DocData.mediaURL)!.pathExtension)"
                cell.backSideVW.layer.cornerRadius = 10.0
                cell.imgdoc.image = DocImgeGet(extection: "\(URL(string: DocData.mediaURL)!.pathExtension)")
                if rcmessage.isSentSuccessFully == "1" {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "Ic_DubleTic.png")
                } else {
                    cell.imgDoubleTic.image = #imageLiteral(resourceName: "ic_singleTic.png")
                }
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocReceiverSideCell", for: indexPath) as! DocReceiverSideCell
                let DocData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                cell.lblFileName.text = DocData.mediaURL.components(separatedBy: "/").last
                cell.lblSiizeExtation.text = byteToSizeGet(size: DocData.fileSize) + " .\(URL(string: DocData.mediaURL)!.pathExtension)"
                cell.backSideVW.layer.cornerRadius = 10.0
                cell.imgdoc.image = DocImgeGet(extection: "\(URL(string: DocData.mediaURL)!.pathExtension)")
                
                let data =  DataFormateSet(yourDataFormate: "yyyy/MM/dd HH:mm:ss", getDataFormat: "yyyy/MM/dd h:mm a", data: rcmessage.dateTime)
                let fullNameArr = data.components(separatedBy: " ")
                if fullNameArr.count > 2 {
                    cell.lblTime.text = fullNameArr[1] + " " + fullNameArr[2]
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                return cell
            }
        }
        return UITableViewCell()
    }
}


// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatVc: UITableViewDelegate {
    
//    //-------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }

//    //-------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let letter = indexLettersInContactsArray[indexPath.section]
        let rcmessage =  groupedUserData[letter]![indexPath.row]
        
//        let rcmessage = RealmDatabaseeHelper.shared.FilterDataModel(ReciverId: chatFindUserId, SenderID:  chatFindUserId)[indexPath.row]
        if (rcmessage.msgType  == ChatConstanct.FileTypes.TEXT_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID { return TextSenderCell.height(self, at: indexPath) } else { return TextReceiverCell.height(self, at: indexPath) }
        } else  if (rcmessage.msgType  == ChatConstanct.FileTypes.IMAGE_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID { return 220 } else { return 220 }
        } else  if (rcmessage.msgType  == ChatConstanct.FileTypes.VIDEO_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID { return 250 } else { return 250 }
        } else  if (rcmessage.msgType  == ChatConstanct.FileTypes.AUDIO_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID { return 90 } else { return 90 }
        } else  if (rcmessage.msgType  == ChatConstanct.FileTypes.FILE_MESSAGE) {
            if rcmessage.senderID == appDelegate.ChatTimeUserUserID { return 100 } else { return 100 }
        }

        return 0
    }

//    //-------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let letter = indexLettersInContactsArray[indexPath.section]
        let rcmessage =  groupedUserData[letter]![indexPath.row]
        if rcmessage.msgType == ChatConstanct.FileTypes.VIDEO_MESSAGE {
            let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
            playVideo(videoUrl: imgData.mediaURL)
        }
        else if rcmessage.msgType == ChatConstanct.FileTypes.IMAGE_MESSAGE {
            let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
            if imgData.isVedioImage64Encoding != "" {
                let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
                let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "TermServiceOrPrivacyPolicyVc") as! TermServiceOrPrivacyPolicyVc
                nextVC.DocumentUrl = imgData.mediaURL
                nextVC.Title = imgData.mediaURL.components(separatedBy: "/").last ?? ""
                navigationController?.pushViewController(nextVC, animated: true)
            }
        }
        else  if rcmessage.msgType == ChatConstanct.FileTypes.FILE_MESSAGE {
            let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
            let nextVC = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "TermServiceOrPrivacyPolicyVc") as! TermServiceOrPrivacyPolicyVc
            nextVC.DocumentUrl = imgData.mediaURL
            nextVC.Title = imgData.mediaURL.components(separatedBy: "/").last ?? ""
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func playVideo(videoUrl: String) {
        let url: URL = URL(string: videoUrl)!
        playerView = AVPlayer(url: url)
        playerViewController.player = playerView
        
        self.present(playerViewController, animated: true)
        self.playerViewController.player?.play()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
        
    }
    
    
    func tableView(_ tableView: UITableView,
                            contextMenuConfigurationForRowAt indexPath: IndexPath,
                            point: CGPoint) -> UIContextMenuConfiguration? {
        
        let letter = indexLettersInContactsArray[indexPath.section]
        let rcmessage =  groupedUserData[letter]![indexPath.row]
        if rcmessage.msgType == ChatConstanct.FileTypes.TEXT_MESSAGE {
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: {
                    suggestedActions in
                let inspectAction =
                    UIAction(title: NSLocalizedString("Copy", comment: ""),
                             image: UIImage(systemName: "doc.on.doc")) { action in
                        UIPasteboard.general.string = rcmessage.message
                        self.showToastMessage(message: "Copy")
                    }
                let duplicateAction =
                    UIAction(title: NSLocalizedString("Share", comment: ""),
                             image: UIImage(named: "ic_share_link")) { action in
                        self.ShareMessage(message: rcmessage.message)
                    }
                let deleteAction =
                    UIAction(title: NSLocalizedString("Delete", comment: ""),
                             image: UIImage(systemName: "trash"),
                             attributes: .destructive) { [self] action in
                       
                       
                        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"chat_id":rcmessage.chatID]
                        print(requestData)
                        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.DELETESINGLECHATFROMONESIDE, requestData)
                        RealmDatabaseeHelper.shared.singelChatDeletDataModel(dataDataModel: rcmessage)
                        dataMange(ScallMove: false)
                    }
                return UIMenu(title: "", children: [inspectAction, duplicateAction, deleteAction])
            })
        }else{
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: {
                    suggestedActions in
                let duplicateAction =
                    UIAction(title: NSLocalizedString("Share", comment: ""),
                             image: UIImage(named: "ic_share_link")) { action in
                        let imgData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)

                        if rcmessage.msgType == ChatConstanct.FileTypes.AUDIO_MESSAGE {
                            self.Mp3Share(baseKey: imgData.isVedioImage64Encoding)
                        }
                        else  if rcmessage.msgType == ChatConstanct.FileTypes.FILE_MESSAGE {
                            self.DocumentShare(urlDoc: imgData.mediaURL)
                            
                        }
                        else if rcmessage.msgType == ChatConstanct.FileTypes.VIDEO_MESSAGE {
                            self.viedoShare(urlPath: imgData.mediaURL)
                        }
                        else{
                            let dataDecoded:NSData = NSData(base64Encoded: imgData.isVedioImage64Encoding, options: NSData.Base64DecodingOptions(rawValue: 0))!
                            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                            self.ImgeShare(img: decodedimage)
                        }
                       
                    }
                let deleteAction =
                    UIAction(title: NSLocalizedString("Delete", comment: ""),
                             image: UIImage(systemName: "trash"),
                             attributes: .destructive) { [self] action in
                       
                       
                        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"chat_id":rcmessage.chatID]
                        print(requestData)
                        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.DELETESINGLECHATFROMONESIDE, requestData)
                        RealmDatabaseeHelper.shared.singelChatDeletDataModel(dataDataModel: rcmessage)
//                        let audioData = RealmDatabaseeHelper.shared.getMediaData(key: rcmessage.chatID)
//                        RealmDatabaseeHelper.shared.singelChatDeletMediaModel(dataMediaModel: audioData)
                        dataMange(ScallMove: false)
                    }
                return UIMenu(title: "", children: [duplicateAction, deleteAction])
            })
        }
      
    }
    
    func ShareMessage(message: String ) {
        if let urlStr = NSURL(string: message) {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    func ImgeShare(img: UIImage){
        let imageShare = [img]
        let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func Mp3Share(baseKey: String){
        if let data = Data(base64Encoded: baseKey) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let filePath = documentsDirectory.appendingPathComponent("Audiofile.mp3")
            let mp3URL = filePath
            do {
                try data.write(to: mp3URL)
                let activityViewController = UIActivityViewController(activityItems: [mp3URL], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            } catch {
                print("Error writing data to file: \(error)")
            }
        }
    }
    
    func DocumentShare(urlDoc: String){
        let fileURL = URL(string: urlDoc)!
        let session = URLSession(configuration: .default)
        let downloadTask = session.downloadTask(with: fileURL) { (location, response, error) in
            guard let location = location, error == nil else {
                print("Error downloading file: \(error!)")
                return
            }
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsURL.appendingPathComponent(response?.suggestedFilename ?? fileURL.lastPathComponent)
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                DispatchQueue.main.sync {
                    let activityViewController = UIActivityViewController(activityItems: [destinationURL], applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                }
            } catch {
                DispatchQueue.main.sync {
                    let activityViewController = UIActivityViewController(activityItems: [destinationURL], applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                }
                
                print("Error moving file to documents folder: \(error)")
            }
        }
        downloadTask.resume()
    }
    
    
    func viedoShare(urlPath: String){
        DispatchQueue.main.async {
            guard let urlData = NSData(contentsOf: NSURL(string:urlPath)! as URL) else {
                return
            }
            print(urlData)
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let docDirectory = paths[0]
            let filePath = "\(docDirectory)/tmpVideo.mov"
            urlData.write(toFile: filePath, atomically: true)
            // File Saved
            let videoLink = NSURL(fileURLWithPath: filePath)
            let objectsToShare = [videoLink] //comment!, imageData!, myWebsite!]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.setValue("Video", forKey: "subject")
            // New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]

            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
}
// MARK: - UIImagePickerControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatVc: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //-------------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let video = info[.mediaURL] as? URL
        let photo = info[.editedImage] as? UIImage

        messageSend(text: nil, photo: photo, video: video, audio: nil)

        picker.dismiss(animated: true)
    }
    
    // MARK: - Message sending methods
    //-------------------------------------------------------------------------------------------------------------------------------------------
    func messageSend(text: String?, photo: UIImage?, video: URL?, audio: String?) {
        
        let time = UInt64(Date().timeIntervalSince1970 * 1000)
        print(time)
        
        var  MessageType = ""
        var LinkStoreLocal = ""
        var MessagePass = ""
        if video != nil {
            LinkStoreLocal = video?.absoluteString ?? ""
            MessageType = ChatConstanct.FileTypes.VIDEO_MESSAGE
            MessagePass = "Video"
        } else if audio != nil  {
            MessageType = ChatConstanct.FileTypes.AUDIO_MESSAGE
            MessagePass = "Auido"
        } else {
            MessageType = ChatConstanct.FileTypes.IMAGE_MESSAGE
            MessagePass = "Image"
        }
        
        let auth = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"msg_type":MessageType,"unique_id": "\(time)"]
        print(auth)
        
        uploadImge.sharUploadImge.UploadImge(photo, video, audio, nil, pram: auth, { [self]response,link,error  in
            let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(time)" ,userID: appDelegate.ChatTimeUserUserID,dateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss") , msgType: MessageType , message: MessagePass , isSentSuccessFully: "0", senderID: appDelegate.ChatTimeUserUserID, receiverID: userChatId, groupID: appDelegate.ChatGroupID)
            RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
            
            if MessageType == ChatConstanct.FileTypes.VIDEO_MESSAGE {
                
                generateThumbnailVideo(path: URL(string: link!)!){ [self] (imge) in
                    if imge != nil {
                        let vidoImageData = imge!.pngData()
                        let imageString = vidoImageData?.base64EncodedString()
                        
                        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"msg":MessageType ,"msg_type":MessageType,"chat_unique_id": "\(time)","files":link ?? "","bs64_string": ""]
                        print(requestData)
                        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.SendMSG, requestData)
                        
                        let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(time)", msgType: MessageType, mediaURL: link ?? "", localPath: LinkStoreLocal, fileSize: "\(response!["size"] as? Int ??  0)" , isDownloaded: "0", isVedioImage64Encoding: imageString!)
                        RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                        
                        dataMange()
                    }else{
                        showToastMessage(message: "Some Think Wan't Worng")
                    }
                    
                }
                
            }
            else if MessageType == ChatConstanct.FileTypes.AUDIO_MESSAGE {
                
                let mp3URL = URL(string: link!)!
                downloadAndConvertToBase64(mp3URL: mp3URL){ [self] (base64String) in
                    if let base64String = base64String {
                        DispatchQueue.main.async { [self] in
                            let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"msg":MessageType ,"msg_type":MessageType,"chat_unique_id": "\(time)","files":link ?? "","bs64_string":""]
                            print(requestData)
                            appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.SendMSG, requestData)
                            
                            let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(time)", msgType: MessageType, mediaURL: link ?? "", localPath: LinkStoreLocal, fileSize: "\(response!["size"] as? Int ??  0)" , isDownloaded: "0", isVedioImage64Encoding: base64String)
                            RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                            dataMange()
                        }
                    }else{
                        print("Failed to download and convert to Base64")
                    }
                }
            }
            else{
                let imageURL = URL(string: link!)!
                downloadImageConvertToBase64(from: imageURL) { [self] (base64String) in
                    if let base64String = base64String {
                        let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"msg":MessageType ,"msg_type":MessageType,"chat_unique_id": "\(time)","files":link ?? "","bs64_string":""]
                        print(requestData)
                        appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.SendMSG, requestData)
                        
                        DispatchQueue.main.async {
                            let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(time)", msgType: MessageType, mediaURL: link ?? "", localPath: LinkStoreLocal, fileSize: "\(response!["size"] as? Int ??  0)" , isDownloaded: "0", isVedioImage64Encoding: base64String)
                            RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                            self.dataMange()
                        }
                    }else{
                        print("Failed to download and convert to Base64")
                    }
                }
            }
            print(response)
        })
    }
    
    
    func convertMP3ToBase64(mp3URL: URL) -> String? {
        let mp3Data = try? Data(contentsOf: mp3URL)
        if let mp3Data = mp3Data {
            let base64String = mp3Data.base64EncodedString()
            return base64String
        }
        return nil
    }
    
    func byteToSizeGet(size: String) -> String {
        let byteSize = Measurement(value: Double(size) ?? 0.0, unit: UnitInformationStorage.bytes)
        return ByteCountFormatter.string(from: byteSize, countStyle: .file)
    }
    
}
extension ChatVc: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileURL = urls[0]
        print(fileURL)
        let certData = try! Data(contentsOf: fileURL)
        if let documentsPathURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            print(documentsPathURL)
            let time = UInt64(Date().timeIntervalSince1970 * 1000)
            print(time)
            let auth = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"msg_type":ChatConstanct.FileTypes.FILE_MESSAGE,"unique_id": "\(time)"]
            print(auth)
            uploadImge.sharUploadImge.UploadImge(nil, nil, nil, fileURL, pram: auth, { [self] response,link,error  in
                let dic = DataModel(id: "\(RealmDatabaseeHelper.shared.getAllDataModel().count + 1)", chatID: "\(time)" ,userID: appDelegate.ChatTimeUserUserID,dateTime: Date().string(format: "yyyy/MM/dd HH:mm:ss") , msgType: ChatConstanct.FileTypes.FILE_MESSAGE , message: "Doc" , isSentSuccessFully: "0", senderID: appDelegate.ChatTimeUserUserID, receiverID: userChatId, groupID: appDelegate.ChatGroupID)
                RealmDatabaseeHelper.shared.saveDataModel(dataModel: dic)
                
                let requestData : [String : String] = ["user_id":appDelegate.ChatTimeUserUserID,"room_id":appDelegate.ChatGroupID,"msg":"Doc" ,"msg_type":ChatConstanct.FileTypes.FILE_MESSAGE,"chat_unique_id": "\(time)","files":link ?? "","bs64_string": ""]
                print(requestData)
                appDelegate.chatService.mSocket.emit(ChatConstanct.EventListener.SendMSG, requestData)
                
                DispatchQueue.main.async {
                    let dicmidia = MediaModel(id: "\(RealmDatabaseeHelper.shared.getAllUserModall().count + 1)", chatID: "\(time)", msgType: ChatConstanct.FileTypes.FILE_MESSAGE, mediaURL: link ?? "", localPath: "", fileSize: "\(response!["size"] as? Int ??  0)" , isDownloaded: "0", isVedioImage64Encoding: "")
                    RealmDatabaseeHelper.shared.saveMediaModel(dataMediaModel: dicmidia)
                    self.dataMange()
                }
                print(response)
                print(link)
            })
        }
        
    }
}
