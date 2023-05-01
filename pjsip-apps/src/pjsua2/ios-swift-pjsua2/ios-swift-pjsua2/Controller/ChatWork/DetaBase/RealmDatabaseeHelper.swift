//
//  RealmDatabaseeHelper.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 30/01/23.
//

import Foundation
import UIKit
import RealmSwift

class RealmDatabaseeHelper{
    static let shared = RealmDatabaseeHelper()
    
    private var realm = try! Realm()
    
    
    func getDatabaseURL() -> URL?{
        return Realm.Configuration.defaultConfiguration.fileURL
    }
    
    ///////////////////// ---------- Data Model -------------------///////////////////
    func saveDataModel(dataModel: DataModel){
        
        try! realm.write{
            realm.add(dataModel)
        }
    }
    
    func getAllDataModel() -> [DataModel] {
        return Array(realm.objects(DataModel.self))
    }
    
    func deletDataModel(dataModel: DataModel){
        try! realm.write{
            realm.delete(dataModel)
        }
    }
    
    func UpdateRowGet(key:String,Data:String,Updatechatid: String)  {
        let realm = try! Realm()
        let taskToUpdate = realm.objects(DataModel.self).filter("chatID = '\(key)'").first!
        try! realm.write {
            taskToUpdate.dateTime = Data
            taskToUpdate.isSentSuccessFully = "1"
            taskToUpdate.chatID = Updatechatid
        }
    }
    
    
    func FilterDataModel(ReciverId: String , SenderID: String) ->  Results<DataModel> {
        let realm = try! Realm()
        let newItems = realm.objects(DataModel.self).filter("senderID == %@ OR receiverID == %@", ReciverId, ReciverId)
        let ascendingdataFormate = newItems.sorted(byKeyPath: "dateTime", ascending: true)
        return ascendingdataFormate
    }
    
    func UpdateRowtMediaModel(key:String,Updatechatid: String)  {
        let realm = try! Realm()
        let taskToUpdate = realm.objects(MediaModel.self).filter("chatID = '\(key)'").first!
        try! realm.write {
            taskToUpdate.chatID = Updatechatid
        }
    }
    
    func DateModelDataIsExistorNot(ChatID: String)-> Bool {
        let realm = try! Realm()
        let userData = realm.objects(DataModel.self)
        let result = userData.filter("chatID == '\(ChatID)'")
        if result.isEmpty {
            return true
        } else {
           return false
        }
    }
    
    func DataDeleteUserKey(key: String) {
        let realm = try! Realm()
        let deleteData = realm.objects(DataModel.self).filter("senderID == %@ OR receiverID == %@", key, key)
        if deleteData.count == 0 {
            print("No data in DB")
        } else {
            try! realm.write {
                for i in deleteData {
                    realm.delete(i)
                }
            }
        }
    }
    
    func singelChatDeletDataModel(dataDataModel: DataModel){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(dataDataModel)
        }
    }
    
    func singelChatDeletMediaModel(dataMediaModel: MediaModel){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(dataMediaModel)
        }
    }
    
    
    ///////////////////// ----------User Modal-------------------///////////////////
    func saveUserModalUpdate(dataUserModal: UserModal){
        let realm = try! Realm()
             
        let people = realm.objects(UserModal.self)

        let result = people.filter("contactNumber == '\(dataUserModal.contactNumber)'")
        if result.isEmpty {
            print("not exist in the database.")
            try! realm.write{
                realm.add(dataUserModal)
            }
        } else {
            print("John Doe exists in the database.")
            try! realm.write {
                result.first!.lastChatDateTime = dataUserModal.lastChatDateTime
                result.first!.lastMessageType = dataUserModal.lastMessageType
                result.first!.lastMessage = dataUserModal.lastMessage
                if result.first!.chatCounter != "0" {
                    let count = Int(result.first!.chatCounter)! + Int(dataUserModal.chatCounter)!
                    result.first!.chatCounter =  "\(count)"
                }else{
                    result.first!.chatCounter = dataUserModal.chatCounter
                }
            }
        }
        
    }
    
    func getUserPhoneNumberUserExitOrNot(phonenumber: String) -> Bool {
        let realm = try! Realm()
        let people = realm.objects(UserModal.self)
        let result = people.filter("contactNumber == '\(phonenumber)'")
        if result.isEmpty {
            print("not exist in the database.")
            return false
        }else{
            print("exists in the database.")
            return true
        }
    }
    
   
    
    func readTimeCountChange(phonenumber: String) {
        let realm = try! Realm()
        let taskToUpdate = realm.objects(UserModal.self).filter("contactNumber = '\(phonenumber)'").first!
        try! realm.write {
            taskToUpdate.chatCounter = "0"
        }
    }
    
    func saveUserModal(dataUserModal: UserModal){
        let realm = try! Realm()
        try! realm.write{
            realm.add(dataUserModal)
        }
    }
    
    
    func objectExist (id: String) -> Bool {
            return realm.object(ofType: UserModal.self, forPrimaryKey: id) != nil
    }
    
    
    func getAllUserModall() -> [UserModal] {
        return Array(realm.objects(UserModal.self))
    }
    
    func deletUserModal(dataUserModal: UserModal){
        try! realm.write{
            realm.delete(dataUserModal)
        }
    }
    
    
    
    ///////////////////// ----------Media Model------------------///////////////////
    ///
    func saveMediaModel(dataMediaModel: MediaModel){
        try! realm.write{
            realm.add(dataMediaModel)
        }
    }
    
    func getAllMediaModel() -> [MediaModel] {
        return Array(realm.objects(MediaModel.self))
    }
    
    func deletMediaModel(dataMediaModel: MediaModel){
        try! realm.write{
            realm.delete(dataMediaModel)
        }
    }
    
    func getMediaData(key:String) ->  MediaModel  {
        let taskToUpdate = realm.objects(MediaModel.self).filter("chatID = '\(key)'").first!
        return taskToUpdate
    }
    
    func imgeDownloadDone(url:String) {
        let realm = try! Realm()
        let taskToUpdate = realm.objects(MediaModel.self).filter("mediaURL = '\(url)'").first!
        try! realm.write {
            taskToUpdate.isDownloaded = "1"
        }
    }
    
    func UpdateToBase64Key(key:String,Base64Key: String,localUrl: String){
        let realm = try! Realm()
        let taskToUpdate = realm.objects(MediaModel.self).filter("chatID = '\(key)'").first!
        try! realm.write {
            taskToUpdate.isVedioImage64Encoding = Base64Key
            taskToUpdate.localPath = localUrl
        }
    }
    
    
}
